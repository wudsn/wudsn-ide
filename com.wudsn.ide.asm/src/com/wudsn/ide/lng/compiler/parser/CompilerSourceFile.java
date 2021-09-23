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

package com.wudsn.ide.lng.compiler.parser;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.Position;

import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.lng.Texts;
import com.wudsn.ide.lng.compiler.syntax.CompilerSyntax;

/**
 * Container for recursive parsing of source files using
 * {@link CompilerSourceParser#parse(CompilerSourceFile, CompilerSourceParserLineCallback)}
 * .
 * 
 * @author Peter Dell
 */
public final class CompilerSourceFile {

	private final static class FoldingStackEntry {
		public final int startOffset;
		public final boolean forSection;

		public FoldingStackEntry(int startOffset, boolean forSection) {
			this.startOffset = startOffset;
			this.forSection = forSection;
		}

		@Override
		public String toString() {
			return "startOffset=" + startOffset + ", forSection=" + forSection;
		}
	}

	private CompilerSyntax compilerSyntax;
	private File documentFile;
	private File documentDirectory;
	private IDocument document;

	private List<Position> foldingPositions;

	/**
	 * Temporary data during the parse process.
	 */
	private List<FoldingStackEntry> foldingStack;

	/**
	 * The result of the last parse process.
	 */
	private CompilerSourceParserTreeObject definitionSection;
	private List<CompilerSourceParserTreeObject> implementationSections;
	private List<CompilerSourceParserTreeObject> sectionStack;

	/**
	 * Creates a new compiler source file. Instances are only created by
	 * {@link CompilerSourceParser#createCompilerSourceFile(File, IDocument)}.
	 * 
	 * @param compilerSyntax The compiler syntax used to parse this file, not
	 *                       <code>null</code>.
	 * @param documentFile   The file in the file system. Its directory is used to
	 *                       resolve relative file paths, or <code>null</code> if
	 *                       the document is not yet persistent.
	 * @param document       The document, not <code>null</code>.
	 */
	CompilerSourceFile(CompilerSyntax compilerSyntax, File documentFile, IDocument document) {
		if (compilerSyntax == null) {
			throw new IllegalArgumentException("Parameter 'compilerSyntax' must not be null.");
		}
		if (document == null) {
			throw new IllegalArgumentException("Parameter 'document' must not be null.");
		}
		this.compilerSyntax = compilerSyntax;
		if (documentFile != null) {
			documentFile = FileUtility.getCanonicalFile(documentFile);
			this.documentFile = documentFile;
			this.documentDirectory = documentFile.getParentFile();
		}

		this.document = document;

		// Folding.
		foldingPositions = new ArrayList<Position>();
		foldingStack = new ArrayList<FoldingStackEntry>();

		// Sections.
		definitionSection = new CompilerSourceParserTreeObject(this, 0,
				CompilerSourceParserTreeObjectType.DEFINITION_SECTION, "DefinitionSection",
				Texts.ASSEMBLER_CONTENT_OUTLINE_TREE_TYPE_DEFINITION_SECTION, "");
		implementationSections = new ArrayList<CompilerSourceParserTreeObject>();
		sectionStack = new ArrayList<CompilerSourceParserTreeObject>();
	}

	/**
	 * Gets the compiler syntax user to parse this file.
	 * 
	 * @return The compiler syntax, not <code>null</code>.
	 * 
	 * @since 1.6.1
	 */
	public CompilerSyntax getCompilerSyntax() {
		return compilerSyntax;
	}

	/**
	 * Gets the canonical document file.
	 * 
	 * @return The file where the document is located, or <code>null</code> if the
	 *         document is not yet persistent.
	 */
	public File getDocumentFile() {
		return documentFile;
	}

	/**
	 * Gets the document directory.
	 * 
	 * @return The directory which is used to resolved relative file paths, or
	 *         <code>null</code> if the document is not yet persistent.
	 */
	public File getDocumentDirectory() {
		return documentDirectory;
	}

	/**
	 * Gets the document.
	 * 
	 * @return The document, not <code>null</code>.
	 */
	public IDocument getDocument() {
		return document;
	}

	/**
	 * Gets the sections of this file.
	 * 
	 * @return The unmodifiable list of section, may be empty, not
	 *         <code>null</code>.
	 */
	public List<CompilerSourceParserTreeObject> getSections() {
		List<CompilerSourceParserTreeObject> result;
		result = new ArrayList<CompilerSourceParserTreeObject>();
		if (definitionSection != null && definitionSection.hasChildren()) {
			result.add(definitionSection);
		}

		result.addAll(implementationSections);
		result = Collections.unmodifiableList(result);
		return result;
	}

	final CompilerSourceParserTreeObject getDefinitionSection() {
		return definitionSection;
	}

	final List<CompilerSourceParserTreeObject> getImplementationSections() {
		return implementationSections;
	}

