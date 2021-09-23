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

package com.wudsn.ide.lng.compiler.syntax;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.StringTokenizer;
import java.util.TreeMap;
import java.util.TreeSet;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;

import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.lng.CPU;
import com.wudsn.ide.lng.compiler.CompilerRegistry;

/**
 * Container for a set of directives, legal, illegal and pseudo opcodes and
 * their properties.
 * 
 * @author Peter Dell
 * @author Daniel Mitte
 * 
 */
public final class CompilerSyntax {

	public static final char NO_CHARACTER = (char) 0;

	private static final class XMLHandler extends DefaultHandler {

		// Completion proposal auto activation characters, possibly empty array
		// of characters.
		String completionProposalAutoActivationCharactersText;

		// Single line delimiters, list of strings separated by spaces.
		String singleLineCommentDelimitersText;

		// Single line delimiters, list of strings separated by spaces.
		String multipleLinesCommentDelimitersText;

		// Single line delimiters, non empty array of characters.
		String stringDelimiterCharactersText;

		// The (possibly empty) string of character pairs which define the begin
		// and end of a named or unnamed (folding) block.
		String blockDefinitionCharactersText;

		// The boolean value indicating if identifiers are case sensitive or
		// not.
		boolean identifiersCaseSensitive;

		// The string containing all allowed identifier start characters.
		String identifierStartCharactersText;

		// The string containing all allowed identifier start characters.
		String identifierPartCharactersText;

		// The string containing the character which separates two parts of a
		// compound identifier or
		// the empty string if compound identifiers are not supported.
		String identifierSeparatorCharacterText;

		// The string containing the character which end a label definition or
		// the empty string if label definitions end at the first white space.
		String labelDefinitionSuffixCharacterText;

		// The string containing the character which start a macro usage or
		// the empty string if macro usages are not prefixed with a character.
		String macroUsagePrefixCharacterText;

		// The boolean value indicating if instructions are case sensitive or
		// not.
		boolean instructionsCaseSensitive;

		// Default file extension to be added if it is missing for source
		// include directives.
		String sourceIncludeDefaultExtension;

		List<Instruction> instructionsList;

		public XMLHandler() {
			instructionsList = new ArrayList<Instruction>();
		}

