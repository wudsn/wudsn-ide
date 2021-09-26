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
package com.wudsn.ide.base.gui;

import java.util.ArrayList;
import java.util.List;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;

import com.wudsn.ide.base.BasePlugin;
import com.wudsn.ide.base.common.ResourceBundleUtility;

/**
 * Combo field offering the elements of an enum class in generic and type safe
 * manner.
 * 
 * @author Peter Dell
 * 
 * @param <T> The enum class.
 */
public final class EnumField<T extends Enum<?>> extends Field {

	private static final class Entry<T> {
		public T constant;
		public String name;
		public String text;

		public Entry() {
		}

	}

	private Combo combo;
	private List<Entry<T>> entries;

	/**
	 * Creates a new enum field.
	 * 
	 * @param parent        The parent composite, not <code>null</code>.
	 * @param labelText     The label text, not <code>null</code>.
	 * @param enumClass     The enum class, not <code>null</code>.
	 * @param visibleValues The non-empty array containing the subset of enum values
	 *                      to be displayed or <code>null</code> to display all
	 *                      values.
	 */
	public EnumField(Composite parent, String labelText, Class<? extends T> enumClass, T visibleValues[]) {
		if (parent == null) {
			throw new IllegalArgumentException("Parameter 'parent' must not be null.");
		}
		if (labelText == null) {
			throw new IllegalArgumentException("Parameter 'labelText' must not be null.");
		}
		if (enumClass == null) {
			throw new IllegalArgumentException("Parameter 'enumClass' must not be null.");
		}
		if (visibleValues != null && visibleValues.length == 0) {
			throw new IllegalArgumentException("Parameter 'visibleValues' must not be empty");
		}
		label = new Label(parent, SWT.NONE);
		label.setText(labelText);
		combo = new Combo(parent, SWT.DROP_DOWN);

		ResourceBundle resourceBundle;
		resourceBundle = ResourceBundleUtility.getResourceBundle(enumClass);

		T[] constants = enumClass.getEnumConstants();

		if (constants.length == 0) {
			throw new IllegalArgumentException("Enum class '" + enumClass + "' has no constants.");
		}

		// Ensure all visible values are contained in the set of constants.
		if (visibleValues != null) {
			for (int i = 0; i < visibleValues.length; i++) {
				T visibleValue = visibleValues[i];
				boolean found = false;
				for (int j = 0; j < constants.length; j++) {
					if (constants[j] == visibleValue) {
						found = true;
						continue;
					}
				}
				if (!found) {
					throw new IllegalArgumentException(
							"Parameter 'visibleValues' contain the undefined value '" + visibleValue + "'.");
				}
			}
			constants = visibleValues;
		}

		// Read the localized texts and create the entries.
		entries = new ArrayList<Entry<T>>(constants.length);
		for (int i = 0; i < constants.length; i++) {
			Entry<T> entry = new Entry<T>();
			entry.constant = constants[i];
			entry.name = constants[i].name();
			String key = enumClass.getName() + "." + entry.name;
			try {
				entry.text = resourceBundle.getString(key);
			} catch (MissingResourceException ex) {
				entry.text = entry.name + " - Text missing";
				BasePlugin.getInstance().logError("Resource for enum value {0} is missing.", new Object[] { key }, ex);
			}

			entries.add(entry);
		}

		for (Entry<T> entry : entries) {
			combo.add(entry.text);
		}
		combo.select(0);

	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public Control getControl() {
		return combo;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public void setEnabled(boolean enabled) {
		label.setEnabled(enabled);
		combo.setEnabled(enabled);

	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public void setEditable(boolean editable) {
		// There is only a style SWT#READ_ONLY, but no changeable property
	}

	/**
	 * Sets the value.
	 * 
	 * @param value The value, not <code>null</code>.
	 */
	public void setValue(T value) {
		if (value == null) {
			throw new IllegalArgumentException("Parameter 'value' must not be null.");
		}
		for (int i = 0; i < entries.size(); i++) {
			if (value.name().equals(entries.get(i).name)) {
				combo.select(i);
				break;
			}
		}
	}

	/**
	 * Gets the value.
	 * 
	 * @return The value, not <code>null</code>.
	 */
	public T getValue() {
		int index;
		index = combo.getSelectionIndex();
		if (index == -1) {
			throw new IllegalStateException("No item selected");
		}
		T result = entries.get(index).constant;
		return result;
	}

	/**
	 * Adds a selection action.
	 * 
	 * @param action The selection action, not <code>null</code>.
	 */
	public void addSelectionAction(Action action) {
		if (action == null) {
			throw new IllegalArgumentException("Parameter 'action' must not be null.");
		}
		combo.addSelectionListener(action);

	}

}