	/**
	 * Gets the list of foldingPositions for folding after parsed has completed.
	 * 
	 * @return The non-modifiable sorted list of foldingPositions, may be empty, not
	 *         <code>null</code>.
	 */
	public List<Position> getFoldingPositions() {
		return Collections.unmodifiableList(foldingPositions);
	}

	/**
	 * Determines if the currently active folding was started for a section.
	 * 
	 * @return <code>true</code> if the folding was started for a section,
	 *         <code>false</code> if not.
	 */
	final boolean isFoldingForSection() {
		if (foldingStack.isEmpty()) {
			return false; // Ignore wrong nesting.
		}
		FoldingStackEntry entry = foldingStack.get(foldingStack.size() - 1);
		return entry.forSection;
	}

	/**
	 * Starts a new active folding level.
	 * 
	 * @param startOffset The start offset, a non-negative integer.
	 * @param forSection  <code>true</code> if the folding is started for a section,
	 *                    <code>false</code> if not.
	 */
	final void beginFolding(int startOffset, boolean forSection) {
		if (startOffset < 0) {
			throw new IllegalArgumentException(
					"Parameter 'startOffset' must not be negative. Specified value is " + startOffset + ".");
		}
		foldingStack.add(new FoldingStackEntry(startOffset, forSection));
	}

	/**
	 * Ends the currently active folding level.
	 * 
	 * @param endOffset The end offset, a non-negative integer. This must be the
	 *                  actual offset of the last character in the line, including
	 *                  the line end delimiter, if present.
	 */
	final void endFolding(int endOffset) {
		if (endOffset < 0) {
			throw new IllegalArgumentException(
					"Parameter 'endOffset' must not be negative. Specified value is " + endOffset + ".");
		}

		if (foldingStack.isEmpty()) {
			return; // Ignore wrong nesting.
		}
		FoldingStackEntry entry = foldingStack.remove(foldingStack.size() - 1);
		int length = endOffset - entry.startOffset;
		if (length < 0) {
			throw new IllegalArgumentException(
					"End offset " + endOffset + " is less than the start offset " + entry.startOffset + ".");
		}
		// Add only non-empty positions.
		if (length > 0) {
			foldingPositions.add(new Position(entry.startOffset, length));
		}
	}

	/**
	 * Ends all currently active folding levels.
	 * 
	 */
	final void endAllFoldings() {

		while (!foldingStack.isEmpty()) {
			endFolding(document.getLength() > 0 ? document.getLength() - 1 : 0);

		}
	}

	/**
	 * Ends all currently active sections.
	 * 
	 */
	public void endAllSections() {
		while (!sectionStack.isEmpty()) {
			endSection(document.getLength() > 0 ? document.getLength() - 1 : 0);
		}
	}

	/**
	 * Starts a new active section.
	 * 
	 * @param startOffset The start offset, a non-negative integer.
	 * @param section     The new section, not <code>null</code>.
	 * @param withFolding <code>true</code> if the section is also a folding
	 *                    section, <code>false</code> otherwise.
	 */
	final void beginSection(int startOffset, CompilerSourceParserTreeObject section, boolean withFolding) {
		if (startOffset < 0) {
			throw new IllegalArgumentException(
					"Parameter 'startOffset' must not be negative. Specified value is " + startOffset + ".");
		}
		if (section == null) {
			throw new IllegalArgumentException("Parameter 'section' must not be null.");
		}

		if (!sectionStack.isEmpty()) {
			CompilerSourceParserTreeObject parent = sectionStack.get(sectionStack.size() - 1);
			parent.addChild(section);
		}
		sectionStack.add(section);
		if (withFolding) {
			beginFolding(startOffset, true);
		}

	}

	/**
	 * Ends the currently active section.
	 * 
	 * @param endOffset The end offset, a non-negative integer. This must be the
	 *                  actual offset of the last character in the line, including
	 *                  the line end delimiter, if present.
	 * 
	 * @return The new top of the section stack, may be null.
	 */
	final CompilerSourceParserTreeObject endSection(int endOffset) {
		if (endOffset < 0) {
			throw new IllegalArgumentException(
					"Parameter 'endOffset' must not be negative. Specified value is " + endOffset + ".");
		}

		CompilerSourceParserTreeObject result;
		result = null;

		// Remove top of stack.
		if (!sectionStack.isEmpty()) {
			sectionStack.remove(sectionStack.size() - 1);

			// Make top of stack the new active section, accepting illegal pops.
			if (!sectionStack.isEmpty()) {
				result = sectionStack.get(sectionStack.size() - 1);
			}
			endFolding(endOffset);
		}
		return result;
	}

	public List<CompilerSourceParserTreeObject> getIdentifiers() {
		List<CompilerSourceParserTreeObject> foundElements;
		foundElements = new ArrayList<CompilerSourceParserTreeObject>();
		getIdentifiers(getSections(), foundElements);
		foundElements = Collections.unmodifiableList(foundElements);
		return foundElements;
	}

