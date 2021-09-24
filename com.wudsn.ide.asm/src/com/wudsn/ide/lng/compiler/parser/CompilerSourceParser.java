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
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;

import com.wudsn.ide.base.BasePlugin;
import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.AssemblerProperties;
import com.wudsn.ide.lng.compiler.Compiler;
import com.wudsn.ide.lng.compiler.syntax.CompilerSyntax;
import com.wudsn.ide.lng.compiler.syntax.Instruction;
import com.wudsn.ide.lng.compiler.syntax.InstructionSet;
import com.wudsn.ide.lng.compiler.syntax.InstructionType;

/**
 * Source parser for creating {@link CompilerSourceParserTreeObject} instances.
 * The performance is so good, that no caching for the results of source include
 * parsing is required.
 * 
 * @author Peter Dell
 * 
 */
public abstract class CompilerSourceParser {

	// The sections of a single line
	private static final class LineSection {
		public static final int NONE = 0;
		public static final int SYMBOL = 1;
		public static final int INSTRUCTION = 2;
		public static final int OPERAND = 3;
	}

	// The compiler syntax and instruction set.
	private CompilerSyntax compilerSyntax;
	private InstructionSet instructionSet;

	// Fields set once for parsing a file.
	private CompilerSourceFile compilerSourceFile;

	// Fields modified during parsing.
	private CompilerSourceParserTreeObject section;

	// Fields modified per line. Preserved to and restored from local variables
	// during recursive parsing of SOURCE_INCLUDE_DIRECTIVE instructions.
	private CompilerSourceParserTreeObject child;
	private CompilerSourceParserTreeObject labelChild;
	private boolean blockStarting;
	private boolean blockEnding;

	// For debugging.
	private boolean logEnabled = false;

	/**
	 * Extract all {@link AssemblerProperties} properties from a document.
	 * 
	 * @param document The document, not <code>null</code>.
	 * @return The properties, may be empty, not <code>null</code>.
	 */
	public static AssemblerProperties getDocumentProperties(IDocument document) {
		if (document == null) {
			throw new IllegalArgumentException("Parameter 'document' must not be null.");
		}
		String content = document.get();
		AssemblerProperties properties = new AssemblerProperties();

		int index1 = content.indexOf(AssemblerProperties.PREFIX);
		while (index1 >= 0) {

			int indexEqualSign = content.indexOf('=', index1);
			int indexNewLine = content.indexOf('\n', index1);
			if (indexNewLine < 0) {
				indexNewLine = content.indexOf('\r', index1);
			}
			if (indexNewLine < 0) {
				indexNewLine = content.length();
			}

			if (indexEqualSign >= 0 && indexEqualSign < indexNewLine) {
				String key = content.substring(index1, indexEqualSign).trim();
				String value = content.substring(indexEqualSign + 1, indexNewLine).trim();
				int lineNumber;
				try {
					lineNumber = document.getLineOfOffset(index1) + 1;
				} catch (BadLocationException ex) {
					lineNumber = 0;
				}
				properties.put(key, value, lineNumber);
			}
			index1 = content.indexOf(AssemblerProperties.PREFIX, indexNewLine);
		}
		return properties;
	}

	/**
	 * Creation is protected.
	 */
	protected CompilerSourceParser() {

	}

	/**
	 * Gets the compiler syntax for this parser.
	 * 
	 * @return The compiler syntax, not <code>null</code>.
	 */
	public final CompilerSyntax getCompilerSyntax() {
		if (compilerSyntax == null) {
			throw new IllegalStateException("Field 'compilerSyntax' must not be null.");
		}
		return compilerSyntax;
	}

	/**
	 * Gets the instruction for the currently active Target.
	 * 
	 * @return The instruction set, not <code>null</code>.
	 * 
	 * @since 1.6.1
	 */
	public final InstructionSet getInstructionSet() {
		if (instructionSet == null) {
			throw new IllegalStateException("Field 'instructionSet' must not be null.");
		}
		return instructionSet;
	}

	/**
	 * Logs a message to the error log in case logging is enabled.
	 * 
	 * @param message    The message with place holders, may be empty, not
	 *                   <code>null</code>.
	 * @param parameters The parameters for the place holders, may be empty or
	 *                   <code>null</code>.
	 */
	private void log(String message, Object... parameters) {
		if (logEnabled) {
			BasePlugin.getInstance().log(message, parameters);
		}

	}

	/**
	 * Called by {@link Compiler} to link the parser to the compile syntax.
	 * 
	 * @param instructionSet The instruction set, not <code>null</code>.
	 */
	public final void init(InstructionSet instructionSet) {
		if (instructionSet == null) {
			throw new IllegalArgumentException("Parameter 'instructionSet' must not be null.");
		}
		this.instructionSet = instructionSet;
		this.compilerSyntax = instructionSet.getCompilerSyntax();

	}

