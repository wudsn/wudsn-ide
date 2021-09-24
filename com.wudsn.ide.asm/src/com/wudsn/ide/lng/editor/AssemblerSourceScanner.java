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
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.text.rules.ICharacterScanner;
import org.eclipse.jface.text.rules.IRule;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.RuleBasedScanner;
import org.eclipse.jface.text.rules.Token;

import com.wudsn.ide.lng.compiler.parser.CompilerSourceParser;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceParserTreeObject;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceParserTreeObjectType;
import com.wudsn.ide.lng.compiler.syntax.CompilerSyntax;
import com.wudsn.ide.lng.compiler.syntax.Directive;
import com.wudsn.ide.lng.compiler.syntax.Instruction;
import com.wudsn.ide.lng.compiler.syntax.InstructionSet;
import com.wudsn.ide.lng.compiler.syntax.InstructionType;
import com.wudsn.ide.lng.compiler.syntax.Opcode;
import com.wudsn.ide.lng.preferences.LanguagePreferences;
import com.wudsn.ide.lng.preferences.LanguagePreferencesConstants;
import com.wudsn.ide.lng.preferences.TextAttributeConverter;

/**
 * A rule based scanner for instructions.
 * 
 * @author Peter Dell
 * @author Andy Reek
 */
final class AssemblerSourceScanner extends RuleBasedScanner {

	private final class AssemblerWordRule implements IRule {
		public final class State {
			public CompilerSourceParser compilerSourceParser;

			public CompilerSyntax compilerSyntax;
			public InstructionSet instructionSet;

			public boolean instructionsCaseSensitive;
			public Map<String, IToken> instructionWordTokens;

			public boolean identifiersCaseSensitive;
			public Map<String, IToken> identifierWordTokens;

			public State() {
				instructionWordTokens = new TreeMap<String, IToken>();
				identifierWordTokens = new TreeMap<String, IToken>();
			}

			public State createDeepCopy() {
				State result = new State();
				result.compilerSourceParser = compilerSourceParser;
				result.compilerSyntax = compilerSyntax;
				result.instructionSet = instructionSet;
				result.instructionsCaseSensitive = instructionsCaseSensitive;
				result.instructionWordTokens = instructionWordTokens;
				result.identifiersCaseSensitive = identifiersCaseSensitive;
				result.identifierWordTokens = identifierWordTokens;
				return result;
			}
		}

		// State of the AssemblerWordRule instance.
		State state;

		/** Buffer used for pattern detection in evaluate() only. */
		private StringBuilder instructionBuffer = new StringBuilder();
		private StringBuilder identifierBuffer = new StringBuilder();
		private StringBuilder numberBuffer = new StringBuilder();

		public AssemblerWordRule() {

		}

		public void setCompilerSourceParser(CompilerSourceParser compilerSourceParser) {
			if (compilerSourceParser == null) {
				throw new IllegalArgumentException("Parameter 'compilerSourceParser' must not be null.");
			}

			State state = new State();
			state.compilerSourceParser = compilerSourceParser;
			state.instructionSet = compilerSourceParser.getInstructionSet();
			state.compilerSyntax = compilerSourceParser.getCompilerSyntax();

			state.instructionsCaseSensitive = state.compilerSyntax.areInstructionsCaseSensitive();
			state.identifiersCaseSensitive = state.compilerSyntax.areIdentifiersCaseSensitive();

			synchronized (this) {
				this.state = state;
			}
		}

		public void setInstructions() {
			synchronized (this) {
				state.instructionWordTokens.clear();

				state.instructionsCaseSensitive = state.compilerSyntax.areInstructionsCaseSensitive();
				state.instructionSet = state.compilerSourceParser.getInstructionSet();

				List<Instruction> instructions = state.instructionSet.getInstructions();

				// Map with lower case name and corresponding token.
				for (Instruction instruction : instructions) {
					IToken token;
					if (instruction instanceof Directive) {
						token = directiveToken;
					} else if (instruction instanceof Opcode) {

						Opcode opcode = (Opcode) instruction;

						switch (opcode.getType()) {

						case InstructionType.LEGAL_OPCODE:
							token = legalOpcodeToken;
							break;
						case InstructionType.ILLEGAL_OPCODE:

							token = illegalOpcodeToken;
							break;
						case InstructionType.PSEUDO_OPCODE:
							token = pseudoOpcodeToken;
							break;
						default:
							throw new IllegalStateException("Unknown opcode type " + opcode.getType() + ".");

						}
					} else {
						throw new IllegalStateException("Unknown instruction type " + instruction.toString() + ".");

					}
					// Case insensitive word rules expect upper case words.
					if (state.instructionsCaseSensitive) {
						state.instructionWordTokens.put(instruction.getName(), token);
					} else {
						state.instructionWordTokens.put(instruction.getUpperCaseName(), token);
					}
				}
			}

		}

