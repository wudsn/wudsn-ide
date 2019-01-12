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

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import com.wudsn.ide.base.common.NumberFactory;

public final class Tile {
    private TileSet tileSet;
    private int column;
    private int row;

    private int xOffset;
    private int yOffset;

    private Map<Integer, Integer> pixelColorCounts;
    private List<Map<Integer, Integer>> linePixelColorCounts;

    private boolean inverseConflict;

    public Tile(TileSet tileSet, int column, int row) {
	if (tileSet == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'tileSet' must not be null.");
	}
	if (column < 0) {
	    throw new IllegalArgumentException(
		    "Parameter 'column' must not be negative. Specified value is "
			    + column + ".");
	}
	if (row < 0) {
	    throw new IllegalArgumentException(
		    "Parameter 'row' must not be negative. Specified value is "
			    + row + ".");
	}
	this.tileSet = tileSet;
	this.column = column;
	this.row = row;

	xOffset = column * tileSet.getPixelsPerColumn();
	yOffset = row * tileSet.getPixelsPerRow();

	pixelColorCounts = new TreeMap<Integer, Integer>();
	linePixelColorCounts = new ArrayList<Map<Integer, Integer>>(tileSet
		.getPixelsPerRow());

	for (int y = 0; y < tileSet.getPixelsPerRow(); y++) {
	    linePixelColorCounts.add(new TreeMap<Integer, Integer>());
	    for (int x = 0; x < tileSet.getPixelsPerColumn(); x++) {
		Integer pixelColor = getPixelColor(x, y);
		increment(pixelColorCounts, pixelColor);
		increment(linePixelColorCounts.get(y), pixelColor);
	    }
	}
    }

    private void increment(Map<Integer, Integer> pixelColorCounts,
	    Integer pixelColorKey) {
	if (pixelColorCounts == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'pixelColorCounts' must not be null.");
	}
	if (pixelColorKey == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'pixelColorKey' must not be null.");
	}
	Integer pixelColorCount = pixelColorCounts.get(pixelColorKey);
	if (pixelColorCount == null) {
	    pixelColorCount = NumberFactory.getInteger(1);
	} else {
	    pixelColorCount = NumberFactory.getInteger(pixelColorCount
		    .intValue() + 1);
	}
	pixelColorCounts.put(pixelColorKey, pixelColorCount);
    }

    public int getColumn() {
	return column;
    }

    public int getRow() {
	return row;
    }

    /**
     * Gets the pixel color of a pixel in the tile.
     * 
     * @param x
     *            The relative x position in the tile, a non-negative integer.
     * @param y
     *            The relative x position in the tile, a non-negative integer.
     * @return The pixel color, not <code>null</code>.
     */
    public Integer getPixelColor(int x, int y) {
	try {
	    return NumberFactory.getInteger(tileSet.getImageData().getPixel(
		    xOffset + x, yOffset + y));
	} catch (IllegalArgumentException ex) {
	    // throw new IllegalArgumentException("Cannot access pixel at "
	    // + xOffset + "+" + x + ", " + yOffset + "+" + y + ".", ex);
	    return NumberFactory.getInteger(0);
	}
    }

    public boolean hasPixelColor(Integer pixelColor) {
	if (pixelColor == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'pixelColor' must not be null.");
	}
	return getPixelColorCount(pixelColor) > 0;
    }

    public int getPixelColorCount(Integer pixelColor) {
	if (pixelColor == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'pixelColor' must not be null.");
	}
	Integer pixelColorCount = pixelColorCounts.get(pixelColor);
	if (pixelColorCount == null) {
	    return 0;
	}
	return pixelColorCount.intValue();

    }

    /**
     * Counts the map of distinct colors used and their count in the tile.
     * 
     * @param ignoredPixelColors
     *            The array of colors to be ignored during counting or
     *            <code>null</code>.
     * @return The map of distinct colors used and their count, not
     *         <code>null</code>.
     */
    public Map<Integer, Integer> getDistinctPixelColorCounts(
	    List<Integer> ignoredPixelColors) {

	if (ignoredPixelColors == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'ignoredPixelColors' must not be null.");
	}
	Map<Integer, Integer> pixelColorCounts;
	pixelColorCounts = new TreeMap<Integer, Integer>();
	for (int y = 0; y < tileSet.getPixelsPerRow(); y++) {
	    for (int x = 0; x < tileSet.getPixelsPerColumn(); x++) {
		Integer pixelColor = getPixelColor(x, y);
		boolean ignore = false;
		if (ignoredPixelColors != null
			&& ignoredPixelColors.contains(pixelColor)) {
		    ignore = true;
		}
		if (!ignore) {
		    increment(pixelColorCounts, pixelColor);
		}
	    }
	}
	return pixelColorCounts;
    }

    public static Integer getMajorColor(Map<Integer, Integer> pixelColorCounts,
	    List<Integer> ignoredPixelColors) {
	if (pixelColorCounts == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'pixelColorCounts' must not be null.");
	}
	if (pixelColorCounts.isEmpty()) {
	    throw new IllegalArgumentException(
		    "Parameter 'pixelColorCounts' must not be empty.");
	}
	Integer majorColor;
	int majorColorCount;
	majorColor = null;
	majorColorCount = -1;
	for (Map.Entry<Integer, Integer> entry : pixelColorCounts.entrySet()) {
	    if (ignoredPixelColors == null
		    || !ignoredPixelColors.contains(entry.getKey())) {
		if (entry.getValue().intValue() > majorColorCount) {
		    majorColor = entry.getKey();
		}
	    }
	}
	return majorColor;
    }

    public int getLinePixelColorCount(int y, int pixelColor) {
	Map<Integer, Integer> pixelColorCounts = linePixelColorCounts.get(y);
	Integer pixelColorCount = pixelColorCounts.get(NumberFactory
		.getInteger(pixelColor));
	if (pixelColorCount == null) {
	    return 0;
	}
	return pixelColorCount.intValue();

    }

    /**
     * Counts the map of distinct colors used and their count in a specific line
     * of the tile.
     * 
     * @param y
     *            The line of the tile, a non-negative integer.
     * @param ignoredPixelColors
     *            The list of colors to be ignored during counting or
     *            <code>null</code>.
     * @return The map of distinct colors used and their count, not
     *         <code>null</code>.
     */
    public Map<Integer, Integer> getDistinctLinePixelColorCounts(int y,
	    List<Integer> ignoredPixelColors) {
	if (y < 0) {
	    throw new IllegalArgumentException(
		    "Parameter 'y' must not be negative, specified value is "
			    + y + ".");
	}
	Map<Integer, Integer> pixelColorCounts;
	pixelColorCounts = new TreeMap<Integer, Integer>();
	for (int x = 0; x < tileSet.getPixelsPerColumn(); x++) {
	    Integer pixelColor = getPixelColor(x, y);
	    boolean ignore = false;
	    if (ignoredPixelColors != null
		    && ignoredPixelColors.contains(pixelColor)) {
		ignore = true;

	    }
	    if (!ignore) {
		increment(pixelColorCounts, pixelColor);
	    }
	}
	return pixelColorCounts;
    }

    public boolean isInverseConflict() {
	return inverseConflict;
    }

    public void setInverseConflict(boolean inverseConflict) {
	this.inverseConflict = inverseConflict;

    }
}