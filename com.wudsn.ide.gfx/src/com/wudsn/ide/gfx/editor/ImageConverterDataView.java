/**
 * Copyright (C) 2009 - 2019 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;

import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.gui.Action;
import com.wudsn.ide.base.gui.CheckBoxField;
import com.wudsn.ide.base.gui.FilePathField;
import com.wudsn.ide.base.gui.IntegerField;
import com.wudsn.ide.base.gui.MessageManager;
import com.wudsn.ide.base.gui.MultiLineTextField;
import com.wudsn.ide.base.gui.SWTFactory;
import com.wudsn.ide.gfx.Texts;
import com.wudsn.ide.gfx.converter.Converter;
import com.wudsn.ide.gfx.converter.ConverterCommonParameters;
import com.wudsn.ide.gfx.converter.ConverterTargetFileDefinition;
import com.wudsn.ide.gfx.converter.ImageConverterData;
import com.wudsn.ide.gfx.converter.ImageConverterParameters;
import com.wudsn.ide.gfx.converter.ImageConverterParameters.TargetFile;
import com.wudsn.ide.gfx.gui.AspectField;
import com.wudsn.ide.gfx.gui.ConverterIdField;
import com.wudsn.ide.gfx.gui.TargetFileView;
import com.wudsn.ide.gfx.model.ConverterDirection;

final class ImageConverterDataView {

    public final class Actions {

	/**
	 * Creation is private.
	 */
	private Actions() {
	}

	public static final int CREATE_CONVERSION = 2000;
	public static final int REFRESH = 2001;
	public static final int SAVE_FILES = 2002;
	public static final int CONVERTER_ID_CHANGED = 2003;

	public static final int PARAMETER_CHANGED = 2100;
	public static final int PALETTE_COLORS_CHANGED = 2101;
    }

    private ImageConverterData imageConverterData;
    private ImageConverterParameters imageConverterParameters;

    private Composite composite;

    private ConverterIdField converterIdField;

    private ToolItem createConversionButton;
    private ToolItem refreshButton;
    private ToolItem saveFilesButton;

    private FilePathField imageFilePathField;
    private AspectField imageAspectField;
    private IntegerField imageDataWidthField;
    private IntegerField imageDataHeightField;

    private static final int TARGET_FILES = 3;
    private List<TargetFileView> targetFileViews;

    private CheckBoxField useDefaultScriptField;
    private MultiLineTextField scriptField;

    public ImageConverterDataView(GraphicsEditor editor, Composite parent, ImageConverterData imageConverterData) {
	if (editor == null) {
	    throw new IllegalArgumentException("Parameter 'editor' must not be null.");
	}
	if (parent == null) {
	    throw new IllegalArgumentException("Parameter 'parent' must not be null.");
	}
	if (imageConverterData == null) {
	    throw new IllegalArgumentException("Parameter 'imageConverterData' must not be null.");
	}
	this.imageConverterData = imageConverterData;
	this.imageConverterParameters = this.imageConverterData.getParameters();

	MessageManager messageManager = editor.getMessageManager();

	// Create visual elements.
	composite = new Composite(parent, SWT.NONE);
	composite.setLayout(new GridLayout(1, false));
	GridData gd = new GridData();
	gd.grabExcessHorizontalSpace = false;
	gd.grabExcessVerticalSpace = false;
	composite.setLayoutData(gd);

	Composite topComposite = SWTFactory.createComposite(composite, 9, 1, SWT.HORIZONTAL);

	converterIdField = new ConverterIdField(topComposite, Texts.CONVERTER_PARAMETERS_CONVERTER_ID_LABEL,
		ConverterDirection.IMAGE_TO_FILES);
	converterIdField.addSelectionListener(new Action(Actions.CONVERTER_ID_CHANGED, editor));
	messageManager.registerField(converterIdField, ConverterCommonParameters.MessageIds.CONVERTER_ID);

	Composite toolBarcomposite = SWTFactory.createComposite(topComposite, 3, 7, GridData.FILL_HORIZONTAL);
	ToolBar toolbar = new ToolBar(toolBarcomposite, SWT.HORIZONTAL);

	createConversionButton = new ToolItem(toolbar, SWT.PUSH);
	createConversionButton.setImage(Icons.CREATE_CONVERSION);
	createConversionButton.setToolTipText(Texts.CREATE_CONVERSION_BUTTON_TOOLTIP);
	createConversionButton.addSelectionListener(new Action(Actions.CREATE_CONVERSION, editor));

	refreshButton = new ToolItem(toolbar, SWT.PUSH);
	refreshButton.setImage(Icons.REFRESH);
	refreshButton.setToolTipText(Texts.REFRESH_BUTTON_TOOLTIP);
	refreshButton.addSelectionListener(new Action(Actions.REFRESH, editor));

	saveFilesButton = new ToolItem(toolbar, SWT.NONE);
	saveFilesButton.setImage(Icons.SAVE_FILES);
	saveFilesButton.setToolTipText(Texts.SAVE_FILES_BUTTON_TOOLTIP);
	saveFilesButton.addSelectionListener(new Action(Actions.SAVE_FILES, editor));

	imageFilePathField = new FilePathField(topComposite, Texts.CONVERTER_PARAMETERS_IMAGE_FILE_PATH_LABEL, SWT.OPEN);
	imageFilePathField.addChangeListener(editor);
	messageManager.registerField(imageFilePathField, ImageConverterParameters.MessageIds.IMAGE_FILE_PATH);

	//
	imageAspectField = new AspectField(topComposite, Texts.CONVERTER_PARAMETERS_IMAGE_ASPECT_LABEL);
	imageAspectField.addSelectionAction(new Action(Actions.PARAMETER_CHANGED, editor));
	messageManager.registerField(imageAspectField, ConverterCommonParameters.MessageIds.IMAGE_ASPECT);

	imageDataWidthField = new IntegerField(topComposite, Texts.CONVERTER_DATA_IMAGE_DATA_WIDTH_LABEL, null, false,
		NumberUtility.AUTOMATIC_LENGTH, SWT.READ_ONLY);
	imageDataHeightField = new IntegerField(topComposite, Texts.CONVERTER_DATA_IMAGE_DATA_HEIGHT_LABEL, null,
		false, NumberUtility.AUTOMATIC_LENGTH, SWT.READ_ONLY);

	targetFileViews = new ArrayList<TargetFileView>(TARGET_FILES);
	for (int i = 0; i < TARGET_FILES; i++) {
	    TargetFileView targetFileView;

	    targetFileView = new TargetFileView(topComposite, "", SWT.SAVE);
	    targetFileView.addChangeListener(editor);
	    messageManager.registerField(targetFileView.getFilePathField(),
		    ImageConverterParameters.MessageIds.TARGET_FILE_PATH + i);
	    targetFileViews.add(targetFileView);
	    SWTFactory.createLabels(topComposite, 4);

	}

	useDefaultScriptField = new CheckBoxField(topComposite, Texts.CONVERTER_PARAMETERS_USE_DEFAULT_SCRIPT_LABEL,
		SWT.NONE);
	useDefaultScriptField.addSelectionAction(new Action(Actions.PARAMETER_CHANGED, editor));
	messageManager.registerField(useDefaultScriptField, ImageConverterParameters.MessageIds.USE_DEFAULT_SCRIPT);
	SWTFactory.createLabels(topComposite, 6);

	scriptField = new MultiLineTextField(composite, SWT.H_SCROLL | SWT.V_SCROLL);
	scriptField.addChangeListener(editor);
	messageManager.registerField(scriptField, ImageConverterParameters.MessageIds.SCRIPT);
	gd = new GridData();
	gd.horizontalSpan = 1;
	gd.verticalSpan = 1;
	gd.grabExcessHorizontalSpace = true;
	gd.grabExcessVerticalSpace = true;
	Rectangle clientArea = Display.getCurrent().getClientArea();
	gd.heightHint = clientArea.width;
	gd.widthHint = clientArea.height;
	StyledText styledText = scriptField.getText();
	styledText.setLayoutData(gd);
	styledText.setFont(JFaceResources.getTextFont());
	styledText.setTabs(4);

    }

    public Composite getComposite() {
	return composite;
    }

    public void dataFromUI() {

	imageConverterParameters.setImageFilePath(imageFilePathField.getValue());
	imageConverterParameters.setImageAspect(imageAspectField.getValue());

	// Copy the file paths before setting the new converter.
	Converter converter = imageConverterData.getConverter();
	for (int i = 0; i < targetFileViews.size(); i++) {
	    TargetFileView targetFileView = targetFileViews.get(i);
	    if (converter == null) {

	    } else {
		List<ConverterTargetFileDefinition> targetFileDefinitions = converter.getDefinition()
			.getTargetFileDefinitions();
		if (i < targetFileDefinitions.size()) {
		    TargetFile targetFile = imageConverterParameters.getTargetFile(i);
		    targetFile.setPath(targetFileView.getFilePath());
		}
	    }
	}

	imageConverterParameters.setConverterId(converterIdField.getValue());

	imageConverterParameters.setUseDefaultScript(useDefaultScriptField.getValue());
	if (!imageConverterParameters.isUseDefaultScript()) {
	    imageConverterParameters.setScript(scriptField.getValue());
	}
    }

    public void dataToUI() {

	createConversionButton.setEnabled(imageConverterData.isCreateConversionEnabled());
	refreshButton.setEnabled(imageConverterData.isRefreshEnabled());
	saveFilesButton.setEnabled(imageConverterData.isSaveFilesEnabled());

	converterIdField.setValue(imageConverterParameters.getConverterId());
	converterIdField.setEnabled(imageConverterData.isValid());

	imageFilePathField.setFilePathPrefix(imageConverterData.getFilePathPrefix());
	imageFilePathField.setValue(imageConverterParameters.getImageFilePath());
	imageFilePathField.setEnabled(imageConverterData.isValid());
	imageFilePathField.setEditable(true);

	imageAspectField.setValue(imageConverterParameters.getImageAspect());
	imageAspectField.setEnabled(imageConverterData.isValid());
	imageDataWidthField.setValue(imageConverterData.getImageDataWidth());
	imageDataWidthField.setEnabled(imageConverterData.isValid());
	imageDataHeightField.setValue(imageConverterData.getImageDataHeight());
	imageDataHeightField.setEnabled(imageConverterData.isValid());

	Converter converter = imageConverterData.getConverter();
	for (int i = 0; i < targetFileViews.size(); i++) {
	    TargetFileView targetFileView = targetFileViews.get(i);
	    targetFileView.setFilePathPrefix(imageConverterData.getFilePathPrefix());
	    if (converter == null) {
		targetFileView.getFilePathField().setLabelText("Not used");
		targetFileView.setFilePath("");
		targetFileView.setFileBytes(null);
		targetFileView.setVisible(true);
		targetFileView.setEnabled(false);
	    } else {
		List<ConverterTargetFileDefinition> targetFileDefinitions = converter.getDefinition()
			.getTargetFileDefinitions();
		if (i < targetFileDefinitions.size()) {
		    targetFileView.getFilePathField().setLabelText(targetFileDefinitions.get(i).getLabel());
		    TargetFile targetFile = imageConverterParameters.getTargetFile(i);
		    targetFileView.setFilePath(targetFile.getPath());
		    targetFileView.setFileBytes(imageConverterData.getTargetFileBytes(targetFile.getId()));
		    targetFileView.setVisible(true);
		    targetFileView.setEnabled(imageConverterData.isValidConversion());
		} else {
		    targetFileView.getFilePathField().setLabelText("Not used");
		    targetFileView.setFilePath("");
		    targetFileView.setFileBytes(null);
		    targetFileView.setVisible(true);
		    targetFileView.setEnabled(false);
		}
	    }

	}

	useDefaultScriptField.setValue(imageConverterParameters.isUseDefaultScript());
	useDefaultScriptField.setEnabled(imageConverterData.isValid());
	useDefaultScriptField.setEditable(imageConverterData.isValidConversion());

	String script = imageConverterParameters.getScript();
	scriptField.setValue(script);
	scriptField.setEnabled(imageConverterData.isValid());
	scriptField.setEditable(!imageConverterParameters.isUseDefaultScript());

	int lineNumber = imageConverterData.getConverterScriptData().geErrorLineNumber();
	if (lineNumber > 0) {
	    int offset = scriptField.getText().getOffsetAtLine(lineNumber - 1);
	    scriptField.setSelection(offset);
	}
	imageConverterData.getConverterScriptData().setErrorLineNumber(-1);

    }
}
