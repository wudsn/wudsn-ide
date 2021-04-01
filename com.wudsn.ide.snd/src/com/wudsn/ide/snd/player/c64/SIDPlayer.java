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

package com.wudsn.ide.snd.player.c64;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import javax.sound.sampled.LineUnavailableException;

import libsidplay.Player;
import libsidplay.common.ISID2Types.Clock;
import libsidplay.common.SIDEmu;
import libsidplay.components.mos656x.Palette;
import libsidplay.sidtune.SidTune;
import libsidplay.sidtune.SidTuneError;
import libsidplay.sidtune.SidTuneInfo;
import libsidutils.SidDatabase;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;

import resid_builder.ReSID;
import resid_builder.ReSIDBuilder;
import resid_builder.resid.ISIDDefs.ChipModel;
import resid_builder.resid.SID;
import resid_builder.resid.Voice;
import sidplay.audio.AudioConfig;
import sidplay.audio.AudioDriver;
import sidplay.audio.JavaSound;
import sidplay.ini.IniConfig;
import sidplay.ini.IniFilterSection;

import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.snd.SoundPlugin;
import com.wudsn.ide.snd.Texts;
import com.wudsn.ide.snd.player.FileType;
import com.wudsn.ide.snd.player.LoopMode;
import com.wudsn.ide.snd.player.SoundGenerator;
import com.wudsn.ide.snd.player.SoundPlayer;
import com.wudsn.ide.snd.player.SoundPlayerListener;

/**
 * Synchronized wrapper for the JSIDPlay2 player. Visit
 * http://jsidplay2.sourceforge.net for the underlying player.
 * 
 * This SID player is based on version 2.5.1 of JSIDPLAY. <br/>
 * Stereo tunes are not supported. They will be support with JSIDPLY 3 and
 * ".sid" files with header type "PSIDv3" <br/>
 * 
 * <p>
 * Issues: <br/>
 * The constructor of "Player" takes an enormous amount of time. It takes > 1-2
 * to > open a song on my powerful machine. It computes the screen colors. This
 * delay you measured is the creation of these huge tables. This has been fixed
 * in the local copy of {@link Palette}<br/>
 * </p>
 * <p>
 * Multi-speed tunes:<br/>
 * On the Commodore 64, there are multi-speed tunes available as well. jsidplay2
 * tries to detect that info and displays it on the status bar. Most tunes are
 * single speed however. The tune file will not tell you that info. jsidplay2
 * just counts calls to the player routine. This address is "sometimes"
 * contained in the SID format. There are basically 2 types of playback. First,
 * using the CIA chip (50/60Hz mode) and using the raster IRQ (speed depends on
 * the NTSC/PAL hardware, where the raster line number varies and the quartz as
 * well). This is accepted as limitation.
 * </p>
 * <p>
 * Durations:<br/>
 * SID tunes themselves do not contain any information on duration or looping of
 * a song. The duration is available separately via the This is the
 * "C64Music/DOCUMENTS/SongLength.txt" file contained in the complete download
 * of the "http://www.hvsc.c64.org/index.html". The ability to load the file
 * content directly from a resource input stream has been fixed in the local
 * copy of {@link SidDatabase}.
 * </p>
 * <p>
 * Seeking:<br/>
 * Seeking a song position by time is currently not support in JSIDPLAY.
 * </p>
 * 
 * @author Peter Dell
 * @since 1.6.1
 */

public final class SIDPlayer extends SoundPlayer {

    private static final Clock DEFAULT_CLOCK = Clock.PAL;
    private static final int VOICES = 3;

    /**
     * Magic value 10000 is the number of events to execute in a sequence. The
     * emulated C64 emulates each clock tick of the ~1MHz Quartz. Each event can
     * be SID or VIC based or any other chip on the hardware which must be
     * clocked to change its state.
     * <ul>
     * <li>
     * You can make it higher to find out that the UI reacts slower on changes
     * (even stop/close calls need longer to work for higher values).</li>
     * 
     * <li>
     * It must be high enough to filled the sound buffer according to the audio
     * frequency (41000 Hz). Otherwise stuttering is audible.</li>
     * </ul>
     */
    private static final int MAGIC_NUMBER_OF_EVENTS = 10000 * 10;

    private static final String HVSC_SONG_LENGTHS = "hvsc/SongLengths.txt";