	/**
	 * Detects a file references in the given source line. This method is stateless.
	 * 
	 * @param line    The source line, may be empty, not <code>null</code>.
	 * @param include The modifiable include statement description, not
	 *                <code>null</code>.
	 */
	public final void detectFileReference(String line, CompilerSourceParserFileReference include) {
		if (line == null) {
			throw new IllegalArgumentException("Parameter 'line' must not be null.");
		}
		if (include == null) {
			throw new IllegalArgumentException("Parameter 'include' must not be null.");
		}

		boolean caseSenstive = instructionSet.areInstructionsCaseSensitive();
		if (!caseSenstive) {
			line = line.toUpperCase();
		}

		// Find next (possible) quote.
		int quoteOffset = -1;
		Iterator<String> i = compilerSyntax.getStringDelimiters().iterator();
		while (i.hasNext() && quoteOffset == -1) {
			String quote = i.next();
			quoteOffset = line.indexOf(quote);
		}

		for (Instruction instruction : instructionSet.getFileReferenceInstructions()) {
			int instructionOffset;
			String instructionName;

			if (caseSenstive) {
				instructionName = instruction.getName();
			} else {
				instructionName = instruction.getUpperCaseName();
			}
			instructionOffset = line.indexOf(instructionName);

			// Key word found before the quote?
			if (quoteOffset > -1 && instructionOffset > -1 && instructionOffset < quoteOffset) {
				if (instruction.getType() == InstructionType.SOURCE_INCLUDE_DIRECTIVE) {
					include.setType(CompilerSourceParserFileReferenceType.SOURCE);
				} else if (instruction.getType() == InstructionType.BINARY_INCLUDE_DIRECTIVE
						|| instruction.getType() == InstructionType.BINARY_OUTPUT_DIRECTIVE) {
					include.setType(CompilerSourceParserFileReferenceType.BINARY);
				} else {
					throw new IllegalStateException("Include instruction '" + instructionName
							+ "' has the unsupported type '" + instruction.getType() + "'");
				}

				include.setDirectiveEndOffset(instructionOffset + instructionName.length());
				return;
			}

		}
	}

	/**
	 * Enhances the file path of an include, for example adds a default extension
	 * for source includes.
	 * 
	 * @param type              The type of include, see
	 *                          {@link CompilerSourceParserFileReferenceType}.
	 * 
	 * @param documentDirectory The current directory which act as the basis for
	 *                          relative paths or not <code>null</code> if it is not
	 *                          known.
	 * 
	 * @param filePath          The possibly relative file path of the include file
	 *                          in OS specific notation, not empty and not
	 *                          <code>null</code>.
	 * @return The enhanced absolute file path of the include file in OS specific
	 *         notation, not empty and not <code>null</code>.
	 */
	public final String getIncludeAbsoluteFilePath(int type, File documentDirectory, String filePath) {

		if (filePath == null) {
			throw new IllegalArgumentException("Parameter 'filePath' must not be null.");
		}

		String relativeCurrentPrefix;
		String relativeParentPrefix;
		File absoluteFile;
		relativeCurrentPrefix = ".";
		relativeParentPrefix = "..";

		// Ensure documentDirectory is a canonical file.
		if (documentDirectory != null) {
			documentDirectory = FileUtility.getCanonicalFile(documentDirectory);
		}

		// Check double or single dots followed by path delimiter first.
		int relativeParentPrefixLength = relativeParentPrefix.length() + 1;
		int relativeCurrentPrefixLength = relativeCurrentPrefix.length() + 1;
		if (filePath.startsWith(relativeParentPrefix) && filePath.length() >= relativeParentPrefixLength) {
			if (documentDirectory == null) {
				return null;
			}
			absoluteFile = new File(documentDirectory.getParentFile(), filePath.substring(relativeParentPrefixLength));

		} else if (filePath.startsWith(relativeCurrentPrefix) && filePath.length() >= relativeCurrentPrefixLength) {
			if (documentDirectory == null) {
				return null;
			}
			absoluteFile = new File(documentDirectory, filePath.substring(relativeCurrentPrefixLength));
		} else {

			// If there is no file separator in the file name, we can assume a
			// relative path based on the current directory.
			File file = new File(filePath);
			if (file.exists()) {
				absoluteFile = file;
			} else {
				absoluteFile = new File(documentDirectory, filePath);
			}
		}

		// Ensure the complete file path is in OS notation.
		absoluteFile = FileUtility.getCanonicalFile(absoluteFile);
		String absoluteFilePath = absoluteFile.getPath();
		if (type == CompilerSourceParserFileReferenceType.SOURCE) {
			int index = absoluteFilePath.lastIndexOf(File.separator);
			if (index < 1) {
				index = 0;
			}
			String fileName = absoluteFilePath.substring(index);
			index = fileName.lastIndexOf('.');
			if (index == -1) {
				String extension = compilerSyntax.getSourceIncludeDefaultExtension();
				if (extension.length() > 0) {
					absoluteFilePath = absoluteFilePath + "." + extension;
				}
			}
		}
		return absoluteFilePath;
	}

