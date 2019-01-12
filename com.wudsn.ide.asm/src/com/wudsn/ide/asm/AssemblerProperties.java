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

package com.wudsn.ide.asm;

import java.util.Map;
import java.util.TreeMap;

import org.eclipse.core.resources.IMarker;

import com.wudsn.ide.base.common.StringUtility;

public final class AssemblerProperties {

    /**
     * A single key value pair.
     * 
     * @since 1.6.1
     */
    public static final class AssemblerProperty {
	public final String key;
	public final String value;
	public final int lineNumber;

	AssemblerProperty(String key, String value, int lineNumber) {
	    this.key = key;
	    this.value = value;
	    this.lineNumber = lineNumber;
	}

	@Override
	public String toString() {
	    return key + "=" + value + " in line " + lineNumber;
	}
    }

    @SuppressWarnings("serial")
    public final static class InvalidAssemblerPropertyException extends Exception {
	public final AssemblerProperty property;
	public final IMarker marker;

	public InvalidAssemblerPropertyException(AssemblerProperty property, IMarker marker) {
	    if (property == null) {
		throw new IllegalArgumentException("Parameter 'property' must not be null.");
	    }
	    this.property = property;
	    this.marker = marker;
	}
    }

    /**
     * Source code constants.
     */
    public final static String PREFIX = "@com.wudsn.ide.asm.";
    public final static String HARDWARE = "@com.wudsn.ide.asm.hardware";
    public final static String MAIN_SOURCE_FILE = "@com.wudsn.ide.asm.mainsourcefile";
    public final static String OUTPUT_FOLDER_MODE = "@com.wudsn.ide.asm.outputfoldermode";
    public final static String OUTPUT_FOLDER = "@com.wudsn.ide.asm.outputfolder";
    public final static String OUTPUT_FILE_EXTENSION = "@com.wudsn.ide.asm.outputfileextension";
    public final static String OUTPUT_FILE = "@com.wudsn.ide.asm.outputfile";

    private Map<String, AssemblerProperty> properties;

    /**
     * Creation is public.
     */
    public AssemblerProperties() {
	properties = new TreeMap<String, AssemblerProperties.AssemblerProperty>();
    }

    /**
     * Puts a new value into the properties provided not other value is already
     * there.
     * 
     * @param key
     *            The property key, not empty and not <code>null</code>.
     * @param value
     *            The property value, may be empty, not <code>null</code>.
     * @param lineNumber
     *            The line number, a positive integer or 0 if the line number is
     *            undefined.
     * @since 1.6.1
     */
    public void put(String key, String value, int lineNumber) {
	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");
	}
	if (StringUtility.isEmpty(key)) {
	    throw new IllegalArgumentException("Parameter 'key' must not be empty.");
	}
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}
	if (lineNumber < 0l) {
	    throw new IllegalArgumentException("Parameter 'lineNumber' must not be negative. Specified value is "
		    + lineNumber + ".");
	}
	if (!properties.containsKey(key)) {
	    AssemblerProperty property = new AssemblerProperty(key, value, lineNumber);
	    properties.put(key, property);
	}
    }

    /**
     * Gets a property from the properties map.
     * 
     * @param key
     *            The property key, not empty and not <code>null</code>.
     * @return The property or <code>null</code> if the property is not defined.
     * 
     * @since 1.6.1
     */
    public AssemblerProperty get(String key) {
	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");
	}
	if (StringUtility.isEmpty(key)) {
	    throw new IllegalArgumentException("Parameter 'key' must not be empty.");
	}
	return properties.get(key);
    }

    @Override
    public String toString() {
	return properties.toString();
    }

}
