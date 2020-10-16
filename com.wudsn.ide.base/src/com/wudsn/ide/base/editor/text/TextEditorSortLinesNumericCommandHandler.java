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

package com.wudsn.ide.base.editor.text;

import java.util.Comparator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.wudsn.ide.base.common.StringUtility;

/**
 * Action to sort lines by the first decimal number found starting at first
 * position.
 * 
 * @author Peter Dell
 */
public final class TextEditorSortLinesNumericCommandHandler extends TextEditorSortLinesCommandHandler {

    private static final class NumericComparator implements Comparator<String> {

	private static final Double MAXIMUM = new Double(Double.POSITIVE_INFINITY);
	private static final Pattern numericPattern = Pattern.compile("[-+]?([0-9]*\\.)?[0-9]+([eE][-+]?[0-9]+)?"); //$NON-NLS-1$

	public NumericComparator() {

	}

	@Override
	public int compare(String o1, String o2) {
	    return getNumber(o1).compareTo(getNumber(o2));
	}

	private Double getNumber(String text) {
	    Double result;

	    result = MAXIMUM;

	    if (text != null && StringUtility.isSpecified(text)) {
		try {
		    Matcher m = numericPattern.matcher(text);
		    if (m.find()) {
			text = text.substring(m.start(), m.end());
			result = Double.valueOf(text);
		    }

		} catch (NumberFormatException ignore) {

		}
	    }
	    return result;
	}
    }

    private static final NumericComparator COMPARATOR = new NumericComparator();

    @Override
    protected Comparator<String> getComparator() {
	return COMPARATOR;
    }

}
