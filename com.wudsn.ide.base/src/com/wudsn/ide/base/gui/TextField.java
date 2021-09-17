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

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;

/**
 * Simple text field.
 * 
 * @author Peter Dell
 * 
 */
public final class TextField extends Field {

	private Text text;

	/**
	 * Creates a text field.
	 * 
	 * @param parent    The parent composite, not <code>null</code>.
	 * @param labelText The label text, not <code>null</code>.
	 * @param style     The SWT style.
	 */
	public TextField(Composite parent, String labelText, int style) {
		if (parent == null) {
			throw new IllegalArgumentException("Parameter 'parent' must not be null.");
		}
		if (labelText == null) {
			throw new IllegalArgumentException("Parameter 'labelText' must not be null.");
		}

		label = new Label(parent, SWT.RIGHT);
		label.setText(labelText);

		text = new Text(parent, style);

	}

	/**
	 * Gets the text control representing this text field.
	 * 
	 * @return The text control, not <code>null</code>.
	 */
	public Text getText() {
		return text;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public Control getControl() {
		return text;
	}

	public void setVisible(boolean visible) {
		label.setVisible(visible);
		text.setVisible(visible);

	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public void setEnabled(boolean enabled) {
		label.setEnabled(enabled);
		text.setEnabled(enabled);
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public void setEditable(boolean editable) {
		text.setEditable(editable);
	}

	/**
	 * Sets the value.
	 * 
	 * @param value The value, not <code>null</code>.
	 */
	public void setValue(String value) {
		if (value == null) {
			throw new IllegalArgumentException("Parameter 'value' must not be null.");
		}
		text.setText(value);
	}

	/**
	 * Gets the value.
	 * 
	 * @return The value, not <code>null</code>.
	 */
	public String getValue() {
		String result;
		result = text.getText();
		result = result.trim();
		return result;

	}

}