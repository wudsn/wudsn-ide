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

package com.wudsn.ide.hex;

import org.eclipse.osgi.util.NLS;

/**
 * Class which holds the localized text constants.
 * 
 * @author Peter Dell
 */
public final class Texts extends NLS {

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

	public static String HEX_EDITOR_IFF_CHUNK;
	public static String HEX_EDITOR_IFF_FORM_CHUNK;
	public static String HEX_EDITOR_IFF_FILE_ERROR;

	public static String HEX_EDITOR_FILE_CONTENT_SIZE_FIELD_LABEL;
	public static String HEX_EDITOR_FILE_CONTENT_SIZE_FIELD_TEXT;
	public static String HEX_EDITOR_FILE_CONTENT_MODE_FIELD_LABEL;
	public static String HEX_EDITOR_CHARACTER_SET_TYPE_FIELD_LABEL;
	public static String HEX_EDITOR_BYTES_PER_ROW_FIELD_LABEL;

	public static String HEX_EDITOR_SAVE_SELECTION_AS_DIALOG_TITLE;

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
