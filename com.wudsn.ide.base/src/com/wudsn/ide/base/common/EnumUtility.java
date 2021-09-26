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

import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

import com.wudsn.ide.base.BasePlugin;

/**
 * Utility class for enums.
 * 
 * @author Peter Dell
 */

public final class EnumUtility {

	/**
	 * Gets the localized text for an enum value.
	 * 
	 * @param enumValue The enum value, not <code>null</code>.
	 * @return The localized text, may be empty, not <code>null</code>.
	 */
	public static String getText(Enum<?> enumValue) {
		if (enumValue == null) {
			throw new IllegalArgumentException("Parameter 'enumValue' must not be null.");
		}

		String result;

		Class<?> enumClass = enumValue.getClass();

		String key = enumClass.getName() + "." + enumValue.name();
		try {
			ResourceBundle resourceBundle;

			resourceBundle = ResourceBundleUtility.getResourceBundle(enumClass);
			result = resourceBundle.getString(key);
		} catch (MissingResourceException ex) {
			result = enumValue.name() + " - Text missing";
			BasePlugin.getInstance().logError("Resource for enum value {0} is missing.", new Object[] { key }, ex);
		}
		return result;
	}

}