	/**
	 * Creates a new, yet empty compiler source file.
	 * 
	 * @param file     The file, not <code>null</code>.
	 * @param document The document, not <code>null</code>.
	 * @return The compiler source file for use in
	 *         {@link #parse(CompilerSourceFile, CompilerSourceParserLineCallback)}
	 *         , not <code>null</code>.
	 * @since 1.6.1
	 */
	public final CompilerSourceFile createCompilerSourceFile(File file, IDocument document) {
		if (compilerSyntax == null) {
			throw new IllegalArgumentException("Parameter 'compilerSyntax' must not be null.");
		}
		if (document == null) {
			throw new IllegalArgumentException("Parameter 'document' must not be null.");
		}
		return new CompilerSourceFile(compilerSyntax, file, document);
	}

	/**
	 * Creates a new compiler source file for persistent file.
	 * 
	 * @param filePath The absolute file path, not empty and not <code>null</code>.
	 * @return The compiler source file, not <code>null</code>.
	 * 
	 * @since 1.6.3
	 */
	private CompilerSourceFile createCompilerSourceFile(String filePath) {
		if (filePath == null) {
			throw new IllegalArgumentException("Parameter 'filePath' must not be null.");
		}
		if (StringUtility.isEmpty(filePath)) {
			throw new IllegalArgumentException("Parameter 'filePath' must not be empty.");
		}
		File newDocumentFile = new File(filePath);
		String newDocumentContent;
		try {
			newDocumentContent = FileUtility.readString(newDocumentFile, FileUtility.MAX_SIZE_UNLIMITED);
		} catch (CoreException ex) {
			newDocumentContent = compilerSyntax.getSingleLineCommentDelimiters().get(0) + " " + ex.getMessage();
		}
		IDocument newDocument = new Document(newDocumentContent);
		CompilerSourceFile newSourceFile = createCompilerSourceFile(newDocumentFile, newDocument);
		return newSourceFile;
	}

	/**
	 * Parse the new input and builds up the parse tree.
	 * 
	 * @param compilerSourceFile               The file to be parsed, not
	 *                                         <code>null</code>.
	 * @param compilerSourceParserLineCallback The callback to be notified when a
	 *                                         certain line is encountered or
	 *                                         <code>null</code>.
	 */
	public final void parse(CompilerSourceFile compilerSourceFile,
			CompilerSourceParserLineCallback compilerSourceParserLineCallback) {
		if (compilerSourceFile == null) {
			throw new IllegalArgumentException("Parameter 'compilerSourceFile' must not be null.");
		}
		Map<String, CompilerSourceFile> parsedFiles;
		parsedFiles = new HashMap<String, CompilerSourceFile>();
		parseInternal(compilerSourceFile, parsedFiles, compilerSourceParserLineCallback);
		return;
	}

