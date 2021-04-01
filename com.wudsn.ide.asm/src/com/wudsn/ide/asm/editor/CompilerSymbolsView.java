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

package com.wudsn.ide.asm.editor;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import org.eclipse.jface.viewers.ArrayContentProvider;
import org.eclipse.jface.viewers.ColumnLabelProvider;
import org.eclipse.jface.viewers.ColumnViewerToolTipSupport;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.jface.viewers.TableViewerColumn;
import org.eclipse.jface.window.ToolTip;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.KeyAdapter;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableColumn;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.part.ViewPart;

import com.wudsn.ide.asm.Texts;
import com.wudsn.ide.asm.compiler.CompilerFiles;
import com.wudsn.ide.asm.compiler.CompilerSymbol;
import com.wudsn.ide.asm.compiler.CompilerSymbolType;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.TextUtility;

// TODO Add column sorting
public final class CompilerSymbolsView extends ViewPart {

    public static final String ID = "com.wudsn.ide.asm.editor.CompilerSymbolsView";

    // Model
    private CompilerFiles compilerFiles;
    private List<CompilerSymbol> compilerSymbols;
    private Date updateTimestamp;

    // View
    private Text filterTextField;
    private Label sourceFileNameText;
    private Label symbolsCountText;
    private TableViewer viewer;

    public CompilerSymbolsView() {
	compilerFiles = null;
	compilerSymbols = Collections.emptyList();
	updateTimestamp = null;
    }

    @Override
    public void createPartControl(Composite parent) {
	GridLayout layout = new GridLayout(4, false);
	parent.setLayout(layout);
	filterTextField = new Text(parent, SWT.BORDER | SWT.SEARCH);
	filterTextField.setToolTipText(Texts.COMPILER_SYMBOLS_VIEW_FILTER_TOOLTIP);
	filterTextField.setMessage(filterTextField.getToolTipText());
	filterTextField.setLayoutData(new GridData(GridData.GRAB_HORIZONTAL | GridData.HORIZONTAL_ALIGN_FILL));

	// Filter as you type...
	filterTextField.addKeyListener(new KeyAdapter() {
	    @Override
	    public void keyReleased(KeyEvent e) {
		dataToUI();
	    }
	});
	Label sourceFileNameLabel = new Label(parent, SWT.NONE);
	sourceFileNameLabel.setText(Texts.COMPILER_SYMBOLS_VIEW_SOURCE_LABEL);
	sourceFileNameText = new Label(parent, SWT.NONE);
	symbolsCountText = new Label(parent, SWT.NONE);
	createViewer(parent);
    }

    private void createViewer(Composite parent) {
	if (parent == null) {
	    throw new IllegalArgumentException("Parameter 'parent' must not be null.");
	}
	viewer = new TableViewer(parent, SWT.MULTI | SWT.H_SCROLL | SWT.V_SCROLL | SWT.FULL_SELECTION | SWT.BORDER);
	createColumns(parent, viewer);
	final Table table = viewer.getTable();
	table.setHeaderVisible(true);
	table.setLinesVisible(true);

	viewer.setContentProvider(new ArrayContentProvider());
	dataToUI();

	// Make the selection available to other views
	getSite().setSelectionProvider(viewer);

	// Set the sorter for the table

	// Define layout for the viewer
	GridData gridData = new GridData();
	gridData.verticalAlignment = GridData.FILL;
	gridData.horizontalSpan = 4;
	gridData.grabExcessHorizontalSpace = true;
	gridData.grabExcessVerticalSpace = true;
	gridData.horizontalAlignment = GridData.FILL;
	viewer.getControl().setLayoutData(gridData);

	// Activate the tooltip support for the viewer
	ColumnViewerToolTipSupport.enableFor(viewer, ToolTip.NO_RECREATE);
    }