		@Override
		public void startElement(String uri, String localName, String qName, Attributes attributes)
				throws SAXException {
			if (qName == null) {
				throw new IllegalArgumentException("Parameter 'qName' must not be null.");
			}
			if (attributes == null) {
				throw new IllegalArgumentException("Parameter 'attributes' must not be null.");
			}

			if (qName.equals("instructionset")) {

				// Completion proposal auto activation characters
				completionProposalAutoActivationCharactersText = attributes
						.getValue("completionProposalAutoActivationCharacters");
				if (completionProposalAutoActivationCharactersText == null) {
					throw new SAXException("No completionProposalAutoActivationCharacters specified.");
				}

				// Single lines comments.
				singleLineCommentDelimitersText = attributes.getValue("singleLineCommentDelimiters");
				if (singleLineCommentDelimitersText == null) {
					throw new SAXException("No singleLineCommentDelimiters specified.");
				}
				if (StringUtility.isEmpty(singleLineCommentDelimitersText)) {
					throw new SAXException("Attribute singleLineCommentDelimiterst must not be empty.");
				}

				// Multiple lines comments.
				multipleLinesCommentDelimitersText = attributes.getValue("multipleLinesCommentDelimiters");
				if (multipleLinesCommentDelimitersText == null) {
					throw new SAXException("No multipleLinesCommentDelimiters specified.");
				}

				// Strings.
				stringDelimiterCharactersText = attributes.getValue("stringDelimiterCharacters");
				if (stringDelimiterCharactersText == null) {
					throw new SAXException("No stringDelimiterCharacters specified.");
				}
				if (StringUtility.isEmpty(stringDelimiterCharactersText)) {
					throw new SAXException("Attribute stringDelimiterCharacters must not be empty.");
				}

				// Block definition characters
				blockDefinitionCharactersText = attributes.getValue("blockDefinitionCharacters");
				if (blockDefinitionCharactersText == null) {
					throw new SAXException("No blockDefinitionCharacters specified.");
				}
				if (blockDefinitionCharactersText.length() % 2 != 0) {
					throw new SAXException("Attribute blockDefinitionCharacters must and even number of characters.");
				}

				// Identifiers: Case sensitive.
				String value = attributes.getValue("identifiersCaseSensitive");
				if (value == null) {
					throw new SAXException("No identifiersCaseSensitive specified.");
				}
				if (!value.equals("true") && !value.equals("false")) {
					throw new SAXException("Attribute identifiersCaseSensitive must be \"true\" or \"false\".");
				}
				identifiersCaseSensitive = Boolean.parseBoolean(value);

				// Identifiers: Start characters.
				identifierStartCharactersText = attributes.getValue("identifierStartCharacters");
				if (identifierStartCharactersText == null) {
					throw new SAXException("No identifierStartCharacters specified.");
				}
				if (StringUtility.isEmpty(identifierStartCharactersText)) {
					throw new SAXException("Attribute identifierStartCharacters must not be empty.");
				}

				// Identifiers: Start characters.
				identifierPartCharactersText = attributes.getValue("identifierPartCharacters");
				if (identifierPartCharactersText == null) {
					throw new SAXException("No identifierPartCharacters specified.");
				}
				if (StringUtility.isEmpty(identifierPartCharactersText)) {
					throw new SAXException("Attribute identifierPartCharacters must not be empty.");
				}

				// Identifiers: Separator character.
				identifierSeparatorCharacterText = attributes.getValue("identifierSeparatorCharacter");
				if (identifierSeparatorCharacterText == null) {
					throw new SAXException("No identifierSeparatorCharacter specified.");
				}
				if (identifierSeparatorCharacterText.length() > 1) {
					throw new SAXException(
							"Attribute identifierSeparatorCharacter must not contain more than 1 characters.");
				}

				// Identifiers: Label definition suffix character.
				labelDefinitionSuffixCharacterText = attributes.getValue("labelDefinitionSuffixCharacter");
				if (labelDefinitionSuffixCharacterText == null) {
					throw new SAXException("No labelDefinitionSuffixCharacter specified.");
				}
				if (labelDefinitionSuffixCharacterText.length() > 1) {
					throw new SAXException(
							"Attribute labelDefinitionSuffixCharacter must not contain more than 1 characters.");
				}

				// Identifiers: Macro usage prefix character.
				macroUsagePrefixCharacterText = attributes.getValue("macroUsagePrefixCharacter");
				if (macroUsagePrefixCharacterText == null) {
					throw new SAXException("No macroUsagePrefixCharacter specified.");
				}
				if (macroUsagePrefixCharacterText.length() > 1) {
					throw new SAXException(
							"Attribute macroUsagePrefixCharacter must not contain more than 1 characters.");
				}

				// Instructions case sensitive.
				value = attributes.getValue("instructionsCaseSensitive");
				if (value == null) {
					throw new SAXException("No instructionsCaseSensitive specified.");
				}
				if (!value.equals("true") && !value.equals("false")) {
					throw new SAXException("Attribute instructionsCaseSensitive must be \"true\" or \"false\".");
				}
				instructionsCaseSensitive = Boolean.parseBoolean(value);

				// Source include default extension.
				sourceIncludeDefaultExtension = attributes.getValue("sourceIncludeDefaultExtension");
				if (sourceIncludeDefaultExtension == null) {
					throw new SAXException("No sourceIncludeDefaultExtension specified.");
				}

			} else if (qName.equals("opcodes")) {
				// Nothing to do.
			} else {

				// Begin parsing of instructions.
				String cpusString;
				Set<CPU> cpus;
				String name;
				String title;
				String proposal;
				String typeString;
				int type;

				name = attributes.getValue("name");
				if (name == null) {
					throw new SAXException("No name specified for '" + qName + "'.");
				}

				cpusString = attributes.getValue("cpus");
				if (cpusString == null) {
					throw new SAXException("No CPUs specified for '" + name + "'.");
				}
				cpus = new TreeSet<CPU>();
				StringTokenizer tokenizer = new StringTokenizer(cpusString, ",");
				while (tokenizer.hasMoreTokens()) {
					String token = tokenizer.nextToken();
					boolean found = false;

					// Wild card?
					if (token.endsWith("*")) {
						token = token.substring(0, token.length() - 1);
						for (CPU cpu : CPU.values()) {
							if (cpu.name().startsWith(token) || cpu == CPU.MOS65C02 && token.equals("MOS6502")) {
								cpus.add(cpu);
								found = true;
							}
						}
					} else {
						// Exact match
						for (CPU cpu : CPU.values()) {
							if (cpu.name().equals(token)) {
								cpus.add(cpu);
								found = true;
							}
						}
					}
					if (!found) {
						throw new SAXException("No cpu matches the cpus '" + cpusString + "' for '" + name + "'.");
					}
				}

				title = attributes.getValue("title");
				if (title == null) {
					throw new SAXException("No title specified for '" + name + "'.");
				}

				typeString = attributes.getValue("type");
				if (typeString == null) {
					typeString = "";
				}

				proposal = attributes.getValue("proposal");
				if (qName.equals("constant")) {
					// Constants always have a simple proposal
					proposal = name + "_";
				}
				if (proposal == null) {
					throw new SAXException("No proposal specified for '" + name + "'.");
				}

				// TODO Have constant as own instruction class
				if (qName.equals("constant")) {
					qName = "directive";
					typeString = "DIRECTIVE";
				}

				if (qName.equals("directive")) {

					// Default and default nesting for folding blocks and
					// sections.
					if (typeString.equals("DIRECTIVE")) {
						type = InstructionType.DIRECTIVE;
					} else if (typeString.equals("BEGIN_IMPLEMENTATION_SECTION_DIRECTIVE")) {
						type = InstructionType.BEGIN_IMPLEMENTATION_SECTION_DIRECTIVE;
					} else if (typeString.equals("BEGIN_FOLDING_BLOCK_DIRECTIVE")) {
						type = InstructionType.BEGIN_FOLDING_BLOCK_DIRECTIVE;
					} else if (typeString.equals("END_FOLDING_BLOCK_DIRECTIVE")) {
						type = InstructionType.END_FOLDING_BLOCK_DIRECTIVE;
					} else if (typeString.equals("END_SECTION_DIRECTIVE")) {
						type = InstructionType.END_SECTION_DIRECTIVE;
					}

					// Begin of sections.
					else if (typeString.equals("BEGIN_ENUM_DEFINITION_SECTION_DIRECTIVE")) {
						type = InstructionType.BEGIN_ENUM_DEFINITION_SECTION_DIRECTIVE;
					} else if (typeString.equals("BEGIN_STRUCTURE_DEFINITION_SECTION_DIRECTIVE")) {
						type = InstructionType.BEGIN_STRUCTURE_DEFINITION_SECTION_DIRECTIVE;
					} else if (typeString.equals("BEGIN_LOCAL_SECTION_DIRECTIVE")) {
						type = InstructionType.BEGIN_LOCAL_SECTION_DIRECTIVE;
					} else if (typeString.equals("BEGIN_MACRO_DEFINITION_SECTION_DIRECTIVE")) {
						type = InstructionType.BEGIN_MACRO_DEFINITION_SECTION_DIRECTIVE;
					} else if (typeString.equals("BEGIN_PAGES_SECTION_DIRECTIVE")) {
						type = InstructionType.BEGIN_PAGES_SECTION_DIRECTIVE;
					} else if (typeString.equals("BEGIN_PROCEDURE_DEFINITION_SECTION_DIRECTIVE")) {
						type = InstructionType.BEGIN_PROCEDURE_DEFINITION_SECTION_DIRECTIVE;
					} else if (typeString.equals("BEGIN_REPEAT_SECTION_DIRECTIVE")) {
						type = InstructionType.BEGIN_REPEAT_SECTION_DIRECTIVE;
					}

					// File references.
					else if (typeString.equals("SOURCE_INCLUDE_DIRECTIVE")) {
						type = InstructionType.SOURCE_INCLUDE_DIRECTIVE;
					} else if (typeString.equals("BINARY_INCLUDE_DIRECTIVE")) {
						type = InstructionType.BINARY_INCLUDE_DIRECTIVE;
					} else if (typeString.equals("BINARY_OUTPUT_DIRECTIVE")) {
						type = InstructionType.BINARY_OUTPUT_DIRECTIVE;
					} else if (typeString.equals("")) {
						throw new SAXException("No directive type specified for directive '" + name + "'.");
					} else {
						throw new SAXException(
								"Unknown directive type '" + typeString + "' for directive '" + name + "'.");
					}
					instructionsList.add(new Directive(cpus, type, instructionsCaseSensitive, name, title, proposal));
				} else if (qName.equals("opcode") || qName.equals("illegalopcode") || qName.equals("pseudoopcode")) {

					if (qName.equals("opcode")) {
						type = InstructionType.LEGAL_OPCODE;
					} else if (qName.equals("illegalopcode")) {
						type = InstructionType.ILLEGAL_OPCODE;
					} else if (qName.equals("pseudoopcode")) {
						type = InstructionType.PSEUDO_OPCODE;
					} else {
						throw new SAXException("Unknown qName '" + qName + "'.");
					}

					String flags = attributes.getValue("flags");
					if (flags == null) {
						flags = "@todo flags";
					}
					String modes = attributes.getValue("modes");
					if (modes == null) {
						modes = "todo=$00";
					}

					// Currently only KickAss uses case sensitive instructions
					// and they are lower case. There this logic is applied here
					// instead of having an additional XML attribute to control
					// the lower/upper case setting for opcodes.
					if (instructionsCaseSensitive) {
						name = name.toLowerCase();
						proposal = proposal.toLowerCase();
					}
					instructionsList.add(new Opcode(cpus, type, instructionsCaseSensitive, name, title, proposal,
							cpus.contains(CPU.MOS65816), flags, modes));
				}
			}
		}
	}

