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

package com.wudsn.ide.gfx.gui;

import java.util.List;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;

import com.wudsn.ide.base.gui.Field;
import com.wudsn.ide.gfx.GraphicsPlugin;
import com.wudsn.ide.gfx.converter.ConverterDefinition;
import com.wudsn.ide.gfx.converter.ConverterRegistry;
import com.wudsn.ide.gfx.model.ConverterDirection;

public final class ConverterIdField extends Field {

    private Label label;
    private Combo combo;
    private List<ConverterDefinition> converterDefinitions;

    public ConverterIdField(Composite parent, String labelText, ConverterDirection converterDirection) {
	if (parent == null) {
	    throw new IllegalArgumentException("Parameter 'parent' must not be null.");
	}
	if (labelText == null) {
	    throw new IllegalArgumentException("Parameter 'labelText' must not be null.");
	}
	if (converterDirection == null) {
	    throw new IllegalArgumentException("Parameter 'converterDirection' must not be null.");
	}
	label = new Label(parent, SWT.NONE);
	label.setText(labelText);
	combo = new Combo(parent, SWT.DROP_DOWN);

	GraphicsPlugin plugin = GraphicsPlugin.getInstance();
	ConverterRegistry converterRegistry = plugin.getConverterRegistry();
	converterDefinitions = converterRegistry.getDefinitions(converterDirection);

	combo.add("");
	for (ConverterDefinition converterDefinition : converterDefinitions) {
	    combo.add(converterDefinition.getName());
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
	// There is only an SWT.READ_ONLY style but not property
    }

    public void setValue(String value) {
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}
	for (int i = 0; i < converterDefinitions.size(); i++) {
	    if (value.equals(converterDefinitions.get(i).getId())) {
		combo.select(i + 1);
		return;
	    }
	}
	combo.select(0);
    }

    public String getValue() {
	int index;
	index = combo.getSelectionIndex();
	if (index == -1 || index == 0) {
	    return "";
	}
	String result = converterDefinitions.get(index - 1).getId();
	return result;
    }

    public void addSelectionListener(SelectionListener selectionListener) {
	combo.addSelectionListener(selectionListener);

    }
}