    // create the columns for the table
    private void createColumns(final Composite parent, final TableViewer viewer) {
	if (parent == null) {
	    throw new IllegalArgumentException("Parameter 'parent' must not be null.");
	}
	if (viewer == null) {
	    throw new IllegalArgumentException("Parameter 'viewer' must not be null.");
	}
	int index = 0;

	// Column: Type
	final CompilerSymbolLabelProvider labelProvider = new CompilerSymbolLabelProvider();
	TableViewerColumn col = createTableViewerColumn(Texts.COMPILER_SYMBOLS_VIEW_TYPE_COLUMN_LABEL, 40, index++);
	col.setLabelProvider(new ColumnLabelProvider() {
	    @Override
	    public String getText(Object element) {
		return null;
	    }

	    @Override
	    public String getToolTipText(Object element) {
		CompilerSymbol compilerSymbol = (CompilerSymbol) element;
		return CompilerSymbolType.getText(compilerSymbol.getType());
	    }

	    @Override
	    public Image getImage(Object element) {
		return labelProvider.getImage(element);
	    }
	});

	// Column: Bank
	col = createTableViewerColumn(Texts.COMPILER_SYMBOLS_VIEW_BANK_COLUMN_LABEL, 40, index++);
	col.setLabelProvider(new ColumnLabelProvider() {
	    @Override
	    public String getText(Object element) {
		CompilerSymbol compilerSymbol = (CompilerSymbol) element;
		return compilerSymbol.getBankString();
	    }
	});

	// Column: Name
	col = createTableViewerColumn(Texts.COMPILER_SYMBOLS_VIEW_NAME_COLUMN_LABEL, 200, index++);
	col.setLabelProvider(new ColumnLabelProvider() {
	    @Override
	    public String getText(Object element) {
		CompilerSymbol compilerSymbol = (CompilerSymbol) element;
		return compilerSymbol.getName();
	    }
	});

	// Column: Hex Value
	col = createTableViewerColumn(Texts.COMPILER_SYMBOLS_VIEW_HEX_VALUE_COLUMN_LABEL, 100, index++);
	col.setLabelProvider(new ColumnLabelProvider() {
	    @Override
	    public String getText(Object element) {
		CompilerSymbol compilerSymbol = (CompilerSymbol) element;
		return compilerSymbol.getValueAsHexString();
	    }
	});

	// Column: Decimal Value
	col = createTableViewerColumn(Texts.COMPILER_SYMBOLS_VIEW_DECIMAL_VALUE_COLUMN_LABEL, 100, index++);
	col.setLabelProvider(new ColumnLabelProvider() {
	    @Override
	    public String getText(Object element) {
		CompilerSymbol compilerSymbol = (CompilerSymbol) element;
		return compilerSymbol.getValueAsDecimalString();
	    }
	});

	// Column: String Value
	col = createTableViewerColumn(Texts.COMPILER_SYMBOLS_VIEW_STRING_VALUE_COLUMN_LABEL, 100, index++);
	col.setLabelProvider(new ColumnLabelProvider() {
	    @Override
	    public String getText(Object element) {
		CompilerSymbol compilerSymbol = (CompilerSymbol) element;
		return compilerSymbol.getValueAsString();
	    }
	});
    }

    private TableViewerColumn createTableViewerColumn(String title, int bound, int colNumber) {
	if (title == null) {
	    throw new IllegalArgumentException("Parameter 'title' must not be null.");
	}
	final TableViewerColumn viewerColumn = new TableViewerColumn(viewer, SWT.NONE);
	final TableColumn column = viewerColumn.getColumn();
	column.setText(title);
	column.setWidth(bound);
	column.setResizable(true);
	column.setMoveable(true);
	return viewerColumn;
    }

    @Override
    public void setFocus() {
	filterTextField.setFocus();
    }

    public void setSymbols(CompilerFiles compilerFiles, List<CompilerSymbol> compilerSymbols) {
	if (compilerFiles == null) {
	    throw new IllegalArgumentException("Parameter 'compilerFiles' must not be null.");
	}
	if (compilerSymbols == null) {
	    throw new IllegalArgumentException("Parameter 'compilerSymbols' must not be null.");
	}
	this.compilerFiles = compilerFiles;
	this.compilerSymbols = new ArrayList<CompilerSymbol>(compilerSymbols);
	this.updateTimestamp = new Date();
	if (viewer != null) {
	    dataToUI();
	}
    }

    void dataToUI() {
	String text = Texts.COMPILER_SYMBOLS_VIEW_SOURCE_NONE;
	if (compilerFiles != null) {
	    text = compilerFiles.mainSourceFile.fileName;
	    text += " " + DateFormat.getTimeInstance().format(updateTimestamp);
	}
	sourceFileNameText.setText(text);
	String filterTextSequence = filterTextField.getText().toUpperCase();

	// A leading ! reverses the filter
	boolean matchTarget = true;
	if (filterTextSequence.startsWith("!")) {
	    filterTextSequence = filterTextSequence.substring(1);
	    matchTarget = false;
	}

	String[] filterTexts = filterTextSequence.split("[ ]+");
	List<CompilerSymbol> filteredCompilerSymbols = compilerSymbols;
	if (filterTexts.length > 0) {
	    filteredCompilerSymbols = new ArrayList<CompilerSymbol>();
	    for (CompilerSymbol compilerSymbol : compilerSymbols) {
		boolean match = true;
		for (int i = 0; i < filterTexts.length && match; i++) {
		    String filterText = filterTexts[i];
		    boolean symbolMatch = (compilerSymbol.getNameUpperCase().contains(filterText)
			    || compilerSymbol.getValueAsHexStringUpperCase().contains(filterText) || compilerSymbol
			    .getValueAsDecimalString().contains(filterText))
			    || compilerSymbol.getValueAsStringUpperCase().contains(filterText);
		    match &= symbolMatch;
		}

		if (match == matchTarget) {
		    filteredCompilerSymbols.add(compilerSymbol);
		}
	    }
	}
	int totalCount = compilerSymbols.size();
	String totalCountText = NumberUtility.getLongValueDecimalString(totalCount);

	int filteredCount = filteredCompilerSymbols.size();
	if (totalCount > 0 && filteredCount < totalCount) {
	    String filteredCountText = NumberUtility.getLongValueDecimalString(filteredCount);
	    text = TextUtility.format(Texts.COMPILER_SYMBOLS_VIEW_SOURCE_FILTERED_COUNT, filteredCountText,
		    totalCountText);
	} else {
	    text = TextUtility.format(Texts.COMPILER_SYMBOLS_VIEW_SOURCE_TOTAL_COUNT, totalCountText);
	}
	symbolsCountText.setText(text);
	// Calling setInput will call getElements in the contentProvider
	viewer.setInput(filteredCompilerSymbols);
    }
}
