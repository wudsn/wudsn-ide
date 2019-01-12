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

package com.wudsn.ide.base.editor.text;

import java.util.Comparator;

/**
 * Action to sort lines case sensitively.
 * 
 * @author Peter Dell
 */
public final class TextEditorSortLinesCaseSensitiveCommandHandler extends TextEditorSortLinesCommandHandler {

    private static final Comparator<String> CASE_SENSITIVE_COMPARATOR = new CaseSensitiveComparator();

    private static class CaseSensitiveComparator implements Comparator<String> {

	public CaseSensitiveComparator() {
	}

	@Override
	public int compare(String o1, String o2) {
	    return o1.compareTo(o2);
	}
    }

    @Override
    protected Comparator<String> getComparator() {
	return CASE_SENSITIVE_COMPARATOR;
    }

}
