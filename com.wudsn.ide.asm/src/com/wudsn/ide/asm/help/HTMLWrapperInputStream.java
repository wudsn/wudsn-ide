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

package com.wudsn.ide.asm.help;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;

/**
 * Wraps plain text files into a HTML document envelope.
 * 
 * @author Peter Dell
 * @since 1.6.3
 * 
 */
final class HTMLWrapperInputStream extends InputStream {

	private InputStream prefixInputStream;
	private InputStream innerInputStream;
	private InputStream suffixInputStream;

	public HTMLWrapperInputStream(String prefix, String suffix, InputStream inputStream) {
		if (prefix == null) {
			throw new IllegalArgumentException("Parameter 'prefix' must not be null.");
		}
		if (suffix == null) {
			throw new IllegalArgumentException("Parameter 'suffix' must not be null.");
		}
		if (inputStream == null) {
			throw new IllegalArgumentException("Parameter 'inputStream' must not be null.");
		}

		try {
			prefixInputStream = new ByteArrayInputStream(prefix.getBytes("UTF-8"));

			innerInputStream = inputStream;
			suffixInputStream = new ByteArrayInputStream(suffix.getBytes("UTF-8"));
		} catch (UnsupportedEncodingException ex) {
			throw new RuntimeException(ex);
		}

	}

	@Override
	public int read() throws IOException {
		int result;

		if (prefixInputStream != null) {
			result = prefixInputStream.read();
			if (result != -1) {
				// System.out.print((char)result);

				return result;
			}
			prefixInputStream = null;
		}

		if (innerInputStream != null) {
			result = innerInputStream.read();
			if (result != -1) {
				// System.out.print((char)result);
				return result;
			}
			innerInputStream = null;
		}

		if (suffixInputStream != null) {
			result = suffixInputStream.read();
			if (result != -1) {
				// System.out.print((char)result);

				return result;
			}
			suffixInputStream = null;
		}
		return -1;

	}

}