		/**
		 * Update the list of identifiers to be highlighted
		 * 
		 * @param identifiers The list of identifiers, not <code>null</code>.
		 */
		public void setIdentifiers(List<CompilerSourceParserTreeObject> identifiers) {
			if (identifiers == null) {
				throw new IllegalArgumentException("Parameter 'identifiers' must not be null.");
			}
			synchronized (this) {

				for (CompilerSourceParserTreeObject element : identifiers) {
					IToken token;
					switch (element.getType()) {
					case CompilerSourceParserTreeObjectType.EQUATE_DEFINITION:
						token = equateIdentifierToken;
						break;
					case CompilerSourceParserTreeObjectType.LABEL_DEFINITION:
						token = labelIdentifierToken;
						break;
					case CompilerSourceParserTreeObjectType.ENUM_DEFINITION_SECTION:
						token = enumDefinitionSectionIdentifierToken;
						break;
					case CompilerSourceParserTreeObjectType.STRUCTURE_DEFINITION_SECTION:
						token = structureDefinitionSectionIdentifierToken;
						break;
					case CompilerSourceParserTreeObjectType.LOCAL_SECTION:
						token = localSectionIdentifierToken;
						break;
					case CompilerSourceParserTreeObjectType.MACRO_DEFINITION_SECTION:
						token = macroDefinitionSectionIdentifierToken;
						break;
					case CompilerSourceParserTreeObjectType.PROCEDURE_DEFINITION_SECTION:
						token = procedureDefinitionSectionIdentifierToken;
						break;

					default:
						throw new RuntimeException("Unexpected identifier element type " + element.getType() + " - "
								+ element.getTreePath() + ".");
					}
					if (element.getDescription().startsWith("@style=(")) {
						String value = element.getDescription().substring(8);
						int index = value.indexOf(")");
						if (index > 0) {
							value = value.substring(0, index);
							TextAttribute textAttribute = TextAttributeConverter.fromString(value);
							token = new Token(textAttribute);
						}
					}
					if (state.identifiersCaseSensitive) {
						state.identifierWordTokens.put(element.getName(), token);
					} else {
						state.identifierWordTokens.put(element.getName().toUpperCase(), token);

					}
				}
			}
			System.out.println("" + this + ":" + state.identifierWordTokens.size());
		}

