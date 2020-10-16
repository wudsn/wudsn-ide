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

package com.wudsn.ide.base.gui;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;

/**
 * Check box field for boolean value.
 * 
 * @author Peter Dell
 * 
 * @since 1.6.0
 */
public final class CheckBoxField extends Field {

    private Button button;
    private List<Action> selectionActions;

    /**
     * Creates a check box field.
     * 
     * @param parent
     *            The parent composite, not <code>null</code>.
     * @param labelText
     *            The label text, not <code>null</code>.
     * @param style
     *            The SWT style.
     */
    public CheckBoxField(Composite parent, String labelText, int style) {
	if (parent == null) {
	    throw new IllegalArgumentException("Parameter 'parent' must not be null.");
	}
	if (labelText == null) {
	    throw new IllegalArgumentException("Parameter 'labelText' must not be null.");
	}

	label = new Label(parent, SWT.NONE);
	label.setText(labelText);
	button = new Button(parent, SWT.CHECK | style);
	selectionActions = new ArrayList<Action>(1);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Control getControl() {
	return button;
    }

    public void setVisible(boolean visible) {
	label.setVisible(visible);
	button.setVisible(visible);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void setEnabled(boolean enabled) {
	label.setEnabled(enabled);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void setEditable(boolean editable) {
	button.setEnabled(editable);
    }

    /**
     * Sets the value.
     * 
     * @param value
     *            The value.
     */
    public void setValue(boolean value) {
	button.setSelection(value);
    }

    /**
     * Gets the value.
     * 
     * @return The value.
     */
    public boolean getValue() {

	return button.getSelection();
    }

    /**
     * Adds a selection action which is fire when the field content changes.
     * 
     * @param action
     *            The selection action, not <code>null</code>.
     */
    public void addSelectionAction(Action action) {
	if (action == null) {
	    throw new IllegalArgumentException("Parameter 'action' must not be null.");
	}
	selectionActions.add(action);
	button.addSelectionListener(action);
    }

}