    private static final SidDatabase sidDatabase;

    /**
     * Internal player.
     */
    private Player player;
    private String moduleFileType;
    private SidTune tune;

    static {
	InputStream result = SIDPlayer.class.getResourceAsStream(HVSC_SONG_LENGTHS);
	if (result == null) {
	    throw new RuntimeException("Canot find resource '" + HVSC_SONG_LENGTHS + "'.");
	}
	sidDatabase = new SidDatabase(result);
    }

    /**
     * Creation is public.
     */
    public SIDPlayer() {
	player = new Player();
	moduleFileType = "";
    }

    @Override
    public void load(String fileName, InputStream inputStream) throws CoreException {

	if (fileName == null) {
	    throw new IllegalArgumentException("Parameter 'fileName' must not be null.");
	}
	if (inputStream == null) {
	    throw new IllegalArgumentException("Parameter 'inputStream' must not be null.");
	}

	clear();
	try {
	    // Load tune.
	    tune = SidTune.load(inputStream);
	    int index = fileName.lastIndexOf('.') + 1;
	    if (index >= 0) {
		moduleFileType = fileName.substring(index).toUpperCase();
	    }
	} catch (IOException ex) {
	    // ERROR: Cannot read sound file {0}. {1}
	    IStatus status = new Status(IStatus.ERROR, SoundPlugin.ID, TextUtility.format(Texts.MESSAGE_E501, fileName,
		    ex.getMessage()));
	    throw new CoreException(status);
	} catch (SidTuneError ex) {
	    // ERROR: Cannot load sound file {0}. {1}
	    IStatus status = new Status(IStatus.ERROR, SoundPlugin.ID, TextUtility.format(Texts.MESSAGE_E502, fileName,
		    ex.getMessage()));
	    throw new CoreException(status);
	} finally {
	    try {
		inputStream.close();
	    } catch (IOException ex) {
		// ERROR: Cannot read sound file {0}. {1}
		IStatus status = new Status(IStatus.ERROR, SoundPlugin.ID, TextUtility.format(Texts.MESSAGE_E501,
			fileName, ex.getMessage()));
		throw new CoreException(status);
	    }
	}

	// Create info.
	info.valid = true;

	SidTuneInfo sidTuneInfo = tune.getInfo();
	if (sidTuneInfo.numberOfInfoStrings >= 3) {
	    info.title = sidTuneInfo.infoString[0];
	    info.author = sidTuneInfo.infoString[1];
	    info.date = sidTuneInfo.infoString[2];
	}
	final StringBuilder ids = new StringBuilder();
	for (final String s : tune.identify()) {
	    if (ids.length() > 0) {
		ids.append(", ");
	    }
	    ids.append(s);
	}
	info.moduleTypeDescription = ids.toString();
	info.moduleFileType = moduleFileType;

	List<FileType> supportedExportFileTypes = new ArrayList<FileType>();
	supportedExportFileTypes.add(FileType.PRG);
	info.setSupportedExportFileTypes(supportedExportFileTypes);

	info.channels = (sidTuneInfo.sidChipBase2 != 0) ? 2 : 1;
	info.songs = sidTuneInfo.songs;
	info.defaultSong = sidTuneInfo.startSong - 1; // SIDPLAY numbering
						      // starts with 1.
	info.durations = new int[info.songs];
	info.loops = new LoopMode[info.songs];
	String md5 = tune.getMD5Digest();
	for (int i = 0; i < info.songs; i++) {
	    // Try to lookup song duration in database.
	    if (md5 != null) {
		info.durations[i] = sidDatabase.length(md5, i + 1) * 1000;
	    }
	    info.loops[i] = LoopMode.UNKNOWN;
	}

	Clock clock = player.getC64().getClock();
	if (clock == null) {
	    clock = DEFAULT_CLOCK;
	}
	switch (clock) {
	case PAL:
	    info.playerClock = com.wudsn.ide.snd.player.Clock.PAL;
	    info.playerRateHertz = clock.getRefresh();
	    info.playerRateScanlines = 312;
	    break;
	case NTSC:
	    info.playerClock = com.wudsn.ide.snd.player.Clock.NTSC;
	    info.playerRateHertz = clock.getRefresh();
	    info.playerRateScanlines = 262;
	    break;
	default:
	    throw new RuntimeException("Unknown clock type '" + clock + "'.");
	}

	info.initAddress = sidTuneInfo.initAddr;
	info.initFulltime = sidTuneInfo.initAddr != 0 && sidTuneInfo.playAddr == 0;
	info.playerAddress = sidTuneInfo.playAddr;
	info.musicAddress = sidTuneInfo.loadAddr;

	setLoaded(true);
    }

