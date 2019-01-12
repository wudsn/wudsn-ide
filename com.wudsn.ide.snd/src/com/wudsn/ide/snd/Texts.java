/**
 * Copyright (C) 2009 - 2019 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

package com.wudsn.ide.snd;

import org.eclipse.osgi.util.NLS;

import com.wudsn.ide.snd.editor.SoundEditor;

/**
 * Class which holds the localized text constants.
 * 
 * @author Peter Dell
 */
public final class Texts extends NLS {

    /**
     * Sound editor
     */
    public static String SOUND_EDITOR_AUTHOR_LABEL;
    public static String SOUND_EDITOR_CHANNELS_LABEL;
    public static String SOUND_EDITOR_CHANNELS_MONO;
    public static String SOUND_EDITOR_CHANNELS_STEREO;
    public static String SOUND_EDITOR_DATE_LABEL;
    public static String SOUND_EDITOR_DEFAULT;
    public static String SOUND_EDITOR_DEFAULT_SONG_LABEL;
    public static String SOUND_EDITOR_DURATION_LABEL;
    public static String SOUND_EDITOR_DURATION_PATTERN;
    public static String SOUND_EDITOR_FORMAT_LABEL;
    public static String SOUND_EDITOR_FORMAT_PATTERN;
    public static String SOUND_EDITOR_FREQUENCY_LABEL;
    public static String SOUND_EDITOR_FREQUENCY_HERTZ_PATTERN;
    public static String SOUND_EDITOR_FREQUENCY_PATTERN;
    public static String SOUND_EDITOR_INIT_ADDRESS_LABEL;
    public static String SOUND_EDITOR_INIT_ADDRESS_FULLTIME;
    public static String SOUND_EDITOR_LOOP_LABEL;
    public static String SOUND_EDITOR_LOOP_NO;
    public static String SOUND_EDITOR_LOOP_YES;
    public static String SOUND_EDITOR_NORM_NTSC;
    public static String SOUND_EDITOR_NORM_PAL;
    public static String SOUND_EDITOR_PAUSED;
    public static String SOUND_EDITOR_PAUSE_BUTTON_TOOLTIP;
    public static String SOUND_EDITOR_PLAYER_ADDRESS_LABEL;
    public static String SOUND_EDITOR_MUSIC_ADDRESS_LABEL;
    public static String SOUND_EDITOR_PLAY_BUTTON_TOOLTIP;
    public static String SOUND_EDITOR_PLAYING_TIME_LABEL;
    public static String SOUND_EDITOR_PLAYYING_POSITION_LABEL;
    public static String SOUND_EDITOR_EXPORT_BUTTON_TOOLTIP;
    public static String SOUND_EDITOR_SONGS_LABEL;
    public static String SOUND_EDITOR_SONG_ID_LABEL;
    public static String SOUND_EDITOR_STOPPED;
    public static String SOUND_EDITOR_STOP_BUTTON_TOOLTIP;
    public static String SOUND_EDITOR_TITLE_LABEL;
    public static String SOUND_EDITOR_UNKNOWN;
    public static String SOUND_EDITOR_VOLUME_LABEL;

    /**
     * Messages for {@link SoundEditor}.
     */
    public static String MESSAGE_E500;
    public static String MESSAGE_E501;
    public static String MESSAGE_E502;
    public static String MESSAGE_E503;
    public static String MESSAGE_E504;
    public static String MESSAGE_I505;
    public static String MESSAGE_E506;
    public static String MESSAGE_I507;
    public static String MESSAGE_I508;
    public static String MESSAGE_E509;

    /**
     * Initializes the constants.
     */
    static {
	NLS.initializeMessages(Texts.class.getName(), Texts.class);
    }
}
