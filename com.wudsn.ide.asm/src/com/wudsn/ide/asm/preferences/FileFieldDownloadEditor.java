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

package com.wudsn.ide.asm.preferences;

import org.eclipse.jface.preference.FieldEditor;
import org.eclipse.jface.preference.FileFieldEditor;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.program.Program;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Link;
import org.eclipse.swt.widgets.Listener;

import com.wudsn.ide.asm.Texts;
import com.wudsn.ide.base.common.TextUtility;

/**
 * Extended file field editor with build-in download link.
 * 
 * @author Peter Dell
 */
final class FileFieldDownloadEditor extends FileFieldEditor {

	Link link;

	public FileFieldDownloadEditor(String name, String labelText, Composite parent) {
		super(name, labelText, parent);
	}

	/**
	 * Override the method declared in {@link FieldEditor}.
	 */
	@Override
	public int getNumberOfControls() {
		return 4;
	}

	@Override
	protected void doFillIntoGrid(Composite parent, int numColumns) {
		super.doFillIntoGrid(parent, numColumns - 1);
		if (link == null) {
			link = new Link(parent, SWT.NONE);
			link.addDisposeListener(new DisposeListener() {
				@Override
				public void widgetDisposed(DisposeEvent event) {
					link = null;
				}
			});

			link.addListener(SWT.Selection, new Listener() {
				@Override
				public void handleEvent(Event event) {
					String url = event.text;
					if (url != null && url.length() > 0) {
						Program.launch(event.text);
					}
				}
			});

		}
		GridData gd = new GridData();
		gd.horizontalAlignment = GridData.FILL;
		link.setLayoutData(gd);
	}

	@Override
	protected void adjustForNumColumns(int numColumns) {
		((GridData) getTextControl().getLayoutData()).horizontalSpan = numColumns - 3;
	}

	/**
	 * Do not reset path to default.
	 */
	@Override
	public void loadDefault() {
	}

	/**
	 * Do not check input as file to allow selecting ".app" directories on MacOS X.
	 * 
	 * @return <code>true</code> in all cases.
	 */
	@Override
	protected boolean checkState() {
		return true;

	}

	/**
	 * Sets the URL for the link label.
	 * 
	 * @param url The URL, may be empty, not <code>null</code>.
	 */
	public void setLinkURL(String url) {
		if (link == null) {
			throw new IllegalArgumentException("Parameter 'link' must not be null.");
		}
		if (url == null) {
			throw new IllegalArgumentException("Parameter 'url' must not be null.");
		}

		if (url.length() > 0) {
			link.setText("<a href=\"" + url + "\">" + Texts.PREFERENCES_DOWNLOAD_LINK + "</a>");
			link.setToolTipText(TextUtility.format(Texts.PREFERENCES_DOWNLOAD_LINK_TOOL_TIP, url));

		} else {
			link.setText("");
			link.setToolTipText("");
		}
	}
}