    private final static class SIDSoundGenerator extends SoundGenerator {
	private final AudioDriver driver;
	private final Player player;
	private boolean generating;

	public SIDSoundGenerator(AudioDriver driver, Player player) {
	    if (driver == null) {
		throw new IllegalArgumentException("Parameter 'driver' must not be null.");
	    }

	    if (player == null) {
		throw new IllegalArgumentException("Parameter 'player' must not be null.");
	    }
	    this.driver = driver;
	    this.player = player;
	    generating = false;
	}

	@Override
	public void generateBuffer() {
	    generating = true;
	}

	@Override
	public void playBuffer() {
	    try {
		player.play(MAGIC_NUMBER_OF_EVENTS);
	    } catch (InterruptedException ex) {
		generating = false;
	    }

	}

	@Override
	public boolean isGenerating() {
	    return generating;
	}

	@Override
	public void close() {
	    player.setTune(null);
	    try {
		player.reset();
	    } catch (InterruptedException ignore) {
	    }
	    driver.close();
	}
    }

    @Override
    public byte[] getExportFileContent(FileType fileType, int musicAddress) {
	if (fileType == null) {
	    throw new IllegalArgumentException("Parameter 'fileType' must not be null.");
	}
	byte[] result;
	switch (fileType) {
	case PRG:
	    byte[] c64buf = new byte[0x10000];
	    tune.placeProgramInMemory(c64buf);
	    SidTuneInfo sidTuneInfo = tune.getInfo();
	    int start = sidTuneInfo.loadAddr;
	    int length = sidTuneInfo.c64dataLen;
	    result = new byte[2 + length];
	    result[0] = (byte) (start & 0xff);
	    result[1] = (byte) (start >>> 8 & 0xff);
	    System.arraycopy(c64buf, start, result, 2, length);
	    break;

	default:
	    result = null;
	}

	return result;
    }

    @Override
    public synchronized void play(int song, SoundPlayerListener listener) throws CoreException {
	stop();

	// Select song. SIDPLAY numbering starts with 1.
	tune.selectSong(song + 1);

	// Apply the tune to the player
	player.setTune(tune);

	// The following code is taken from sidplay.Test#playTune(String) with
	// some parts for stereo handling taken from
	// sidplay.ConsolePlayer#open().

	// Read filter settings and create filter
	final IniConfig iniCfg = new IniConfig();

	// Customize player configuration
	player.setClock(DEFAULT_CLOCK);

	// Get sound driver and apply to the player
	final AudioDriver driver = new JavaSound();
	final AudioConfig config = iniCfg.audio().toAudioConfig(getInfo().getChannels());
	try {
	    driver.open(config);

	    // Setup the SID emulation (not part of the player)
	    final ReSIDBuilder rs = new ReSIDBuilder(config, player.getC64().getClock().getCpuFrequency());
	    rs.setOutput(driver);

	    // Create SID chip of desired model (mono tunes need exactly one)
	    final ReSID sid = createSID(rs, iniCfg);

	    // Apply mono SID chip to the C64, then reset
	    player.getC64().setSID(0, sid);

	    // The following is taken from sidplay.ConsolePlayer#open() to
	    // handle stereo..
	    SidTuneInfo tuneInfo = tune.getInfo();
	    int secondAddress = 0;

	    if (tuneInfo != null) {
		if (tuneInfo.sidChipBase2 != 0) {
		    secondAddress = tuneInfo.sidChipBase2;
		}
	    }

	    if (secondAddress != 0) {
		// Create 2nd SID.
		player.getC64().setSID(1, createSID(rs, iniCfg));

		// Set correct SID address.
		if (secondAddress != 0xd400) {
		    player.getC64().setSecondSIDAddress(secondAddress);
		} else {

		    /* Stereo SID at 0xd400 hack */

		    final SIDEmu s1 = player.getC64().getSID(0);
		    final SIDEmu s2 = player.getC64().getSID(1);

		    // Register a merged SIDEmu that writes both results into
		    // one stream.
		    player.getC64().setSID(0, new SIDEmu(player.getC64().getEventScheduler()) {
			@Override
			public void reset(byte volume) {
			    s1.reset(volume);
			}

			@Override
			public byte read(int addr) {
			    return s1.read(addr);
			}

			@Override
			public void write(int addr, byte data) {
			    s1.write(addr, data);
			    s2.write(addr, data);
			}

			@Override
			public byte readInternalRegister(int addr) {
			    return s1.readInternalRegister(addr);
			}

			@Override
			public void clock() {
			    s1.clock();
			}

			@Override
			public void setEnabled(int num, boolean mute) {
			    s1.setEnabled(num, mute);
			}

			@Override
			public void setFilter(boolean enable) {
			    s1.setFilter(enable);
			}

			@Override
			public ChipModel getChipModel() {
			    return s1.getChipModel();
			}
		    });
		}
	    }

	    player.reset();
	} catch (LineUnavailableException ex) {
	    driver.close();
	    // ERROR: No free audio line available to play song {0}. {1}
	    IStatus status = new Status(IStatus.ERROR, SoundPlugin.ID, TextUtility.format(Texts.MESSAGE_E501,
		    NumberUtility.getLongValueDecimalString(song), ex.getMessage()));
	    throw new CoreException(status);

	} catch (Exception ex) {
	    // ERROR: Cannot play song number {0}. {1}
	    IStatus status = new Status(IStatus.ERROR, SoundPlugin.ID, TextUtility.format(Texts.MESSAGE_E503,
		    NumberUtility.getLongValueDecimalString(song), ex.getMessage()));
	    throw new CoreException(status);
	}

	playInNewThread(song, new SIDSoundGenerator(driver, player), listener);

    }

