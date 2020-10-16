/**
 * Copyright (C) 2009 - 2020 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

import java.io.IOException;
import java.io.InputStream;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import org.eclipse.core.runtime.CoreException;

/**
 * Base class for sound player wrappers.
 * 
 * @author Peter Dell
 * @since 1.6.1
 */
public abstract class SoundPlayer {

    /**
     * Implementation class for the {@link SoundInfo} interface. Attribute are
     * publicly writable but can only access via getters in the interface.
     * 
     */
    protected final static class SoundInfoImpl implements SoundInfo {

	public boolean valid;
	public String title;
	public String moduleTypeDescription;
	public String moduleFileType;
	private List<FileType> supportedExportFileTypes;
	public String author;
	public String date;
	public int channels;
	public int songs;
	public int defaultSong;
	public int durations[];
	public LoopMode loops[];
	public Clock playerClock;
	public int playerRateScanlines;
	public double playerRateHertz;
	public int initAddress;
	public boolean initFulltime;
	public int playerAddress;
	public int musicAddress;

	public SoundInfoImpl() {
	    title = "";
	    moduleTypeDescription = "";
	    moduleFileType = "";
	    supportedExportFileTypes = Collections.emptyList();
	    author = "";
	    date = "";
	    songs = 0;
	    defaultSong = -1;
	    durations = new int[0];
	    loops = new LoopMode[0];
	}

	@Override
	public boolean isValid() {
	    return valid;
	}

	@Override
	public String getTitle() {
	    return title;
	}

	@Override
	public String getModuleTypeDescription() {
	    return moduleTypeDescription;
	}

	@Override
	public String getModuleFileType() {
	    return moduleFileType;
	}

	public void setSupportedExportFileTypes(List<FileType> supportedExportFileTypes) {
	    if (supportedExportFileTypes == null) {
		throw new IllegalArgumentException("Parameter 'supportedExportFileTypes' must not be null.");
	    }

	    // Sort instances by description.
	    Collections.sort(supportedExportFileTypes, new Comparator<FileType>() {
		@Override
		public int compare(FileType o1, FileType o2) {
		    return o1.getDescription().compareTo(o2.getDescription());
		}
	    });

	    // Make it unmodifiable.
	    this.supportedExportFileTypes = Collections.unmodifiableList(supportedExportFileTypes);
	}

	@Override
	public List<FileType> getSupportedExportFileTypes() {
	    return supportedExportFileTypes;
	}

	@Override
	public String getAuthor() {
	    return author;
	}

	@Override
	public String getDate() {
	    return date;
	}

	@Override
	public int getChannels() {
	    return channels;
	}

	@Override
	public int getSongs() {
	    return songs;
	}

	@Override
	public int getDefaultSong() {
	    return defaultSong;
	}

	@Override
	public int getDuration(int song) {
	    if (songs > 0) {
		return durations[song];
	    }
	    return 0;
	}

	@Override
	public LoopMode getLoopMode(int song) {
	    if (songs > 0) {
		return loops[song];
	    }
	    return LoopMode.UNKNOWN;
	}

	@Override
	public Clock getPlayerClock() {
	    return playerClock;
	}

	@Override
	public int getInitAddress() {
	    return initAddress;
	}

	@Override
	public boolean isInitFulltime() {
	    return initFulltime;
	}

	@Override
	public int getPlayerAddress() {
	    return playerAddress;
	}

	@Override
	public int getMusicAddress() {
	    return musicAddress;
	}

	@Override
	public int getPlayerRateScanLines() {
	    return playerRateScanlines;
	}

	@Override
	public double getPlayerRateHertz() {
	    return playerRateHertz;
	}
    }

    private final static class SoundGeneratorRunnable implements Runnable {

	private SoundPlayer player;
	private SoundGenerator generator;
	private SoundPlayerListener listener;

	/**
	 * Create a new runnable for the thread in which the sound player
	 * generator is executed.
	 * 
	 * @param player
	 *            The sound player,not <code>null</code>.
	 * @param generator
	 *            The sound generator, not <code>null</code>.
	 * @param listener
	 *            The sound player listener or <code>null</code>.
	 */
	SoundGeneratorRunnable(SoundPlayer player, SoundGenerator generator, SoundPlayerListener listener) {
	    if (player == null) {
		throw new IllegalArgumentException("Parameter 'player' must not be null.");
	    }
	    if (generator == null) {
		throw new IllegalArgumentException("Parameter 'generator' must not be null.");
	    }

	    this.player = player;
	    this.generator = generator;
	    this.listener = listener;
	}

