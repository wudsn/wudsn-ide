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

import java.util.List;

/**
 * Info class describing the properties of a sound file which can contains a
 * player and multiple songs.
 * 
 * @author Peter Dell
 * @since 1.6.1
 */
public interface SoundInfo {

	public boolean isValid();

	public String getTitle();

	public String getAuthor();

	public String getDate();

	/**
	 * Gets the description of the type of the current module.
	 * 
	 * @return The description of the type, may be empty, not <code>null</code>.
	 */
	public String getModuleTypeDescription();

	/**
	 * Gets the file type (typically the file extension) of the current module.
	 * 
	 * @return The file type , may be empty, not <code>null</code>. The value is in
	 *         upper case letter without a leading dot.
	 */
	public String getModuleFileType();

	/**
	 * Gets the list of supported export file types.
	 * 
	 * @return The modifiable list (copy) of supported export file types, may be
	 *         empty, not <code>null</code>.
	 */
	public List<FileType> getSupportedExportFileTypes();

	/**
	 * Gets the number of channels used by the current module.
	 * 
	 * @return <code>0</code> if undefined, <code>1</code> if mono, <code>2</code>
	 *         if stereo.
	 */
	public int getChannels();

	/**
	 * Gets the number of songs in the current module.
	 * 
	 * @return <code>0</code> if no module is loaded, a positive integer if a module
	 *         is loaded.
	 */
	public int getSongs();

	/**
	 * Gets the default song number.
	 * 
	 * @return The default song number, a non-negative number starting at 0.
	 */
	public int getDefaultSong();

	/**
	 * Gets the duration of a song in milliseconds.
	 * 
	 * @param song The song number, a non-negative number starting at 0.
	 * 
	 * @return The duration of a song in milliseconds, a non-negative integer.
	 */
	public int getDuration(int song);

	/**
	 * Gets the loop mode of a song.
	 * 
	 * @param song The song number, a non-negative number starting at 0.
	 * 
	 * @return The loop mode, not <code>null</code>.
	 */
	public LoopMode getLoopMode(int song);

	public Clock getPlayerClock();

	/**
	 * Gets the player rates in scan lines.
	 * 
	 * @return The player rates in scan lines, non-negative integer.
	 */
	public int getPlayerRateScanLines();

	/**
	 * Gets the player rate in Hertz based on the player clock (PAL/NTSC) and the
	 * player scan line rate.
	 * 
	 * @return The player rate in Hertz, a non-negative double.
	 */
	public double getPlayerRateHertz();

	public int getInitAddress();

	public boolean isInitFulltime();

	public int getPlayerAddress();

	/**
	 * Gets the music address or <code>-1</code> if the module type does not have
	 * one.
	 * 
	 * @return The music address or <code>-1</code> if the module type does not have
	 * one.
	 */
	public int getMusicAddress();

}