	private String compilerId;

	private char[] completionProposalAutoActivationCharacters;

	private List<String> singleLineCommentDelimiters;

	private List<String> multipleLinesCommentDelimiters;

	private List<String> stringDelimiters;

	private String blockDefinitionCharacters;
	private char blockDefinitionStartCharacter;
	private char blockDefinitionEndCharacter;

	private boolean identifiersCaseSensitive;

	private String identifierStartCharacters;
	private boolean identifierStartCharactersArray[];

	private String identifierPartCharacters;
	private boolean identifierPartCharactersArray[];

	private char identifierSeparatorCharacter;

	private char labelDefinitionSuffixCharacter;

	private char macroUsagePrefixCharacter;

	private boolean instructionsCaseSensitive;

	private String sourceIncludeDefaultExtension;

	private List<Instruction> instructionList;
	private Map<CPU, InstructionSet> instructionSets;

	/**
	 * Creates new instance. Called by {@link CompilerRegistry}.
	 * 
	 * @param compilerId The compiler id, not empty and <code>null</code>.
	 */
	public CompilerSyntax(String compilerId) {
		if (compilerId == null) {
			throw new IllegalArgumentException("Parameter 'compilerId' must not be null.");
		}
		if (StringUtility.isEmpty(compilerId)) {
			throw new IllegalArgumentException("Parameter 'compilerId' must not be empty.");
		}
		this.compilerId = compilerId;
	}

