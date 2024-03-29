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

import org.eclipse.jface.text.TextAttribute;

/**
 * Item in the highlighting color list.
 * 
 * @author Peter Dell
 */
final class TextAttributeListItem {

	/** Display name */
	private TextAttributeDefinition definition;
	
	/** Text attribute */
	private TextAttribute textAttribute;

	TextAttributeListItem(TextAttributeDefinition definition) {
		if (definition == null) {
			throw new IllegalArgumentException("Parameter 'definition' must not be null.");
		}
		this.definition = definition;
	}

	/**
	 * Gets the preferences key.
	 * 
	 * @return The preferences key, not empty and not <code>null</code>.
	 */
	public TextAttributeDefinition getDefinition() {
		return definition;
	}

	/**
	 * Sets the text attribute.
	 * 
	 * @param textAttribute The text attribute, not <code>null</code>.
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