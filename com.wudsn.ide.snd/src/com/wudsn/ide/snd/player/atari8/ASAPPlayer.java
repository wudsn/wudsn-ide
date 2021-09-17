/**
 * Copyright (C) 2009 - 2021 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
 *
 * This file is part of WUDSN IDE.
 * 
 * WUDSN IDE is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 * 
 * WUDSN IDE is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with WUDSN IDE.  If not, see <http://www.gnu.org/licenses/>.
 */
package com.wudsn.ide.snd.player.atari8;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.DataLine;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.SourceDataLine;

import net.sf.asap.ASAP;
import net.sf.asap.ASAPInfo;
import net.sf.asap.ASAPMusicRoutine;
import net.sf.asap.ASAPWriter;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;

import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.snd.SoundPlugin;
import com.wudsn.ide.snd.Texts;
import com.wudsn.ide.snd.player.Clock;
import com.wudsn.ide.snd.player.FileType;
import com.wudsn.ide.snd.player.LoopMode;
import com.wudsn.ide.snd.player.SoundPlayer;
import com.wudsn.ide.snd.player.SoundPlayerListener;

/**
 * Synchronized wrapper for the ASAP player. Visit http://asap.sourceforge.net
 * for the underlying player by Piotr Fusik (0xF). See
 * http://asap.sourceforge.net/sap-format.html for the SAP format specification.
 * Visit http://asma.atari.org for the biggest collection of SAP tunes.
 * 
 * @author Peter Dell
 * @since 1.6.1
 */
public final class ASAPPlayer extends SoundPlayer {

	private final ASAP asap;

	private static final int MAX_EXPORT_SIZE = 655636;

	// Module binary is not in the base class because other players only work on
	// the input stream and do not expose it at all. Is it also not purely local
	// to load() because it is also used during export.
	private byte[] module;
	private int moduleLen;

	/**
	 * Creation is public.
	 */
	public ASAPPlayer() {
		asap = new ASAP();
		module = null;
		moduleLen = 0;
	}

	/**
	 * Loads a file from an input stream.
	 * 
	 * @param fileName    The file name including the file extensions, may be empty,
	 *                    not <code>null</code>.
	 * @param inputStream The input stream to read the file, not <code>null</code>.
	 * @throws CoreException If and error occurs
	 */
	@Override
	public synchronized void load(String fileName, InputStream inputStream) throws CoreException {
		if (fileName == null) {
			throw new IllegalArgumentException("Parameter 'fileName' must not be null.");
		}
		if (inputStream == null) {
			throw new IllegalArgumentException("Parameter 'inputStream' must not be null.");
		}

		clear();

		// Read binary from the input stream.
		try {
			module = new byte[ASAPInfo.MAX_MODULE_LENGTH];
			moduleLen = readAndClose(inputStream, module);

		} catch (IOException ex) {
			// ERROR: Cannot read sound file {0}. {1}
			IStatus status = new Status(IStatus.ERROR, SoundPlugin.ID,
					TextUtility.format(Texts.MESSAGE_E501, fileName, ex.getMessage()));
			throw new CoreException(status);
		} finally {
			try {
				inputStream.close();
			} catch (IOException ex) {
				// ERROR: Cannot read sound file {0}. {1}
				IStatus status = new Status(IStatus.ERROR, SoundPlugin.ID,
						TextUtility.format(Texts.MESSAGE_E501, fileName, ex.getMessage()));
				throw new CoreException(status);
			}
		}

		// Parse binary.
		ASAPMusicRoutine asapMusicRoutine;
		try {
			asap.load(fileName, module, moduleLen);
			asapMusicRoutine = new ASAPMusicRoutine(fileName, module, moduleLen);
		} catch (Exception ex) {
			// ERROR: Cannot load sound file '{0}'. {1}
			IStatus status = new Status(IStatus.ERROR, SoundPlugin.ID,
					TextUtility.format(Texts.MESSAGE_E502, fileName, ex.getMessage()));
			throw new CoreException(status);
		}

		// Create info.
		info.valid = true;

		ASAPInfo asapInfo = asap.getInfo();
		info.title = asapInfo.getTitleOrFilename();
		info.author = asapInfo.getAuthor();

		// Determine the original file type in the container.
		// Only if it cannot be determined, the file extension is used.
		info.moduleFileType = asap.getInfo().getOriginalModuleExt(module, moduleLen);
		if (info.moduleFileType == null) {
			info.moduleFileType = fileName.substring(fileName.lastIndexOf('.') + 1);
		}
		info.moduleFileType = info.moduleFileType.toUpperCase();

		// Translate the file type to a human readable text.
		try {
			info.moduleTypeDescription = ASAPInfo.getExtDescription(info.moduleFileType);
		} catch (Exception unknownExtensionException) {
			info.moduleTypeDescription = unknownExtensionException.getMessage();
		}

		final List<FileType> supportedExportFileTypes = new ArrayList<FileType>();
		String[] extensions = new String[ASAPWriter.MAX_SAVE_EXTS]; //
		int numberOfExtensions = ASAPWriter.getSaveExts(extensions, asap.getInfo(), module, module.length);
		for (int i = 0; i < numberOfExtensions; i++) {
			String extension = "." + extensions[i];
			FileType fileType = FileType.getInstanceByExtension(extension);
			if (fileType == null) {
				throw new RuntimeException("Unknown file extension '" + extension + "'.");
			}
			supportedExportFileTypes.add(fileType);

		}
		info.setSupportedExportFileTypes(supportedExportFileTypes);
		info.channels = asapInfo.getChannels();
		info.songs = asapInfo.getSongs();
		info.defaultSong = asapInfo.getDefaultSong();
		info.durations = new int[info.songs];
		info.loops = new LoopMode[info.songs];
		for (int i = 0; i < info.songs; i++) {
			info.durations[i] = asapInfo.getDuration(i);
			info.loops[i] = asapInfo.getLoop(i) ? LoopMode.YES : LoopMode.NO;
		}
		info.playerClock = asapInfo.isNtsc() ? Clock.NTSC : Clock.PAL;
		int scanlines = asapInfo.getPlayerRateScanlines();
		info.playerRateScanlines = scanlines;
		int cycles = scanlines * 114;
		double clock = (asapInfo.isNtsc() ? 1789772.5d : 1773447.0d);
		info.playerRateHertz = clock / cycles;

		info.initAddress = asapMusicRoutine.getInitAddress();
		info.initFulltime = asapMusicRoutine.isFulltime();
		info.playerAddress = asapMusicRoutine.getPlayerAddress();
		info.musicAddress = asapInfo.getMusicAddress();

		setLoaded(true);

	}

