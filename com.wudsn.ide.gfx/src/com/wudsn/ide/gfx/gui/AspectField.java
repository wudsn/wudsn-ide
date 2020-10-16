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

package com.wudsn.ide.gfx.gui;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;

import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.gui.Action;
import com.wudsn.ide.base.gui.Field;
import com.wudsn.ide.gfx.model.Aspect;
import com.wudsn.ide.gfx.model.AspectUtility;

public final class AspectField extends Field {

    private Label label;
    private Combo combo;
    private List<Action> selectionActions;

    public AspectField(Composite parent, String labelText) {
	if (parent == null) {
	    throw new IllegalArgumentException("Parameter 'parent' must not be null.");
	}
	if (labelText == null) {
	    throw new IllegalArgumentException("Parameter 'labelText' must not be null.");
	}

	label = new Label(parent, SWT.NONE);
	label.setText(labelText);
	combo = new Combo(parent, SWT.DROP_DOWN);

	combo.add("1x1");
	combo.add("2x1");
	combo.add("2x2");
	combo.add("4x2");
	combo.add("4x4");

	combo.select(0);

	selectionActions = new ArrayList<Action>(1);
    }

    public void setValue(Aspect value) {
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}
	for (Action action : selectionActions) {
	    action.setEnabled(false);
	}
	combo.setText(AspectUtility.toString(value));
	for (Action action : selectionActions) {
	    action.setEnabled(true);
	}
    }

    public Aspect getValue() {
	Aspect result;
	String text = combo.getText().toLowerCase();
	if (StringUtility.isEmpty(text)) {
	    result = new Aspect(1, 1);
	} else {
	    result = AspectUtility.fromString(text);
	}
	return result;

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
	combo.addSelectionListener(action);
    }

}