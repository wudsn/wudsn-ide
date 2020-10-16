/**
 * Copyright (C) 2009 - 2020 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

package com.wudsn.ide.asm.preferences;

import org.eclipse.jface.text.TextAttribute;

/**
 * Item in the highlighting color list.
 * 
 * @author Peter Dell
 */
final class TextAttributeListItem {

    /** Display name */
    private String displayName;

    /** Color preference key */
    private String preferencesKey;

    /** Text attribute */
    private TextAttribute textAttribute;

    TextAttributeListItem(String displayName, String preferencesKey) {
	if (displayName == null) {
	    throw new IllegalArgumentException("Parameter 'displayName' must not be null.");
	}
	if (preferencesKey == null) {
	    throw new IllegalArgumentException("Parameter 'preferencesKey' must not be null.");
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

    /**
     * Sets the text attribute.
     * 
     * @param textAttribute
     *            The text attribute, not <code>null</code>.
     * 
     */
    public void setTextAttribute(TextAttribute textAttribute) {
	if (textAttribute == null) {
	    throw new IllegalArgumentException("Parameter 'textAttribute' must not be null.");
	}
	this.textAttribute = textAttribute;
    }

    /**
     * Gets the text attribute.
     * 
     * @return The text attribute, not <code>null</code>.
     */
    public TextAttribute getTextAttribute() {
	if (textAttribute == null) {
	    throw new IllegalStateException("Field 'textAttribute' must not be null.");
	}
	return textAttribute;
    }
}