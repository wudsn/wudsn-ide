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

package com.wudsn.ide.gfx.editor;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.jface.preference.ColorSelector;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.TraverseEvent;
import org.eclipse.swt.events.TraverseListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;

import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.gui.Action;
import com.wudsn.ide.base.gui.FilePathField;
import com.wudsn.ide.base.gui.IntegerField;
import com.wudsn.ide.base.gui.MessageManager;
import com.wudsn.ide.base.gui.SWTFactory;
import com.wudsn.ide.gfx.Texts;
import com.wudsn.ide.gfx.converter.Converter;
import com.wudsn.ide.gfx.converter.ConverterCommonParameters;
import com.wudsn.ide.gfx.converter.ConverterSourceFileDefinition;
import com.wudsn.ide.gfx.converter.FilesConverterData;
import com.wudsn.ide.gfx.converter.FilesConverterParameters;
import com.wudsn.ide.gfx.converter.FilesConverterParameters.SourceFile;
import com.wudsn.ide.gfx.gui.AspectField;
import com.wudsn.ide.gfx.gui.ConverterIdField;
import com.wudsn.ide.gfx.gui.SourceFileView;
import com.wudsn.ide.gfx.model.ConverterDirection;

final class FilesConverterDataView {

    public final class Actions {

	/**
	 * Creation is private.
	 */
	private Actions() {
	}

	public static final int FIND_DEFAULT_FILE_CONVERTER = 999;
	public static final int CREATE_CONVERSION = 1000;
	public static final int REFRESH = 1001;
	public static final int SAVE_IMAGE = 1002;
	public static final int CONVERTER_ID_CHANGED = 1003;
	public static final int PARAMETER_CHANGED = 1100;
	public static final int PALETTE_COLORS_CHANGED = 1101;
    }

    private FilesConverterData filesConverterData;
    private FilesConverterParameters filesConverterParameters;

    private Composite composite;

    private ConverterIdField converterIdField;

    private ToolItem findDefaultFileConverterButton;
    private ToolItem createConversionButton;
    private ToolItem refreshButton;
    private ToolItem saveImageButton;

    private static final int SOURCE_FILES = 3;
    private List<SourceFileView> sourceFileViews;

    private IntegerField columnsField;
    private IntegerField rowsField;

    private Label spacingColorSelectorLabel;
    private ColorSelector spacingColorSelector;
    private IntegerField spacingWidthField;

    private FilePathField imageFilePathField;
    private AspectField imageAspectField;
    private IntegerField imageDataWidthField;
    private IntegerField imageDataHeightField;