	/**
	 * Load XML data.
	 * 
	 * @param compilerClasses The list of compiler classes for which the XML files
	 *                        shall be loaded, not empty and not <code>null</code>.
	 *                        The content of subsequent files will extend the
	 *                        content of previous files.
	 */
	public void loadXMLData(List<Class<?>> compilerClasses) {

		if (compilerClasses == null) {
			throw new IllegalArgumentException("Parameter 'compilerClasses' must not be null.");
		}
		if (compilerClasses.isEmpty()) {
			throw new IllegalArgumentException("Parameter 'compilerClasses' must not be empty.");
		}
		XMLHandler xmlHandler;
		xmlHandler = new XMLHandler();
		for (int i = 0; i < compilerClasses.size(); i++) {
			Class<?> compilerClass = compilerClasses.get(i);
			if (compilerClass == null) {
				throw new IllegalArgumentException("Parameter 'compilerClasses[" + i + "]' must not be null.");
			}

			SAXParser parser;
			try {
				parser = SAXParserFactory.newInstance().newSAXParser();
			} catch (ParserConfigurationException ex) {
				throw new RuntimeException("Cannot create parser for compiler class '" + compilerClass.getName() + "'.",
						ex);
			} catch (SAXException ex) {
				throw new RuntimeException("Cannot create parser for compiler class '" + compilerClass.getName() + "'.",
						ex);
			}

			String syntaxFileName = "/" + compilerClass.getName().replace('.', '/') + ".xml";
			try {

				InputStream inputStream = compilerClass.getResourceAsStream(syntaxFileName);
				parser.parse(inputStream, xmlHandler);
			} catch (SAXParseException ex) {
				throw new RuntimeException("Cannot create parser for file '" + syntaxFileName + "'. Error in line "
						+ ex.getLineNumber() + ", column " + ex.getColumnNumber() + ".", ex);
			} catch (SAXException ex) {
				throw new RuntimeException("Cannot create parser for file '" + syntaxFileName + "'.", ex);
			} catch (IOException ex) {
				throw new RuntimeException("Cannot create parser for file '" + syntaxFileName + "'.", ex);
			}
		}

		// Completion proposal auto activation characters
		completionProposalAutoActivationCharacters = xmlHandler.completionProposalAutoActivationCharactersText
				.toCharArray();

		// Single line comments.
		String delimiterText = xmlHandler.singleLineCommentDelimitersText;
		if (delimiterText == null) {
			throw new IllegalStateException("Attribute 'singleLineCommentDelimiters' is no set.");
		}
		StringTokenizer tokenizer = new StringTokenizer(delimiterText, " ");
		singleLineCommentDelimiters = new ArrayList<String>(tokenizer.countTokens());
		while (tokenizer.hasMoreTokens()) {
			String token = tokenizer.nextToken();
			singleLineCommentDelimiters.add(token);
		}
		singleLineCommentDelimiters = Collections.unmodifiableList(singleLineCommentDelimiters);

		// Multiple lines comments.
		delimiterText = xmlHandler.multipleLinesCommentDelimitersText;
		if (delimiterText == null) {
			throw new IllegalStateException("Attribute 'singleLineCommentDelimiters' is no set.");
		}
		tokenizer = new StringTokenizer(delimiterText, " ");
		int tokenCount = tokenizer.countTokens();
		if ((tokenCount & 1) == 1) {
			throw new IllegalStateException(
					"Attribute 'multipleLinesCommentDelimiters' has an odd number of tokens: '" + delimiterText + "'.");
		}
		multipleLinesCommentDelimiters = new ArrayList<String>(tokenCount);
		while (tokenizer.hasMoreTokens()) {
			multipleLinesCommentDelimiters.add(tokenizer.nextToken());
		}
		multipleLinesCommentDelimiters = Collections.unmodifiableList(multipleLinesCommentDelimiters);

		// Strings.
		delimiterText = xmlHandler.stringDelimiterCharactersText;
		if (delimiterText == null) {
			throw new IllegalStateException("Attribute 'stringDelimiters' is not set.");
		}
		stringDelimiters = new ArrayList<String>(delimiterText.length());
		for (int i = 0; i < delimiterText.length(); i++) {
			stringDelimiters.add(delimiterText.substring(i, i + 1));
		}
		stringDelimiters = Collections.unmodifiableList(stringDelimiters);

		// Block definitions.
		if (xmlHandler.blockDefinitionCharactersText == null) {
			throw new IllegalArgumentException("Attribute 'blockDefinitionCharacters' is not set.");
		}
		blockDefinitionCharacters = xmlHandler.blockDefinitionCharactersText;
		if (blockDefinitionCharacters.length() > 0) {
			if (blockDefinitionCharacters.length() == 2) {
				blockDefinitionStartCharacter = blockDefinitionCharacters.charAt(0);
				blockDefinitionEndCharacter = blockDefinitionCharacters.charAt(1);
			} else {
				throw new IllegalArgumentException("Attribute 'blockDefinitionCharacters' has the value '"
						+ blockDefinitionCharacters + "' and does not have 2 characters.");
			}
		} else {
			blockDefinitionStartCharacter = NO_CHARACTER;
			blockDefinitionEndCharacter = NO_CHARACTER;
		}

		// Identifiers: Case sensitive.
		identifiersCaseSensitive = xmlHandler.identifiersCaseSensitive;

		// Identifiers: Start characters.
		if (xmlHandler.identifierStartCharactersText == null) {
			throw new IllegalArgumentException("Attribute 'identifierStartCharacters' is not set.");
		}
		identifierStartCharacters = xmlHandler.identifierStartCharactersText;
		identifierStartCharactersArray = createBooleanArray(identifierStartCharacters);

		// Identifiers: Start characters.
		if (xmlHandler.identifierPartCharactersText == null) {
			throw new IllegalArgumentException("Attribute 'identifierPartCharacters' is not set.");
		}
		identifierPartCharacters = xmlHandler.identifierPartCharactersText;
		identifierPartCharactersArray = createBooleanArray(identifierPartCharacters);

		// Identifiers: Separator characters.
		if (xmlHandler.identifierSeparatorCharacterText == null) {
			throw new IllegalArgumentException("Attribute 'identifierSeparatorCharacter' is not set.");
		}
		if (xmlHandler.identifierSeparatorCharacterText.length() == 0) {
			identifierSeparatorCharacter = NO_CHARACTER;
		} else {
			identifierSeparatorCharacter = xmlHandler.identifierSeparatorCharacterText.charAt(0);
		}

		// Identifiers: Label definition suffix character.
		if (xmlHandler.labelDefinitionSuffixCharacterText == null) {
			throw new IllegalArgumentException("Attribute 'labelDefinitionSuffixCharacterText' is not set.");
		}
		if (xmlHandler.labelDefinitionSuffixCharacterText.length() == 0) {
			labelDefinitionSuffixCharacter = NO_CHARACTER;
		} else {
			labelDefinitionSuffixCharacter = xmlHandler.labelDefinitionSuffixCharacterText.charAt(0);
		}

		// Identifiers: Macro usage prefix character
		if (xmlHandler.macroUsagePrefixCharacterText == null) {
			throw new IllegalArgumentException("Attribute 'macroUsagePrefixCharacterText' is not set.");
		}
		if (xmlHandler.macroUsagePrefixCharacterText.length() == 0) {
			macroUsagePrefixCharacter = NO_CHARACTER;
		} else {
			macroUsagePrefixCharacter = xmlHandler.macroUsagePrefixCharacterText.charAt(0);
		}

		// Instructions case sensitive.
		instructionsCaseSensitive = xmlHandler.instructionsCaseSensitive;

		// Source include default extension.
		sourceIncludeDefaultExtension = xmlHandler.sourceIncludeDefaultExtension;

		instructionList = Collections.unmodifiableList(xmlHandler.instructionsList);

		// Create instruction set map.
		instructionSets = new TreeMap<CPU, InstructionSet>();
	}