	private void getIdentifiers(List<CompilerSourceParserTreeObject> allElements,
			List<CompilerSourceParserTreeObject> foundElements) {
		if (allElements == null) {
			throw new IllegalArgumentException("Parameter 'allElements' must not be null.");
		}
		if (foundElements == null) {
			throw new IllegalArgumentException("Parameter 'foundElements' must not be null.");
		}
		CompilerSourceParserTreeObject element = null;
		for (int i = 0; i < allElements.size(); i++) {
			element = allElements.get(i);
			switch (element.getType()) {
			case CompilerSourceParserTreeObjectType.EQUATE_DEFINITION:
			case CompilerSourceParserTreeObjectType.LABEL_DEFINITION:
			case CompilerSourceParserTreeObjectType.LOCAL_SECTION:
			case CompilerSourceParserTreeObjectType.MACRO_DEFINITION_SECTION:
			case CompilerSourceParserTreeObjectType.PROCEDURE_DEFINITION_SECTION:

				foundElements.add(element);
				break;
			}
			if (element.hasChildren()) {
				getIdentifiers(element.getChildren(), foundElements);
			}

		}
	}

	/**
	 * Find the definition elements for a given identifier.
	 * 
	 * @param identifier The identifier to search for, not empty and not
	 *                   <code>null</code>.
	 * @return The unmodifiable list of compiler source tree object with the label,
	 *         may be empty, not <code>null</code>. The result may contain entries
	 *         from source include files.
	 */
	public List<CompilerSourceParserTreeObject> getIdentifierDefinitionElements(String identifier) {

		if (identifier == null) {
			throw new IllegalArgumentException("Parameter 'identifier' must not be null.");
		}
		if (StringUtility.isEmpty(identifier)) {
			throw new IllegalArgumentException("Parameter 'identifier' must not be empty.");
		}
		List<CompilerSourceParserTreeObject> foundElements;
		foundElements = new ArrayList<CompilerSourceParserTreeObject>();
		getIdentifierDefinitionElements(getSections(), identifier, foundElements);
		foundElements = Collections.unmodifiableList(foundElements);
		return foundElements;

	}

	private void getIdentifierDefinitionElements(List<CompilerSourceParserTreeObject> allElements, String identifier,
			List<CompilerSourceParserTreeObject> foundElements) {
		if (allElements == null) {
			throw new IllegalArgumentException("Parameter 'allElements' must not be null.");
		}
		if (identifier == null) {
			throw new IllegalArgumentException("Parameter 'identifier' must not be null.");
		}
		if (foundElements == null) {
			throw new IllegalArgumentException("Parameter 'foundElements' must not be null.");
		}
		String compoundIdentifierSuffix = null;
		char c = compilerSyntax.getIdentifierSeparatorCharacter();
		if (c != CompilerSyntax.NO_CHARACTER) {
			compoundIdentifierSuffix = c + identifier;
		}

		boolean identifiersCaseSensitive = compilerSyntax.areIdentifiersCaseSensitive();
		CompilerSourceParserTreeObject element = null;
		for (int i = 0; i < allElements.size(); i++) {
			element = allElements.get(i);
			switch (element.getType()) {
			case CompilerSourceParserTreeObjectType.EQUATE_DEFINITION:
			case CompilerSourceParserTreeObjectType.LABEL_DEFINITION:
			case CompilerSourceParserTreeObjectType.ENUM_DEFINITION_SECTION:
			case CompilerSourceParserTreeObjectType.STRUCTURE_DEFINITION_SECTION:
			case CompilerSourceParserTreeObjectType.LOCAL_SECTION:
			case CompilerSourceParserTreeObjectType.MACRO_DEFINITION_SECTION:
			case CompilerSourceParserTreeObjectType.PROCEDURE_DEFINITION_SECTION:
				// Check if name equals the identifier, compound name equals the
				// identifier or compound name ends with
				// compoundIdentifierSuffix.
				if (identifiersCaseSensitive) {
					if (element.getName().equals(identifier) || element.getCompoundName().equals(identifier)
							|| (compoundIdentifierSuffix != null
									&& element.getCompoundName().endsWith(compoundIdentifierSuffix))) {
						foundElements.add(element);
					}
				} else {
					if (element.getName().equalsIgnoreCase(identifier) || element.getCompoundName().equals(identifier)
							|| (compoundIdentifierSuffix != null && element.getCompoundName().regionMatches(true,
									element.getCompoundName().length() - compoundIdentifierSuffix.length(),
									compoundIdentifierSuffix, 0, compoundIdentifierSuffix.length()))) {
						foundElements.add(element);
					}
				}
				break;
			}

			if (element.hasChildren()) {
				getIdentifierDefinitionElements(element.getChildren(), identifier, foundElements);
			}

		}
	}
}
