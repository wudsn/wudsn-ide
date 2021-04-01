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
package com.wudsn.ide.gfx.converter;

import java.util.Iterator;
import java.util.List;

import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.gfx.GraphicsPlugin;
import com.wudsn.ide.gfx.converter.atari8bit.LinearBitMapGraphics8Converter;
import com.wudsn.ide.gfx.model.ConverterDirection;

/**
 * This class is based on the excellent open source
 * "First Atari Image Library (FAIL)". Thanks to the creators to FAIL: Piotr
 * Fusik, Adrian Matoga and Pawel Szewczyk for their support. You can find FAIL
 * on sourceforge "http://fail.sourceforge.net".
 * 
 * @author Peter Dell
 * 
 */

public final class FilesConverterDataLogic {

    /**
     * Helper class to detect the support binary file formats by their
     * extension. The extension have to be defined with lower case characters.
     * 
     * @author Peter Dell
     */
    public static final class FileExtensions {

	// C64 font with 2 bytes load address
	public static final String _64c = "64c";

	// 80x192, 256 colors, interlaced
	// @since FAIL 1.0.0
	public static final String AP3 = "ap3";

	// Any Point, Any Color; 80x96, 256 colors, interlaced
	// @since FAIL 1.0.0
	public static final String APC = "apc";

	// 8x8 charset, mono or multicolor
	// @since FAIL 1.0.0
	public static final String CHR = "chr";

	// Champions' Interlace; 160x192, compressed
	// @since FAIL 1.0.0
	public static final String CCI = "cci";

	// Champions' Interlace; 160x192
	// @since FAIL 1.0.0
	public static final String CIN = "cin";

	// Trzmiel; 320x192, mono, compressed
	// @since FAIL 1.0.0
	public static final String CPR = "cpr";

	// Standard 8x8 font, mono
	// @since FAIL 1.0.0
	public static final String FNT = "fnt";

	// Gephard Hires Graphics; up to 320x200, mono
	// @since FAIL 1.0.1
	public static final String GHG = "ghg";

	// Standard 320x192, mono
	// @since FAIL 1.0.0
	public static final String GR8 = "gr8";

	// Standard 80x192, grayscale
	// @since FAIL 1.0.0
	public static final String GR9 = "gr9";

	// Hard Interlace Picture; 160x200, grayscale
	// @since FAIL 1.0.0
	public static final String HIP = "hip";

	// Hires 256x239, 3 colors, interlaced
	// @since FAIL 1.0.0
	public static final String HR = "hr";

	// Hires 320x200, 5 colors, interlaced
	// @since FAIL 1.0.1
	public static final String HR2 = "hr2";

	// APAC 80x192, 256 colors interlaced
	// @since FAIL 1.0.0
	public static final String ILC = "ilc";

	// Interlace Picture 160x200, 7 colors, interlaced
	// @since FAIL 1.0.0
	public static final String INP = "inp";

	// INT95a, up to 160x239, 16 colors, interlaced
	// @since FAIL 1.0.0
	public static final String INT = "int";

	// McPainter; 160x200, 16 colors, interlaced
	// @since FAIL 1.0.1
	public static final String MCP = "mcp";

	// Micropainter 160x192, 4 colors
	// @since FAIL 1.0.0
	public static final String MIC = "mic";

	// Koala MicroIllustrator; 160x192, 4 colors, compressed
	// @since FAIL 1.0.0
	public static final String PIC = "pic";

	// Plama 256; 80x96, 256 colors
	// @since FAIL 1.0.0
	public static final String PLM = "plm";

	// Rocky Interlace Picture; up to 160x239
	// @since FAIL 1.0.0
	public static final String RIP = "rip";

	// C64 sprites
	// Can be mono or multi color.
	public static final String SPR = "spr";

	// 16x16 font, mono
	// @since FAIL 1.0.0
	public static final String SXS = "sxs";

	// Taquart Interlace Picture; up to 160x119
	// @since FAIL 1.0.0
	public static final String TIP = "tip";