	static boolean[] createBooleanArray(String string) {
		int length = string.length();
		int max = 0;
		for (int i = 0; i < length; i++) {
			char c = string.charAt(i);
			if (c > max) {
				max = c;
			}
		}
		boolean[] result = new boolean[max + 1];

		for (int i = 0; i < length; i++) {
			char c = string.charAt(i);
			result[c] = true;
		}
		return result;
	}

	/**
	 * Gets the completion proposal auto activation characters.
	 * 
	 * @return The array of completion proposal auto activation characters, may be
	 *         empty, not <code>null</code>.
	 */
	public char[] getCompletionProposalAutoActivationCharacters() {
		if (completionProposalAutoActivationCharacters == null) {
			throw new IllegalStateException("Attribute 'completionProposalAutoActivationCharacters' is not set.");
		}
		return completionProposalAutoActivationCharacters;
	}

	/**
	 * Gets the delimiter prefixes for single line comments.
	 * 
	 * @return The unmodifiable list of delimiter prefixes for single line comments,
	 *         not empty and not <code>null</code>.
	 */
	public List<String> getSingleLineCommentDelimiters() {
		if (singleLineCommentDelimiters == null) {
			throw new IllegalStateException("Attribute 'singleLineCommentDelimiters' is not set.");
		}
		return singleLineCommentDelimiters;
	}