	/**
	 * Parse the new input and builds up the parse tree recursively with collecting
	 * already parsed includes.
	 * 
	 * @param compilerSourceFile               The file to be parsed, not
	 *                                         <code>null</code>.
	 * @param parsedFiles                      The list of already parsed file names
	 *                                         to prevent recursion, not
	 *                                         <code>null</code>.
	 * @param compilerSourceParserLineCallback The callback to be notified when a
	 *                                         certain line is encountered or
	 *                                         <code>null</code>.
	 * @return <code>true</code> if the file was parsed now, <code>false</code> if
	 *         the file is already in the list of parsed files.
	 */
	private boolean parseInternal(CompilerSourceFile compilerSourceFile, Map<String, CompilerSourceFile> parsedFiles,
			CompilerSourceParserLineCallback compilerSourceParserLineCallback) {
		if (compilerSourceFile == null) {
			throw new IllegalArgumentException("Parameter 'compilerSourceFile' must not be null.");
		}
		if (parsedFiles == null) {
			throw new IllegalArgumentException("Parameter 'parsedFiles' must not be null.");
		}

		// Ensure every persistent file is parsed only once to prevent infinite
		// recursions caused by circular includes. Non-persistent files cannot
		// cause recursions since they cannot be included yet.
		if (compilerSourceFile.getDocumentFile() != null) {
			String key = compilerSourceFile.getDocumentFile().getPath();
			if (parsedFiles.containsKey(key)) {
				return false;
			}
			parsedFiles.put(key, compilerSourceFile);
		}

		this.compilerSourceFile = compilerSourceFile;

		// To allow folding for introduction comment at the begin of the source,
		// the definition section is always open already, even if it does not
		// contain any definitions.
		child = compilerSourceFile.getDefinitionSection();
		beginSection(0, true);

		IDocument document = compilerSourceFile.getDocument();
		int lines = document.getNumberOfLines();
		int lineOffset, lineLength, startOffset, endOffset;
		String stringLine = "";

		// Prepare line and document offsets.
		lineOffset = 0;
		lineLength = 0;
		startOffset = 0;
		endOffset = 0;

		// Prepare line section buffers.
		StringBuilder symbolBuffer;
		StringBuilder instructionBuffer;
		StringBuilder operandBuffer;
		StringBuilder commentBuffer;
		char blockDefinitonStartCharacter;
		char blockDefinitonEndCharacter;

		symbolBuffer = new StringBuilder(100);
		instructionBuffer = new StringBuilder(100);
		operandBuffer = new StringBuilder(100);
		commentBuffer = new StringBuilder(100);
		blockDefinitonStartCharacter = compilerSyntax.getBlockDefinitionStartCharacter();
		blockDefinitonEndCharacter = compilerSyntax.getBlockDefinitionEndCharacter();

		for (int lineNumber = 0; lineNumber < lines; lineNumber++) {

			/**
			 * Part 1: Parse line segments from line string.
			 */

			int symbolOffset = 0;
			boolean symbolOffsetFound = false;
			symbolBuffer.setLength(0);
			int instructionOffset = 0;
			boolean instructionOffsetFound = false;
			instructionBuffer.setLength(0);
			int operandOffset = 0;
			boolean operandOffsetFound = false;
			operandBuffer.setLength(0);
			int commentOffset = 0;
			boolean commentOffsetFound = false;
			commentBuffer.setLength(0);

			try {
				IRegion region = document.getLineInformation(lineNumber);
				lineOffset = region.getOffset();
				lineLength = region.getLength();
				stringLine = document.get(lineOffset, lineLength);

				int pos = 0;
				char lastChar = 0;
				int lineSection = LineSection.NONE;
				while (pos < lineLength) {
					char ch = stringLine.charAt(pos);
					boolean whiteSpace = Character.isWhitespace(ch);
					// Find the next word.
					if (pos == 0 || (!whiteSpace && Character.isWhitespace(lastChar))) {

						// Does the current section allow instructions?
						if (CompilerSourceParserTreeObjectType.areInstructionsAllowed(section.getType())) {
							if (lineSection == LineSection.NONE) {
								lineSection = LineSection.SYMBOL;
							} else if (lineSection == LineSection.SYMBOL) {
								lineSection = LineSection.INSTRUCTION;
								if (symbolBuffer.length() > 0) {
									String possibleInstruction = symbolBuffer.toString().toUpperCase();
									if (isInstruction(possibleInstruction)) {

										instructionOffset = symbolOffset;
										instructionOffsetFound = true;
										instructionBuffer.append(symbolBuffer);
										symbolOffset = 0;
										symbolBuffer.setLength(0);
										lineSection = LineSection.OPERAND;
									}
								}
							} else if (lineSection == LineSection.INSTRUCTION) {
								lineSection = LineSection.OPERAND;
							}
						} else {
							// No instructions allowed.
							if (!symbolOffsetFound) {
								if (!whiteSpace && lineSection == LineSection.NONE) {
									lineSection = LineSection.SYMBOL;
								}
							} else {
								lineSection = LineSection.OPERAND;
							}
						}

					}
					String type = document.getPartition(lineOffset + pos).getType();
					if (type.equals(IDocument.DEFAULT_CONTENT_TYPE)) {
						if (lineSection == LineSection.SYMBOL) {

							// TODO: Does not work with kernel equates
							// if (symbolBuffer.length() == 0 &&
							// compilerSyntax.isIdentifierStartCharacter(ch)
							// || symbolBuffer.length() > 0 &&
							// compilerSyntax.isIdentifierPartCharacter(ch))
							if (compilerSyntax.isIdentifierCharacter(ch)) {
								if (!symbolOffsetFound) {
									symbolOffsetFound = true;
									symbolOffset = pos;
								}
								symbolBuffer.append(ch);

							}
						} else if (lineSection == LineSection.INSTRUCTION) {
							if (!whiteSpace) {
								if (!instructionOffsetFound) {
									instructionOffsetFound = true;
									instructionOffset = pos;
								}
								instructionBuffer.append(ch);
							}
						} else {
							if (!operandOffsetFound) {
								operandOffsetFound = true;
								operandOffset = pos;
							}
							operandBuffer.append(ch);
						}
					} else if (type.equals(CompilerSourcePartitionScanner.PARTITION_COMMENT_SINGLE)) {
						if (!commentOffsetFound) {
							commentOffsetFound = true;
							commentOffset = pos;
						}
						// Keep spaces within comments and convert tabs to
						// spaces.
						if (ch == 0x9) {
							ch = ' ';
						}
						if (ch != 0xa && ch != 0xd) {
							commentBuffer.append(ch);
						}
					} else if (type.equals(CompilerSourcePartitionScanner.PARTITION_STRING)) {
						operandBuffer.append(ch);
					}

					lastChar = ch;
					pos++;
				}

			} catch (BadLocationException ex) {
				throw new RuntimeException(ex);
			}

			/**
			 * Part 2: Post processing of line segments
			 */
			startOffset = lineOffset;
			try {
				endOffset = startOffset + document.getLineLength(lineNumber);
			} catch (BadLocationException ex) {
				throw new RuntimeException(ex);
			}

			// Check if the single symbol in the line is actually an
			// instruction.
			String possibleInstruction = symbolBuffer.toString().toUpperCase();
			if (isInstruction(possibleInstruction)) {

				instructionOffset = symbolOffset;
				instructionBuffer.append(symbolBuffer);
				symbolOffset = 0;
				symbolBuffer.setLength(0);
			}

			String symbol = symbolBuffer.toString();
			String instruction = instructionBuffer.toString();
			if (!instructionSet.areInstructionsCaseSensitive()) {
				instruction = instruction.toUpperCase();
			}

			// Refine operand and detect block start and end.
			String operand = operandBuffer.toString().trim();
			blockStarting = false;
			if (operandOffsetFound) {
				int blockStartOffset = operand.indexOf(blockDefinitonStartCharacter);
				if (blockStartOffset > -1) {
					operand = operand.substring(0, blockStartOffset);
					blockStarting = true;
				}
			}
			blockEnding = false;
			int blockEndOffset = stringLine.indexOf(blockDefinitonEndCharacter);
			if (blockEndOffset > -1) {
				if (!commentOffsetFound || blockEndOffset < commentOffset) {
					blockEnding = true;
				}
			}

			// Refine comment. Strip leading single comment sign.
			String comment = commentBuffer.toString();
			if (comment.length() > 0) {
				for (String singleLineCommentDelimiter : compilerSyntax.getSingleLineCommentDelimiters()) {
					if (comment.startsWith(singleLineCommentDelimiter)) {
						comment = comment.substring(singleLineCommentDelimiter.length());
					}
				}
				comment = comment.trim();
			}

			/**
			 * Part 3: Parse labels or equates, either directly or via delegation.
			 */
			// This is an instance variable modified per line.
			labelChild = null;

			// Depending on the current context parsing is delegated or not.
			switch (section.getType()) {
			case CompilerSourceParserTreeObjectType.ENUM_DEFINITION_SECTION:
				if (symbol.length() > 0) {
					String value = operand.trim();

					if (value.startsWith("=")) {
						value = value.substring(1).trim();
					}
					if (value.length() == 0) {
						value = "(auto)";
					}
					createEquateDefinitionChild(startOffset, startOffset + symbolOffset, symbol, value, comment);
				}
				break;
			case CompilerSourceParserTreeObjectType.STRUCTURE_DEFINITION_SECTION:
				if (symbol.length() > 0) {
					createLabelDefinitionChild(startOffset, startOffset + symbolOffset, symbol, comment);
				}
				break;
			default:
				parseLine(startOffset, symbol, symbolOffset, instruction, instructionOffset, operand, comment);
				break;
			}

			/**
			 * Part 4: Instruction based parsing
			 */
			int positionStartOffset = startOffset + instructionOffset;
			parseInstruction(startOffset, endOffset, positionStartOffset, symbol, instruction, operand, comment,
					parsedFiles, compilerSourceParserLineCallback);
			// Label not yet consumed by instruction, so it is a single label.
			if (labelChild != null) {
				section.addChild(labelChild);
			}

			/**
			 * Part 6: Handle generic block starts and ends.
			 */
			if (blockStarting && child == null) {
				// Block started but not yet converted into a child like a macro
				// or procedure.
				beginFolding(startOffset);
			}
			if (blockEnding) {
				// Arbitrary block end, can be section or folding.
				if (compilerSourceFile.isFoldingForSection()) {
					endSection(startOffset + blockEndOffset);
				} else {
					endFolding(startOffset + blockEndOffset);
				}
			}

			/**
			 * Part 7: Callback for dedicated source file lines.
			 */
			// Was the current file and line relevant for the callback?
			if (compilerSourceParserLineCallback != null
					&& compilerSourceParserLineCallback.getSourceFilePath()
							.equals(compilerSourceFile.getDocumentFile().getPath())
					&& lineNumber == compilerSourceParserLineCallback.getLineNumber()) {
				compilerSourceParserLineCallback.processLine(this, compilerSourceFile, lineNumber, startOffset,
						symbolOffset, isInstruction(instruction), instructionOffset, instruction, operandOffset,
						section);
			}
		}

		// End last section.
		endSection(document.getLength() > 0 ? document.getLength() - 1 : 0);

		// End incomplete sections.
		compilerSourceFile.endAllSections();

		// End incomplete sections.
		compilerSourceFile.endAllFoldings();

		return true;
	}