		/*
		 * @see IRule#evaluate(ICharacterScanner)
		 */
		@Override
		public IToken evaluate(ICharacterScanner scanner) {

			// Create a local copy to prevent synchronization issues.
			State localState;
			synchronized (this) {
				localState = state.createDeepCopy();
			}

			int c = scanner.read();
			boolean instructionStartCharacter = localState.instructionSet.isInstructionStartCharacter((char) c);
			boolean identifierStartCharacter = localState.compilerSyntax.isIdentifierStartCharacter((char) c);
			boolean numberStartCharacter = localState.compilerSyntax.isNumberStartCharacter((char) c);
			if (c != ICharacterScanner.EOF
					&& (instructionStartCharacter || identifierStartCharacter || numberStartCharacter)) {

				instructionBuffer.setLength(0);
				identifierBuffer.setLength(0);
				numberBuffer.setLength(0);
				int charactersRead = 0;
				boolean instructionPartCharacter = instructionStartCharacter;
				boolean identifierPartCharacter = identifierStartCharacter;
				boolean numberPartCharacter = numberStartCharacter;
				do {
					charactersRead++;
					if (instructionPartCharacter) {
						instructionBuffer.append((char) c);
					}
					if (identifierPartCharacter) {
						identifierBuffer.append((char) c);
					}
					if (numberPartCharacter) {
						numberBuffer.append((char) c);
					}
					c = scanner.read();
					instructionPartCharacter = instructionPartCharacter
							&& localState.instructionSet.isInstructionPartCharacter((char) c);
					identifierPartCharacter = identifierPartCharacter
							&& (localState.compilerSyntax.isIdentifierPartCharacter((char) c));
					numberPartCharacter = numberPartCharacter
							&& localState.compilerSyntax.isNumberPartCharacter((char) c);

				} while (c != ICharacterScanner.EOF
						&& (instructionPartCharacter || identifierPartCharacter || numberPartCharacter));
				scanner.unread();

				String instructionString = instructionBuffer.toString();
				String identifierString = identifierBuffer.toString();
				String numberString = numberBuffer.toString();
				// System.out.println(instructionString + "/" + identifierString
				// + "/" + numberString);

				// If case-insensitive, convert to upper case before
				// accessing the map
				if (!localState.instructionsCaseSensitive) {
					instructionString = instructionString.toUpperCase();
				}

				IToken instructionToken = localState.instructionWordTokens.get(instructionString);

				// Anything found at all?
				if (instructionToken == null && identifierString.length() == 0 && numberString.length() == 0) {
					unreadBuffer(scanner, charactersRead);
					return Token.UNDEFINED;
				}

				// If the identifier string is longer, use it.
				IToken token;
				if (instructionToken == null || identifierString.length() > instructionString.length()) {
					if (identifierString.length() >= numberString.length()) {
						if (identifierString.length() == 0) {
							return Token.UNDEFINED;
						}
						if (!localState.identifiersCaseSensitive) {
							identifierString = identifierString.toUpperCase();
						}
						token = localState.identifierWordTokens.get(identifierString);

						// Consume the next separator if there is one.
						if (localState.compilerSyntax.isIdentifierSeparatorCharacter((char) c)) {
							charactersRead--;
						}
						unreadBuffer(scanner, charactersRead - identifierString.length());
						if (token == null) {
							token = Token.UNDEFINED;
						}
						return token;
					}
					unreadBuffer(scanner, charactersRead - numberString.length());
					return numberToken;

				}
				if (instructionString.length() >= numberString.length()) {
					unreadBuffer(scanner, charactersRead - instructionString.length());
					return instructionToken;
				} else if (numberString.length() > 0) {
					return numberToken;
				}

				return Token.UNDEFINED;
			}

			scanner.unread();
			return Token.UNDEFINED;

		}

		/**
		 * Returns the specified number of characters to the scanner.
		 * 
		 * @param scanner The scanner to be used, not <code>null</code>.
		 * @param count   The count. If the count is 0 or negative, no characters will
		 *                be returned.
		 */
		private void unreadBuffer(ICharacterScanner scanner, int count) {
			for (int i = 0; i < count; i++) {
				scanner.unread();
			}
		}
	}

	private AssemblerEditor editor;
	private Map<String, Token> tokens;

	// Numbers
	IToken numberToken;

	// Instructions.
	IToken directiveToken;
	IToken legalOpcodeToken;
	IToken illegalOpcodeToken;
	IToken pseudoOpcodeToken;

	// Identifiers.
	IToken equateIdentifierToken;
	IToken labelIdentifierToken;
	IToken enumDefinitionSectionIdentifierToken;
	IToken structureDefinitionSectionIdentifierToken;
	IToken localSectionIdentifierToken;
	IToken macroDefinitionSectionIdentifierToken;
	IToken procedureDefinitionSectionIdentifierToken;

	// Word rule
	private AssemblerWordRule wordRule;

	/**
	 * Creates a new instance. Called by the
	 * {@link AssemblerSourceViewerConfiguration}.
	 * 
	 * @param editor The underlying AssemblerEditor for the code scanner, not
	 *               <code>null</code>.
	 */
	AssemblerSourceScanner(AssemblerEditor editor) {
		if (editor == null) {
			throw new IllegalArgumentException("Parameter 'editor' must not be null.");
		}
		this.editor = editor;
		this.tokens = new TreeMap<String, Token>();

		createTokens();
		createRules();
	}

