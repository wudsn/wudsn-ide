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

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;

import com.wudsn.ide.base.common.MarkerUtility;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.lng.compiler.CompilerFiles.SourceFile;

public final class LanguageAnnotationValues {

	/**
	 * A single key value pair.
	 * 
	 * @since 1.6.1
	 */
	public static final class LanguageAnnotationValue {
		public final String key;
		public final String value;
		public final int lineNumber;
		public final List<IStatus> statusList;

		LanguageAnnotationValue(String key, String value, int lineNumber) {
			this.key = key;
			this.value = value;
			this.lineNumber = lineNumber;
			this.statusList = new ArrayList<IStatus>(1);
		}

		public boolean equals(Object other) {
			if (other instanceof LanguageAnnotationValue) {
				LanguageAnnotationValue otherObject = (LanguageAnnotationValue) other;
				if (!this.key.equals(otherObject.key)) {
					return false;
				}
				if (!this.value.equals(otherObject.value)) {
					return false;
				}
				if (this.lineNumber != (otherObject.lineNumber)) {
					return false;
				}
				return true;
			}
			return false;
		}

		@Override
		public String toString() {
			return key + "=" + value + " in line " + lineNumber;
		}
	}

	@SuppressWarnings("serial")
	public final static class InvalidLanguageAnnotationException extends Exception {
		public final LanguageAnnotationValue value;
		public final IMarker marker;

		public InvalidLanguageAnnotationException(LanguageAnnotationValue property, IMarker marker) {
			if (property == null) {
				throw new IllegalArgumentException("Parameter 'value' must not be null.");
			}
			this.value = property;
			this.marker = marker;
		}
	}

	private Map<String, LanguageAnnotationValue> properties;

	/**
	 * Creation is public.
	 */
	public LanguageAnnotationValues() {
		properties = new TreeMap<String, LanguageAnnotationValues.LanguageAnnotationValue>();
	}

	/**
	 * Puts a new value into the properties provided not other value is already
	 * there.
	 * 
	 * @param key        The value key, not empty and not <code>null</code>.
	 * @param value      The value value, may be empty, not <code>null</code>.
	 * @param lineNumber The line number, a positive integer or 0 if the line number
	 *                   is undefined.
	 * @since 1.6.1
	 */
	public void put(String key, String value, int lineNumber) {
		if (key == null) {
			throw new IllegalArgumentException("Parameter 'key' must not be null.");
		}
		if (StringUtility.isEmpty(key)) {
			throw new IllegalArgumentException("Parameter 'key' must not be empty.");
		}
		if (value == null) {
			throw new IllegalArgumentException("Parameter 'value' must not be null.");
		}
		if (lineNumber < 0l) {
			throw new IllegalArgumentException(
					"Parameter 'lineNumber' must not be negative. Specified value is " + lineNumber + ".");
		}
		if (!properties.containsKey(key)) {
			LanguageAnnotationValue property = new LanguageAnnotationValue(key, value, lineNumber);
			properties.put(key, property);
		}
	}

	public Set<String> keySet() {
		return new TreeSet<String>(properties.keySet());
	}

	/**
	 * Gets a value from the properties map.
	 * 
	 * @param key The value key, not empty and not <code>null</code>.
	 * @return The value or <code>null</code> if the value is not defined.
	 * 
	 * @since 1.6.1
	 */
	public LanguageAnnotationValue get(String key) {
		if (key == null) {
			throw new IllegalArgumentException("Parameter 'key' must not be null.");
		}
		if (StringUtility.isEmpty(key)) {
			throw new IllegalArgumentException("Parameter 'key' must not be empty.");
		}
		return properties.get(key);
	}

	@Override
	public String toString() {
		return properties.toString();
	}

	public static LanguageAnnotationValues parseDocument(IDocument document) {
		if (document == null) {
			throw new IllegalArgumentException("Parameter 'document' must not be null.");
		}
		String content = document.get();
		LanguageAnnotationValues result = new LanguageAnnotationValues();

		int index = getMinIndex(content.indexOf(LanguageAnnotation.PREFIX),
				content.indexOf(LanguageAnnotation.OLD_PREFIX));
		while (index >= 0) {

			int indexEqualSign = content.indexOf('=', index);
			int indexNewLine = content.indexOf('\n', index);
			if (indexNewLine < 0) {
				indexNewLine = content.indexOf('\r', index);
			}
			if (indexNewLine < 0) {
				indexNewLine = content.length();
			}

			if (indexEqualSign >= 0 && indexEqualSign < indexNewLine) {
				String key = content.substring(index, indexEqualSign).trim();
				String value = content.substring(indexEqualSign + 1, indexNewLine).trim();
				int lineNumber;
				try {
					lineNumber = document.getLineOfOffset(index) + 1;
				} catch (BadLocationException ex) {
					lineNumber = 0;
				}
				result.put(key, value, lineNumber);
			}
			index = getMinIndex(content.indexOf(LanguageAnnotation.PREFIX, indexNewLine),
					content.indexOf(LanguageAnnotation.OLD_PREFIX, indexNewLine));
		}

		checkAnnotations(result);
		return result;
	}

	/**
	 * Gets the smaller of two string indexes. Values less than 0 indicate "not
	 * found" and are ignored.
	 * 
	 * @param index1 The first index
	 * @param index2 The second index
	 * @return The smaller index or a value less than 0 if no index is valid.
	 */
	private static int getMinIndex(int index1, int index2) {
		if (index1 < 0) {
			return index2;
		}
		if (index2 < 0) {
			return index1;
		}
		return Math.min(index1, index2);
	}

	private static void checkAnnotations(LanguageAnnotationValues annotationValues) {
		if (annotationValues == null) {
			throw new IllegalArgumentException("Parameter 'annotationValues' must not be null.");
		}

		var annotations = LanguageAnnotation.getAnnotations();
		for (String key : annotationValues.keySet()) {
			var value = annotationValues.get(key);
			if (key.startsWith(LanguageAnnotation.OLD_PREFIX)) {
				var newKey = LanguageAnnotation.PREFIX + key.substring(LanguageAnnotation.OLD_PREFIX.length());
				// WARNING: Use annotation '{0}' instead of the deprecated annotation '{1}'.
				value.statusList.add(new Status(IStatus.WARNING, LanguagePlugin.ID,
						TextUtility.format(Texts.MESSAGE_W144, new String[] { newKey, key })));
				// New annotations take precedence if they are already present.
				if (!annotationValues.keySet().contains(newKey)) {
					annotationValues.put(newKey, value.value, value.lineNumber);
				}
				key = newKey;
			}
			if (!annotations.contains(key)) {
				// ERROR: Annotation '{0}' is unknown.
				value.statusList.add(new Status(IStatus.WARNING, LanguagePlugin.ID,
						TextUtility.format(Texts.MESSAGE_E145, new String[] { key })));
			}
		}

	}
}
