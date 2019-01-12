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

package com.wudsn.ide.gfx.converter;

import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.swt.graphics.ImageData;

/**
 * Base class for {@link FilesConverterData} and {@link ImageConverterData}.
 * 
 * @author Peter Dell
 * 
 */
public abstract class ConverterCommonData {

    protected final ConverterData converterData;

    private int imageDataWidth;
    private int imageDataHeight;
    protected ImageData imageData;
    private ImageColorHistogram imageColorHistogram;

    ConverterCommonData(ConverterData converterData) {
	if (converterData == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'converterData' must not be null.");
	}

	this.converterData = converterData;
	imageData = null;
	imageColorHistogram = new ImageColorHistogram();
    }

    public final IPath getFilePathPrefix() {
	IPath result;
	if (converterData.isValid()) {
	    result = converterData.getFile().getFullPath()
		    .removeLastSegments(1);
	} else {
	    result = new Path("");

	}
	return result;
    }

    public abstract boolean isCreateConversionEnabled();

    public abstract boolean isValid();

    public abstract boolean isRefreshEnabled();

    protected void clear() {
	imageData = null;
	imageColorHistogram.clear();
    }

    public final void setImageDataWidth(int width) {
	this.imageDataWidth = width;
    }

    public final int getImageDataWidth() {
	return imageDataWidth;
    }

    public final void setImageDataHeight(int height) {
	this.imageDataHeight = height;
    }

    public final int getImageDataHeight() {
	return imageDataHeight;
    }

    /**
     * Sets the image data.
     * 
     * @param imageData
     *            The image data, may be <code>null</code>.
     */
    final void setImageData(ImageData imageData) {
	this.imageData = imageData;
	imageColorHistogram = null;
    }

    /**
     * Gets the image data.
     * 
     * @return The image data or <code>null</code>.
     */
    public final ImageData getImageData() {
	return imageData;
    }

    /**
     * Sets the image color histogram.
     * 
     * @param imageColorHistogram
     *            The image color histogram, may be <code>null</code>.
     * 
     * @since 1.6.0
     */
    final void setImageColorHistogram(ImageColorHistogram imageColorHistogram) {
	this.imageColorHistogram = imageColorHistogram;
    }

    /**
     * Gets the image color histogram.
     * 
     * @return The image color histogram, not <code>null</code>.
     */
    public final ImageColorHistogram getImageColorHistogram() {
	return imageColorHistogram;
    }
}
