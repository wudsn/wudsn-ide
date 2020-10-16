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

import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;

/**
 * Utility class for creating SWT components. Based on the SWT factory of the
 * JDT.
 * 
 * @author Peter Dell
 */
public final class SWTFactory {
    private SWTFactory() {
    }

    /**
     * Creates a composite that uses the parent's font and has a grid layout
     * 
     * @param parent
     *            The parent to add the composite to, not <code>null</code>.
     * @param columns
     *            The number of columns the composite should have.
     * @param hspan
     *            The horizontal span the new composite should take up in the
     *            parent.
     * @param style
     *            The fill style of the composite {@link GridData#GridData(int)}
     *            .
     * @return The new composite with a grid layout, not <code>null</code>.
     */
    public static Composite createComposite(Composite parent, int columns, int hspan, int style) {
	if (parent == null) {
	    throw new IllegalArgumentException("Parameter 'parent' must not be null.");
	}
	Composite composite = new Composite(parent, SWT.NONE);
	GridLayout gridLayout = new GridLayout(columns, false);
	gridLayout.marginWidth = 0;
	composite.setLayout(gridLayout);
	composite.setFont(parent.getFont());
	GridData gd = new GridData(style);
	gd.horizontalSpan = hspan;
	composite.setLayoutData(gd);
	return composite;
    }

    /**
     * Creates a group that uses the parent's font and has a grid layout
     * 
     * @param parent
     *            The parent to add the composite to, not <code>null</code>.
     * @param text
     *            The group title, not <code>null</code>.
     * @param columns
     *            The number of columns the composite should have.
     * @param hspan
     *            The horizontal span the new composite should take up in the
     *            parent.
     * @param fill
     *            The fill style of the composite {@link GridData}.
     * @return The new composite with a grid layout, not <code>null</code>.
     */
    public static Group createGroup(Composite parent, String text, int columns, int hspan, int fill) {
	if (parent == null) {
	    throw new IllegalArgumentException("Parameter 'parent' must not be null.");
	}
	if (text == null) {
	    throw new IllegalArgumentException("Parameter 'text' must not be null.");
	}
	Group group = new Group(parent, SWT.NONE);
	GridLayout layout = new GridLayout(columns, true);
	group.setLayout(layout);
	group.setText(text);
	group.setFont(parent.getFont());
	GridData gd = new GridData(fill);
	gd.horizontalSpan = hspan;
	group.setLayoutData(gd);
	return group;
    }

    /**
     * Create a number of labels to fill up the layout.
     * 
     * @param composite
     *            The composite which is used as parent for the label, not
     *            <code>null</code>.
     * @param number
     *            The number of labels to be created, a positive integer.
     */
    @SuppressWarnings("unused")
    public static void createLabels(Composite composite, int number) {
	if (composite == null) {
	    throw new IllegalArgumentException("Parameter 'composite' must not be null.");
	}
	if (number < 1) {
	    throw new IllegalArgumentException("Parameter 'number' must not be positive. Specified value is " + number
		    + ".");
	}
	for (int i = 0; i < number; i++) {
	    new Label(composite, SWT.NONE);
	}
    }

}