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
import org.eclipse.swt.custom.Bullet;
import org.eclipse.swt.custom.CaretEvent;
import org.eclipse.swt.custom.CaretListener;
import org.eclipse.swt.custom.LineBackgroundEvent;
import org.eclipse.swt.custom.LineBackgroundListener;
import org.eclipse.swt.custom.LineStyleEvent;
import org.eclipse.swt.custom.LineStyleListener;
import org.eclipse.swt.custom.ST;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.GlyphMetrics;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;

/**
 * Multi line text field without label.
 * 
 * @author Peter Dell
 * 
 * @since 1.6.0
 */
public final class MultiLineTextField extends Field {

    static final Color LINE_NUMBER_COLOR = new Color(Display.getCurrent(), new RGB(0, 0, 255));
    static final Color LINE_HIGHLIGHT_COLOR = new Color(Display.getCurrent(), new RGB(220, 220, 255));

    Color parentBackground;
    Color ownBackground;
    private StyledText text;
    private ModifyListener textModifyListener;

    /**
     * Creates a text field.
     * 
     * @param parent
     *            The parent composite, not <code>null</code>.
     * @param style
     *            The SWT style.
     */
    public MultiLineTextField(final Composite parent, int style) {
	if (parent == null) {
	    throw new IllegalArgumentException("Parameter 'parent' must not be null.");
	}

	parentBackground = parent.getBackground();
	text = new StyledText(parent, style | SWT.MULTI);
	ownBackground = text.getBackground();

	text.addCaretListener(new CaretListener() {

	    @Override
	    public void caretMoved(CaretEvent event) {
		StyledText text = (StyledText) event.widget;
		text.redraw();
	    }
	});
	text.addLineStyleListener(new LineStyleListener() {
	    @Override
	    public void lineGetStyle(LineStyleEvent event) {
		// Set the line number
		StyledText text = (StyledText) event.widget;
		event.bulletIndex = text.getLineAtOffset(event.lineOffset);

		// Set the style, 12 pixels wide for each digit
		StyleRange style = new StyleRange();
		style.metrics = new GlyphMetrics(0, 0, Integer.toString(text.getLineCount() + 1).length() * 12);
		style.foreground = LINE_NUMBER_COLOR;

		// Create and set the bullet
		event.bullet = new Bullet(ST.BULLET_NUMBER, style);
	    }
	});

	text.addLineBackgroundListener(new LineBackgroundListener() {

	    @Override
	    public void lineGetBackground(LineBackgroundEvent event) {
		StyledText text = (StyledText) event.widget;
		if (text.getEditable()) {
		    if (text.getLineAtOffset(event.lineOffset) == text.getLineAtOffset(text.getCaretOffset())) {
			event.lineBackground = LINE_HIGHLIGHT_COLOR;
		    } else {
			event.lineBackground = ownBackground;
		    }
		} else {
		    event.lineBackground = parentBackground;
		}
	    }
	});

	textModifyListener = new ModifyListener() {
	    @Override
	    public void modifyText(ModifyEvent e) {
		MultiLineTextField.this.notifyChangeListenner();
	    }
	};
    }

    /**
     * Gets the text control representing this text field.
     * 
     * @return The text control, not <code>null</code>.
     */
    public StyledText getText() {
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
	text.setVisible(visible);

    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void setEnabled(boolean enabled) {
	text.setEnabled(enabled);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void setEditable(boolean editable) {
	text.setEditable(editable);
	text.setBackground(editable ? ownBackground : parentBackground);
    }

    /**
     * Sets the value.
     * 
     * @param value
     *            The value, not <code>null</code>.
     */
    public void setValue(String value) {
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}
	if (!value.equals(text.getText())) {
	    text.removeModifyListener(textModifyListener);
	    text.setText(value);
	    text.addModifyListener(textModifyListener);
	}
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

    /**
     * Sets the selection.
     * <p>
     * Indexing is zero based. The range of a selection is from 0..N where N is
     * the number of characters in the widget.
     * 
     * @param start
     *            new caret position.
     */

    public void setSelection(int start) {
	text.setSelection(start);
	text.setFocus();
    }

}