    public FilesConverterDataView(final GraphicsConversionEditor editor, Composite parent, FilesConverterData filesConverterData) {
	if (parent == null) {
	    throw new IllegalArgumentException("Parameter 'parent' must not be null.");
	}

	if (filesConverterData == null) {
	    throw new IllegalArgumentException("Parameter 'filesConverterData' must not be null.");
	}
	this.filesConverterData = filesConverterData;
	this.filesConverterParameters = this.filesConverterData.getParameters();

	MessageManager messageManager = editor.getMessageManager();

	GridData gd = new GridData();

	composite = SWTFactory.createComposite(parent, 9, 1, SWT.HORIZONTAL);

	converterIdField = new ConverterIdField(composite, Texts.CONVERTER_PARAMETERS_CONVERTER_ID_LABEL,
		ConverterDirection.FILES_TO_IMAGE);
	converterIdField.addSelectionListener(new Action(Actions.CONVERTER_ID_CHANGED, editor));
	messageManager.registerField(converterIdField, ConverterCommonParameters.MessageIds.CONVERTER_ID);

	Composite toolBarcomposite = SWTFactory.createComposite(composite, 3, 7, GridData.FILL_HORIZONTAL);
	ToolBar toolbar = new ToolBar(toolBarcomposite, SWT.HORIZONTAL);

	findDefaultFileConverterButton = new ToolItem(toolbar, SWT.PUSH);
	findDefaultFileConverterButton.setImage(Icons.FIND_DEFAULT_CONVERTER);
	findDefaultFileConverterButton.setToolTipText(Texts.FIND_DEFAULT_FILE_CONVERTER_BUTTON_TOOLTIP);
	findDefaultFileConverterButton.addSelectionListener(new Action(Actions.FIND_DEFAULT_FILE_CONVERTER, editor));

	createConversionButton = new ToolItem(toolbar, SWT.PUSH);
	createConversionButton.setImage(Icons.CREATE_CONVERSION);
	createConversionButton.setToolTipText(Texts.CREATE_CONVERSION_BUTTON_TOOLTIP);
	createConversionButton.addSelectionListener(new Action(Actions.CREATE_CONVERSION, editor));

	final Action refreshAction = new Action(Actions.REFRESH, editor);
	refreshButton = new ToolItem(toolbar, SWT.PUSH);
	refreshButton.setImage(Icons.REFRESH);
	refreshButton.setToolTipText(Texts.REFRESH_BUTTON_TOOLTIP);
	refreshButton.addSelectionListener(refreshAction);

	// Press
	composite.addTraverseListener(new TraverseListener() {

	    @Override
	    public void keyTraversed(TraverseEvent event) {
		if (event.detail == SWT.TRAVERSE_RETURN) {
		    // The user pressed Enter
		    refreshAction.widgetDefaultSelected(null);
		}

	    }
	});

	saveImageButton = new ToolItem(toolbar, SWT.NONE);
	saveImageButton.setImage(Icons.SAVE_IMAGE);
	saveImageButton.setToolTipText(Texts.SAVE_IMAGE_BUTTON_TOOLTIP);
	saveImageButton.addSelectionListener(new Action(Actions.SAVE_IMAGE, editor));

	sourceFileViews = new ArrayList<SourceFileView>(SOURCE_FILES);
	for (int i = 0; i < SOURCE_FILES; i++) {
	    SourceFileView sourceFileView;

	    sourceFileView = new SourceFileView(composite, "", SWT.OPEN);
	    sourceFileView.addChangeListener(editor);
	    sourceFileView.getFileOffsetField().addSelectionAction(refreshAction);
	    messageManager.registerField(sourceFileView.getFilePathField(),
		    FilesConverterParameters.MessageIds.SOURCE_FILE_PATH + i);
	    messageManager.registerField(sourceFileView.getFileOffsetField(),
		    FilesConverterParameters.MessageIds.SOURCE_FILE_OFFSET + i);
	    sourceFileViews.add(sourceFileView);
	    SWTFactory.createLabels(composite, 1);

	}

	SWTFactory.createLabels(composite, 1);

	spacingColorSelectorLabel = new Label(composite, SWT.NONE);
	spacingColorSelectorLabel.setText(Texts.CONVERTER_PARAMETERS_SPACING_COLOR_LABEL);
	spacingColorSelector = new ColorSelector(composite);
	Button spacingColorButton = spacingColorSelector.getButton();
	gd = new GridData(GridData.HORIZONTAL_ALIGN_BEGINNING);
	spacingColorButton.setLayoutData(gd);
	spacingColorButton.addSelectionListener(new Action(Actions.PARAMETER_CHANGED, editor));
	// messageManager.registerField(rowsField,
	// FilesConverterParameters.MessageIds.SPACING_COLOR);
	// TODO Requires a ColorSelectorField

	spacingWidthField = new IntegerField(composite, Texts.CONVERTER_PARAMETERS_SPACING_WIDTH_LABEL, new int[] { 0,
		1, 2, 4, 8 }, false, NumberUtility.AUTOMATIC_LENGTH, SWT.NONE);
	spacingWidthField.addSelectionAction(new Action(Actions.PARAMETER_CHANGED, editor));
	messageManager.registerField(spacingWidthField, FilesConverterParameters.MessageIds.SPACING_WIDTH);

	columnsField = new IntegerField(composite, Texts.CONVERTER_PARAMETERS_COLUMNS_LABEL, new int[] { 1, 2, 3, 4, 8,
		16, 32, 40, 48, 64, 128, 256 }, false, NumberUtility.AUTOMATIC_LENGTH, SWT.NONE);
	columnsField.addChangeListener(editor);
	columnsField.addSelectionAction(new Action(Actions.PARAMETER_CHANGED, editor));
	messageManager.registerField(columnsField, FilesConverterParameters.MessageIds.COLUMNS);

	rowsField = new IntegerField(composite, Texts.CONVERTER_PARAMETERS_ROWS_LABEL,
		new int[] { 1, 2, 3, 4, 24, 25 }, false, NumberUtility.AUTOMATIC_LENGTH, SWT.NONE);
	rowsField.addChangeListener(editor);
	rowsField.addSelectionAction(new Action(Actions.PARAMETER_CHANGED, editor));
	messageManager.registerField(rowsField, FilesConverterParameters.MessageIds.ROWS);

	imageFilePathField = new FilePathField(composite, Texts.CONVERTER_PARAMETERS_IMAGE_FILE_PATH_LABEL, SWT.SAVE);
	imageFilePathField.addChangeListener(editor);
	imageFilePathField.addChangeListener(editor);
	messageManager.registerField(imageFilePathField, FilesConverterParameters.MessageIds.IMAGE_FILE_PATH);

	imageAspectField = new AspectField(composite, Texts.CONVERTER_PARAMETERS_IMAGE_ASPECT_LABEL);
	imageAspectField.addSelectionAction(new Action(Actions.PARAMETER_CHANGED, editor));
	imageFilePathField.addChangeListener(editor);
	messageManager.registerField(imageAspectField, ConverterCommonParameters.MessageIds.IMAGE_ASPECT);

	// Read only fields.
	imageDataWidthField = new IntegerField(composite, Texts.CONVERTER_DATA_IMAGE_DATA_WIDTH_LABEL, null, false,
		NumberUtility.AUTOMATIC_LENGTH, SWT.READ_ONLY);
	imageDataHeightField = new IntegerField(composite, Texts.CONVERTER_DATA_IMAGE_DATA_HEIGHT_LABEL, null, false,
		NumberUtility.AUTOMATIC_LENGTH, SWT.READ_ONLY);
    }

