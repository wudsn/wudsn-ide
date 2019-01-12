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

package com.wudsn.ide.asm.help;

import java.util.ArrayList;
import java.util.List;

/**
 * Convenience HTML writer.
 * 
 * @author Peter Dell
 * @since 1.6.3
 */
final class HTMLWriter {
    private static final String BORDER_STYLE = "border-style:solid;border-width:1px;border-collapse:collapse;";

    private StringBuilder builder;
    private List<String> stack;
    private boolean tableBorder;

    public HTMLWriter() {
	builder = new StringBuilder();
	stack = new ArrayList<String>();
    }

    public void begin(String tag, String attributes) {
	if (tag == null) {
	    throw new IllegalArgumentException("Parameter 'tag' must not be null.");
	}
	builder.append("<");
	builder.append(tag);

	if (attributes != null) {
	    builder.append(" ");
	    builder.append(attributes);

	} else {
	    if ((tag.equals("th") || tag.equals("td")) && tableBorder) {
		builder.append(" style=\"border:1px solid\"");
	    }
	}
	builder.append(">");
	stack.add(tag);
    }

    public void end() {
	if (stack.isEmpty()) {
	    throw new RuntimeException("No open tag: " + builder);
	}
	String tag = stack.remove(stack.size() - 1);
	builder.append("</");
	builder.append(tag);
	builder.append(">\n");

	if (tag.equals("table")) {
	    tableBorder = false;
	}

    }

    public void writeText(String text) {
	if (text == null) {
	    throw new IllegalArgumentException("Parameter 'text' must not be null.");
	}
	builder.append(text);
    }

    public void beginTable() {
	beginTable(true);
    }

    public void beginTable(boolean border) {
	tableBorder = border;

	begin("table", "style=\"text-align:left;" + (tableBorder ? BORDER_STYLE : "") + "\"");
    }

    public void beginTableRow() {
	begin("tr", null);
    }

    public void writeTableRow(String header, String text) {
	if (header == null) {
	    throw new IllegalArgumentException("Parameter 'header' must not be null.");
	}
	if (text == null) {
	    throw new IllegalArgumentException("Parameter 'text' must not be null.");
	}
	beginTableRow();
	writeTableHeader(header);
	writeTableCell(text);
	end();
    }

    public void writeTableRowCode(String header, String text) {
	beginTableRow();
	writeTableHeader(header);
	begin("td", "style=\"vertical-align:text-top;font-family:Courier New, Courier, monospace;border:1px solid;\"");

	// Cell content must not be empty, otherwise the border is not
	// displayed.
	if (text.trim().length() == 0) {
	    text = "&nbsp;";
	}
	builder.append(text);
	end();
	end();
    }

    public void writeTableRowCode(String header, char character) {
	String text = "";
	if (character >= 32) {
	    text = Character.toString(character);
	}
	writeTableRowCode(header, text);
    }

    public void writeTableHeader(String text) {
	if (text == null) {
	    throw new IllegalArgumentException("Parameter 'text' must not be null.");
	}
	begin("th", "style=\"" + (tableBorder ? BORDER_STYLE : "") + ";vertical-align:text-top;white-space:nowrap;\"");
	builder.append(text);
	end();
    }

    public void writeTableCell(String text) {
	if (text == null) {
	    throw new IllegalArgumentException("Parameter 'text' must not be null.");
	}
	begin("td", "style=\"" + (tableBorder ? BORDER_STYLE : "") + ";vertical-align:text-top;white-space:nowrap;\"");
	builder.append(text);
	end();
    }

    public void beginList() {
	begin("ul", null);
    }

    public void writeListItem(String text) {
	if (text == null) {
	    throw new IllegalArgumentException("Parameter 'text' must not be null.");
	}
	begin("li", null);
	builder.append(text);
	end();
    }

    public String toHTML() {
	if (!stack.isEmpty()) {
	    throw new IllegalStateException("There are still open tags: " + stack + "\n" + builder.toString());
	}
	return builder.toString();
    }

    public static String getImage(String src, String alt, String text) {
	if (src == null) {
	    throw new IllegalArgumentException("Parameter 'src' must not be null.");
	}
	if (alt == null) {
	    throw new IllegalArgumentException("Parameter 'alt' must not be null.");
	}
	if (text == null) {
	    throw new IllegalArgumentException("Parameter 'text' must not be null.");
	}
	return "<img style=\"vertical-align:middle\" src=\"" + src + "\" alt=\"" + alt + "\"/> " + text;
    }

    public static String getLink(String href, String text) {
	if (href == null) {
	    throw new IllegalArgumentException("Parameter 'href' must not be null.");
	}

	if (text == null) {
	    throw new IllegalArgumentException("Parameter 'text' must not be null.");
	}
	return "<a href=\"" + href + "\" >" + text + "</a>";
    }

    public static String getString(List<String> list) {
	if (list == null) {
	    throw new IllegalArgumentException("Parameter 'list' must not be null.");
	}
	StringBuilder builder = new StringBuilder();
	int size = list.size();
	for (int i = 0; i < size; i++) {
	    builder.append(list.get(i));
	    if (i < size - 1) {
		builder.append(" ");
	    }
	}
	return builder.toString();
    }
}
