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

import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;
import java.util.Map;
import java.util.Properties;

/**
 * Properties which keep their sequence of keys.
 * 
 * @author Peter Dell
 */
public final class SequencedProperties extends Properties {
	/**
	 * Not used.
	 */
	private static final long serialVersionUID = 1L;

	private List<Object> propertyNames;

	public SequencedProperties() {
		propertyNames = new ArrayList<Object>();
	}

	@Override
	public synchronized Object put(Object key, Object value) {
		if (propertyNames.contains(key)) {
			throw new IllegalArgumentException("Value for key '" + key + "' already added.");
		}
		propertyNames.add(key);
		return super.put(key, value);
	}

	/**
	 * Returns an enumeration of the keys in this hashtable.
	 * 
	 * @return an enumeration of the keys in this hashtable.
	 * @see Enumeration
	 * @see #elements()
	 * @see #keySet()
	 * @see Map
	 */
	@Override
	public synchronized Enumeration<Object> keys() {
		return Collections.enumeration(propertyNames);
	}

	@Override
	public synchronized String toString() {
		StringBuilder builder = new StringBuilder();
		for (Object key : propertyNames) {

			builder.append(key).append("=").append(get(key)).append("\n");
		}
		return builder.toString();

	}

}