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

package com.wudsn.ide.gfx.converter.atari8bit;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.eclipse.swt.graphics.ImageData;

import com.wudsn.ide.base.common.NumberFactory;
import com.wudsn.ide.gfx.converter.FilesConverterData;
import com.wudsn.ide.gfx.converter.ImageConverterData;
import com.wudsn.ide.gfx.converter.InverseBlock;
import com.wudsn.ide.gfx.converter.InverseBlockList;
import com.wudsn.ide.gfx.converter.Tile;
import com.wudsn.ide.gfx.converter.TileSet;
import com.wudsn.ide.gfx.converter.c64.C64Utility;
import com.wudsn.ide.gfx.converter.generic.CharMapConverter;
import com.wudsn.ide.gfx.converter.generic.CharMapMultiColorConverter;

public class CharMapGraphics12Converter extends CharMapMultiColorConverter {

	private static final Integer PF1 = NumberFactory.getInteger(1);
	private static final Integer PF2 = NumberFactory.getInteger(2);
	private static final Integer PF3 = NumberFactory.getInteger(3);

	public CharMapGraphics12Converter() {
	}

	@Override
	public void convertToImageDataSize(FilesConverterData data) {
		data.setImageDataWidth(data.getParameters().getColumns() * (8 + data.getParameters().getSpacingWidth()));
		data.setImageDataHeight(data.getParameters().getRows() * (8 + data.getParameters().getSpacingWidth()));
	}

	@Override
	public boolean convertToImageData(FilesConverterData data) {
		if (data == null) {
			throw new IllegalArgumentException("Parameter 'data' must not be null.");
		}
		return false;

	}

	public static void convertToFileData(ImageConverterData data) {
		if (data == null) {
			throw new IllegalArgumentException("Parameter 'data' must not be null.");
		}
		int pixelPerColumn = 4;
		int pixelPerRow = 8;

		TileSet tileSet;
		tileSet = new TileSet(data.getImageData(), pixelPerColumn, pixelPerRow);

		int screenWidth = 48;
		int rowsPerCharset = 3;

		// If the actual image is larger that the screen with, it cannot be
		// processed..
		if (tileSet.getColumns() > screenWidth) {
			data.setTargetImageData(null);
		}

		// If the actual image is smaller that the screen with, it shall be
		// centered.
		int screenOffset = (screenWidth - tileSet.getColumns()) / 2;

		boolean effect = data.getParameters().getConverterId().equals(CharMapGraphics12Converter.class.getName());

		int charSets = (tileSet.getRows() + rowsPerCharset - 1) / rowsPerCharset;
		byte[] screenBuffer = new byte[tileSet.getRows() * screenWidth];
		byte[] charSetBuffer = new byte[1024 * charSets];

		Integer gridColor = C64Utility.PINK;
		Integer inverseConflictColor = C64Utility.YELLOW;

		ImageData targetImageData = tileSet.createTiledImageData();

		int screenCharacter = 0;
		int charSetCount = -1;
		for (int r = 0; r < tileSet.getRows(); r++) {
			if (r % rowsPerCharset == 0) {
				charSetCount++;
				int charSetBufferOffset = charSetCount * 1024;
				for (int i = 0; i < pixelPerRow; i++) {
					charSetBuffer[charSetBufferOffset + i] = (byte) 0x55;
				}
				screenCharacter = 1;

			}

			for (int c = 0; c < tileSet.getColumns(); c++) {

				// Create and analyze tile
				Tile tile = tileSet.getTile(c, r);

				Map<Integer, Integer> pixelMapping;
				List<Integer> ignoredPixelColors;
				InverseBlockList inverseBlockList;
				pixelMapping = new TreeMap<Integer, Integer>();
				ignoredPixelColors = new ArrayList<Integer>();
				inverseBlockList = new InverseBlockList();

				// TODO Make hard coded mapping real parameters
				if (System.getProperty("user.name").equals("d025328")) {
					if (r < 10 || r > 19) {
						getTileMapping1(pixelMapping, ignoredPixelColors, inverseBlockList);
					} else {

						getTileMapping2(pixelMapping, ignoredPixelColors, inverseBlockList);
					}
				}

				InverseBlock inverseBlock;
				inverseBlock = inverseBlockList.getInverseBlock(c, r);

				int inverseCharacter = 0x00;
				Integer inverseColor;
				if (inverseBlock != null) {
					inverseColor = inverseBlock.getInverseColor();

					if (tile.hasPixelColor(inverseColor)) {
						// Collect all mappings which map to PF3.
						List<Integer> pf3colors;
						pf3colors = new ArrayList<Integer>();
						for (Map.Entry<Integer, Integer> entry : pixelMapping.entrySet()) {
							if (entry.getValue().equals(PF3)) {
								pf3colors.add(entry.getKey());
							}
						}

						// Set inverse color to PF3 which becomes PF4 using the
						// inverse
						pixelMapping.put(inverseColor, PF3);

						for (Integer pf3Color : pf3colors) {
							if (tile.hasPixelColor(pf3Color)) {
								tile.setInverseConflict(true);
								break;
							}
						}
						if (!tile.isInverseConflict()) {
							// No conflict
							ignoredPixelColors.add(inverseColor);
							inverseCharacter = 0x80;
						} else {
							if (inverseBlock.isInverseIfConflict()) {
								inverseCharacter = 0x80;
							} else {
								inverseCharacter = 0x00;
							}
						}
					}
				} else {
					inverseColor = null;
				}

				screenBuffer[r * screenWidth + c + screenOffset] = (byte) (screenCharacter + inverseCharacter);
				int charSetBufferOffset = charSetCount * 1024 + 8 * (screenCharacter & 0x7f);
				screenCharacter++;

				// Draw/copy tile.
				Map<Integer, Integer> pixelColorCounts = tile.getDistinctPixelColorCounts(ignoredPixelColors);

				Integer lastRowMajorColor = null;

				for (int r1 = 0; r1 < pixelPerRow; r1++) {
					int my = r * (pixelPerRow + 1) + r1 + 1;

					Map<Integer, Integer> rowPixelColorCounts = tile.getDistinctLinePixelColorCounts(r1,
							ignoredPixelColors);

					int charSetByte = 0;
					for (int c1 = 0; c1 < pixelPerColumn; c1++) {
						int mx = c * (pixelPerColumn + 1) + c1 + 1;

						Integer color = tile.getPixelColor(c1, r1);

						Integer pixelBits = pixelMapping.get(color);

						if (effect) {
							if (pixelColorCounts.size() == 0) {
								color = C64Utility.BLACK;
							} else if (pixelColorCounts.size() == 1) {
								color = Tile.getMajorColor(pixelColorCounts, ignoredPixelColors);
							} else if (rowPixelColorCounts.size() == 0) {
								color = lastRowMajorColor;
							} else if (rowPixelColorCounts.size() == 1) {
								color = Tile.getMajorColor(rowPixelColorCounts, ignoredPixelColors);
								lastRowMajorColor = color;
							}

							if (color == null) {
								color = C64Utility.BLACK;
							}
							if (color == inverseColor) {
								color = inverseConflictColor;
							}
						}

						targetImageData.setPixel(mx, my, color.intValue());
						charSetByte = (charSetByte << 2);
						if (pixelBits != null) {
							charSetByte |= pixelBits.intValue();
						}
					}
					charSetBuffer[charSetBufferOffset + r1] = (byte) charSetByte;
				}
			}

			tileSet.drawTileBoundaries(targetImageData, gridColor, inverseConflictColor);
		}

		data.setTargetFileBytes(CharMapConverter.CHAR_SET_FILE, charSetBuffer);
		data.setTargetFileBytes(CharMapConverter.CHAR_MAP_FILE, screenBuffer);

		data.setTargetImageData(targetImageData);
	}