	private boolean isInstruction(String instructionName) {
		if (instructionName == null) {
			throw new IllegalArgumentException("Parameter 'instructionName' must not be null.");
		}
		boolean result;
		result = instructionSet.getInstruction(instructionName) != null;
		return result;
	}

	protected void parseLine(int startOffset, String symbol, int symbolOffset, String instruction,
			int instructionOffset, String operand, String comment) {
		return;
	}

	protected final void createEquateDefinitionChild(int startOffset, int positionStartOffset, String symbol,
			String operand, String comment) {
		ensureDefinitionSection(startOffset, positionStartOffset);
		createChild(positionStartOffset, CompilerSourceParserTreeObjectType.EQUATE_DEFINITION, symbol,
				symbol + " = " + operand, comment);
		section.addChild(child);

	}

	protected final void createLabelDefinitionChild(int startOffset, int positionStartOffset, String symbol,
			String comment) {
		createChild(positionStartOffset, CompilerSourceParserTreeObjectType.LABEL_DEFINITION, symbol, symbol, comment);
		// Remember the label child. It will be added only if the label is not
		// consumed by some other instruction.
		labelChild = child;
	}

	protected final void beginImplementationSection(int startOffset, int positionStartOffset, String operand,
			String comment) {

		if (section.getParent() != null) {
			return;
		}
		int endOffset = startOffset - 1;
		if (endOffset < 0) {
			endOffset = 0;
		}
		endSection(endOffset);

		// Folding for an implementation section should only bebe active if
		// there is�a name section in the code.
		boolean withFolding = (StringUtility.isSpecified(operand));
		if (StringUtility.isEmpty(operand)) {
			operand = "Implementation Section";
		}

		createChild(positionStartOffset, CompilerSourceParserTreeObjectType.IMPLEMENTATION_SECTION, operand, operand,
				comment);

		// This will always be a top level section.
		beginSection(startOffset, withFolding);
		compilerSourceFile.getImplementationSections().add(section);
		labelChild = null;
	}

