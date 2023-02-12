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

package com.wudsn.ide.lng;

import java.util.Set;
import java.util.TreeSet;

import org.eclipse.jface.text.Document;

import com.wudsn.ide.base.common.Assertions;
import com.wudsn.ide.base.common.TestMethod;
import com.wudsn.ide.lng.LanguageAnnotationValues.LanguageAnnotationValue;

/**
 * Utility class to test dynamic variables.
 * 
 * @author Peter Dell
 */
public final class LanguageAnnotationValuesTest {

	/**
	 * Creation is private.
	 */
	private LanguageAnnotationValuesTest() {
	}

	@TestMethod
	public static void main(String[] args) {
		var documment = new Document("; @com.wudsn.ide.asm.test=1");
		var values = LanguageAnnotationValues.parseDocument(documment);
		Set<String> expectedKeySet = new TreeSet<String>();
		expectedKeySet.add("@com.wudsn.ide.asm.test");
		values.keySet().equals(expectedKeySet);
		Assertions.assertEquals(values.get("@com.wudsn.ide.asm.test"),
				new LanguageAnnotationValue("@com.wudsn.ide.asm.test", "1", 1));
		System.out.println(values);
	}

}