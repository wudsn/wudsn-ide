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

import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.gfx.converter.ImageColorHistogram;
import com.wudsn.ide.gfx.model.Aspect;

public interface ImageProvider {

	public void setImageView(ImageView imageView);

	public void setImagePaletteView(ImagePaletteView imagePaletteView);

	public Aspect getAspect();

	public void setAspect(Aspect value);

	public boolean isShrinkToFit();

	public void setShrinkToFit(boolean value);

	public boolean isZoomToFit();

	public void setZoomToFit(boolean value);

	public ImageData getImageData();

	public ImageColorHistogram getImageColorHistogram();

	public boolean isPaletteChangeable();

	public void setPaletteRGBs(RGB[] rgbs);

	public void setPaletteRGB(int pixelColor, RGB rgb);

}
