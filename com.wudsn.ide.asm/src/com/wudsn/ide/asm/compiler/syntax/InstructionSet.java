/**
 * Copyright (C) 2009 - 2019 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

package com.wudsn.ide.asm.compiler.syntax;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import com.wudsn.ide.asm.CPU;
import com.wudsn.ide.asm.compiler.CompilerRegistry;
import com.wudsn.ide.asm.compiler.syntax.Opcode.OpcodeAddressingMode;

/**
 * Container for a set of directives, legal, illegal and pseudo opcodes and
 * their properties.
 * 
 * TODO Maintain address modes for all illegal opcodes for online help
 * 
 * @author Peter Dell
 * @since 1.6.1
 */
public final class InstructionSet {

    private CompilerSyntax compilerSyntax;

    private boolean instructionStartCharactersArray[];
    private boolean instructionPartCharactersArray[];

    private List<Instruction> instructionsList;

    private Map<String, Instruction> instructionsMap;

    /**
     * Array list of opcode addressing modes.
     * 
     * @since 1.7.0
     */
    private List<List<OpcodeAddressingMode>> opcodeAddessingModesList;

    private List<Instruction> fileReferenceInstructionsList;

    /**
     * Creates new instance. Called by {@link CompilerRegistry}.
     * 
     * @param compilerSyntax
     *            The compiler syntax, not <code>null</code>.
     * 
     * @param instructionsList
     *            The non-filtered list of compiler instructions.
     * @param cpu
     *            The cpu to filter by, not <code>null</code>.
     */
    InstructionSet(CompilerSyntax compilerSyntax, List<Instruction> instructionsList, CPU cpu) {

	if (compilerSyntax == null) {
	    throw new IllegalArgumentException("Parameter 'compilerSyntax' must not be null.");
	}
	if (instructionsList == null) {
	    throw new IllegalArgumentException("Parameter 'instructionsList' must not be null.");
	}
	if (cpu == null) {
	    throw new IllegalArgumentException("Parameter 'cpu' must not be null.");
	}
	// Compute the list of all include instructions.
	this.compilerSyntax = compilerSyntax;
	this.instructionsList = new ArrayList<Instruction>(instructionsList.size());
	instructionsMap = new TreeMap<String, Instruction>();

	opcodeAddessingModesList = new ArrayList<List<OpcodeAddressingMode>>(Opcode.MAX_OPCODES);
	for (int i = 0; i < Opcode.MAX_OPCODES; i++) {
	    opcodeAddessingModesList.add(new ArrayList<OpcodeAddressingMode>());
	}
	fileReferenceInstructionsList = new ArrayList<Instruction>(10);

	// Collect all start and part characters.
	boolean caseSenstive = compilerSyntax.areIdentifiersCaseSensitive();
	StringBuilder instructionStartCharacters = new StringBuilder(512);
	StringBuilder instructionPartCharacters = new StringBuilder(2048);

	for (Instruction instruction : instructionsList) {
	    if (!instruction.getCPUs().contains(cpu)) {
		continue;
	    }
	    this.instructionsList.add(instruction);

	    // If not case sensitive, the upper case and lower case
	    // representation is allowed
	    if (caseSenstive) {
		instructionStartCharacters.append(instruction.getName().substring(0, 1));
		instructionPartCharacters.append(instruction.getName().substring(1));
		instructionsMap.put(instruction.getName(), instruction);

	    } else {
		instructionStartCharacters.append(instruction.getUpperCaseName().substring(0, 1));
		instructionPartCharacters.append(instruction.getUpperCaseName().substring(1));
		instructionStartCharacters.append(instruction.getLowerCaseName().substring(0, 1));
		instructionPartCharacters.append(instruction.getLowerCaseName().substring(1));
		instructionsMap.put(instruction.getUpperCaseName(), instruction);
	    }

	    switch (instruction.getType()) {
	    case InstructionType.LEGAL_OPCODE:
	    case InstructionType.ILLEGAL_OPCODE:
	    case InstructionType.PSEUDO_OPCODE:
		Opcode opcode = (Opcode) instruction;
		for (OpcodeAddressingMode opcodeAddressingMode : opcode.getAddressingModes()) {
		    // Even if an instruction is supported by all CPUs, not all
		    // addressing modes may be supported by the CPU,
		    if (opcodeAddressingMode.getCPUs().contains(cpu)) {
			List<OpcodeAddressingMode> list = opcodeAddessingModesList.get(opcodeAddressingMode
				.getOpcodeValue());
			if (list == null) {
			    list = new ArrayList<OpcodeAddressingMode>();
			}
			list.add(opcodeAddressingMode);
		    }
		}
		break;

	    case InstructionType.SOURCE_INCLUDE_DIRECTIVE:
	    case InstructionType.BINARY_INCLUDE_DIRECTIVE:
	    case InstructionType.BINARY_OUTPUT_DIRECTIVE:
		fileReferenceInstructionsList.add(instruction);
		break;

	    }

	}

	instructionStartCharactersArray = CompilerSyntax.createBooleanArray(instructionStartCharacters.toString());
	instructionPartCharactersArray = CompilerSyntax.createBooleanArray(instructionPartCharacters.toString());

	this.instructionsList = Collections.unmodifiableList(this.instructionsList);
	instructionsMap = Collections.unmodifiableMap(instructionsMap);
	fileReferenceInstructionsList = Collections.unmodifiableList(fileReferenceInstructionsList);
    }

