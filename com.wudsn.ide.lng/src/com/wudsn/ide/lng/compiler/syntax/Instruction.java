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

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import com.wudsn.ide.base.common.NumberFactory;
import com.wudsn.ide.lng.Target;

public abstract class Instruction implements Comparable<Instruction> {

	public static final char CURSOR = '_';
	public static final char NEWLINE = '\n';

	private Set<Target> cpus;
	private int type;
	private String name;
	private String upperCaseName;
	private String lowerCaseName;
	private String title;
	private String formattedTitle;
	private String styledTitle;
	private int[] styledTitleOffsets;
	private String proposal;

	protected Instruction(Set<Target> cpus, int type, boolean caseSensitive, String name, String title, String proposal) {
		if (cpus == null) {
			throw new IllegalArgumentException("Parameter 'cpus' must not be null.");
		}
		if (name == null) {
			throw new IllegalArgumentException("Parameter 'name' must not be null.");
		}
		if (title == null) {
			throw new IllegalArgumentException("Parameter 'title' must not be null for instruction '" + name + "'.");
		}
		if (proposal == null) {
			throw new IllegalArgumentException("Parameter 'proposal' must not be null for instruction '" + name + "'.");
		}
		this.cpus = cpus;
		this.type = type;
		this.name = name;
		if (caseSensitive) {
			this.upperCaseName = name;
			this.lowerCaseName = name;
		} else {
			this.upperCaseName = name.toUpperCase();
			this.lowerCaseName = name.toLowerCase();
		}
		this.title = title;

		int length = title.length();
		StringBuilder mnemonicBuilder = new StringBuilder(3);
		StringBuilder formattedTitleBuilder = new StringBuilder(length);
		StringBuilder styledTitleBuilder = new StringBuilder(length);
		List<Integer> styledTitleOffsetsList = new ArrayList<Integer>(10);
		for (int i = 0; i < length; i++) {
			char c = title.charAt(i);
			char fc;
			if (c == '_') {
				i++;
				if (i >= title.length()) {
					throw new RuntimeException("Instruction '" + name + "' has invalid title '" + title + "'.");
				}
				c = title.charAt(i);
				fc = Character.toUpperCase(c);
				mnemonicBuilder.append(fc);
				styledTitleOffsetsList.add(NumberFactory.getInteger(styledTitleBuilder.length()));
			} else {
				fc = c;
			}
			formattedTitleBuilder.append(fc);
			styledTitleBuilder.append(c);
		}
		this.formattedTitle = formattedTitleBuilder.toString();
		this.styledTitle = styledTitleBuilder.toString();
		int size = styledTitleOffsetsList.size();
		this.styledTitleOffsets = new int[size];
		for (int i = 0; i < size; i++) {
			this.styledTitleOffsets[i] = styledTitleOffsetsList.get(i).intValue();
		}

		proposal = proposal.replace("\\n", "" + NEWLINE);
		if (!proposal.startsWith(name)) {
			throw new RuntimeException(
					"Proposal '" + proposal + "' of instruction '" + name + "' does not start with '" + name + "'.");
		}
		if (proposal.indexOf(CURSOR) == -1) {

			throw new RuntimeException("Proposal '" + proposal + "' of instruction '" + name
					+ "' does not contain cursor positioning via '_'.");
		}

		this.proposal = proposal;

		// Remove all special characters like
		StringBuilder mnemonicNameBuilder = new StringBuilder(upperCaseName);
		for (int i = 0; i < mnemonicNameBuilder.length(); i++) {
			if (!Character.isLetter(mnemonicNameBuilder.charAt(i))
					&& !Character.isDigit(mnemonicNameBuilder.charAt(i))) {
				mnemonicNameBuilder.deleteCharAt(i);
			}
		}

		String mnemonic = mnemonicBuilder.toString();
		String mnemonicName = mnemonicNameBuilder.toString();
		if (!mnemonicName.equalsIgnoreCase(mnemonic)) {
			throw new RuntimeException(
					"Menmonic '" + mnemonic + "' derived from title '" + title + "' with of instruction '" + name
							+ "' does match mnemonic '" + mnemonicName + " derived from the name'.");

		}
	}

	public Set<Target> getCPUs() {
		return cpus;
	}

	public int getType() {
		return type;
	}

	public final String getName() {
		return name;
	}

	public final String getUpperCaseName() {
		return upperCaseName;
	}

	public final String getLowerCaseName() {
		return lowerCaseName;
	}

	public final String getTitle() {
		return title;
	}

	public final String getFormattedTitle() {
		return formattedTitle;
	}

	public final String getStyledTitle() {
		return styledTitle;
	}

	public final int[] getStyledTitleOffsets() {
		return styledTitleOffsets;
	}

	/**
	 * Gets the upper case proposal text for the instruction. By default the
	 * proposal is the same as the {@link #getName()}. In case the instruction has a
	 * mandatory parameter, a space is added. In case the proposal span several
	 * line, they are separated via {@link #NEWLINE}. The position of the cursor is
	 * defined by the character {@link #CURSOR}.
	 * 
	 * @return The proposal, not empty, not <code>null</code>.
	 */
	public final String getProposal() {
		return proposal;
	}

	@Override
	public final int compareTo(Instruction o) {
		return name.compareToIgnoreCase(o.name);
	}

	@Override
	public final String toString() {
		return "type=" + type + ", name=" + name;
	}
}