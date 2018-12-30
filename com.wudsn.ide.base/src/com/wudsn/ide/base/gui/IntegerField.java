/**
* Copyright (C) 2009 - 2014 <a href="http://www.wudsn.com" target="_top">Peter Dell</a>
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
import java.util.Arrays;
import java.util.List;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;

import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.NumberUtility;

/**
 * Numeric field for integers.
 * 
 * TODO Have explicit Hex Mode/sub class with minimum digi number for 16 bit
 * addresses
 * 
 * @author Peter Dell
 * 
 */
public final class IntegerField extends Field {

    private int[] defaultValues;
    private boolean hexMode;
    private int digitLength;

    private Combo combo;
    private Text text;
    private List<Action> selectionActions;

    /**
     * Creates a integer field.
     * 
     * @param parent
     *            The parent composite, not <code>null</code>.
     * @param labelText
     *            The label text, not <code>null</code>.
     * @param defaultValues
     *            The array of default values or <code>null</code>.
     * @param digitLength
     *            The minimum digit length, see {@link NumberUtility} and
     *            {@link HexUtility}.
     * @param hexMode
     *            <code>true</code> if display and value help shall be in hex
     *            mode
     * @param style
     *            The SWT style.
     */
    public IntegerField(Composite parent, String labelText,
	    int[] defaultValues, boolean hexMode, int digitLength, int style) {
	if (parent == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'parent' must not be null.");
	}
	if (labelText == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'labelText' must not be null.");
	}
	this.hexMode = hexMode;
	this.digitLength = digitLength;

	label = new Label(parent, SWT.NONE);
	label.setText(labelText);

	ModifyListener modifyListener= new ModifyListener() {

	    @Override
	    public void modifyText(ModifyEvent e) {
		IntegerField.this.notifyChangeListenner();

	    }
	};
	
	if (defaultValues != null) {
	    if (defaultValues.length == 0) {
		throw new IllegalArgumentException(
			"Parameter 'defaultValues0' must not be empty.");
	    }
	    combo = new Combo(parent, SWT.DROP_DOWN | style);

	    setDefaultValues(defaultValues);
	    combo.select(0);
	    combo.addModifyListener(modifyListener);

	} else {
	    text = new Text(parent, style);
	    text.addModifyListener(modifyListener);
	}


	selectionActions = new ArrayList<Action>(1);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Control getControl() {
	if (combo != null) {
	    return combo;
	}
	return text;
    }

    public void setVisible(boolean visible) {
	label.setVisible(visible);
	if (combo != null) {
	    combo.setVisible(visible);
	} else {
	    text.setVisible(visible);
	}
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void setEnabled(boolean enabled) {
	label.setEnabled(enabled);
	if (combo != null) {
	    combo.setEnabled(enabled);
	} else {
	    text.setEnabled(enabled);
	}

    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void setEditable(boolean editable) {
	if (combo != null) {
	    // There is only an SWT.READ_ONLY style but not property
	} else {
	    text.setEditable(editable);
	}

    }

    public void setDefaultValues(int[] defaultValues) {
	if (defaultValues == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'defaultValues' must not be null.");
	}

	if (defaultValues.length == 0) {
	    throw new IllegalArgumentException(
		    "Parameter 'defaultValues' must not be empty.");
	}

	if (this.defaultValues != null) {
	    if (Arrays.equals(defaultValues, this.defaultValues)) {
		return;
	    }
	}
	combo.removeAll();

	// Compute maxmimum.
	int max = 0;
	for (int defaultValue : defaultValues) {
	    if (defaultValue > max) {
		max = defaultValue;
	    }
	}

	for (int defaultValue : defaultValues) {
	    String textValue;
	    if (hexMode) {
		textValue = HexUtility.getLongValueHexString(defaultValue,
			digitLength);
	    } else {
		textValue = NumberUtility.getLongValueDecimalString(
			defaultValue, digitLength);
	    }
	    combo.add(textValue);
	}
	this.defaultValues = defaultValues;
    }

    /**
     * Sets the value.
     * 
     * @param value
     *            The value.
     */
    public void setValue(int value) {
	String textValue;
	if (hexMode) {
	    textValue = HexUtility.getLongValueHexString(value, digitLength);
	} else {
	    textValue = NumberUtility.getLongValueDecimalString(value,
		    digitLength);
	}
	for (Action action : selectionActions) {
	    action.setEnabled(false);
	}
	setText(textValue);
	for (Action action : selectionActions) {
	    action.setEnabled(true);
	}
    }

    private void setText(String value) {
	if (value == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'value' must not be null.");
	}

	if (combo != null) {
	    combo.setText(value);
	} else {
	    text.setText(value);
	}
    }

    /**
     * Gets the value.
     * 
     * @return The value.
     */
    public int getValue() {
	int result;
	String textValue = getText().toLowerCase();

	try {
	    if (hexMode) {
		result = Integer.parseInt(textValue, 16);
	    } else {
		result = Integer.parseInt(textValue);

	    }
	} catch (NumberFormatException ex) {
	    result = 0;
	}

	return result;
    }

    private String getText() {
	String result;
	if (combo != null) {
	    result = combo.getText();
	} else {
	    result = text.getText();
	}
	return result;
    }

    /**
     * Adds a selection action which is fired when the field content changes.
     * 
     * @param action
     *            The selection action, not <code>null</code>.
     */
    public void addSelectionAction(Action action) {
	if (action == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'action' must not be null.");
	}
	selectionActions.add(action);
	combo.addSelectionListener(action);
    }

}