	/**
	 * Gets the delimiter prefixes for multiple lines comments.
	 * 
	 * @return The unmodifiable list of delimiter prefixes for single line comments,
	 *         not empty and not <code>null</code>. The list contains an even number
	 *         of entries where two entries constitute the start sequence and the
	 *         end sequence of the multiple lines rules.
	 */
	public List<String> getMultipleLinesCommentDelimiters() {
		if (multipleLinesCommentDelimiters == null) {
			throw new IllegalStateException("Attribute 'multipleLinesCommentDelimiters' is not set.");
		}
		return multipleLinesCommentDelimiters;
	}

	/**
	 * Gets the delimiter characters for strings.
	 * 
	 * @return The unmodifiable list of delimiter characters for strings, not empty
	 *         and not <code>null</code>.
	 */
	public List<String> getStringDelimiters() {
		if (stringDelimiters == null) {
			throw new IllegalStateException("Attribute 'stringDelimiters' is not set.");
		}
		return stringDelimiters;
	}

	/**
	 * Gets the (possibly empty) string of character pairs which define the begin
	 * and end of a named or unnamed (folding) block.
	 * 
	 * @return The string of character pairs which define the begin and end of a
	 *         named or unnamed (folding) block, may be empty, not
	 *         <code>null</code>.
	 * @since 1.6.1
	 */
	public String getBlockDefinitionCharacters() {
		return blockDefinitionCharacters;
	}

