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

package com.wudsn.ide.lng.help;

/**
 * HTML Constants.
 * 
 * @author Peter Dell
 * @since 1.6.3
 */
final class HTMLConstants {
	public static final String UTF8 = "UTF-8";

	private static final String NL = "\n";
	private static final String DOC_TYPE = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">";
	private static final String CONTENT_TYPE = "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=" + UTF8
			+ "\" />";
	private static final String STYLE_SHEETS = "<link rel=\"STYLESHEET\" href=\"/help/content/org.eclipse.platform/book.css\" type=\"text/css\" />"
			+ NL + "<link rel=\"stylesheet\" type=\"text/css\" media=\"all\" href=\"stylesheets/ide.css\"/>";

	public static final String PREFIX = DOC_TYPE + NL + "<html xmlns=\"http://www.w3.org/1999/xhtml\">" + NL + "<head>"
			+ NL + HTMLConstants.CONTENT_TYPE + NL + HTMLConstants.STYLE_SHEETS + NL + "</head><body>";
	public static final String SUFFIX = "</body>" + NL + "</html>";

	public static final String BR = "<br>";

}
