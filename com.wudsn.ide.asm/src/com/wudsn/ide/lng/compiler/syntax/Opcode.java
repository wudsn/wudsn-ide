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

import java.util.*;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import com.wudsn.ide.lng.Target;

public final class Opcode extends Instruction {

	public static final int MAX_OPCODES = 256;

	public final static class OpcodeAddressingMode {

		private static Map<String, String> addressingModeText;

		static {
			addressingModeText = new TreeMap<String, String>();

			// 6502 mode.
			addressingModeText.put("abs", " abs"); // Absolute
			addressingModeText.put("abx", " abs,x"); // Absolute withX
			addressingModeText.put("aby", " abs,y"); // Absolute with Y
			addressingModeText.put("imm", " #$nn"); // Immediate
			addressingModeText.put("imp", ""); // Implied
			addressingModeText.put("ind", " (abs)"); // Indirect absolute
			addressingModeText.put("izx", " (zp,x)"); // Indirect zero page with X
			addressingModeText.put("izy", " (zp),y"); // Indirect zero page with Y
			addressingModeText.put("rel", " rel"); // Relative
			addressingModeText.put("zp", " zp"); // Zero page
			addressingModeText.put("zpx", " zp,x"); // Zero page with X
			addressingModeText.put("zpy", " zp,y"); // Zero page with Y

			// 65816 modes. Some are equals to 6502 mode, but have different a code.
			addressingModeText.put("abl", " abs (long)"); // Absolute long
			addressingModeText.put("alx", " abs,x (long)"); // Absolute long with X
			addressingModeText.put("bm", " $nn,$mm"); // Block move
			addressingModeText.put("dp", " dp"); // Direct page
			addressingModeText.put("dpx", " dp,x"); // Direct page with X
			addressingModeText.put("dpy", " dp,y"); // Direct page with Y
			addressingModeText.put("ial", " (abs) (long)"); // Indirect absolute long
			addressingModeText.put("idl", " (abs) (long)"); // Indirect absolute long for JMP
			addressingModeText.put("iax", " (abs,x) (long)"); // Indirect absolute long with X
			addressingModeText.put("idly", " (abs),y (long)"); // Indirect absolute long with Y
			addressingModeText.put("idp", " (dp)"); // Indirect direct page
			addressingModeText.put("isy", " ($00,S),Y"); // Stack indirect with Y in first 64k
			addressingModeText.put("rell", " rel (long)"); // Relative long
			addressingModeText.put("sr", "$00,S"); // Stack in first 64k

		}

		private Opcode opcode;
		private Set<Target> targets;
		private String addressingMode;
		private int opcodeValue;

		OpcodeAddressingMode(Opcode opcode, Set<Target> targets, String addressingMode, int opcodeValue) {
			if (opcode == null) {
				throw new IllegalArgumentException("Parameter 'opcode' must not be null.");
			}
			if (targets == null) {
				throw new IllegalArgumentException(
						"Parameter 'targets' must not be null for opcode '" + opcode.getName() + "'.");
			}
			if (addressingMode == null) {
				throw new IllegalArgumentException(
						"Parameter 'addressingMode' must not be nullfor opcode '" + opcode.getName() + "'.");
			}
			if (opcodeValue < 0 || opcodeValue > 255) {
				throw new IllegalArgumentException("Parameter 'opcodeValue' has value " + opcodeValue + " for opcode '"
						+ opcode.getName() + "' but must be between $00 and $ff.");

			}
			this.opcode = opcode;
			this.targets = targets;
			this.addressingMode = addressingMode;
			this.opcodeValue = opcodeValue;
		}

		public Opcode getOpcode() {
			return opcode;
		}

		public Set<Target> getCPUs() {
			return targets;
		}

		public String getAddressingMode() {
			return addressingMode;
		}

		public String getFormattedText() {

			StringBuffer result = new StringBuffer(opcode.getName());
			String text = addressingModeText.get(addressingMode);
			if (text != null) {
				result.append(text);
			} else {
				throw new RuntimeException(
						"Unmapped addressing mode " + addressingMode + " for opcode " + opcode.getName());
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

	Opcode(Set<Target> cpus, int type, boolean instructionsCaseSensitive, String name, String title, String proposal,
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
		Set<Target> addressingModeCPUs = cpus;
		for (String mode : modes.split(",")) {
			mode = mode.trim();
			String values[] = mode.split("=");
			String addressingMode = values[0];
			String value = values[1].substring(1);
			int index = value.indexOf("[");
			if (index >= 0) {
				String[] cpuNameList = value.substring(index + 1, value.length() - 1).split(";");
				value = value.substring(0, index);
				addressingModeCPUs = new TreeSet<Target>();
				for (String cpuName : cpuNameList) {
					addressingModeCPUs.add(Target.valueOf(cpuName));
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