	@Override
	public byte[] getExportFileContent(FileType fileType, int musicAddress) throws Exception {
		if (fileType == null) {
			throw new IllegalArgumentException("Parameter 'fileType' must not be null.");
		}
		if (!isLoaded()) {
			throw new IllegalStateException("No module loaded");
		}

		// The file name must have a least one character before the dot.
		String asapFile = "DUMMY" + fileType.getExtension().toUpperCase();
		ASAPInfo asapInfo = asap.getInfo();
		int oldMusicAddress = asapInfo.getMusicAddress();
		byte[] output = new byte[MAX_EXPORT_SIZE];
		ASAPWriter asapWriter = new ASAPWriter();
		int outputOffset = 0;
		asapWriter.setOutput(output, outputOffset, output.length);
		// Change the music address in case it is changeable.
		if (fileType.isMusicAddressChangeable()) {
			asapInfo.setMusicAddress(musicAddress);
		}
		/**
		 * Writes the given module in a possibly different file format.
		 * 
		 * @param targetFilename Output filename, used to determine the format.
		 * @param info           File information got from the source file with data
		 *                       updated for the output file.
		 * @param module         Contents of the source file.
		 * @param moduleLen      Length of the source file.
		 * @param tag            Display information (xex output only).
		 */

		outputOffset = asapWriter.write(asapFile, asapInfo, module, moduleLen, false);
		// Change the music address back in case it was changed.
		if (fileType.isMusicAddressChangeable()) {
			asapInfo.setMusicAddress(oldMusicAddress);
		}
		byte[] result = new byte[outputOffset];
		System.arraycopy(output, 0, result, 0, outputOffset);
		return result;
	}

	@Override
	public synchronized void play(int song, SoundPlayerListener listener) throws CoreException {

		stop();

		ASAPInfo info;
		try {
			info = asap.getInfo();
			asap.playSong(song, info.getLoop(song) ? -1 : info.getDuration(song));
		} catch (Exception ex) {
			// ERROR: Cannot play song number {0}. {1}
			IStatus status = new Status(IStatus.ERROR, SoundPlugin.ID, TextUtility.format(Texts.MESSAGE_E503,
					NumberUtility.getLongValueDecimalString(song), ex.getMessage()));
			throw new CoreException(status);
		}

		AudioFormat format = new AudioFormat(ASAP.SAMPLE_RATE, 16, info.getChannels(), true, false);
		SourceDataLine line;
		int bufferSize = 8192;
		try {
			line = (SourceDataLine) AudioSystem.getLine(new DataLine.Info(SourceDataLine.class, format));
			line.open(format, bufferSize);
		} catch (LineUnavailableException ex) {
			// ERROR: No free audio line available to play song {0}. {1}
			IStatus status = new Status(IStatus.ERROR, SoundPlugin.ID, TextUtility.format(Texts.MESSAGE_E504,
					NumberUtility.getLongValueDecimalString(song), ex.getMessage()));
			throw new CoreException(status);
		}
		playInNewThread(song, new ASAPSoundGenerator(asap, line), listener);

	}

	@Override
	public synchronized int getPosition() {
		return asap.getPosition();
	}

	@Override
	public boolean isSeekSupported() {
		return true;
	}

	@Override
	public synchronized void seekPosition(int position) {
		try {

			asap.seek(position);
			if (listener != null) {
				listenerUpdatedPosition = position;
				listener.playerUpdated(SoundPlayerListener.POSITION);
			}
		} catch (Exception ex) {
			throw new RuntimeException("Cannot seeek to position " + position, ex);
		}
	}

	@Override
	public synchronized int[] getChannelVolumes() {
		int[] result;

		int channels = asap.getInfo().getChannels() * 4;
		result = new int[channels];
		if (isPlaying()) {
			for (int i = 0; i < channels; i++) {
				result[i] = asap.getPokeyChannelVolume(i) * 16;
			}
		}
		return result;
	}
}