	/**
	 * Parse the instruction in a single line.
	 * 
	 * @param startOffset                      The start offset of the line.
	 * @param endOffset                        The end offset of the line, including
	 *                                         its last character and the line
	 *                                         delimiter is available.
	 * @param positionStartOffset              The start offset for positioning the
	 *                                         cursor.
	 * @param symbol                           The symbol name, may be empty, not
	 *                                         <code>null</code>.
	 * @param instructionName                  The instruction name, may be empty,
	 *                                         not <code>null</code>.
	 * @param operand                          The operand, may be empty, not
	 *                                         <code>null</code>.
	 * @param comment                          The comment, may be empty, not
	 *                                         <code>null</code>.
	 * @param parsedFiles                      The parsed files, not
	 *                                         <code>null</code>.
	 * @param compilerSourceParserLineCallback The callback to be notified when a
	 *                                         certain line is encountered or
	 *                                         <code>null</code>.
	 */
	private void parseInstruction(int startOffset, int endOffset, int positionStartOffset, String symbol,
			String instructionName, String operand, String comment, Map<String, CompilerSourceFile> parsedFiles,
			CompilerSourceParserLineCallback compilerSourceParserLineCallback) {

		if (StringUtility.isEmpty(instructionName)) {
			return;
		}
		Instruction instruction = instructionSet.getInstruction(instructionName);

		if (instruction == null) {
			return;
		}

		if (logEnabled) {
			log("parseInstruction: startOffset={0} endOffset={1} positionStartOffset={2}, symbol={3} instructionName={4} symbol={5} instructionType={6} labelChild={7}",
					Integer.toString(startOffset), Integer.toString(endOffset), Integer.toString(positionStartOffset),
					symbol, instructionName, operand, Integer.toString(instruction.getType()), labelChild);
		}

		String symbolOrOperand;
		String symbolOrOperandFirstWord;
		symbolOrOperand = symbol;
		if (StringUtility.isEmpty(symbolOrOperand)) {
			symbolOrOperand = operand;
		}
		symbolOrOperandFirstWord = symbolOrOperand;
		int i = 0;
		for (; i < symbolOrOperandFirstWord.length(); i++) {
			if (Character.isWhitespace(symbolOrOperandFirstWord.charAt(i))) {
				break;
			}
		}
		symbolOrOperandFirstWord = symbolOrOperandFirstWord.substring(0, i);

		switch (instruction.getType()) {
		case InstructionType.BEGIN_IMPLEMENTATION_SECTION_DIRECTIVE:
			beginImplementationSection(startOffset, positionStartOffset, operand, comment);
			break;
		case InstructionType.DIRECTIVE:
			if (blockStarting) {
				beginFolding(startOffset);
			}
			break;
		case InstructionType.BEGIN_FOLDING_BLOCK_DIRECTIVE:
			beginFolding(startOffset);
			break;
		case InstructionType.END_FOLDING_BLOCK_DIRECTIVE:
			endFolding(endOffset);
			break;
		case InstructionType.END_SECTION_DIRECTIVE:
			endSection(endOffset);
			break;

		case InstructionType.BEGIN_ENUM_DEFINITION_SECTION_DIRECTIVE:
			ensureDefinitionSection(startOffset, positionStartOffset);
			createChild(positionStartOffset, CompilerSourceParserTreeObjectType.ENUM_DEFINITION_SECTION,
					symbolOrOperandFirstWord, symbolOrOperand, comment);
			beginSection(startOffset, true);
			break;

		case InstructionType.BEGIN_STRUCTURE_DEFINITION_SECTION_DIRECTIVE:
			ensureDefinitionSection(startOffset, positionStartOffset);
			createChild(positionStartOffset, CompilerSourceParserTreeObjectType.STRUCTURE_DEFINITION_SECTION,
					symbolOrOperandFirstWord, symbolOrOperand, comment);
			beginSection(startOffset, true);
			break;

		case InstructionType.BEGIN_LOCAL_SECTION_DIRECTIVE:
			ensureImplementationSection(startOffset, positionStartOffset);
			createChild(positionStartOffset, CompilerSourceParserTreeObjectType.LOCAL_SECTION, symbolOrOperandFirstWord,
					symbolOrOperand, comment);
			beginSection(startOffset, true);

			break;
		case InstructionType.BEGIN_MACRO_DEFINITION_SECTION_DIRECTIVE:
			ensureDefinitionSection(startOffset, positionStartOffset);
			createChild(positionStartOffset, CompilerSourceParserTreeObjectType.MACRO_DEFINITION_SECTION,
					symbolOrOperandFirstWord, symbolOrOperand, comment);
			beginSection(startOffset, true);
			break;
		case InstructionType.BEGIN_PROCEDURE_DEFINITION_SECTION_DIRECTIVE:
			ensureImplementationSection(startOffset, positionStartOffset);
			createChild(positionStartOffset, CompilerSourceParserTreeObjectType.PROCEDURE_DEFINITION_SECTION,
					symbolOrOperandFirstWord, symbolOrOperand, comment);
			beginSection(startOffset, true);
			break;
		case InstructionType.BEGIN_PAGES_SECTION_DIRECTIVE:
			ensureImplementationSection(startOffset, positionStartOffset);
			createChild(positionStartOffset, CompilerSourceParserTreeObjectType.PAGES_SECTION, "", symbolOrOperand,
					comment);
			beginSection(startOffset, true);
			break;
		case InstructionType.BEGIN_REPEAT_SECTION_DIRECTIVE:
			createChild(positionStartOffset, CompilerSourceParserTreeObjectType.REPEAT_SECTION, "", symbolOrOperand,
					comment);
			beginSection(startOffset, true);
			break;

		case InstructionType.SOURCE_INCLUDE_DIRECTIVE:
			// Remove leading and trailing string delimiters.
			String filePath = operand;
			for (String stringDelimiter : compilerSyntax.getStringDelimiters()) {
				if (filePath.startsWith(stringDelimiter)) {
					filePath = filePath.substring(stringDelimiter.length());
					break;
				}
			}
			for (String stringDelimiter : compilerSyntax.getStringDelimiters()) {
				if (filePath.endsWith(stringDelimiter)) {
					filePath = filePath.substring(0, filePath.length() - stringDelimiter.length());
					break;
				}
			}
			filePath = getIncludeAbsoluteFilePath(CompilerSourceParserFileReferenceType.SOURCE,
					compilerSourceFile.getDocumentDirectory(), filePath);

			createChild(positionStartOffset, CompilerSourceParserTreeObjectType.SOURCE_INCLUDE, "", operand, comment);

			// If there is no file, the include is a normal child.
			if (filePath == null) {
				if (labelChild == null) {
					section.addChild(child);
				} else {
					labelChild.addChild(child);
				}
			} else {
				// If there is a file, the include is a section.
				beginSection(startOffset, true);

				// Preserve current line specific state into local variables.
				CompilerSourceFile oldSourceFile = compilerSourceFile;
				CompilerSourceParserTreeObject oldSection = section;
				CompilerSourceParserTreeObject oldChild = child;
				CompilerSourceParserTreeObject oldLabelChild = labelChild;
				boolean oldBlockStarting = blockStarting;
				boolean oldBlockEnding = blockEnding;

				CompilerSourceFile newSourceFile = createCompilerSourceFile(filePath);

				// This might be moved to the createCompilerSourceFile() method.
				CompilerSourcePartitionScanner partitionScanner = new CompilerSourcePartitionScanner(compilerSyntax);
				partitionScanner.createDocumentPartitioner(newSourceFile.getDocument());
				boolean parsed = parseInternal(newSourceFile, parsedFiles, compilerSourceParserLineCallback);

				if (parsed) {
					// Restore old line specific state from local variables.
					section = oldSection;
					compilerSourceFile = oldSourceFile;
					child = oldChild;
					labelChild = oldLabelChild;
					blockStarting = oldBlockStarting;
					blockEnding = oldBlockEnding;

					section.setIncludedCompilerSourceFile(newSourceFile);
					List<CompilerSourceParserTreeObject> newSourceFileSections = newSourceFile.getSections();
					if (newSourceFileSections.size() == 1 && newSourceFileSections.get(0)
							.getType() == CompilerSourceParserTreeObjectType.SOURCE_INCLUDE) {
						newSourceFileSections = newSourceFileSections.get(0).getChildren();
					}
					for (CompilerSourceParserTreeObject newChild : newSourceFileSections) {
						section.addChild(newChild);
					}
				} else {
					LanguagePlugin.getInstance().log("Include file '{0}' was already parsed. Stopping recursion.",
							new Object[] { newSourceFile.getDocumentFile().getPath() });
				}
				endSection(endOffset);
			}
			break;
		case InstructionType.BINARY_INCLUDE_DIRECTIVE:
			ensureImplementationSection(startOffset, positionStartOffset);
			createChild(positionStartOffset, CompilerSourceParserTreeObjectType.BINARY_INCLUDE, "", operand, comment);
			if (labelChild == null) {
				section.addChild(child);
			} else {
				labelChild.addChild(child);
			}

			break;
		case InstructionType.BINARY_OUTPUT_DIRECTIVE:

			createChild(positionStartOffset, CompilerSourceParserTreeObjectType.BINARY_OUTPUT, "", operand, comment);
			if (labelChild == null) {
				section.addChild(child);
			} else {
				labelChild.addChild(child);
			}

			break;
		}

	}