	/**
	 * Implementation of {@link Runnable} which generated the actual sound,
	 * passes it to the source data line and notifies the listener about the
	 * updates.
	 */
	@Override
	public void run() {
	    synchronized (player) {
		player.threadActive = true;
		player.listenerUpdatedPosition = 0;
	    }

	    try {

		do {
		    synchronized (player) {
			generator.generateBuffer();
			while (player.playing && player.paused) {
			    try {
				player.wait(200);
			    } catch (InterruptedException ex) {
				throw new RuntimeException(ex);
			    }
			}
			if (listener != null) {
			    int flags = SoundPlayerListener.VOLUME;

			    if (player.getPosition() - player.listenerUpdatedPosition >= SoundPlayerListener.POSITION_UPDATE_INCREMENT) {
				player.listenerUpdatedPosition = player.getPosition();
				flags |= SoundPlayerListener.POSITION;
			    }
			    listener.playerUpdated(flags);

			}
		    }

		    generator.playBuffer();
		} while (generator.isGenerating() && player.isPlaying());

	    } finally {
		synchronized (player) {
		    player.playing = false;

		    generator.close();

		    if (listener != null) {
			listener.playerUpdated(SoundPlayerListener.ALL);
		    }
		    this.listener = null;
		    player.threadActive = false;
		    player.notifyAll();
		}
	    }

	}
    }

    private boolean loaded;
    protected SoundInfoImpl info;

    boolean playing;
    int playingSong;
    boolean paused;
    protected SoundPlayerListener listener;
    protected int listenerUpdatedPosition;
    boolean threadActive;

    /**
     * Creation is protected.
     */
    protected SoundPlayer() {

	clear();
    }

    /**
     * Determines, if the player has a loaded module.
     * 
     * @return <code>true</code> if the player has loaded a module.
     */
    public synchronized boolean isLoaded() {
	return loaded;
    }

    /**
     * Called by sub-classes in the {@link #load(String, InputStream)}
     * implementation.
     * 
     * @param loaded
     *            <code>true</code> if the song player has loaded a module,
     *            <code>false</code> otherwise.
     */
    protected final void setLoaded(boolean loaded) {
	this.loaded = loaded;
    }

    /**
     * Gets the replay routine binary to playing the tune.
     * 
     * @param fileType
     *            The file type to be returned.
     * @param musicAddress
     *            The music address to be used. Either an address between $0000
     *            and $ffff or <code>-1</code>. The value is only applied, if
     *            the file type supports changing the address at all.
     * 
     * @return The content, a non-empty binary executable or <code>null</code>
     *         if the file type is not supported.
     * 
     * @throws Exception
     *             If conversion to binary format is not possible.
     */
    public abstract byte[] getExportFileContent(FileType fileType, int musicAddress) throws Exception;

    /**
     * Loads a file from an input stream.
     * 
     * @param fileName
     *            The file name including the file extensions, may be empty, not
     *            <code>null</code>.
     * @param inputStream
     *            The input stream to read the file, not <code>null</code>.
     * @throws CoreException
     *             If and error occurs
     */
    public abstract void load(String fileName, InputStream inputStream) throws CoreException;

    /**
     * This method is called by subclasses in the implementation of load(),
     * before the actual loading starts.
     */
    protected final void clear() {
	stop();
	setLoaded(false);
	info = new SoundInfoImpl();
    }

    /**
     * Fill a byte array from an input stream.
     * 
     * @param inputStream
     *            The input stream, not <code>null</code>.
     * @param module
     *            The byte array in which the module shall be loaded. Only te
     *            byte which fit into the array are loaded.
     * @return The actual number of bytes read.
     * @throws IOException
     *             If the reading fails.
     */
    protected final int readAndClose(InputStream inputStream, byte[] module) throws IOException {
	if (inputStream == null) {
	    throw new IllegalArgumentException("Parameter 'inputStream' must not be null.");
	}
	if (module == null) {
	    throw new IllegalArgumentException("Parameter 'module' must not be null.");
	}
	int got = 0;
	int need = module.length;
	try {
	    while (need > 0) {
		int i = inputStream.read(module, got, need);
		if (i <= 0)
		    break;
		got += i;
		need -= i;
	    }
	} finally {
	    inputStream.close();
	}
	return got;

    }

