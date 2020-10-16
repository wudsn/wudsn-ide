/**
 * Copyright (C) 2009 - 2020 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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
package com.wudsn.ide.pas.editor;

import java.util.StringTokenizer;

import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.Token;
import org.eclipse.jface.text.rules.WordRule;

/**
 * 
 * @author Peter Dell
 * @since 1.7.1
 */
public class PascalWordRule extends WordRule {

	public PascalWordRule(IToken token) {
		super(new PascalWordDetector(), new Token(""), true);

		// From C:\jac\system\Atari800\Tools\PAS\MP\geany\data\filedefs\filetypes.pascal
		String words = "absolute abstract add and array as asm assembler automated begin boolean break byte cardinal case cdecl char class const constructor contains default deprecated destructor dispid dispinterface div do downto dynamic dword else end except export exports external far file final finalization finally for forward function goto if implementation implements in index inherited initialization inline integer interface is label library longword longint message mod name near nil nodefault not object of on or out overload override package packed pascal platform private procedure program property protected public published raise read readonly real record register reintroduce remove repeat requires resourcestring safecall sealed set shl shortint smallint shr static stdcall stored strict string then threadvar to try tstring type uint32 unit unsafe until uses var varargs virtual while with word write writeonly xor";
		StringTokenizer st = new StringTokenizer(words, " ");
		while (st.hasMoreTokens()) {
			addWord(st.nextToken(), token);

		}
	}

}
