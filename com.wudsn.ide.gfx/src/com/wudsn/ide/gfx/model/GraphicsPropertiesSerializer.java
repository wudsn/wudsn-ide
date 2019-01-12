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

package com.wudsn.ide.gfx.model;

import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.base.common.PropertiesSerializer;

public final class GraphicsPropertiesSerializer extends PropertiesSerializer {

    /**
     * Creation is public.
     */
    public GraphicsPropertiesSerializer() {

 
    }

    public final RGB readRGB(String key, RGB defaultValue) {

	if (key == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'key' must not be null.");
	}
	if (defaultValue == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'defaultValue' must not be null.");
	}

	RGB result;

	int red = readInteger(key + ".red", 0);
	int green = readInteger(key + ".green", 0);
	int blue = readInteger(key + ".blue", 0);

	result = new RGB(red, green, blue);

	return result;
    }

    public final void writeRGB(String key, RGB value) {

	if (key == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'key' must not be null.");
	}
	if (value == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'value' must not be null.");
	}

	writeInteger(key + ".red", value.red);
	writeInteger(key + ".green", value.green);
	writeInteger(key + ".blue", value.blue);
    }

    public final Aspect readXYFactor(String key, Aspect defaultValue) {

	if (key == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'key' must not be null.");
	}
	if (defaultValue == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'defaultValue' must not be null.");
	}
	Aspect result;

	int factorX = readInteger(key + ".factorX", 1);
	int factorY = readInteger(key + ".factorY", 1);

	result = new Aspect(factorX, factorY);
	return result;
    }

    public final void writeAspect(String key, Aspect value) {

	if (key == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'key' must not be null.");
	}
	if (value == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'value' must not be null.");
	}
	setProperty(key + ".factorX", String.valueOf(value.getFactorX()));
	setProperty(key + ".factorY", String.valueOf(value.getFactorY()));
    }


    public final RGB[] readRGBArray(String key, RGB[] defaultValue) {
	if (key == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'key' must not be null.");
	}
	if (defaultValue == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'defaultValue' must not be null.");
	}
	RGB[] result;

	if (properties.containsKey(key)) {
	    int length = readInteger(key, 0);
	    result = new RGB[length];
	    String prefix = key + ".";
	    RGB black = new RGB(0, 0, 0);
	    for (int i = 0; i < length; i++) {
		String valueKey = prefix + i;
		result[i] = readRGB(valueKey, black);
	    }
	} else {
	    result = defaultValue;
	}
	return result;

    }

    public final void writeRGBArray(String key, RGB[] value) {
	if (key == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'key' must not be null.");
	}
	if (value == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'value' must not be null.");
	}
	writeInteger(key, value.length);
	String prefix = key + ".";
	for (int i = 0; i < value.length; i++) {
	    String valueKey = prefix + i;
	    writeRGB(valueKey, value[i]);
	}
    }
}
