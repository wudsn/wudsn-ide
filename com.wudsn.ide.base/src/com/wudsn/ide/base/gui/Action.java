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

import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;

/**
 * Action class which abstracts from SWT.
 * 
 * @author Peter Dell
 * 
 */
public final class Action implements SelectionListener {

    private int id;
    private ActionListener actionListener;
    private boolean enabled;

    /**
     * Creates a new action.
     * 
     * @param id
     *            The action is, a non-negative integer.
     * @param actionListener
     *            The action listener, not <code>null</code>.
     */
    public Action(int id, ActionListener actionListener) {
	if (id < 0) {
	    throw new IllegalArgumentException("Parameter 'id' must not be negative. Specified value is " + id + ".");
	}
	if (actionListener == null) {
	    throw new IllegalArgumentException("Parameter 'actionListener' must not be null.");
	}
	this.id = id;
	this.actionListener = actionListener;
	this.enabled = true;
    }

    /**
     * Gets the id of the action.
     * 
     * @return The id of the action, a non-negative integer.
     */
    public int getId() {
	return id;
    }

    /**
     * Sets the enabled state of the action. Disabled actions do not fire.
     * 
     * @param enabled
     *            <code>true</code> to enable the action, <code>false</code> to
     *            disable the action.
     */
    public void setEnabled(boolean enabled) {
	this.enabled = enabled;

    }

    /**
     * Callback from SWT, do not use.
     */
    @Override
    public void widgetDefaultSelected(SelectionEvent e) {
	performAction();
    }

    /**
     * Callback from SWT, do not use.
     */
    @Override
    public void widgetSelected(SelectionEvent e) {
	performAction();

    }

    private void performAction() {
	if (enabled) {
	    actionListener.performAction(this);
	}
    }

    @Override
    public String toString() {
	return "actionId=" + id;
    }

}