    /**
     * Gets the compiler syntax.
     * 
     * @return The compiler syntax, not <code>null</code>.
     */
    public CompilerSyntax getCompilerSyntax() {
	return compilerSyntax;
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
	return compilerSyntax.areInstructionsCaseSensitive();
    }

    /**
     * Determines if a character can be the start of an instruction.
     * 
     * @param c
     *            The character to be checked.
     * @return <code>true</code> if the character can be the start of an
     *         instruction, <code>false</code> otherwise.
     * 
     * @since 1.6.1
     */
    public boolean isInstructionStartCharacter(char c) {
	return c < instructionStartCharactersArray.length && instructionStartCharactersArray[c];
    }

    /**
     * Determines if a character can be the part of an instruction.
     * 
     * @param c
     *            The character to be checked.
     * @return <code>true</code> if the character can be part of an instruction,
     *         <code>false</code> otherwise.
     * @since 1.6.1
     */
    public boolean isInstructionPartCharacter(char c) {
	return c < instructionPartCharactersArray.length && instructionPartCharactersArray[c];
    }

    /**
     * Gets the list of all instructions.
     * 
     * @return The unmodifiable list of instructions, not <code>null</code>.
     */
    public List<Instruction> getInstructions() {

	if (instructionsList == null) {
	    throw new IllegalStateException("Variable 'instructionsList' not yet initialized.");
	}
	return instructionsList;
    }

    /**
     * Gets list of opcode address modes for the given opcode value. Only
     * instances that are support by the CPU of the instruction set are
     * returned.
     * 
     * @param opcodeValue
     *            The opcode value.
     * @return The list of opcode address modes, may be empty, not
     *         <code>null</code>.
     * 
     * @since 1.7.0
     */
    public List<OpcodeAddressingMode> getOpcodeAddressingModes(int opcodeValue) {
	if (opcodeAddessingModesList == null) {
	    throw new IllegalStateException("Variable 'opcodeAddessingModesList' not yet initialized.");
	}
	List<OpcodeAddressingMode> result = null;
	if (opcodeValue > 0 && opcodeValue < opcodeAddessingModesList.size()) {
	    result = opcodeAddessingModesList.get(opcodeValue);
	}
	if (result == null) {
	    result = Collections.emptyList();
	}
	return result;
    }

    /**
     * Gets an instruction by its upper case name.
     * 
     * @param instructionName
     *            The upper case name
     * 
     * @return The instruction or <code>null</code>.
     */
    public Instruction getInstruction(String instructionName) {
	return instructionsMap.get(instructionName);
    }

    /**
     * Gets the list of all include instructions.
     * 
     * @return The unmodifiable list of include instructions, not
     *         <code>null</code>.
     */
    public List<Instruction> getFileReferenceInstructions() {
	if (fileReferenceInstructionsList == null) {
	    throw new IllegalStateException("Variable 'fileReferenceInstructionsList' not yet initialized.");
	}
	return fileReferenceInstructionsList;
    }

    @Override
    public String toString() {
	return compilerSyntax.toString() + ": " + instructionsMap.keySet().toString();
    }
}
