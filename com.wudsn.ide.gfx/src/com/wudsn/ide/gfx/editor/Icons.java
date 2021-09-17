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

package com.wudsn.ide.gfx.editor;

import org.eclipse.swt.graphics.Image;

import com.wudsn.ide.base.common.AbstractIDEPlugin;
import com.wudsn.ide.gfx.GraphicsPlugin;

final class Icons {

	public static final Image FIND_DEFAULT_CONVERTER;
	public static final Image CREATE_CONVERSION;
	public static final Image REFRESH;
	public static final Image SAVE_IMAGE;
	public static final Image SAVE_FILES;

	static {
		AbstractIDEPlugin plugin = GraphicsPlugin.getInstance();
		FIND_DEFAULT_CONVERTER = plugin.getImage("searchm_obj.gif");
		CREATE_CONVERSION = plugin.getImage("graphics-editor-16x16.gif");
		REFRESH = plugin.getImage("refresh.gif");
		SAVE_IMAGE = plugin.getImage("save_edit.gif");
		SAVE_FILES = plugin.getImage("save_edit.gif");
	}
}