    private ReSID createSID(ReSIDBuilder rs, IniConfig iniCfg) {
	if (rs == null) {
	    throw new IllegalArgumentException("Parameter 'rs' must not be null.");
	}
	if (iniCfg == null) {
	    throw new IllegalArgumentException("Parameter 'iniCfg' must not be null.");
	}
	final IniFilterSection filter6581 = iniCfg.filter(ChipModel.MOS6581);
	final IniFilterSection filter8580 = iniCfg.filter(ChipModel.MOS8580);

	ReSID sid = (ReSID) rs.lock(player.getC64().getEventScheduler(), ChipModel.MOS6581);
	// Enable/apply filter to the SID emulation
	sid.setFilter(true);
	sid.filter(filter6581, filter8580);
	sid.sampling(player.getC64().getClock().getCpuFrequency(), iniCfg.audio().getFrequency(), iniCfg.audio()
		.getSampling());
	return sid;
    }

    @Override
    public synchronized int getPosition() {
	return player.time() * 1000;
    }

    @Override
    public boolean isSeekSupported() {
	return false;
    }

    @Override
    public void seekPosition(int position) {
	// Not yet supported.
    }

    @Override
    public synchronized int[] getChannelVolumes() {
	int[] result;

	// From SID.output()
	// externalFilter.clock(filter.clock(voice[0].output(voice[2].wave),
	// voice[1].output(voice[0].wave), voice[2].output(voice[1].wave)));

	final int channels = getInfo().getChannels();
	result = new int[channels * VOICES];
	for (int channel = 0; channel < channels; channel++) {
	    SIDEmu sidEmu = player.getC64().getSID(channel);
	    if (sidEmu != null && sidEmu instanceof ReSID) {
		SID sid = ((ReSID) sidEmu).sid();
		Voice[] voices = sid.voice;

		for (int voice = 0; voice < VOICES; voice++) {
		    int sampleValue;
		    switch (voice) {
		    case 0:
			sampleValue = voices[0].output(voices[2].wave);
			break;
		    case 1:
			sampleValue = voices[1].output(voices[0].wave);
			break;
		    case 2:
			sampleValue = voices[2].output(voices[1].wave);
			break;
		    default:
			throw new RuntimeException("Only 3 voices supported.");
		    }

		    sampleValue = sampleValue / 4096;
		    if (sampleValue < 0) {
			sampleValue = 0;
		    } else if (sampleValue > 255) {
			sampleValue = 255;
		    }
		    result[channel * VOICES + voice] = sampleValue;
		}
	    }
	}
	return result;
    }
}
