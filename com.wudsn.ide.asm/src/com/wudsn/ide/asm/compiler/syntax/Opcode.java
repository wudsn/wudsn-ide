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
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import com.wudsn.ide.asm.CPU;

public final class Opcode extends Instruction {

    public static final int MAX_OPCODES = 256;

    public final static class OpcodeAddressingMode {
	private Opcode opcode;
	private Set<CPU> cpus;
	private String addressingMode;
	private int opcodeValue;

	OpcodeAddressingMode(Opcode opcode, Set<CPU> cpus, String addressingMode, int opcodeValue) {
	    if (opcode == null) {
		throw new IllegalArgumentException("Parameter 'opcode' must not be null.");
	    }
	    if (cpus == null) {
		throw new IllegalArgumentException("Parameter 'cpus' must not be null for opcode '" + opcode.getName()
			+ "'.");
	    }
	    if (addressingMode == null) {
		throw new IllegalArgumentException("Parameter 'addressingMode' must not be nullfor opcode '"
			+ opcode.getName() + "'.");
	    }
	    if (opcodeValue < 0 || opcodeValue > 255) {
		throw new IllegalArgumentException("Parameter 'opcodeValue' has value " + opcodeValue + " for opcode '"
			+ opcode.getName() + "' but must be between $00 and $ff.");

	    }
	    this.opcode = opcode;
	    this.cpus = cpus;
	    this.addressingMode = addressingMode;
	    this.opcodeValue = opcodeValue;
	}

	public Opcode getOpcode() {
	    return opcode;
	}

	public Set<CPU> getCPUs() {
	    return cpus;
	}

	public String getAddressingMode() {
	    return addressingMode;
	}

	public String getFormattedText() {

	    StringBuffer result = new StringBuffer(opcode.getName());
	    if (addressingMode.equals("imp")) {

	    } else if (addressingMode.equals("imm")) {
		result.append(" #$nn");
	    } else if (addressingMode.equals("zp")) {
		result.append(" zp");
	    } else if (addressingMode.equals("zpx")) {
		result.append(" zp,x");
	    } else if (addressingMode.equals("zpy")) {
		result.append(" zp,y");
	    } else if (addressingMode.equals("izx")) {
		result.append(" (zp,x)");
	    } else if (addressingMode.equals("izy")) {
		result.append(" (zp),y");
	    } else if (addressingMode.equals("abs")) {
		result.append(" abs");
	    } else if (addressingMode.equals("abx")) {
		result.append(" abs,x");
	    } else if (addressingMode.equals("aby")) {
		result.append(" abs,y");
	    } else if (addressingMode.equals("ind")) {
		result.append(" (abs)");
	    } else if (addressingMode.equals("rel")) {
		result.append(" rel");
	    } else

	    // 65816 modes
	    if (addressingMode.equals("abl")) {
		result.append(" adr (long)");
	    } else if (addressingMode.equals("bm")) {
		result.append(" $nn,$nn");
	    } else if (addressingMode.equals("dp")) {
		result.append(" (zp)");
	    } else if (addressingMode.equals("ial")) {
		result.append(" abs (long)");
	    } else if (addressingMode.equals("iax")) {
		result.append(" (abs,x)");
	    } else if (addressingMode.equals("idp")) {
		result.append(" (zp)");
	    } else if (addressingMode.equals("rell")) {
		result.append(" rel (long)");
	    } else {
		throw new RuntimeException("Unmapped addressing mode " + addressingMode + " for opcode "
			+ opcode.getName());
	    }

	    return result.toString();
	}

	public int getOpcodeValue() {
	    return opcodeValue;
	}
    }

    private boolean w65816;
    private String flags;
    private String modes;
    private List<OpcodeAddressingMode> addressingModes;

    Opcode(Set<CPU> cpus, int type, boolean instructionsCaseSensitive, String name, String title, String proposal,
	    boolean w65816, String flags, String modes) {

	super(cpus, type, instructionsCaseSensitive, name, title, proposal);
	switch (type) {
	case InstructionType.LEGAL_OPCODE:
	case InstructionType.ILLEGAL_OPCODE:
	case InstructionType.PSEUDO_OPCODE:
	    break;

	default:
	    throw new IllegalArgumentException("Unknown type " + type + " for opcode '" + name + "'.");
	}
	if (flags == null) {
	    throw new IllegalArgumentException("Parameter 'flags' must not be null for opcode '" + name + "'.");
	}
	if (modes == null) {
	    throw new IllegalArgumentException("Parameter 'modes' must not be null for opcode '" + name + "'.");

	}
	this.w65816 = w65816;
	this.flags = flags;
	this.modes = modes;
	addressingModes = new ArrayList<OpcodeAddressingMode>();
	Set<CPU> addressingModeCPUs = cpus;
	for (String mode : modes.split(",")) {
	    mode = mode.trim();
	    String values[] = mode.split("=");
	    String addressingMode = values[0];
	    String value = values[1].substring(1);
	    int index = value.indexOf("[");
	    if (index >= 0) {
		String[] cpuNameList = value.substring(index + 1, value.length() - 1).split(";");
		value = value.substring(0, index);
		addressingModeCPUs = new TreeSet<CPU>();
		for (String cpuName : cpuNameList) {
		    addressingModeCPUs.add(CPU.valueOf(cpuName));
		}
	    }
	    int opcode = Integer.parseInt(value, 16);
	    OpcodeAddressingMode addressingModeInstance = new OpcodeAddressingMode(this, addressingModeCPUs,
		    addressingMode, opcode);
	    addressingModes.add(addressingModeInstance);
	}

    }

    public boolean isW65816() {
	return w65816;
    }

    public String getFlags() {
	return flags;
    }

    public String getModes() {
	return modes;
    }

    public List<OpcodeAddressingMode> getAddressingModes() {
	return addressingModes;
    }

}