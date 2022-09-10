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

package com.wudsn.ide.lng.preferences;

/**
 * A property key with it's label
 * 
 * @author Peter Dell
 */
public class TextAttributeDefinition {

	/** Color preference key */
	private String preferencesKey;

	/** Display name */
	private String displayName;

	TextAttributeDefinition(String preferencesKey, String displayName) {
		if (preferencesKey == null) {
			throw new IllegalArgumentException("Parameter 'preferencesKey' must not be null.");
		}
		if (displayName == null) {
			throw new IllegalArgumentException("Parameter 'displayName' must not be null.");
		}

		this.displayName = displayName;
		this.preferencesKey = preferencesKey;
	}

	/**
	 * Gets the preferences key.
	 * 
	 * @return The preferences key, not empty and not <code>null</code>.
	 */
	public String getPreferencesKey() {
		return preferencesKey;
	}

	/**
	 * Gets the display name.
	 * 
	 * @return The display name, not empty and not <code>null</code>.
	 */
	public String getDisplayName() {
		return displayName;
	}

}