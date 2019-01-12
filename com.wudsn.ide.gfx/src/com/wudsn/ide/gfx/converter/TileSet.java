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

import org.eclipse.swt.graphics.ImageData;

/**
 * An image data divided into a rectangle of tiles.
 * 
 * @author Peter Dell
 * 
 */
public final class TileSet {

    private ImageData imageData;
    private int pixelsPerColumn;
    private int pixelsPerRow;

    private int columns;
    private int rows;
    private int paletteSize;

    private Tile[][] tiles;

    /**
     * Creates a new tile set.
     * 
     * @param imageData
     *            The source image data, not <code>null</code>.
     * @param pixelsPerColumn
     *            The number of pixels per column, a positive integer.
     * @param pixelsPerRow
     *            The number of pixels per row, a positive integer.
     */
    public TileSet(ImageData imageData, int pixelsPerColumn, int pixelsPerRow) {
	if (imageData == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'imageData' must not be null.");
	}
	if (pixelsPerColumn < 1) {
	    throw new IllegalArgumentException(
		    "Parameter 'pixelsPerColumn' must be poitive. Specified value is "
			    + pixelsPerColumn + ".");
	}
	if (pixelsPerRow < 1) {
	    throw new IllegalArgumentException(
		    "Parameter 'pixelsPerRow' must be poitive. Specified value is "
			    + pixelsPerRow + ".");
	}

	this.imageData = imageData;
	this.pixelsPerColumn = pixelsPerColumn;
	this.pixelsPerRow = pixelsPerRow;

	// Round-up columns and rows
	columns = (imageData.width + pixelsPerColumn - 1) / pixelsPerColumn;
	rows = (imageData.height + pixelsPerRow - 1) / pixelsPerRow;

	// Create the tiles
	tiles = new Tile[rows][];
	for (int r = 0; r < rows; r++) {
	    tiles[r] = new Tile[columns];
	    for (int c = 0; c < columns; c++) {
		Tile tile = new Tile(this, c, r);
		tiles[r][c] = tile;
	    }
	}
    }

    /**
     * Gets the source image data.
     * 
     * @return The source image data, not <code>null</code>.
     */
    public ImageData getImageData() {
	return imageData;
    }

    /**
     * Gets the number of columns.
     * 
     * @return The number of columns, a positive integer.
     */
    public int getColumns() {
	return columns;
    }

    /**
     * Gets the number of rows.
     * 
     * @return The number of rows, a positive integer.
     */
    public int getRows() {
	return rows;
    }

    /**
     * Gets the number of pixels per column.
     * 
     * @return The number of pixels per column, a positive integer.
     */
    public int getPixelsPerColumn() {
	return pixelsPerColumn;
    }

    /**
     * Gets the number of pixels per row.
     * 
     * @return The number of of pixels per row, a positive integer.
     */
    public int getPixelsPerRow() {
	return pixelsPerRow;
    }

    /**
     * Gets the size of the palette.
     * 
     * @return The size of the palette, a positive integer.
     */
    public int getPaletteSize() {
	return paletteSize;
    }

    /**
     * Gets the tile a a given location.
     * 
     * @param column
     *            The column, a non-negative integer
     * @param row
     *            The row, a non-negative integer
     * @return The tile, not <code>null</code>.
     */
    public Tile getTile(int column, int row) {
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
	return tiles[row][column];
    }

    /**
     * Create an image data instance large enough to hold the tiled source
     * image.
     * 
     * @return The tile image data, not <code>null</code>.
     */
    public ImageData createTiledImageData() {
	int width = columns * (pixelsPerColumn + 1) + 1;
	int height = rows * (pixelsPerRow + 1) + 1;
	ImageData tiledImageData = new ImageData(width, height,
		imageData.depth, imageData.palette);
	return tiledImageData;
    }

    /**
     * Draws bounding rectangles around the tiles of the target image data.
     * 
     * @param targetImageData
     *            The target image data, not <code>null</code>.
     * @param gridColor
     *            The pixel color for coloring the tile grid.
     * @param inverseConflictColor
     *            The pixel color for coloring conflict tiles in the tile grid.
     */
    public void drawTileBoundaries(ImageData targetImageData,
	    Integer gridColor, Integer inverseConflictColor) {
	if (targetImageData == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'targetImageData' must not be null.");
	}
	if (gridColor == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'gridColor' must not be null.");
	}
	if (inverseConflictColor == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'inverseConflictColor' must not be null.");
	}
	for (int r = 0; r < rows + 1; r++) {
	    int ty = r * (pixelsPerRow + 1);
	    for (int x = 0; x < targetImageData.width; x++) {
		targetImageData.setPixel(x, ty, gridColor.intValue());
	    }
	}
	for (int c = 0; c < columns + 1; c++) {
	    int tx = c * (pixelsPerColumn + 1);
	    for (int y = 0; y < targetImageData.height; y++) {
		targetImageData.setPixel(tx, y, gridColor.intValue());
	    }
	}

	for (int r = 0; r < rows; r++) {
	    int ty = r * (pixelsPerRow + 1);
	    for (int c = 0; c < columns; c++) {
		int tx = c * (pixelsPerColumn + 1);

		Tile tile = getTile(c, r);
		if (tile.isInverseConflict()) {
		    for (int x = 0; x < pixelsPerColumn + 1; x++) {
			targetImageData.setPixel(tx + x, ty,
				inverseConflictColor.intValue());
			targetImageData.setPixel(tx + x, ty + pixelsPerRow + 1,
				inverseConflictColor.intValue());
		    }
		    for (int y = 0; y < pixelsPerRow + 1; y++) {
			targetImageData.setPixel(tx, ty + y,
				inverseConflictColor.intValue());
			targetImageData.setPixel(tx + pixelsPerColumn + 1, ty
				+ y, inverseConflictColor.intValue());

		    }
		}
	    }
	}

    }
}
