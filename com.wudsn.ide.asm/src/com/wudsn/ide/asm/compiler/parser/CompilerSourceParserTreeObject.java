/**
 * Copyright (C) 2009 - 2014 <a href="http://www.wudsn.com" target="_top">Peter Dell</a>
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

package com.wudsn.ide.asm.compiler.parser;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.jface.viewers.StyledString;

import com.wudsn.ide.asm.compiler.syntax.CompilerSyntax;
import com.wudsn.ide.base.common.StringUtility;

/**
 * The object representing a node in the content outline tree.
 * 
 * @author Peter Dell
 * @author Andy Reek
 */
public final class CompilerSourceParserTreeObject {

    private final CompilerSourceFile compilerSourceFile;

    private final int startOffset;

    private final int type;

    private final String name;

    private final String displayName;

    private final String description;

    private final StyledString styledString;

    private final List<CompilerSourceParserTreeObject> children;

    private CompilerSourceParserTreeObject parent;

    private String treePath;

    private String compoundName;

    private CompilerSourceFile includedCompilerSourceFile;

    /**
     * Create a new instance.
     * 
     * @param compilerSourceFile
     *            The source file to which this parser tree object belongs.
     * 
     * @param startOffset
     *            The start offset of the instance, a non-negative integer.
     * @param type
     *            The type of a instance, see
     *            {@link CompilerSourceParserTreeObjectType}.
     * @param name
     *            The name of the tree object, not <code>null</code>. It is used
     *            to build the full tree path,
     * @param displayName
     *            The display name of the tree object, not <code>null</code>. It
     *            is used in the tree view.
     * @param description
     *            The description of the tree object, not <code>null</code>.
     */
    CompilerSourceParserTreeObject(CompilerSourceFile compilerSourceFile,
	    int startOffset, int type, String name, String displayName,
	    String description) {
	if (compilerSourceFile == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'compilerSourceFile' must not be null.");
	}
	if (startOffset < 0) {
	    throw new IllegalArgumentException(
		    "Parameter 'startOffset' must not be negative. Specified value is "
			    + startOffset + ".");
	}
	this.compilerSourceFile = compilerSourceFile;
	this.startOffset = startOffset;

	switch (type) {
	case CompilerSourceParserTreeObjectType.DEFAULT:

	case CompilerSourceParserTreeObjectType.DEFINITION_SECTION:
	case CompilerSourceParserTreeObjectType.IMPLEMENTATION_SECTION:

	case CompilerSourceParserTreeObjectType.EQUATE_DEFINITION:
	case CompilerSourceParserTreeObjectType.LABEL_DEFINITION:

	case CompilerSourceParserTreeObjectType.ENUM_DEFINITION_SECTION:
	case CompilerSourceParserTreeObjectType.STRUCTURE_DEFINITION_SECTION:
	case CompilerSourceParserTreeObjectType.LOCAL_SECTION:
	case CompilerSourceParserTreeObjectType.MACRO_DEFINITION_SECTION:
	case CompilerSourceParserTreeObjectType.PAGES_SECTION:
	case CompilerSourceParserTreeObjectType.PROCEDURE_DEFINITION_SECTION:
	case CompilerSourceParserTreeObjectType.REPEAT_SECTION:

	case CompilerSourceParserTreeObjectType.SOURCE_INCLUDE:
	case CompilerSourceParserTreeObjectType.BINARY_INCLUDE:
	case CompilerSourceParserTreeObjectType.BINARY_OUTPUT:

	    break;

	default:
	    throw new IllegalArgumentException("Unknown type " + type + ".");
	}
	if (name == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'name' must not be null.");
	}
	if (displayName == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'displayName' must not be null.");
	}
	if (description == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'description' must not be null.");
	}
	this.type = type;
	this.name = name;
	this.displayName = displayName;
	this.description = description;

	styledString = new StyledString(displayName);
	if (description.length() > 0) {
	    styledString.append(" ");
	    styledString.append(description, StyledString.QUALIFIER_STYLER);
	}
	this.children = new ArrayList<CompilerSourceParserTreeObject>();
    }

    /**
     * Gets the compiler source file, this parser tree object belongs to.
     * 
     * @return The compiler source file, this parser tree object belongs to, not
     *         <code>null</code>.
     */
    public CompilerSourceFile getCompilerSourceFile() {
	return compilerSourceFile;
    }

    /**
     * Gets the start offset of this parser tree object in the compiler source
     * file.
     * 
     * @return The start offset of this parser tree object in the compiler
     *         source file, a non-negative integer.
     */
    public int getStartOffset() {
	return startOffset;
    }

    /**
     * Gets the type of the object.
     * 
     * @return The type, see {@link CompilerSourceParserTreeObjectType}.
     */
    public int getType() {
	return type;
    }

    /**
     * Gets the name of the object.
     * 
     * @return The name, not <code>null</code>.
     */
    public String getName() {
	return name;
    }

