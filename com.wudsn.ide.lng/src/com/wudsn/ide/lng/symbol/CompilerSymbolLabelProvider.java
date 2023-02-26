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

package com.wudsn.ide.lng.symbol;

import org.eclipse.swt.graphics.Image;

import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.compiler.CompilerSymbol;
import com.wudsn.ide.lng.compiler.CompilerSymbolType;

/**
 * LabelProvider for the {@link CompilerSymbol} instances in the compiler
 * symbols view.
 * 
 * @author Peter Dell
 */
final class CompilerSymbolLabelProvider {

	/** Default image */
	private final Image defaultImage;

	/** Outline equate definition image */
	private final Image equateDefintionImage;

	/** Outline label definition image */
	private final Image labelDefinitionImage;

	/** Outline enum definition section image */
	private final Image enumDefinitionSectionImage;

	/** Outline structure definition section image */
	private final Image structureDefinitionSectionImage;

	/** Outline local section image */
	private final Image localSectionImage;

	/** Outline procedure definition section image */
	private final Image procedureDefinitionSectionImage;

	CompilerSymbolLabelProvider() {
		LanguagePlugin plugin;
		plugin = LanguagePlugin.getInstance();
		defaultImage = plugin.getImage("outline-default-16x16.png");

		equateDefintionImage = plugin.getImage("outline-equate-definition-16x16.png");
		labelDefinitionImage = plugin.getImage("outline-label-definition-16x16.png");

		enumDefinitionSectionImage = plugin.getImage("outline-enum-definition-section-16x16.png");
		structureDefinitionSectionImage = plugin.getImage("outline-structure-definition-section-16x16.png");
		localSectionImage = plugin.getImage("outline-local-section-16x16.png");
		procedureDefinitionSectionImage = plugin.getImage("outline-procedure-definition-section-16x16.png");

	}

	public Image getImage(Object element) {
		Image result;
		if (element instanceof CompilerSymbol) {
			CompilerSymbol elem = (CompilerSymbol) element;
			int type = elem.getType();

			switch (type) {
			case CompilerSymbolType.EQUATE_DEFINITION:
				result = equateDefintionImage;
				break;
			case CompilerSymbolType.LABEL_DEFINITION:
				result = labelDefinitionImage;
				break;

			case CompilerSymbolType.ENUM_DEFINITION_SECTION:
				result = enumDefinitionSectionImage;
				break;
			case CompilerSymbolType.STRUCTURE_DEFINITION_SECTION:
				result = structureDefinitionSectionImage;
				break;
			case CompilerSymbolType.LOCAL_SECTION:
				result = localSectionImage;
				break;

			case CompilerSymbolType.PROCEDURE_DEFINITION_SECTION:
				result = procedureDefinitionSectionImage;
				break;

			default:
				result = defaultImage;
			}
		} else {
			result = null;
		}

		return result;
	}
}
