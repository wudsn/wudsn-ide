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

package com.wudsn.ide.gfx.converter.generic;

import com.wudsn.ide.gfx.converter.Converter;
import com.wudsn.ide.gfx.converter.FilesConverterData;
import net.sf.recoil.RECOIL;

/**
 * Generic converter based on <a href="http://recoil.sourceforge.net">RECOIL</a>
 * by Piotr Fusik, Adrian Matoga et. al.
 * 
 * @author Peter Dell
 */
public class RecoilConverter extends Converter {

    public static final int SOURCE_FILE = 1;

    @Override
    public void convertToImageDataSize(FilesConverterData data) {
	RECOIL recoil = new RECOIL();
	byte[] content = data.getSourceFileBytes(SOURCE_FILE);
	boolean valid = recoil.decode(data.getParameters().getSourceFile(SOURCE_FILE).getPath(), content,
		content.length);
	if (valid) {
	    data.setImageDataHeight(recoil.getHeight());
	    data.setImageDataWidth(recoil.getWidth());

	}
    }

    @Override
    public boolean convertToImageData(FilesConverterData data) {
	RECOIL recoil = new RECOIL();
	byte[] content = data.getSourceFileBytes(SOURCE_FILE);
	boolean valid = recoil.decode(data.getParameters().getSourceFile(SOURCE_FILE).getPath(), content,
		content.length);
	return valid;
    }

}