    public Composite getComposite() {
	return composite;
    }

    public void dataFromUI() {

	// Copy the file paths and offsets before setting the new converter.
	Converter converter = filesConverterData.getConverter();
	for (int i = 0; i < sourceFileViews.size(); i++) {
	    SourceFileView sourceFileView = sourceFileViews.get(i);
	    if (converter == null) {

	    } else {
		List<ConverterSourceFileDefinition> sourceFileDefinitions = converter.getDefinition()
			.getSourceFileDefinitions();
		if (i < sourceFileDefinitions.size()) {
		    SourceFile sourceFile = filesConverterParameters.getSourceFile(i);
		    sourceFile.setPath(sourceFileView.getFilePath());
		    sourceFile.setOffset(sourceFileView.getFileOffset());
		}
	    }
	}

	filesConverterParameters.setImageFilePath(imageFilePathField.getValue());

	filesConverterParameters.setConverterId(converterIdField.getValue());

	filesConverterParameters.setColumns(columnsField.getValue());
	filesConverterParameters.setRows(rowsField.getValue());

	filesConverterParameters.setSpacingColor(spacingColorSelector.getColorValue());
	filesConverterParameters.setSpacingWidth(spacingWidthField.getValue());

	filesConverterParameters.setImageAspect(imageAspectField.getValue());
    }

    public void dataToUI() {

	findDefaultFileConverterButton.setEnabled(filesConverterData.isValid());
	createConversionButton.setEnabled(filesConverterData.isCreateConversionEnabled());
	refreshButton.setEnabled(filesConverterData.isRefreshEnabled());
	saveImageButton.setEnabled(filesConverterData.isSaveImageEnabled());

	converterIdField.setValue(filesConverterParameters.getConverterId());
	converterIdField.setEnabled(filesConverterData.isValid());

	Converter converter = filesConverterData.getConverter();
	for (int i = 0; i < sourceFileViews.size(); i++) {
	    SourceFileView sourceFileView = sourceFileViews.get(i);
	    sourceFileView.setFilePathPrefix(filesConverterData.getFilePathPrefix());
	    if (converter == null) {
		sourceFileView.getFilePathField().setLabelText("Not used");
		sourceFileView.setFilePath("");
		sourceFileView.setFileBytes(null);
		sourceFileView.setFileOffset(0);
		sourceFileView.setVisible(true);
		sourceFileView.setEnabled(false);
	    } else {
		List<ConverterSourceFileDefinition> sourceFileDefinitions = converter.getDefinition()
			.getSourceFileDefinitions();
		if (i < sourceFileDefinitions.size()) {
		    sourceFileView.getFilePathField().setLabelText(sourceFileDefinitions.get(i).getLabel());
		    SourceFile sourceFile = filesConverterParameters.getSourceFile(i);
		    sourceFileView.setFilePath(sourceFile.getPath());
		    sourceFileView.setFileBytes(filesConverterData.getSourceFileBytes(sourceFile.getId()));
		    sourceFileView.setFileOffset(sourceFile.getOffset());
		    sourceFileView.setVisible(true);
		    sourceFileView.setEnabled(true);
		} else {
		    sourceFileView.getFilePathField().setLabelText("Not used");
		    sourceFileView.setFilePath("");
		    sourceFileView.setFileBytes(null);
		    sourceFileView.setFileOffset(0);
		    sourceFileView.setVisible(true);
		    sourceFileView.setEnabled(false);
		}
	    }

	}

	imageFilePathField.setFilePathPrefix(filesConverterData.getFilePathPrefix());
	imageFilePathField.setValue(filesConverterParameters.getImageFilePath());
	imageFilePathField.setEnabled(filesConverterData.isValid());
	imageFilePathField.setEditable(true);

	columnsField.setValue(filesConverterParameters.getColumns());
	columnsField.setEnabled(filesConverterData.isValid());
	rowsField.setValue(filesConverterParameters.getRows());
	rowsField.setEnabled(filesConverterData.isValid());

	spacingColorSelector.setColorValue(filesConverterParameters.getSpacingColor());
	spacingColorSelectorLabel.setEnabled(filesConverterData.isValid());
	spacingColorSelector.setEnabled(filesConverterData.isValid());
	spacingWidthField.setValue(filesConverterParameters.getSpacingWidth());
	spacingWidthField.setEnabled(filesConverterData.isValid());

	imageAspectField.setValue(filesConverterParameters.getImageAspect());
	imageAspectField.setEnabled(filesConverterData.isValid());
	imageDataWidthField.setValue(filesConverterData.getImageDataWidth());
	imageDataWidthField.setEnabled(filesConverterData.isImageDataValid());
	imageDataHeightField.setValue(filesConverterData.getImageDataHeight());
	imageDataHeightField.setEnabled(filesConverterData.isImageDataValid());

	composite.pack();
    }
}
