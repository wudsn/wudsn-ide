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

package com.wudsn.ide.asm.editor;

import org.eclipse.jface.viewers.DelegatingStyledCellLabelProvider;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.StyledString;
import org.eclipse.swt.graphics.Image;

import com.wudsn.ide.asm.AssemblerPlugin;
import com.wudsn.ide.asm.compiler.parser.CompilerSourceParserTreeObject;
import com.wudsn.ide.asm.compiler.parser.CompilerSourceParserTreeObjectType;

/**
 * LabelProvider for the {@link CompilerSourceParserTreeObject} instances in the
 * outline page and the content assist popup.
 * 
 * @author Peter Dell
 * @author Daniel Mitte
 */
final class CompilerSourceParserTreeObjectLabelProvider extends DelegatingStyledCellLabelProvider {

    /** Default tree image */
    private final Image defaultImage;

    /** Outline definition section image */
    private final Image definitionSectionImage;

    /** Outline implementation section image */
    private final Image implementationSectionImage;

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

    /** Outline macro definition section image */
    private final Image macroDefinitionSectionImage;

    /** Outline pages section image */
    private final Image pagesSectionImage;

    /** Outline procedure definition section image */
    private final Image procedureDefinitionSectionImage;

    /** Outline repeat section image */
    private final Image repeatSectionImage;

    /** Outline source include image */
    private final Image sourceIncludeImage;

    /** Outline binary include image */
    private final Image binaryIncludeImage;

    /** Outline binary include image */
    private final Image binaryOutputImage;

    private static class StyledLabelProvider extends LabelProvider implements IStyledLabelProvider {

	/**
	 * Creation is local.
	 */
	StyledLabelProvider() {

	}

	@Override
	public StyledString getStyledText(Object element) {
	    if (element == null) {
		throw new IllegalArgumentException("Parameter 'element' must not be null.");
	    }
	    if (element instanceof CompilerSourceParserTreeObject) {
		CompilerSourceParserTreeObject elem = (CompilerSourceParserTreeObject) element;
		return elem.getStyledString();
	    }

	    return new StyledString(getText(element));
	}
    }

    /**
     * Creates a new instance.
     * 
     * Called by
     * {@link AssemblerContentOutlinePage#createControl(org.eclipse.swt.widgets.Composite)}
     * .
     */
    CompilerSourceParserTreeObjectLabelProvider() {
	super(new StyledLabelProvider());
	AssemblerPlugin plugin;
	plugin = AssemblerPlugin.getInstance();
	defaultImage = plugin.getImage("outline-default-16x16.gif");
	definitionSectionImage = plugin.getImage("outline-definition-section-16x16.gif");
	implementationSectionImage = plugin.getImage("outline-implementation-section-16x16.gif");

	equateDefintionImage = plugin.getImage("outline-equate-definition-16x16.gif");
	labelDefinitionImage = plugin.getImage("outline-label-definition-16x16.gif");

	enumDefinitionSectionImage = plugin.getImage("outline-enum-definition-section-16x16.gif");
	structureDefinitionSectionImage = plugin.getImage("outline-structure-definition-section-16x16.gif");
	localSectionImage = plugin.getImage("outline-local-section-16x16.gif");
	macroDefinitionSectionImage = plugin.getImage("outline-macro-definition-section-16x16.gif");
	pagesSectionImage = plugin.getImage("outline-pages-section-16x16.gif");
	procedureDefinitionSectionImage = plugin.getImage("outline-procedure-definition-section-16x16.gif");
	repeatSectionImage = plugin.getImage("outline-repeat-section-16x16.gif");

	sourceIncludeImage = plugin.getImage("outline-source-include-16x16.gif");
	binaryIncludeImage = plugin.getImage("outline-binary-include-16x16.gif");
	binaryOutputImage = plugin.getImage("outline-binary-output-16x16.gif");
    }

    @Override
    public Image getImage(Object element) {
	Image result;
	if (element instanceof CompilerSourceParserTreeObject) {
	    CompilerSourceParserTreeObject elem = (CompilerSourceParserTreeObject) element;
	    int type = elem.getType();

	    switch (type) {
	    case CompilerSourceParserTreeObjectType.DEFINITION_SECTION:
		result = definitionSectionImage;
		break;
	    case CompilerSourceParserTreeObjectType.IMPLEMENTATION_SECTION:
		result = implementationSectionImage;
		break;

	    case CompilerSourceParserTreeObjectType.EQUATE_DEFINITION:
		result = equateDefintionImage;
		break;
	    case CompilerSourceParserTreeObjectType.LABEL_DEFINITION:
		result = labelDefinitionImage;
		break;

	    case CompilerSourceParserTreeObjectType.ENUM_DEFINITION_SECTION:
		result = enumDefinitionSectionImage;
		break;
	    case CompilerSourceParserTreeObjectType.STRUCTURE_DEFINITION_SECTION:
		result = structureDefinitionSectionImage;
		break;
	    case CompilerSourceParserTreeObjectType.LOCAL_SECTION:
		result = localSectionImage;
		break;
	    case CompilerSourceParserTreeObjectType.MACRO_DEFINITION_SECTION:
		result = macroDefinitionSectionImage;
		break;
	    case CompilerSourceParserTreeObjectType.PAGES_SECTION:
		result = pagesSectionImage;
		break;
	    case CompilerSourceParserTreeObjectType.PROCEDURE_DEFINITION_SECTION:
		result = procedureDefinitionSectionImage;
		break;
	    case CompilerSourceParserTreeObjectType.REPEAT_SECTION:
		result = repeatSectionImage;
		break;

	    case CompilerSourceParserTreeObjectType.SOURCE_INCLUDE:
		result = sourceIncludeImage;
		break;
	    case CompilerSourceParserTreeObjectType.BINARY_INCLUDE:
		result = binaryIncludeImage;
		break;
	    case CompilerSourceParserTreeObjectType.BINARY_OUTPUT:
		result = binaryOutputImage;
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