	/**
	 * Gets the block definition start character if defined.
	 * 
	 * @return The block definition start character or {@link #NO_CHARACTER}.
	 */
	public char getBlockDefinitionStartCharacter() {
		return blockDefinitionStartCharacter;
	}

	/**
	 * Gets the block definition start character if defined.
	 * 
	 * @return The block definition start character or {@link #NO_CHARACTER}.
	 */
	public char getBlockDefinitionEndCharacter() {
		return blockDefinitionEndCharacter;
	}

	/**
	 * Determines if identifiers are case sensitive.
	 * 
	 * @return <code>true</code> if identifiers are case sensitive,
	 *         <code>false</code> otherwise.
	 * 
	 * @since 1.6.1
	 */
	public boolean areIdentifiersCaseSensitive() {
		return identifiersCaseSensitive;
	}

	/**
	 * Determines if a character can be the start or part of an identifier.
	 * 
	 * @param c The character to be checked.
	 * @return <code>true</code> if the character can be the start of an identifier,
	 *         <code>false</code> otherwise.
	 */
	public boolean isIdentifierCharacter(char c) {
		return isIdentifierStartCharacter(c) || isIdentifierPartCharacter(c)
				|| (c == identifierSeparatorCharacter && c != NO_CHARACTER);
	}

	/**
	 * Gets the valid identifier start characters.
	 * 
	 * @return The non empty string of identifier start characters, not
	 *         <code>null</code>.
	 * 
	 * @since 1.6.3
	 */
	public String getIdentifierStartCharacters() {
		return identifierStartCharacters;
	}

	/**
	 * Determines if a character can be the start of an identifier.
	 * 
	 * @param c The character to be checked.
	 * @return <code>true</code> if the character can be the start of an identifier,
	 *         <code>false</code> otherwise.
	 * 
	 * @since 1.6.1
	 */
	public boolean isIdentifierStartCharacter(char c) {
		return c < identifierStartCharactersArray.length && identifierStartCharactersArray[c];
	}

	/**
	 * Gets the valid identifier part characters.
	 * 
	 * @return The non empty string of identifier part characters, not
	 *         <code>null</code>.
	 * 
	 * @since 1.6.3
	 */
	public String getIdentifierPartCharacters() {
		return identifierPartCharacters;
	}

	/**
	 * Determines if a character can be the part of an identifier.
	 * 
	 * @param c The character to be checked.
	 * @return <code>true</code> if the character can be part of an identifier,
	 *         <code>false</code> otherwise.
	 * @since 1.6.1
	 */
	public boolean isIdentifierPartCharacter(char c) {
		return c < identifierPartCharactersArray.length && identifierPartCharactersArray[c];
	}

