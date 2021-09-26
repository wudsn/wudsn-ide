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

package com.wudsn.ide.lng.editor;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.jface.text.contentassist.IContentAssistProcessor;
import org.eclipse.jface.text.contentassist.IContextInformation;
import org.eclipse.jface.text.contentassist.IContextInformationValidator;
import org.eclipse.jface.viewers.DelegatingStyledCellLabelProvider.IStyledLabelProvider;
import org.eclipse.jface.viewers.StyledString;
import org.eclipse.jface.viewers.StyledString.Styler;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.TextStyle;

import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.compiler.CompilerFiles;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceFile;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceParser;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceParserLineCallback;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceParserTreeObject;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceParserTreeObjectLabelProvider;
import com.wudsn.ide.lng.compiler.syntax.CompilerSyntax;
import com.wudsn.ide.lng.compiler.syntax.Directive;
import com.wudsn.ide.lng.compiler.syntax.Instruction;
import com.wudsn.ide.lng.compiler.syntax.InstructionSet;
import com.wudsn.ide.lng.compiler.syntax.InstructionType;
import com.wudsn.ide.lng.compiler.syntax.Opcode;
import com.wudsn.ide.lng.preferences.LanguagePreferences;

/**
 * Class for content assist. Creates the content assist list.
 * 
 * @author Peter Dell
 * @author Daniel Mitte
 */
final class LanguageContentAssistProcessor implements IContentAssistProcessor {

	/**
	 * Empty styler
	 */
	private final static class InstructionStyler extends Styler {

		InstructionStyler() {
		}

		@Override
		public void applyStyles(TextStyle textStyle) {

		}
	}

	/**
	 * Underline styler
	 */
	private final static class HighlightStyler extends Styler {

		HighlightStyler() {
		}

		@Override
		public void applyStyles(TextStyle textStyle) {
			textStyle.underline = true;

		}
	}

	/**
	 * Callback to find out if a given line already contains an instruction.
	 * 
	 * @since 1.6.0
	 */
	private static final class SourceParserCallback extends CompilerSourceParserLineCallback {
		private boolean instructionFound;
		private int instructionEndOffset;

		/**
		 * Create a new callback.
		 * 
		 * @param filePath   The absolute path of the source file, not empty and not
		 *                   <code>null</code>.
		 * @param lineNumber The line number, a non-negative integer or <code>-1</code>
		 *                   to indicate that no line number is relevant.
		 */
		public SourceParserCallback(String filePath, int lineNumber) {
			super(filePath, lineNumber);
		}

		@Override
		public void processLine(CompilerSourceParser compilerSourceParser, CompilerSourceFile compilerSourceFile,
				int lineNumber, int startOffset, int symbolOffset, boolean instructionFound, int instructionOffset,
				String instruction, int operandOffset, CompilerSourceParserTreeObject section) {

			this.instructionFound = instructionFound;
			if (instructionFound) {
				instructionEndOffset = instructionOffset + instruction.length();
			} else {
				instructionEndOffset = -1;
			}
		}

		/**
		 * Determines if the specified line in the source file already contains an
		 * instruction.
		 * 
		 * @return <code>true</code> if the specified line in the source file already
		 *         contains an instruction, <code>false</code> otherwise.
		 */
		public boolean wasInstructionFound() {
			return instructionFound;
		}

		/**
		 * Gets the offset of the last character of the instruction if an instruction
		 * was found.
		 * 
		 * @return The offset or -1 if no instruction was found.
		 */
		public int getInstructionEndOffset() {
			return instructionEndOffset;
		}
	}

	private LanguageEditor editor;

	private Image directiveImage;
	private Image legalOpcodeImage;
	private Image illegalOpcodeImage;
	private Image pseudoOpcodeImage;
	private Styler instructionStyler;
	private Styler highlightStyler;