	private static void getTileMapping2(Map<Integer, Integer> pixelMapping, List<Integer> ignoredPixelColors,
			InverseBlockList inverseBlockList) {
		pixelMapping.put(C64Utility.BLACK, PF1);
		pixelMapping.put(C64Utility.WHITE, PF2);
		pixelMapping.put(C64Utility.RED, PF3);
		pixelMapping.put(C64Utility.LIGHT_GREEN, PF3);

		ignoredPixelColors.add(C64Utility.BLACK);
		ignoredPixelColors.add(C64Utility.WHITE);
		// ignoredPixelColors.add(C64Utility.DARK_GRAY);
		ignoredPixelColors.add(C64Utility.LIGHT_GREEN);

		// Blue floor
		inverseBlockList.add(0, 39, 8, 19, C64Utility.LIGHT_BLUE, true);

		// Brown Ship
		inverseBlockList.add(16, 18, 5, 7, C64Utility.BROWN, true);
		// Blue Planet
		inverseBlockList.add(0, 39, 0, 6, C64Utility.LIGHT_BLUE, true);

		// Cybernoid
		// inverseBlockList.add(0,
		// 39, 8,
		// 19,
		// C64Utility.LIGHT_RED);
		// // Red

		// Yellow Explosion
		inverseBlockList.add(4, 11, 20, 24, C64Utility.BROWN, false);
	}

	private static void getTileMapping1(Map<Integer, Integer> pixelMapping, List<Integer> ignoredPixelColors,
			InverseBlockList inverseBlockList) {
		pixelMapping.put(C64Utility.BLACK, PF1);
		pixelMapping.put(C64Utility.WHITE, PF2);
		pixelMapping.put(C64Utility.DARK_GRAY, PF3);

		ignoredPixelColors.add(C64Utility.BLACK);
		ignoredPixelColors.add(C64Utility.WHITE);
		ignoredPixelColors.add(C64Utility.DARK_GRAY);

		// Brown Ship
		inverseBlockList.add(16, 18, 5, 7, C64Utility.BROWN, true);
		// Blue Planet
		inverseBlockList.add(0, 39, 0, 6, C64Utility.LIGHT_BLUE, true);

		// Cybernoid
		inverseBlockList.add(0, 39, 8, 19, C64Utility.LIGHT_RED, false);

		// Yellow Explosion
		inverseBlockList.add(4, 11, 20, 24, C64Utility.BROWN, true);
	}
}
