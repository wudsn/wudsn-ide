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
package com.wudsn.ide.snd.player;

import java.io.InputStream;

import org.eclipse.core.runtime.CoreException;

/**
 * Empty player which is used in case the sound file type cannot be handled.
 * 
 * @author Peter Dell
 * @since 1.6.1
 */
public final class EmptyPlayer extends SoundPlayer {

	/**
	 * Creation is public.
	 * 
	 * @param fileName The file name of the file which could not be loaded.
	 */
	public EmptyPlayer(String fileName) {
		if (fileName == null) {
			throw new IllegalArgumentException("Parameter 'fileName' must not be null.");
		}
		info.title = fileName;
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

		stop();

	}

	@Override
	public byte[] getExportFileContent(FileType fileType, int musicAddress) {
		return null;
	}

	@Override
	public synchronized void play(int song, SoundPlayerListener listener) throws CoreException {

		stop();

	}

	@Override
	public synchronized int getPosition() {
		return 0;
	}

	@Override
	public boolean isSeekSupported() {
		return false;
	}

	@Override
	public void seekPosition(int position) {

	}

	@Override
	public synchronized int[] getChannelVolumes() {
		return new int[0];
	}

}