    /**
     * Gets the compound name of the object.
     * 
     * @return The compound name, not <code>null</code>.
     */
    public String getCompoundName() {
	if (compoundName == null) {
	    char identifierSeparatorCharacter = compilerSourceFile
		    .getCompilerSyntax().getIdentifierSeparatorCharacter();
	    switch (type) {
	    case CompilerSourceParserTreeObjectType.DEFINITION_SECTION:
	    case CompilerSourceParserTreeObjectType.IMPLEMENTATION_SECTION:
	    case CompilerSourceParserTreeObjectType.REPEAT_SECTION:
	    case CompilerSourceParserTreeObjectType.SOURCE_INCLUDE:
	    case CompilerSourceParserTreeObjectType.BINARY_INCLUDE:
	    case CompilerSourceParserTreeObjectType.BINARY_OUTPUT:
		if (parent != null) {
		    compoundName = parent.getCompoundName();
		} else {
		    compoundName = "";
		}
		return compoundName;
	    }

	    compoundName = name;

	    // Compound identifiers supported?
	    if (identifierSeparatorCharacter != CompilerSyntax.NO_CHARACTER) {

		// Find next named parent.
		CompilerSourceParserTreeObject namedParent = parent;
		while (namedParent != null
			// && namedParent.getType() !=
			// CompilerSourceParserTreeObjectType.DEFINITION_SECTION
			// && namedParent.getType() !=
			// CompilerSourceParserTreeObjectType.IMPLEMENTATION_SECTION
			// && namedParent.getType() !=
			// CompilerSourceParserTreeObjectType.REPEAT_SECTION
			// && namedParent.getType() !=
			// CompilerSourceParserTreeObjectType.SOURCE_INCLUDE
			// && namedParent.getType() !=
			// CompilerSourceParserTreeObjectType.BINARY_INCLUDE
			// && namedParent.getType() !=
			// CompilerSourceParserTreeObjectType.BINARY_OUTPUT

			&& namedParent.getType() != CompilerSourceParserTreeObjectType.ENUM_DEFINITION_SECTION
			&& namedParent.getType() != CompilerSourceParserTreeObjectType.STRUCTURE_DEFINITION_SECTION
			&& namedParent.getType() != CompilerSourceParserTreeObjectType.LOCAL_SECTION
			&& namedParent.getType() != CompilerSourceParserTreeObjectType.MACRO_DEFINITION_SECTION
			&& namedParent.getType() != CompilerSourceParserTreeObjectType.PROCEDURE_DEFINITION_SECTION) {
		    namedParent = namedParent.getParent();
		}
		if (namedParent != null
			&& StringUtility.isSpecified(compoundName)) {
		    String parentCompoundName;
		    parentCompoundName = parent.getCompoundName();
		    if (StringUtility.isSpecified(parentCompoundName)) {
			compoundName = parentCompoundName
				+ identifierSeparatorCharacter + compoundName;
		    }
		}
	    }
	}

	return compoundName;

    }

    /**
     * Gets the display name of the object.
     * 
     * @return The display name, not <code>null</code>.
     */
    public String getDisplayName() {
	return displayName;
    }

    /**
     * Gets the unique tree path of this tree object within the tree.
     * 
     * @return The unique tree path, not empty and not <code>null</code>.
     */
    public String getTreePath() {
	if (treePath == null) {
	    treePath = "\"" + type + "/" + name + "\"";
	    if (parent != null) {
		treePath = parent.getTreePath() + "/" + treePath;
	    }
	}
	return treePath;
    }

    /**
     * Gets the description of the object.
     * 
     * @return The description, not <code>null</code>.
     */
    public String getDescription() {
	return description;
    }

    /**
     * Gets the styled string of the object.
     * 
     * @return The styled string, not <code>null</code>.
     */
    public StyledString getStyledString() {
	return styledString;
    }

    /**
     * Gets the parent object of the tree object.
     * 
     * @return The parent, may be <code>null</code>.
     */
    public CompilerSourceParserTreeObject getParent() {
	return parent;
    }

    /**
     * Sets a new parent.
     * 
     * @param parent
     *            The new parent, may be <code>null</code>.
     */
    final void setParent(CompilerSourceParserTreeObject parent) {
	this.parent = parent;
	this.treePath = null;
    }

    /**
     * Determines if this tree object has children.
     * 
     * @return <code>true</code> if this tree object has children,
     *         <code>false</code> otherwise.
     */
    public boolean hasChildren() {
	return !children.isEmpty();
    }

    /**
     * Gets all children of the tree object.
     * 
     * @return The array of children, not <code>null</code>..
     */
    public Object[] getChildrenAsArray() {
	return children.toArray(new Object[0]);
    }

    /**
     * Gets all children of the tree object.
     * 
     * @return The array of children, not <code>null</code>. Do not modify.
     */
    public List<CompilerSourceParserTreeObject> getChildren() {
	return children;
    }

    /**
     * Adds a new Child.
     * 
     * @param child
     *            The new child, not <code>null</code>.
     */
    final void addChild(CompilerSourceParserTreeObject child) {
	if (child == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'child' must not be null.");
	}
	if (child == this) {
	    throw new IllegalArgumentException(
		    "Parameter 'child' must not be this: " + toString());
	}
	children.add(child);
	child.setParent(this);

    }

    /**
     * Gets the included compiler source file for a SOURCE_INCLUDE tree object.
     * 
     * @return The included compiler source file or <code>null</code>.
     */
    final CompilerSourceFile setIncludedCompilerSourceFile() {
	return includedCompilerSourceFile;
    }

    /**
     * Sets the included compiler source file for a SOURCE_INCLUDE tree object.
     * 
     * @param includedCompilerSourceFile
     *            The included compiler source file, may be <code>null</code>.
     */
    final void setIncludedCompilerSourceFile(
	    CompilerSourceFile includedCompilerSourceFile) {
	if (type != CompilerSourceParserTreeObjectType.SOURCE_INCLUDE) {
	    throw new IllegalStateException("The type of this tree object is "
		    + type + " and not SOURCE_INCLUDE");
	}
	this.includedCompilerSourceFile = includedCompilerSourceFile;

    }
    

    @Override
    public boolean equals(Object object) {
	if (!(object instanceof CompilerSourceParserTreeObject)) {
	    return false;
	}
	CompilerSourceParserTreeObject other;
	other = (CompilerSourceParserTreeObject) object;
	return getTreePath().equals(other.getTreePath());
    }

    @Override
    public int hashCode() {
	return getTreePath().hashCode();

    }

    @Override
    public String toString() {
	return getTreePath();
    }
}