	// TODO Fail 1.1.0
	// Fixed decoding of ILC, AP3, RIP, PIC, CPR, HIP and CIN.
	// Added support for MCH, IGE, 256, AP2, JGP, DGP, ESC, PZM, IST and
	// RAW.
	// MCH IGE 256 AP2 JGP DGP ESC PZM IST RAW
	// 256:: 80x96, 256 colors.
	// AP2:: 80x96, 256 colors.
	//
	// DGP:: "DigiPaint", 80x192, 256 colors, interlaced.
	// ESC:: "EscalPaint", 80x192, 256 colors, interlaced.
	// IGE:: "Interlace Graphics Editor", 128x96, 16 colors, interlaced.
	//
	// IST:: "Interlace Studio", 160x200, interlaced.
	// JGP:: "Jet Graphics Planner", 8x16 tiles, 4 colors.
	// MCH:: Up to 192x240, 128 colors.
	// PZM:: "EscalPaint", 80x192, 256 colors, interlaced.
	// RAW:: "XL-Paint MAX", 160x192, 16 colors, interlaced.

	// fail.h: #define FAIL_WIDTH_MAX 320 => 384, used in RIP
	//
	// /* Limits. */
	// #define FAIL_IMAGE_MAX 30000
	// #define FAIL_WIDTH_MAX 384
	// #define FAIL_HEIGHT_MAX 240
	// #define FAIL_PALETTE_MAX 768
	// #define FAIL_PIXELS_MAX (FAIL_WIDTH_MAX * FAIL_HEIGHT_MAX * 3)
    }

    FilesConverterDataLogic() {

    }

    public void applyDefaults(FilesConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	FilesConverterParameters parameters;
	Converter converter;

	parameters = data.getParameters();
	converter = data.getConverter();

	// Take defaults from the definition.
	if (converter != null) {
	    int targetImagePaletteSize = converter.getDefinition().getTargetImagePaletteSize();
	    RGB[] rgbs;
	    if (targetImagePaletteSize > 0) {
		rgbs = new RGB[targetImagePaletteSize];
		for (int i = 0; i < targetImagePaletteSize; i++) {
		    int brightness = (255 * i) / (targetImagePaletteSize - 1);
		    RGB rgb = new RGB(brightness, brightness, brightness);
		    rgbs[i] = rgb;
		}
	    } else {
		rgbs = new RGB[0];
	    }
	    parameters.setPaletteRGBs(rgbs);
	    parameters.setDisplayAspect(converter.getDefinition().getTargetImageDisplayAspect());
	}
    }

    /**
     * Find the most suitable converter, apply its defaults and preset image
     * dimensions and colors based on the input file. In case of compressed
     * images, the source file in the data container is replaced by the unpacked
     * content. This leads to unwanted effect during reload which can only be
     * removed by the introduction of separate converters for these cases.
     * 
     * @param data
     *            The file converter data, not <code>null</code>.
     * @param bytes
     *            The file content of the input file, not <code>null</code>.
     * @param fileExtension
     *            The file extension of the input file, may be empty, not
     *            <code>null</code>.
     */
    public void findDefaultFileConverter(FilesConverterData data, byte[] bytes, String fileExtension) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	if (fileExtension == null) {
	    throw new IllegalArgumentException("Parameter 'fileExtension' must not be null.");
	}
	int columns;
	int rows;
	FilesConverterParameters parameters = data.getParameters();

	ConverterRegistry converterRegistry = GraphicsPlugin.getInstance().getConverterRegistry();
	List<ConverterDefinition> converterDefinitions = converterRegistry
		.getDefinitions(ConverterDirection.FILES_TO_IMAGE);

	// Try to match file extensions and content.
	boolean converted = false;
	Iterator<ConverterDefinition> i = converterDefinitions.iterator();
	while (i.hasNext() && !converted) {
	    ConverterDefinition converterDefinition = i.next();
	    if (converterDefinition.isSourceFileExtensionSupported(fileExtension)) {
		Converter converter = converterRegistry.getConverter(converterDefinition.getId());
		if (converter.canConvertToImage(bytes)) {
		    converter.convertToImageSizeAndPalette(data, bytes);
		    converted = true;
		}
	    }
	}

	// Ignore file extension and try to match content only.
	if (!converted) {
	    i = converterDefinitions.iterator();
	    while (i.hasNext() && !converted) {
		ConverterDefinition converterDefinition = i.next();
		Converter converter = converterRegistry.getConverter(converterDefinition.getId());
		if (converter.canConvertToImage(bytes)) {
		    converter.convertToImageSizeAndPalette(data, bytes);
		    converted = true;
		}
	    }
	}

	// If nothing matched, display as hires bitmap.
	if (!converted) {
	    data.getParameters().setConverterId(LinearBitMapGraphics8Converter.class.getName());
	    applyDefaults(data);
	    columns = 40;
	    rows = (bytes.length + columns - 1) / columns;
	    parameters.setColumns(columns);
	    parameters.setRows(rows);
	}
    }
}
