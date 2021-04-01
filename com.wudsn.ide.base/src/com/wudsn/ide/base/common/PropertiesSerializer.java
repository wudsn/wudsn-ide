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

package com.wudsn.ide.base.common;

import java.util.Enumeration;
import java.util.Properties;

/**
 * Serializer which reads and writes simple and complex data types as
 * properties.
 * 
 * @author Peter Dell
 */
public class PropertiesSerializer {

    protected final SequencedProperties properties;

    /**
     * Creation is public.
     */
    public PropertiesSerializer() {

	properties = new SequencedProperties();
    }

    public final SequencedProperties getProperties() {
	return properties;
    }

    protected final void setProperty(String key, String value) {
	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");
	}
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}

	properties.put(key, value);
    }

    public final String readString(String key, String defaultValue) {

	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");
	}
	if (defaultValue == null) {
	    throw new IllegalArgumentException("Parameter 'defaultValue' must not be null.");
	}
	String result;
	result = properties.getProperty(key);
	if (result == null) {
	    result = defaultValue;
	}

	return result;
    }

    public final void writeString(String key, String value) {

	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");
	}
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}
	setProperty(key, value);
    }

    public boolean readBoolean(String key, boolean defaultValue) {
	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");

	}
	boolean result;
	result = defaultValue;
	String text = properties.getProperty(key);
	if (text != null) {
	    result = Boolean.parseBoolean(text);
	}
	return result;
    }

    public final void writeBoolean(String key, boolean value) {
	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");
	}
	properties.setProperty(key, Boolean.toString(value));
    }

    public final <T extends Enum<?>> T readEnum(String key, T defaultValue, Class<T> enumClass) {
	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");
	}
	if (defaultValue == null) {
	    throw new IllegalArgumentException("Parameter 'defaultValue' must not be null.");
	}
	if (enumClass == null) {
	    throw new IllegalArgumentException("Parameter 'enumClass' must not be null.");
	}
	T result;
	result = defaultValue;
	String text = properties.getProperty(key);
	if (text != null) {
	    T[] enumConstants = enumClass.getEnumConstants();

	    for (int i = 0; i < enumConstants.length; i++) {
		T enumConstant = enumConstants[i];
		if (enumConstant.name().equals(text)) {
		    result = enumConstant;
		    break;
		}
	    }
	}

	return result;
    }

    public final <T extends Enum<?>> void writeEnum(String key, T value) {
	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");
	}
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}
	setProperty(key, value.name());
    }

    public final int readInteger(String key, int defaultValue) {

	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");
	}

	int result;
	String text = properties.getProperty(key);
	if (text == null) {
	    result = defaultValue;
	} else {
	    try {
		result = Integer.parseInt(text);
	    } catch (NumberFormatException ex) {
		result = 0;
	    }
	}

	return result;
    }

    public final void writeInteger(String key, int value) {

	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");
	}

	setProperty(key, String.valueOf(value));
    }

    public final void readProperties(String key, PropertiesSerializer value) {
	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");
	}
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}
	String prefix = key + ".";
	Properties valueProperties = value.getProperties();
	valueProperties.clear();
	Enumeration<Object> i = properties.keys();
	while (i.hasMoreElements()) {
	    String valueKey = (String) i.nextElement();
	    if (valueKey.startsWith(prefix)) {
		valueProperties.setProperty(valueKey.substring(prefix.length()), properties.getProperty(valueKey));
	    }
	}
    }

    public final void writeProperties(String key, PropertiesSerializer value) {
	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");
	}
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}
	String prefix = key + ".";
	Properties valueProperties = value.getProperties();
	Enumeration<Object> i = valueProperties.keys();
	while (i.hasMoreElements()) {
	    String valueKey = (String) i.nextElement();
	    setProperty(prefix + valueKey, valueProperties.getProperty(valueKey));
	}
    }

}
