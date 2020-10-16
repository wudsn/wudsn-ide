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

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import org.eclipse.core.commands.Command;

/**
 * Base class for text editor actions sorting on the selected lines.
 * 
 * @author Peter Dell
 */
abstract class TextEditorSortLinesCommandHandler extends TextEditorLinesCommandHandler {

    @Override
    protected void process(Command command, List<String> lines) {
	if (command == null) {
	    throw new IllegalArgumentException("Parameter 'command' must not be null.");
	}
	if (lines == null) {
	    throw new IllegalArgumentException("Parameter 'lines' must not be null.");
	}
	Comparator<String> comparator = getComparator();
	Collections.sort(lines, comparator);

	if (command.getId().endsWith("WithoutDuplicatesCommand")) {
	    int i = 0;
	    while (lines.size() > 1 && i < lines.size() - 1) {
		String line1 = lines.get(i);
		String line2 = lines.get(i + 1);
		int result = comparator.compare(line1, line2);
		if (result == 0) {
		    lines.remove(i + 1);
		} else {
		    i++;
		}
	    }
	}
    }

    /**
     * Sub classes must provide a comparator for strings.
     * 
     * @return The comparator, not <code>null</code>.
     */
    protected abstract Comparator<String> getComparator();

}
