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

package com.wudsn.ide.gfx;

import org.eclipse.osgi.util.NLS;

import com.wudsn.ide.gfx.editor.GraphicsConversionEditor;

/**
 * Class which holds the localized text constants.
 * 
 * @author Peter Dell
 */
public final class Texts extends NLS {

	public static String FILE_SECTION_FIELD_SIZE_LABEL;
	public static String FILE_SECTION_FIELD_SIZE_NO_DATA;
	public static String FILE_SECTION_FIELD_OFFSET_LABEL;

	public static String FIND_DEFAULT_FILE_CONVERTER_BUTTON_TOOLTIP;
	public static String CREATE_CONVERSION_BUTTON_TOOLTIP;

	public static String FILES_CONVERTER_DATA_VIEW_TAB;
	public static String IMAGE_CONVERTER_DATA_VIEW_TAB;

	public static String CONVERTER_PARAMETERS_CONVERTER_ID_LABEL;
	public static String REFRESH_BUTTON_TOOLTIP;
	public static String SAVE_IMAGE_BUTTON_TOOLTIP;
	public static String SAVE_FILES_BUTTON_TOOLTIP;

	public static String CONVERTER_PARAMETERS_BIT_MAP_FILE_PATH_LABEL;
	public static String CONVERTER_PARAMETERS_BIT_MAP_FILE_SECTION_LABEL;
	public static String CONVERTER_PARAMETERS_CHAR_SET_FILE_PATH_LABEL;
	public static String CONVERTER_PARAMETERS_CHAR_SET_FILE_SECTION_LABEL;
	public static String CONVERTER_PARAMETERS_CHAR_MAP_FILE_PATH_LABEL;
	public static String CONVERTER_PARAMETERS_CHAR_MAP_FILE_SECTION_LABEL;
	public static String CONVERTER_PARAMETERS_COLOR_MAP_FILE_PATH_LABEL;
	public static String CONVERTER_PARAMETERS_COLOR_MAP_FILE_SECTION_LABEL;
	public static String CONVERTER_PARAMETERS_IMAGE_FILE_PATH_LABEL;

	// Files to image texts
	public static String CONVERTER_PARAMETERS_COLUMNS_LABEL;
	public static String CONVERTER_PARAMETERS_ROWS_LABEL;

	public static String CONVERTER_PARAMETERS_SPACING_COLOR_LABEL;
	public static String CONVERTER_PARAMETERS_SPACING_WIDTH_LABEL;

	// Image to Files texts
	public static String CONVERTER_PARAMETERS_USE_DEFAULT_SCRIPT_LABEL;
	public static String CONVERTER_PARAMETERS_SCRIPT_LABEL;

	public static String CONVERTER_DATA_IMAGE_DATA_WIDTH_LABEL;
	public static String CONVERTER_DATA_IMAGE_DATA_HEIGHT_LABEL;

	public static String CONVERTER_PARAMETERS_IMAGE_ASPECT_LABEL;

	public static String CREATE_CONVERSION_DIALOG_TITLE;
	public static String CREATE_CONVERSION_DIALOG_MESSAGE;
	public static String SAVE_AS_DIALOG_TITLE;
	public static String SAVE_AS_DIALOG_MESSAGE;

	public static String CONVERTER_CONSOLE_TITLE;

	public static String IMAGE_VIEW_ASPECT_LABEL;

	public static String IMAGE_PALETTE_VIEW_EDIT_COLOR_ACTION_LABEL;
	public static String IMAGE_PALETTE_VIEW_EDIT_COLOR_ACTION_TOOLTIP;
	public static String IMAGE_PALETTE_VIEW_UNUSED_COLORS_ACTION_LABEL;
	public static String IMAGE_PALETTE_VIEW_UNUSED_COLORS_ACTION_TOOLTIP;
	public static String IMAGE_PALETTE_VIEW_INFO_NO_IMAGE;
	public static String IMAGE_PALETTE_VIEW_INFO_INDEXED_PALETTE_IMAGE;
	public static String IMAGE_PALETTE_VIEW_INFO_DIRECT_PALETTE_IMAGE;

	public static String IMAGE_PALETTE_VIEW_COLUMN_INDEX_TEXT;
	public static String IMAGE_PALETTE_VIEW_COLUMN_COLOR_HEX_TEXT;
	public static String IMAGE_PALETTE_VIEW_COLUMN_COLOR_BINARY_TEXT;
	public static String IMAGE_PALETTE_VIEW_COLUMN_RGB_COLOR_TEXT;
	public static String IMAGE_PALETTE_VIEW_COLUMN_COLOR_COUNT_TEXT;
	public static String IMAGE_PALETTE_VIEW_COLUMN_COLOR_COUNT_PERCENT_TEXT;

	/**
	 * Messages for {@link GraphicsConversionEditor}.
	 */
	public static String MESSAGE_S100 = "Source files loaded and converted in {0} ms";
	public static String MESSAGE_E400;

	/**
	 * Initializes the constants.
	 */
	static {
		NLS.initializeMessages(Texts.class.getName(), Texts.class);
	}
}