	/**
	 * Creates a new instance.
	 * 
	 * Called by
	 * {@link LanguageSourceViewerConfiguration#getContentAssistant(org.eclipse.jface.text.source.ISourceViewer)}
	 * .
	 * 
	 * @param editor The language editor for which this instance is created, not
	 *               <code>null</code>.
	 */
	LanguageContentAssistProcessor(LanguageEditor editor) {
		if (editor == null) {
			throw new IllegalArgumentException("Parameter 'editor' must not be null.");
		}

		this.editor = editor;

		LanguagePlugin plugin = editor.getPlugin();
		directiveImage = plugin.getImage("instruction-type-directive-16x16.gif");
		legalOpcodeImage = plugin.getImage("instruction-type-legal-opcode-16x16.gif");
		illegalOpcodeImage = plugin.getImage("instruction-type-illegal-opcode-16x16.gif");
		pseudoOpcodeImage = plugin.getImage("instruction-type-pseudo-opcode-16x16.gif");
		instructionStyler = new InstructionStyler();
		highlightStyler = new HighlightStyler();
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public ICompletionProposal[] computeCompletionProposals(ITextViewer viewer, int offset) {
		if (viewer == null) {
			throw new IllegalArgumentException("Parameter 'viewer' must not be null.");
		}
		ITextSelection selection = (ITextSelection) viewer.getSelectionProvider().getSelection();

		int selectionOffset = offset;

		if (selection.getOffset() != offset) {
			selectionOffset = selection.getOffset();
		}

		List<ICompletionProposal> proposalList = new ArrayList<ICompletionProposal>();

		// Convert offset into line number.
		int lineNumber;
		int lineOffset;
		try {
			lineNumber = viewer.getDocument().getLineOfOffset(offset);
			lineOffset = viewer.getDocument().getLineOffset(lineNumber);
		} catch (BadLocationException ex) {
			lineNumber = -1;
			lineOffset = -1;
		}

		// Parse the current compiler file and try to find the line in the
		// correct source file.
		CompilerFiles files = LanguageEditorFilesLogic.createInstance(editor).createCompilerFiles();
		if (files == null) {
			return null;
		}
		SourceParserCallback compilerSourceCallback = new SourceParserCallback(files.sourceFile.filePath, lineNumber);
		CompilerSourceParser compilerSourceParser = editor.createCompilerSourceParser();
		CompilerSourceFile compilerSourceFile = compilerSourceParser.createCompilerSourceFile(files.sourceFile.file,
				viewer.getDocument());
		compilerSourceParser.parse(compilerSourceFile, compilerSourceCallback);

		// If there is no instruction in the line yet or the cursor is exactly
		// at the last character of that instruction, propose one.
		if (!compilerSourceCallback.wasInstructionFound()
				|| selectionOffset == lineOffset + compilerSourceCallback.getInstructionEndOffset()) {
			String prefix = getPrefix(viewer, compilerSourceParser.getCompilerSyntax(), selectionOffset, false);
			Region region = new Region(selectionOffset - prefix.length(), prefix.length() + selection.getLength());
			addInstructionProposals(region, prefix, proposalList);
		} else {
			// Otherwise propose to use an identifier as operand.
			String prefix = getPrefix(viewer, compilerSourceParser.getCompilerSyntax(), selectionOffset, true);
			Region region = new Region(selectionOffset - prefix.length(), prefix.length() + selection.getLength());
			addIdentifierProposals(region, prefix, compilerSourceFile, proposalList);
		}

		// If there is no proposal entry, return null instead of an empty array.
		int size = proposalList.size();
		if (proposalList.size() == 0) {
			return null;
		}

		return proposalList.toArray(new ICompletionProposal[size]);
	}

	/**
	 * Gets the prefix of the document starting at a given offset to the start of
	 * the document until a space or control character is found.
	 * 
	 * @param viewer          The viewer, not <code>null</code>.
	 * @param compilerSyntax  The compiler syntax, not <code>null</code>.
	 * @param offset          The offset, a non-negative integer.
	 * @param onlyIdentifiers <code>true</code> if only identifier characters shall
	 *                        be considered as part of the prefix.
	 * 
	 * @return The prefix, may be empty, not <code>null</code>.
	 */
	private String getPrefix(ITextViewer viewer, CompilerSyntax compilerSyntax, int offset, boolean onlyIdentifiers) {
		if (viewer == null) {
			throw new IllegalArgumentException("Parameter 'viewer' must not be null.");
		}
		if (compilerSyntax == null) {
			throw new IllegalArgumentException("Parameter 'compilerSyntax' must not be null.");
		}
		int i = offset;
		IDocument document = viewer.getDocument();

		int l = document.getLength();
		if (i > l) {
			return "";
		}

		try {
			while (i > 0) {
				char ch = document.getChar(i - 1);

				if (onlyIdentifiers) {
					if (!compilerSyntax.isIdentifierCharacter(ch)) {
						break;
					}
				} else {
					if (Character.isWhitespace(ch)) {
						break;
					}
				}

				i--;
			}

			return document.get(i, offset - i);
		} catch (BadLocationException ex) {
			throw new RuntimeException(ex);
		}
	}

	private void addInstructionProposals(Region region, String prefix, List<ICompletionProposal> proposalList) {
		if (region == null) {
			throw new IllegalArgumentException("Parameter 'region' must not be null.");
		}
		if (prefix == null) {
			throw new IllegalArgumentException("Parameter 'prefix' must not be null.");
		}
		if (proposalList == null) {
			throw new IllegalArgumentException("Parameter 'proposalList' must not be null.");
		}
		LanguagePreferences languagePreferences = editor.getLanguagePreferences();

		int offset = region.getOffset();
		boolean lowerCase;

		// Prefix is empty or prefix does not end with a letter but for
		// example "."
		if (StringUtility.isEmpty(prefix) || !Character.isLetter(prefix.charAt(prefix.length() - 1))) {
			String defaultCase;
			defaultCase = languagePreferences.getEditorContentAssistProcessorDefaultCase();
			lowerCase = LanguageContentAssistProcessorDefaultCase.LOWER_CASE.equals(defaultCase);
		} else {
			char lastchar = prefix.charAt(prefix.length() - 1);
			lowerCase = ((lastchar < 'a') || (lastchar > 'z')) ? false : true;
		}

		CompilerSourceParser compilerSourceParser = editor.createCompilerSourceParser();
		InstructionSet instructionSet = compilerSourceParser.getInstructionSet();

		boolean caseSenstive = instructionSet.areInstructionsCaseSensitive();
		if (!caseSenstive) {
			prefix = prefix.toUpperCase();
		}

		List<Instruction> instructions = instructionSet.getInstructions();
		for (int i = 0; i < instructions.size(); i++) {
			Instruction instruction = instructions.get(i);

			String name = null;
			if (caseSenstive) {
				if (instruction.getName().indexOf(prefix) == 0) {
					name = instruction.getName();
				}
			} else {
				if (instruction.getUpperCaseName().indexOf(prefix) == 0) {

					name = lowerCase ? instruction.getLowerCaseName() : instruction.getUpperCaseName();
				}
			}

			if (name != null) {
				Image image;

				if (instruction instanceof Directive) {
					image = directiveImage;
				} else {
					Opcode opcode = (Opcode) instruction;
					switch (opcode.getType()) {
					case InstructionType.LEGAL_OPCODE:
						image = legalOpcodeImage;
						break;
					case InstructionType.ILLEGAL_OPCODE:
						image = illegalOpcodeImage;

						break;
					case InstructionType.PSEUDO_OPCODE:
						image = pseudoOpcodeImage;
						break;
					default:
						throw new IllegalStateException("Unknown opcode type " + opcode.getType() + ".");
					}
				}

				String separator = " - ";
				String displayString = name + separator + instruction.getTitle();
				StyledString styledDisplayString = new StyledString();
				styledDisplayString.append(name);
				styledDisplayString.append(separator);
				int start = styledDisplayString.length();
				styledDisplayString.append(instruction.getStyledTitle());
				styledDisplayString.setStyle(0, name.length(), instructionStyler);
				int[] offsets = instruction.getStyledTitleOffsets();

				for (int j = 0; j < offsets.length; j++) {
					styledDisplayString.setStyle(start + offsets[j], 1, highlightStyler);
				}

				// Adapt proposal.
				String proposal = instruction.getProposal();
				proposal = lowerCase ? proposal.toLowerCase() : proposal;
				int proposalIndex;
				int newCursorOffset;
				// Must be positive.
				proposalIndex = proposal.indexOf('_');
				// Remove cursor positioning.
				proposal = proposal.replace("_", "");
				// Apply leading tabulator.
				proposal = proposal.replace("\n", "\n\t");
				newCursorOffset = offset + proposalIndex;

				proposalList.add(new LanguageInstructionCompletionProposal(proposal, offset, region.getLength(),
						newCursorOffset, image, displayString, styledDisplayString, null));
			}
		}
	}

	// TODO Handle prefixes which contain "." or end with it.
	// TODO Handle identifier case sensitivity correctly
	private void addIdentifierProposals(Region region, String prefix, CompilerSourceFile compilerSourceFile,
			List<ICompletionProposal> proposalList) {
		if (region == null) {
			throw new IllegalArgumentException("Parameter 'region' must not be null.");
		}
		if (prefix == null) {
			throw new IllegalArgumentException("Parameter 'prefix' must not be null.");
		}
		if (compilerSourceFile == null) {
			throw new IllegalArgumentException("Parameter 'compilerSourceFile' must not be null.");
		}
		if (proposalList == null) {
			throw new IllegalArgumentException("Parameter 'proposalList' must not be null.");
		}

		CompilerSourceParserTreeObjectLabelProvider imageProvider = new CompilerSourceParserTreeObjectLabelProvider();
		IStyledLabelProvider styledStringProvider = imageProvider.getStyledStringProvider();
		int regionOffset = region.getOffset();
		int regionLength = region.getLength();
		String lowerCasePrefix = prefix.toLowerCase();

		// Find last separator as basis for the prefix.
		char identifierSeparatorCharacter = editor.getCompilerDefinition().getSyntax()
				.getIdentifierSeparatorCharacter();
		if (identifierSeparatorCharacter != CompilerSyntax.NO_CHARACTER) {
			int index = lowerCasePrefix.lastIndexOf(identifierSeparatorCharacter);
			if (index >= 0) {
				regionOffset += index + 1;
				regionLength -= index + 1;
				lowerCasePrefix = lowerCasePrefix.substring(index + 1);
			}
		}
		List<CompilerSourceParserTreeObject> identifiers = compilerSourceFile.getIdentifiers();
		String separator = " - ";
		for (int i = 0; i < identifiers.size(); i++) {
			CompilerSourceParserTreeObject element = identifiers.get(i);
			String lowerCaseName = element.getName().toLowerCase();
			if (lowerCaseName.indexOf(lowerCasePrefix) == 0) {
				String proposal = element.getName();
				Image image = imageProvider.getImage(element);
				String displayName;
				String description;
				String displayString;
				displayName = element.getDisplayName();
				description = element.getDescription();
				if (StringUtility.isSpecified(description)) {
					displayString = displayName + separator + description;
				} else {
					displayString = displayName;

				}
				StyledString styledDisplayString = styledStringProvider.getStyledText(element);

				int newCursorOffset = regionOffset + proposal.length();

				proposalList.add(new LanguageInstructionCompletionProposal(proposal, regionOffset, regionLength,
						newCursorOffset, image, displayString, styledDisplayString, null));
			}
		}

	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public IContextInformation[] computeContextInformation(ITextViewer viewer, int offset) {
		return null;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public char[] getCompletionProposalAutoActivationCharacters() {
		CompilerSyntax compilerSyntax = editor.getCompilerDefinition().getSyntax();
		char[] result = compilerSyntax.getCompletionProposalAutoActivationCharacters();
		if (result.length == 0) {
			result = null;
		}
		return result;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public char[] getContextInformationAutoActivationCharacters() {
		return null;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public String getErrorMessage() {
		return null;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public IContextInformationValidator getContextInformationValidator() {
		return null;
	}
}