	/**
	 * Gets the character which separates two parts of a compound identifier.
	 * 
	 * @return The character which separates two parts of a compound identifier or
	 *         {@link #NO_CHARACTER} if compound identifiers are not supported.
	 */
	public char getIdentifierSeparatorCharacter() {
		return identifierSeparatorCharacter;
	}

	/**
	 * Determines if a character can be part of an identifier and separates two
	 * parts of a compound identifier characters.
	 * 
	 * @param c The character to be checked.
	 * @return <code>true</code> if the character can be part of an identifier and
	 *         separates two parts of a compound identifier, <code>false</code>
	 *         otherwise.
	 * @since 1.6.1
	 */
	public boolean isIdentifierSeparatorCharacter(char c) {
		return (c != NO_CHARACTER) && (c == identifierSeparatorCharacter);
	}

	/**
	 * Gets the character which end a label definition, e.g. ':'.
	 * 
	 * @return The character which ends a label definition or {@link #NO_CHARACTER}
	 *         if label definitions end at the first white space.
	 * 
	 * @since 1.6.1
	 */
	public char getLabelDefinitionSuffixCharacter() {
		return labelDefinitionSuffixCharacter;
	}

	/**
	 * Gets the character which separates two parts of a compound identifier.
	 * 
	 * @return The character which start a macro usage or {@link #NO_CHARACTER} if
	 *         macro usages are not prefixed with a character.
	 * 
	 * @since 1.6.1
	 */
	public char getMacroUsagePrefixCharacter() {
		return macroUsagePrefixCharacter;
	}

	/**
	 * Determines if instructions are case sensitive.
	 * 
	 * @return <code>true</code> if instructions are case sensitive,
	 *         <code>false</code> otherwise.
	 * 
	 * @since 1.6.1
	 */
	public boolean areInstructionsCaseSensitive() {
		return instructionsCaseSensitive;
	}

	/**
	 * Determines if a character can be the start of a number.
	 * 
	 * @param c The character to be checked.
	 * @return <code>true</code> if the character can be the start of a number,
	 *         <code>false</code> otherwise.
	 * 
	 * @since 1.6.1
	 */
	public boolean isNumberStartCharacter(char c) {
		return c == '$' || c == '%' || c == '~' || (c >= '0' && c <= '9');
	}

	/**
	 * Determines if a character can be the part of a number.
	 * 
	 * @param c The character to be checked.
	 * @return <code>true</code> if the character can be part of a number,
	 *         <code>false</code> otherwise.
	 * @since 1.6.1
	 */
	public boolean isNumberPartCharacter(char c) {
		return (c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f');
	}

	/**
	 * Gets the default extension (excluding the period) to use in case source
	 * include file name does not end with an extension.
	 * 
	 * @return Gets the default extension (excluding the period) to use in case
	 *         source include file name does not end with an extension, may be
	 *         empty, not <code>null</code>.
	 */
	public String getSourceIncludeDefaultExtension() {
		if (sourceIncludeDefaultExtension == null) {
			throw new IllegalStateException("Variable 'sourceIncludeDefaultExtension' not yet initialized.");
		}
		return sourceIncludeDefaultExtension;
	}

	/**
	 * Gets the instruction set for a CPU.
	 * 
	 * @param cpu The CPU this which the allowed list of instructions shall be
	 *            returned, not <code>null</code>.
	 * @return The set of instructions supported by the compiler for the specified
	 *         CPU, not <code>null</code>.
	 * 
	 * @since 1.6.1
	 */
	public InstructionSet getInstructionSet(CPU cpu) {
		if (cpu == null) {
			throw new IllegalArgumentException("Parameter 'cpu' must not be null.");
		}
		InstructionSet result;
		synchronized (instructionSets) {
			result = instructionSets.get(cpu);
			if (result == null) {
				result = new InstructionSet(this, instructionList, cpu);
				instructionSets.put(cpu, result);
			}
		}

		return result;
	}

	@Override
	public String toString() {
		return compilerId;
	}
}