    /**
     * Gets the info for the current module.
     * 
     * @return The info, not <code>null</code>.
     */
    public final SoundInfo getInfo() {
	return info;
    }

    /**
     * Stops current song and starts playing the specified song again from the
     * start. Calls
     * {@link #playInNewThread(int, SoundGenerator, SoundPlayerListener)} to
     * start playing at the end. Implementations must be synchronized.
     * 
     * @param song
     *            The song number, a non-negative integer starting at zero for
     *            the first song in the tune.
     * @param listener
     *            The listener to be notified about status changes or
     *            <code>null</code>.
     * @throws CoreException
     *             In case the song cannot be played.
     */
    public abstract void play(int song, SoundPlayerListener listener) throws CoreException;

    /**
     * Starts a new thread in which the sound player generator is executed.
     * 
     * @param song
     *            The song number, a non-
     * @param generator
     *            The sound player generator, not <code>null</code>.
     * @param listener
     *            The sound player listener or <code>null</code>.
     */
    protected final void playInNewThread(int song, SoundGenerator generator, SoundPlayerListener listener) {
	if (generator == null) {
	    throw new IllegalArgumentException("Parameter 'generator' must not be null.");
	}
	if (!isLoaded()) {
	    throw new IllegalStateException("No song loaded");
	}
	playingSong = song;
	playing = true;
	this.listener = listener;
	if (listener != null) {
	    listener.playerUpdated(SoundPlayerListener.ALL);
	}

	Thread thread = new Thread(new SoundGeneratorRunnable(this, generator, listener));
	thread.setName(getClass() + ":" + getInfo().getTitle());
	thread.start();

    }

    /**
     * Determines, if the current song is playing.
     * 
     * @return <code>true</code> if the current song is playing.
     */
    public synchronized boolean isPlaying() {
	return playing;
    }

    /**
     * Gets the song number of the currently playing song.
     * 
     * @return The song number, a non-negative number starting at 0.
     */
    public synchronized int getPlayingSong() {
	return playingSong;
    }

    /**
     * Gets the maximum position possible in the current song.
     * 
     * @return The position in the current song as number of milliseconds since
     *         the start, a non negative integer.
     */
    public final int getMaximumPosition() {
	return getInfo().getDuration(playingSong);

    }

    /**
     * Gets the current position in the current song.
     * 
     * @return The position in the current song as number of milliseconds since
     *         the start.
     */
    public abstract int getPosition();

    /**
     * Determines if seeking is supported.
     * 
     * @return <code>true</code> if seeking is supported, <code>false</code>
     *         otherwise.
     */
    public abstract boolean isSeekSupported();

    /**
     * Seeks the new position in the current song.
     * 
     * @param position
     *            The position in the current song as number of milliseconds
     *            since the start.
     */
    public abstract void seekPosition(int position);

    /**
     * Stops the playing for the current song and notifies the listener.
     */
    public synchronized void stop() {
	synchronized (this) {
	    playing = false;
	    paused = false;
	    notifyAll();
	}

	synchronized (this) {
	    while (threadActive) {
		try {
		    wait(10);
		} catch (InterruptedException ignore) {
		}
	    }
	}
	if (listener != null) {
	    listener.playerUpdated(SoundPlayerListener.ALL);
	    listener = null;
	}
    }

    /**
     * Toggles the pause status for the current song and notifies the listener.
     */
    public final synchronized void togglePause() {
	paused = !paused;
	if (listener != null) {
	    listener.playerUpdated(SoundPlayerListener.STATE | SoundPlayerListener.VOLUME);
	}
	if (!paused) {
	    notifyAll();
	}
    }

    /**
     * Determines, if the current song is paused.
     * 
     * @return <code>true</code> if the current song is paused.
     */
    public final synchronized boolean isPaused() {
	return paused;
    }

    /**
     * Gets the channel volumes.
     * 
     * @return The array of channel volumes. May be empty, not <code>null</code>
     *         . The minimum volume value is 0. The maximum volume value is 255.
     */
    public abstract int[] getChannelVolumes();

}
