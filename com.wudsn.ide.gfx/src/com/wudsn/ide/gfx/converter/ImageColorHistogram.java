/**
 * Copyright (C) 2009 - 2014 <a href="http://www.wudsn.com" target="_top">Peter Dell</a>
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

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.TreeMap;

import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.base.common.NumberFactory;

/**
 * Image color histogram container. Counts the number of occurrences of a pixel
 * color value in an image data. Pixel color values may be greater than 256 in
 * case of direct palettes.
 * 
 * @author Peter Dell
 */
public final class ImageColorHistogram {

    private PaletteData paletteData;
    private int pixelCount;
    private List<Integer> pixelColors;
    private List<Integer> usedPixelColors;
    private TreeMap<Integer, Integer> pixelColorCounts;

    /**
     * Created by {@link ImageConverterData}.
     */
    ImageColorHistogram() {
	pixelColors = Collections.emptyList();
	usedPixelColors = Collections.emptyList();
	pixelColorCounts = new TreeMap<Integer, Integer>();
    }

    /**
     * Clears the histogram.
     */
    final void clear() {
	paletteData = null;
	pixelCount = 0;
	pixelColors = Collections.emptyList();
	usedPixelColors = Collections.emptyList();
	pixelColorCounts.clear();
    }

    /**
     * Counts the number of occurrences of a pixel value in the image data.
     * 
     * @param imageData
     *            The image data or <code>null</code>.
     */
    final void analyze(ImageData imageData) {

	clear();
	if (imageData != null) {
	    pixelCount = imageData.height * imageData.width;
	    paletteData = imageData.palette;

	    if (paletteData.isDirect) {
		pixelColors = Collections.emptyList();
	    } else {
		RGB[] rgbs = paletteData.getRGBs();
		int size = rgbs.length;
		pixelColors = new ArrayList<Integer>(size);
		for (int i = 0; i < size; i++) {
		    pixelColors.add(NumberFactory.getInteger(i));
		}
		pixelColors = Collections.unmodifiableList(pixelColors);
	    }
	    for (int y = 0; y < imageData.height; y++) {
		for (int x = 0; x < imageData.width; x++) {
		    Integer pixelColor = NumberFactory.getInteger(imageData
			    .getPixel(x, y));
		    Integer pixelColorCount = pixelColorCounts.get(pixelColor);
		    if (pixelColorCount == null) {
			pixelColorCount = NumberFactory.getInteger(1);
		    } else {
			pixelColorCount = NumberFactory
				.getInteger(pixelColorCount.intValue() + 1);
		    }
		    pixelColorCounts.put(pixelColor, pixelColorCount);
		}
	    }
	} else {
	    pixelColors = Collections.emptyList();
	}
	usedPixelColors = Collections.unmodifiableList(new ArrayList<Integer>(
		pixelColorCounts.keySet()));
    }

    public boolean isDirectPalette() {
	if (paletteData == null) {
	    return true;
	}
	return paletteData.isDirect;
    }

    /**
     * Gets the number of bits used for representing pixels.
     * 
     * @return The number of bits used for representing pixels or <code>0</code>
     *         if there is no image.
     */
    public int getPaletteBits() {
	if (paletteData == null) {
	    return 0;
	}
	if (paletteData.isDirect) {
	    return Integer.bitCount(paletteData.redMask)
		    + Integer.bitCount(paletteData.greenMask)
		    + Integer.bitCount(paletteData.blueMask);
	}
	int length = paletteData.getRGBs().length;
	int result = 0;
	while (length != 0) {
	    result++;
	    length = length >>> 1;
	}
	return result;
    }

    /**
     * Gets the total number of pixels in the image data. It corresponds to the
     * sum of count returned by {@link #getPixelColorCount(Integer)}.
     * 
     * @return The total pixel color count.
     */
    public int getPixelCount() {
	return pixelCount;
    }

    /**
     * Gets the list of all pixel colors in the palette if the palette is an
     * indexed palette. If the palette is not indexed, the result is an empty
     * list.
     * 
     * @return The unmodifiable list of pixel colors, sorted by their pixel
     *         value, may be empty, not <code>null</code>.
     */
    public List<Integer> getPalettePixelColors() {
	return pixelColors;
    }

    /**
     * Gets the list of used pixel colors in the image data, sorted by their
     * pixel value. This method work the same way for direct and indexed
     * palettes.
     * 
     * @return The unmodifiable list of pixel colors, sorted by their pixel
     *         value, may be empty, not <code>null</code>.
     */
    public List<Integer> getUsedPixelColors() {
	return usedPixelColors;
    }

    /**
     * Gets the number of occurrences of a pixel color value in the image data.
     * 
     * @param pixelColor
     *            The pixel color, not <code>null</code>.
     * @return The count or <code>0</code> in case the pixel color is not
     *         contained in the image.
     */
    public int getPixelColorCount(Integer pixelColor) {
	if (pixelColor == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'pixelColor' must not be null.");
	}
	Integer count = pixelColorCounts.get(pixelColor);
	if (count == null) {
	    return 0;
	}
	return count.intValue();

    }

    /**
     * Gets the RGB value for a pixel color. This method work the same way for
     * direct and indexed palettes.
     * 
     * @param pixelColor
     *            The pixel color, not <code>null</code>.
     * @return The RGB value for the pixel color, not <code>null</code>.
     */
    public RGB getRGB(Integer pixelColor) {
	if (pixelColor == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'pixelColor' must not be null.");
	}

	RGB rgb;
	if (paletteData != null) {
	    // Indexed palette images may contain pixel values without
	    // corresponding
	    int intValue = pixelColor.intValue();
	    if (paletteData.isDirect) {
		rgb = paletteData.getRGB(intValue);
	    } else {
		// In indexed palette images, the palette may be shorter than
		// the actually used color.
		RGB[] rgbs = paletteData.getRGBs();
		if (intValue < rgbs.length) {
		    rgb = rgbs[intValue];
		    if (rgb == null) {
			throw new IllegalStateException(
				"Palette data has no RGB value at index "
					+ intValue + ".");
		    }
		} else {
		    rgb = new RGB(0, 0, 0);
		}
	    }
	} else {
	    rgb = new RGB(0, 0, 0);
	}
	return rgb;
    }

}