	private void ensureDefinitionSection(int startOffset, int positionStartOffset) {
		// To allow folding for introduction comment at the begin of the source,
		// the definition section is always open already.
	}

	private void ensureImplementationSection(int startOffset, int positionStartOffset) {
		if (section.getType() == CompilerSourceParserTreeObjectType.DEFINITION_SECTION) {
			beginImplementationSection(startOffset, positionStartOffset, "", "");
		}
	}

	private void createChild(int startOffset, int type, String name, String displayName, String comment) {
		if (startOffset < 0) {
			throw new IllegalArgumentException(
					"Parameter 'startOffset' must not be negative. Specified value is " + startOffset + ".");
		}
		if (name == null) {
			throw new IllegalArgumentException("Parameter 'name' must not be null.");
		}
		if (displayName == null) {
			throw new IllegalArgumentException("Parameter 'displayName' must not be null.");
		}
		if (comment == null) {
			throw new IllegalArgumentException("Parameter 'comment' must not be null.");
		}

		child = new CompilerSourceParserTreeObject(compilerSourceFile, startOffset, type, name, displayName, comment);
	}

	/**
	 * Starts a new active section.
	 * 
	 * @param startOffset The start offset, a non-negative integer.
	 * @param withFolding <code>true</code> if the section is also a folding
	 *                    section, <code>false</code> otherwise.
	 */
	private void beginSection(int startOffset, boolean withFolding) {
		if (startOffset < 0) {
			throw new IllegalArgumentException(
					"Parameter 'startOffset' must not be negative. Specified value is " + startOffset + ".");
		}
		if (child == null) {
			throw new IllegalStateException("Field 'child' must not be null.");
		}
		section = child;
		compilerSourceFile.beginSection(startOffset, section, withFolding);
		labelChild = null;
		blockStarting = false;
	}

	/**
	 * Ends the currently active section.
	 * 
	 * @param endOffset The end offset, a non-negative integer.
	 */
	private void endSection(int endOffset) {
		if (section == null) {
			throw new IllegalStateException("Variable 'section' must not be null.");
		}
		if (endOffset < 0) {
			throw new IllegalArgumentException(
					"Parameter 'endOffset' must not be negative. Specified value is " + endOffset + ".");
		}
		CompilerSourceParserTreeObject section;
		section = compilerSourceFile.endSection(endOffset);
		if (section != null) {
			this.section = section;
		}
		labelChild = null;
		blockEnding = false;
	}

	/**
	 * Starts a new active folding which does not belong to a section.
	 * 
	 * @param startOffset The start offset, a non-negative integer.
	 */
	private void beginFolding(int startOffset) {
		compilerSourceFile.beginFolding(startOffset, false);
		blockStarting = false;
	}

	/**
	 * Ends the currently active folding which does not belong to a section.
	 * 
	 * @param endOffset The end offset, a non-negative integer. This must be the
	 *                  actual offset of the last character in the line, including
	 *                  the line end delimiter, if present.
	 */
	private void endFolding(int endOffset) {
		compilerSourceFile.endFolding(endOffset);
		blockEnding = false;
	}
}
