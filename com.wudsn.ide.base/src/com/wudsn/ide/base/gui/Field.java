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

import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;

/**
 * Base class for all fields.
 * 
 * @author Peter Dell
 * 
 */
public abstract class Field {

    protected Label label;
    private ChangeListener changeListener;

    /**
     * Creation is protected.
     */
    protected Field() {

    }

    /**
     * Gets the label for the field.
     * 
     * @return The label, not <code>null</code>.
     */
    public final Label getLabel() {
	if (label == null) {
	    throw new IllegalStateException("Label not yet created.");
	}
	return label;
    }

    /**
     * Gets the control relevant for messages decorations.
     * 
     * @return The control relevant for messages decorations, not
     *         <code>null</code>.
     */
    public abstract Control getControl();

    /**
     * Sets the enabled state of the field.
     * 
     * @param enabled
     *            The enabled state of the field.
     */
    public abstract void setEnabled(boolean enabled);

    /**
     * Sets the editable state of the field.
     * 
     * @param editable
     *            The editable state of the field.
     */
    public abstract void setEditable(boolean editable);

    /**
     * Adds a change listener to this field.
     * 
     * @param changeListener
     *            The change listener, not <code>null</code>.
     */
    public final void addChangeListener(ChangeListener changeListener) {
	if (changeListener == null) {
	    throw new IllegalArgumentException("Parameter 'changeListener' must not be null.");
	}
	this.changeListener = changeListener;
    }

    protected final void notifyChangeListenner() {
	if (changeListener != null) {
	    changeListener.stateChanged(new ChangeEvent(this));
	}
    }
}