	/**
	 * The token are stable over the life time of the editor, whereas the rules may
	 * change if the preferences are changed.
	 */
	private void createTokens() {

		// Numbers
		numberToken = createToken(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_NUMBER);

		// Instructions
		directiveToken = createToken(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_DIRECTVE);
		legalOpcodeToken = createToken(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_OPCODE_LEGAL);
		illegalOpcodeToken = createToken(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_OPCODE_ILLEGAL);
		pseudoOpcodeToken = createToken(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_OPCODE_PSEUDO);

		// Identifiers
		equateIdentifierToken = createToken(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_EQUATE);
		labelIdentifierToken = createToken(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_LABEL);
		enumDefinitionSectionIdentifierToken = createToken(
				LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_ENUM_DEFINITION_SECTION);
		structureDefinitionSectionIdentifierToken = createToken(
				LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_STRUCTURE_DEFINITION_SECTION);
		localSectionIdentifierToken = createToken(
				LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_LOCAL_SECTION);
		macroDefinitionSectionIdentifierToken = createToken(
				LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_MACRO_DEFINITION_SECTION);
		procedureDefinitionSectionIdentifierToken = createToken(
				LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_PROCEDURE_DEFINITION_SECTION);

	}

	/**
	 * Creates a token bound to a text attribute name.
	 * 
	 * @param textAttributeName The text attribute name, not empty and not
	 *                          <code>null</code>.
	 * @return The new token, not <code>null</code>.
	 */
	private IToken createToken(String textAttributeName) {
		if (textAttributeName == null) {
			throw new IllegalArgumentException("Parameter 'textAttributeName' must not be null.");
		}
		LanguagePreferences preferences;
		Token token;
		preferences = editor.getPlugin().getPreferences();
		token = new Token(preferences.getEditorTextAttribute(textAttributeName));
		tokens.put(textAttributeName, token);
		return token;
	}

	/**
	 * Creates and sets the rules based on the the compiler syntax.
	 */
	private void createRules() {

		// Instructions, identifiers and numbers.
		wordRule = new AssemblerWordRule();
		List<IRule> rules = new ArrayList<IRule>(4);
		rules.add(wordRule);
		setRules(rules.toArray(new IRule[rules.size()]));

		CompilerSourceParser compilerSourceParser = editor.createCompilerSourceParser();
		wordRule.setCompilerSourceParser(compilerSourceParser);
		wordRule.setInstructions();
	}

	/**
	 * Update the list of identifiers to be highlighted
	 * 
	 * @param identifiers The list of identifiers, not <code>null</code>.
	 */
	final void setIdentifiers(List<CompilerSourceParserTreeObject> identifiers) {
		if (identifiers == null) {
			throw new IllegalArgumentException("Parameter 'identifiers' must not be null.");
		}
		wordRule.setIdentifiers(identifiers);
	}

	/**
	 * Dispose UI resources.
	 */
	final void dispose() {
		for (Token token : tokens.values()) {
			TextAttributeConverter.dispose((TextAttribute) token.getData());
		}
	}

	/**
	 * Update the token based on the preferences. Called by
	 * {@link AssemblerSourceViewerConfiguration}.
	 * 
	 * @param preferences          The preferences, not <code>null</code>.
	 * @param changedPropertyNames The set of changed property names, not
	 *                             <code>null</code>.
	 * 
	 * @return <code>true</code> If the editor has to be refreshed.
	 */
	final boolean preferencesChanged(LanguagePreferences preferences, Set<String> changedPropertyNames) {
		if (preferences == null) {
			throw new IllegalArgumentException("Parameter 'preferences' must not be null.");
		}
		if (changedPropertyNames == null) {
			throw new IllegalArgumentException("Parameter 'changedPropertyNames' must not be null.");
		}
		boolean refresh = false;
		for (String propertyName : changedPropertyNames) {
			Token token = tokens.get(propertyName);
			if (token != null) {
				TextAttributeConverter.dispose((TextAttribute) token.getData());
				token.setData(preferences.getEditorTextAttribute(propertyName));
				refresh = true;

			} else if (LanguagePreferencesConstants.isCompilerTargetName(propertyName)) {
				CompilerSourceParser compilerSourceParser = editor.createCompilerSourceParser();
				wordRule.setCompilerSourceParser(compilerSourceParser);
				wordRule.setInstructions();
				refresh = true;
			}
		}
		return refresh;

	}

}
