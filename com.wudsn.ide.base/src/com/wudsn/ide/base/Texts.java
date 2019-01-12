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

package com.wudsn.ide.base;

import org.eclipse.osgi.util.NLS;

import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.editor.hex.HexEditor;

/**
 * Class which holds the localized text constants.
 * 
 * @author Peter Dell
 */
public final class Texts extends NLS {

    /**
     * Common texts.
     */
    public static String DIALOG_TITLE;
    public static String FILE_PATH_FIELD_BROWSE_BUTTON_LABEL;
    public static String FILE_PATH_FIELD_DIALOG_MESSAGE;

    /**
     * Hex editor
     */
    public static String HEX_EDITOR_FILE_SIZE;

    public static String HEX_EDITOR_ATARI_COM_BLOCK_HEADER;
    public static String HEX_EDITOR_ATARI_COM_BLOCK_HEADER_PARAMETERS;
    public static String HEX_EDITOR_ATARI_COM_BLOCK_ERROR;

    public static String HEX_EDITOR_ATARI_DISK_IMAGE_HEADER;
    public static String HEX_EDITOR_ATARI_SECTOR_HEADER;
    public static String HEX_EDITOR_ATARI_SECTOR_HEADER_PARAMETERS;
    public static String HEX_EDITOR_ATARI_SECTOR_ERROR;

    public static String HEX_EDITOR_ATARI_MADS_RELOC_BLOCK_HEADER;
    public static String HEX_EDITOR_ATARI_MADS_UPDATE_RELOC_BLOCK_HEADER;
    public static String HEX_EDITOR_ATARI_MADS_UPDATE_SYMBOLS_BLOCK_HEADER;
    public static String HEX_EDITOR_ATARI_MADS_DEFINE_SYMBOLS_BLOCK_HEADER;
    public static String HEX_EDITOR_ATARI_MADS_DEFINE_SYMBOL_HEADER;
    public static String HEX_EDITOR_ATARI_MADS_BLOCK_ERROR;

    public static String HEX_EDITOR_ATARI_SAP_FILE_HEADER;

    public static String HEX_EDITOR_ATARI_SDX_NON_RELOC_BLOCK_HEADER;
    public static String HEX_EDITOR_ATARI_SDX_NON_RELOC_BLOCK_HEADER_PARAMETERS;
    public static String HEX_EDITOR_ATARI_SDX_RELOC_BLOCK_HEADER;
    public static String HEX_EDITOR_ATARI_SDX_UPDATE_RELOC_BLOCK_HEADER;
    public static String HEX_EDITOR_ATARI_SDX_UPDATE_SYMBOLS_BLOCK_HEADER;
    public static String HEX_EDITOR_ATARI_SDX_DEFINE_SYMBOLS_BLOCK_HEADER;
    public static String HEX_EDITOR_ATARI_SDX_BLOCK_ERROR;

    public static String HEX_EDITOR_C64_PRG_HEADER;
    public static String HEX_EDITOR_C64_PRG_HEADER_PARAMETERS;
    public static String HEX_EDITOR_C64_PRG_ERROR;

    public static String HEX_EDITOR_FILE_CONTENT_SIZE_FIELD_LABEL;
    public static String HEX_EDITOR_FILE_CONTENT_SIZE_FIELD_TEXT;
    public static String HEX_EDITOR_FILE_CONTENT_MODE_FIELD_LABEL;
    public static String HEX_EDITOR_CHARACTER_SET_TYPE_FIELD_LABEL;
    public static String HEX_EDITOR_BYTES_PER_ROW_FIELD_LABEL;

    public static String HEX_EDITOR_SAVE_SELECTION_AS_DIALOG_TITLE;

    /**
     * Messages for {@link FileUtility}.
     */
    public static String MESSAGE_E200;
    public static String MESSAGE_E201;
    public static String MESSAGE_E202;
    public static String MESSAGE_E203;
    public static String MESSAGE_E204;
    public static String MESSAGE_E205;
    public static String MESSAGE_E206;
    public static String MESSAGE_E207;
    public static String MESSAGE_E208;
    public static String MESSAGE_E209;
    public static String MESSAGE_E210;
    public static String MESSAGE_E211;
    public static String MESSAGE_E212;
    public static String MESSAGE_E213;

    /**
     * Message for the {@link HexEditor}
     */
    public static String MESSAGE_E300;
    public static String MESSAGE_E301;
    public static String MESSAGE_I302;
    public static String MESSAGE_I303;

    /**
     * Initializes the constants.
     */
    static {
	NLS.initializeMessages(Texts.class.getName(), Texts.class);
    }
}
