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

/**
 * Listener interface for periodic changes in the player.
 * 
 * @author Peter Dell
 * @since 1.6.1
 */
public interface SoundPlayerListener {

	public static final int STATE = 0x1;
	public static final int POSITION = 0x2;
	public static final int VOLUME = 0x4;
	public static final int ALL = STATE | POSITION | VOLUME;

	// Number of milliseconds between position update.
	public static final int POSITION_UPDATE_INCREMENT = 1000;

	public void playerUpdated(int flag);
}
