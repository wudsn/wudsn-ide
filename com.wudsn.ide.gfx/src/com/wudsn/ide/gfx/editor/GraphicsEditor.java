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

package com.wudsn.ide.gfx.editor;

import java.util.ArrayList;
import java.util.List;

import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.TabFolder;
import org.eclipse.swt.widgets.TabItem;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorSite;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IViewPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.dialogs.SaveAsDialog;
import org.eclipse.ui.ide.IDE;
import org.eclipse.ui.part.EditorPart;

import com.wudsn.ide.base.BasePlugin;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.gui.Action;
import com.wudsn.ide.base.gui.Application;
import com.wudsn.ide.base.gui.MessageManager;
import com.wudsn.ide.gfx.GraphicsPlugin;
import com.wudsn.ide.gfx.Texts;
import com.wudsn.ide.gfx.converter.ConverterData;
import com.wudsn.ide.gfx.converter.ConverterDataLogic;
import com.wudsn.ide.gfx.converter.FilesConverterParameters;
import com.wudsn.ide.gfx.converter.ImageColorHistogram;
import com.wudsn.ide.gfx.converter.ImageConverterParameters;
import com.wudsn.ide.gfx.model.Aspect;
import com.wudsn.ide.gfx.model.ConverterDirection;
import com.wudsn.ide.gfx.model.ConverterMode;


public final class GraphicsEditor extends EditorPart implements Application, ISelectionProvider, ChangeListener {

    public final class Actions {

	/**
	 * Creation is private.
	 */
	private Actions() {
	}

	public static final int TAB_CHANGED = 900;
    }

    /**
     * Encapsulation of the external image views.
     */
    private final class MyImageProvider implements ImageProvider {

	private ImageData displayImageData;
	private ImageColorHistogram displayImageColorHistogram;

	private ImageView imageView;
	private ImagePaletteView imagePaletteView;

	MyImageProvider() {

	}

	@Override
	public void setImageView(ImageView imageView) {
	    this.imageView = imageView;
	}

	@Override
	public void setImagePaletteView(ImagePaletteView imagePaletteView) {
	    this.imagePaletteView = imagePaletteView;
	}

	@Override
	public Aspect getAspect() {
	    return converterData.getParameters().getConverterCommonParameters().getDisplayAspect();
	}

	@Override
	public void setAspect(Aspect value) {
	    dataFromUI();
	    converterData.getParameters().getConverterCommonParameters().setDisplayAspect(value);
	    dataToUI();
	}

	@Override
	public boolean isShrinkToFit() {
	    return converterData.getParameters().getConverterCommonParameters().isDisplayShrinkToFit();
	}

	@Override
	public void setShrinkToFit(boolean value) {
	    dataFromUI();
	    converterData.getParameters().getConverterCommonParameters().setDisplayShrinkToFit(value);
	    dataToUI();
	}

	@Override
	public boolean isZoomToFit() {
	    return converterData.getParameters().getConverterCommonParameters().isDisplayZoomToFit();
	}

	@Override
	public void setZoomToFit(boolean value) {
	    dataFromUI();
	    converterData.getParameters().getConverterCommonParameters().setDisplayZoomToFit(value);
	    dataToUI();
	}

	@Override
	public ImageData getImageData() {
	    return displayImageData;
	}

	@Override
	public ImageColorHistogram getImageColorHistogram() {
	    return displayImageColorHistogram;
	}

	@Override
	public boolean isPaletteChangeable() {
	    return converterData.getConverterDirection() == ConverterDirection.FILES_TO_IMAGE
		    && displayImageData != null && !displayImageData.palette.isDirect;
	}

	@Override
	public void setPaletteRGBs(RGB[] rgbs) {
	    if (rgbs == null) {
		throw new IllegalArgumentException("Parameter 'rgbs' must not be null.");
	    }
	    dataFromUI();
	    FilesConverterParameters parameters;
	    parameters = converterData.getParameters().getFilesConverterParameters();
	    RGB[] currentRGBs = parameters.getPaletteRGBs();
	    for (int i = 0; i < rgbs.length && i < currentRGBs.length; i++) {
		currentRGBs[i] = rgbs[i];
	    }
	    parameters.setPaletteManual();
	    parameters.setPaletteRGBs(currentRGBs);
	    convert();
	    dataToUi();
	}

	@Override
	public void setPaletteRGB(int pixelColor, RGB rgb) {
	    if (rgb == null) {
		throw new IllegalArgumentException("Parameter 'rgb' must not be null.");
	    }
	    dataFromUI();
	    FilesConverterParameters parameters;
	    parameters = converterData.getParameters().getFilesConverterParameters();
	    RGB[] rgbs = parameters.getPaletteRGBs();
	    rgbs[pixelColor] = rgb;
	    parameters.setPaletteManual();
	    parameters.setPaletteRGBs(rgbs);
	    convert();
	    dataToUi();
	}

	final void dataToUi() {
	    IWorkbenchPage workbenchPage = getSite().getPage();

	    // If there is no perspective active yet, we are in the phase of
	    // starting while launching the IDE.
	    // In this situation, the additional views cannot be opened yet.
	    if (workbenchPage.getOpenPerspectives().length == 0) {
		return;
	    }

	    displayImageData = converterData.getConverterCommonData().getImageData();
	    displayImageColorHistogram = converterData.getConverterCommonData().getImageColorHistogram();

	    // Ensure that there is an open image palette view.
	    if (imagePaletteView == null) {
		try {
		    IViewPart viewPart = getSite().getPage().showView(ImagePaletteView.ID);
		    if (viewPart instanceof ImagePaletteView) {
			((ImagePaletteView) viewPart).setImageProvider(this);
		    }
		} catch (PartInitException ex) {
		    imagePaletteView = null;
		    BasePlugin.getInstance().logError("Cannot open image palette view.", null, ex.getCause());
		}
	    }
	    if (imagePaletteView != null) {
		imagePaletteView.dataToUI();
	    }

	    // Ensure that there is an open image view.
	    if (imageView == null) {
		try {
		    IViewPart viewPart = getSite().getPage().showView(ImageView.ID);
		    if (viewPart instanceof ImageView) {
			((ImageView) viewPart).setImageProvider(this);
		    }
		} catch (PartInitException ex) {
		    imageView = null;
		    BasePlugin.getInstance().logError("Cannot open image view.", null, ex);
		}
	    }
	    if (imageView != null) {
		imageView.dataToUI();
	    }
	}

	final void dispose() {
	    if (imageView != null) {
		imageView.setImageProvider(null);
	    }
	    if (imagePaletteView != null) {
		imagePaletteView.setImageProvider(null);
	    }
	}
    }

    private static final class MySaveAsDialog extends SaveAsDialog {
	private String title;
	private String message;

	public MySaveAsDialog(Shell parentShell, String title, String message) {
	    super(parentShell);
	    this.title = title;
	    this.message = message;
	}

	@Override
	protected Control createContents(Composite parent) {
	    if (parent == null) {
		throw new IllegalArgumentException("Parameter 'parent' must not be null.");
	    }
	    Control result;
	    result = super.createContents(parent);
	    setTitle(title);
	    setMessage(message);
	    return result;
	}

    }

    // ID of the editor in the plugin manifest.
    public static final String ID = "com.wudsn.ide.gfx.editor.GraphicsEditor";

    private MessageManager messageManager;
    private boolean processing;
    private boolean closeEditor;

    // All data and parameters.
    private ConverterDataLogic converterDataLogic;
    final ConverterData converterData;

    // UI state.
    private boolean partControlCreated;
    private TabFolder tabFolder;
    private TabItem filesConverterDataViewTabItem;
    private FilesConverterDataView filesConverterDataView;
    private TabItem imageConverterDataViewTabItem;
    private ImageConverterDataView imageConverterDataView;

    // UI state in external views.
    private List<ISelectionChangedListener> selectionChangedListeners;
    private MyImageProvider imageProvider;

    public GraphicsEditor() {
	messageManager = new MessageManager(this);

	converterDataLogic = new ConverterDataLogic(messageManager);
	converterData = converterDataLogic.createData();

	selectionChangedListeners = new ArrayList<ISelectionChangedListener>();
	imageProvider = new MyImageProvider();
    }

    @Override
    public MessageManager getMessageManager() {
	return messageManager;
    }

    @Override
    public void dispose() {
	imageProvider.dispose();
	messageManager.dispose();
	super.dispose();
    }

    @Override
    public void doSave(IProgressMonitor monitor) {
	dataFromUI();
	if (!converterData.isValid()) {
	    throw new IllegalStateException("Converter data is not valid.");
	}
	if (converterData.getConverterMode() != ConverterMode.CNV) {
	    throw new IllegalStateException("Converter data is not in mode CNV.");
	}
	messageManager.clearMessages();
	IFile saveFile = converterDataLogic.saveConversion(converterData, monitor);
	if (saveFile != null) {
	    firePropertyChange(PROP_INPUT);
	    messageManager.sendMessage(0, IStatus.INFO, "Conversion {0} saved", saveFile.getFullPath().toString());
	} else if (monitor != null) {
	    monitor.setCanceled(true);

	}
	dataToUI();
    }

    @Override
    public void doSaveAs() {
	dataFromUI();
	if (!converterData.isValid()) {
	    throw new IllegalStateException("Converter data is not valid.");
	}
	if (converterData.getConverterMode() != ConverterMode.CNV) {
	    throw new IllegalStateException("Converter data is not in mode CNV.");
	}
	IFile saveAsFile = saveConversionAs(converterData, Texts.SAVE_AS_DIALOG_TITLE, Texts.SAVE_AS_DIALOG_MESSAGE,
		null);
	if (saveAsFile != null) {
	    firePropertyChange(PROP_INPUT);
	    messageManager.sendMessage(0, IStatus.INFO, "Conversion {0} saved", saveAsFile.getFullPath().toString());
	}
	dataToUI();
    }

    @Override
    public void init(IEditorSite site, IEditorInput input) throws PartInitException {
	if (site == null) {
	    throw new IllegalArgumentException("Parameter 'site' must not be null.");
	}
	setSite(site);
	setInput(input);

	if (input != null) {
	    setPartName(input.getName());
	} else {
	    setPartName("");
	}

	messageManager.clearMessages();
	converterData.clear();
	try {
	    if (input instanceof IFileEditorInput) {
		IFileEditorInput fileEditorInput = (IFileEditorInput) input;
		IFile file = fileEditorInput.getFile();
		converterData.setFile(file);
		converterDataLogic.load(converterData);
	    }
	} catch (Exception ex) {
	    BasePlugin.getInstance().logError("Cannot open file.", null, ex);
	}
	convert();
	if (partControlCreated) {
	    dataToUI();
	}

    }

    /**
     * Opens another file a new editor instance.
     * 
     * @param file
     *            The file, not <code>null</code>.
     * @return <code>true</code> if the editor was opened, <code>false</code>
     *         otherwise.
     */
    private boolean openEditor(IFile file) {
	if (file == null) {
	    throw new IllegalArgumentException("Parameter 'file' must not be null.");
	}

	boolean result;

	result = false;
	try {

	    IDE.openEditor(getSite().getPage(), file, ID);
	    result = true;

	} catch (PartInitException ex) {
	    GraphicsPlugin.getInstance().logError("Cannot open default editor for {0}'.", new Object[] { file }, ex);
	}
	return result;
    }

    /**
     * Closes the current editor instance.
     */
    private void closeEditor() {
	getSite().getPage().closeEditor(this, false);
    }

    @Override
    public boolean isDirty() {
	boolean result;
	dataFromUI();
	result = converterData.isValidConversion() && converterData.isChanged();
	return result;
    }

    @Override
    public boolean isSaveAsAllowed() {
	boolean result;
	result = converterData.isValidConversion();
	return result;
    }

    @Override
    public void createPartControl(Composite parent) {

	getSite().setSelectionProvider(this);

	Composite composite = parent;
	composite.setLayout(new FillLayout(SWT.VERTICAL));
	tabFolder = new TabFolder(composite, SWT.TOP);

	filesConverterDataViewTabItem = new TabItem(tabFolder, SWT.NONE);
	filesConverterDataViewTabItem.setText(Texts.FILES_CONVERTER_DATA_VIEW_TAB);
	filesConverterDataView = new FilesConverterDataView(this, tabFolder, converterData.getFilesConverterData());
	filesConverterDataViewTabItem.setControl(filesConverterDataView.getComposite());

	imageConverterDataViewTabItem = new TabItem(tabFolder, SWT.NONE);
	imageConverterDataViewTabItem.setText(Texts.IMAGE_CONVERTER_DATA_VIEW_TAB);
	imageConverterDataView = new ImageConverterDataView(this, tabFolder, converterData.getImageConverterData());
	imageConverterDataViewTabItem.setControl(imageConverterDataView.getComposite());

	// Add selection listener only after all tabs have been added.
	tabFolder.addSelectionListener(new Action(Actions.TAB_CHANGED, this));

	partControlCreated = true;

	dataToUI();

    }

    @Override
    public void performAction(Action action) {
	if (action == null) {
	    throw new IllegalArgumentException("Parameter 'action' must not be null.");
	}
	if (!processing) {
	    processing = true;

	    try {

		messageManager.clearMessages();
		dataFromUI();

		switch (action.getId()) {
		case Actions.TAB_CHANGED:
		    loadSources(false, true);
		    break;

		case FilesConverterDataView.Actions.FIND_DEFAULT_FILE_CONVERTER:
		    converterDataLogic.findDefaultFileConverter(converterData);
		    convert();
		    break;

		case FilesConverterDataView.Actions.CREATE_CONVERSION:
		    createConversion();
		    break;

		case FilesConverterDataView.Actions.REFRESH:
		    loadSources(false, true);
		    break;

		case FilesConverterDataView.Actions.SAVE_IMAGE:
		    saveTargets();
		    break;

		case FilesConverterDataView.Actions.CONVERTER_ID_CHANGED:
		    loadSources(true, true);
		    break;

		case FilesConverterDataView.Actions.PARAMETER_CHANGED:
		    convert();
		    break;

		case FilesConverterDataView.Actions.PALETTE_COLORS_CHANGED:
		    converterData.getFilesConverterData().getParameters().setPaletteManual();
		    convert();
		    break;

		case ImageConverterDataView.Actions.CREATE_CONVERSION:
		    createConversion();
		    break;

		case ImageConverterDataView.Actions.REFRESH:
		    loadSources(false, true);
		    break;

		case ImageConverterDataView.Actions.SAVE_FILES:
		    saveTargets();
		    break;

		case ImageConverterDataView.Actions.CONVERTER_ID_CHANGED:
		    loadSources(true, true);
		    break;

		case ImageConverterDataView.Actions.PARAMETER_CHANGED:
		    convert();
		}

		dataToUI();
	    } catch (Exception ex) {
		GraphicsPlugin.getInstance().showError(getSite().getShell(), "Error in update()", ex);
	    }

	    processing = false;
	    if (closeEditor) {
		closeEditor();
	    }
	}

    }

    private void loadSources(boolean applyDefaults, boolean convert) {
	if (applyDefaults) {
	    converterDataLogic.applyDefaults(converterData);
	}
	long startTimeMillis = System.currentTimeMillis();
	if (converterDataLogic.loadSources(converterData, false)) {
	    if (convert) {
		converterDataLogic.convert(converterData);
		long duration = System.currentTimeMillis() - startTimeMillis;
		String durationString = NumberUtility.getLongValueDecimalString(duration);
		switch (converterData.getConverterDirection()) {
		case FILES_TO_IMAGE:
		    messageManager.sendMessage(ImageConverterParameters.MessageIds.IMAGE_FILE_PATH, IStatus.OK,
			    Texts.MESSAGE_S100, durationString);
		    break;
		case IMAGE_TO_FILES:
		    messageManager.sendMessage(ImageConverterParameters.MessageIds.IMAGE_FILE_PATH, IStatus.OK,
			    "Image file loaded and converted in {0} ms", durationString);
		    break;
		}
	    } else {
		switch (converterData.getConverterDirection()) {
		case FILES_TO_IMAGE:
		    messageManager.sendMessage(ImageConverterParameters.MessageIds.IMAGE_FILE_PATH, IStatus.OK,
			    "Source files loaded");
		    break;
		case IMAGE_TO_FILES:
		    messageManager.sendMessage(ImageConverterParameters.MessageIds.IMAGE_FILE_PATH, IStatus.OK,
			    "Image file loaded");
		    break;
		}
	    }
	}
    }

    final void convert() {
	converterDataLogic.convert(converterData);
    }

    private void saveTargets() {
	converterDataLogic.saveTargets(converterData);

    }

    private void createConversion() {

	ConverterData newConverterData;
	IFile saveAsFile;

	newConverterData = converterDataLogic.createConversion(converterData);

	saveAsFile = saveConversionAs(newConverterData, Texts.CREATE_CONVERSION_DIALOG_TITLE,
		Texts.CREATE_CONVERSION_DIALOG_MESSAGE, null);
	if (saveAsFile != null) {
	    messageManager.sendMessage(0, IStatus.INFO, "Conversion {0} saved", saveAsFile.getFullPath().toString());
	    closeEditor = openEditor(saveAsFile);

	}
    }

    private IFile saveConversionAs(ConverterData data, String title, String message, IProgressMonitor monitor) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}

	if (title == null) {
	    throw new IllegalArgumentException("Parameter 'title' must not be null.");
	}
	if (message == null) {
	    throw new IllegalArgumentException("Parameter 'message' must not be null.");
	}
	IFile saveAsFile;
	IPath saveAsPath;
	SaveAsDialog saveAsDialog = new MySaveAsDialog(getSite().getShell(), title, message);
	saveAsDialog.setBlockOnOpen(true);
	saveAsDialog.setOriginalFile(data.getFile());
	saveAsDialog.open();
	saveAsPath = saveAsDialog.getResult();
	if (saveAsPath != null) {

	    IWorkspaceRoot workspaceRoot = ResourcesPlugin.getWorkspace().getRoot();
	    saveAsFile = workspaceRoot.getFile(saveAsPath);
	    converterData.setFile(saveAsFile);
	    converterDataLogic.saveConversion(data, monitor);

	} else {
	    saveAsFile = null;
	}
	return saveAsFile;
    }

    final void dataFromUI() {

	TabItem[] tabItems = tabFolder.getSelection();
	if (tabItems == null || tabItems.length == 0 || tabItems[0] == filesConverterDataViewTabItem) {
	    converterData.getParameters().setConverterDirection(ConverterDirection.FILES_TO_IMAGE);
	} else {
	    converterData.getParameters().setConverterDirection(ConverterDirection.IMAGE_TO_FILES);
	}

	filesConverterDataView.dataFromUI();
	imageConverterDataView.dataFromUI();

    }

    final void dataToUI() {

	firePropertyChange(PROP_DIRTY);

	switch (converterData.getConverterDirection()) {
	case FILES_TO_IMAGE:
	    tabFolder.setSelection(filesConverterDataViewTabItem);
	    break;
	case IMAGE_TO_FILES:
	    tabFolder.setSelection(imageConverterDataViewTabItem);
	    break;
	default:
	    throw new IllegalStateException("Unknown converter direction '" + converterData.getConverterDirection()
		    + "'.");
	}

	filesConverterDataView.dataToUI();
	imageConverterDataView.dataToUI();

	if (partControlCreated) {
	    imageProvider.dataToUi();
	}

	messageManager.displayMessages();

    }

    @Override
    public void setFocus() {
	tabFolder.setFocus();
	// dataToUI(); Do not use here. Causes a recursion due to the image view
	// trying to come to front.
    }

    @Override
    public void addSelectionChangedListener(ISelectionChangedListener listener) {
	selectionChangedListeners.add(listener);
    }

    @Override
    public void removeSelectionChangedListener(ISelectionChangedListener listener) {
	selectionChangedListeners.remove(listener);
    }

    @Override
    public ISelection getSelection() {
	return new StructuredSelection();
    }

    @Override
    public void setSelection(ISelection selection) {
	for (ISelectionChangedListener listener : selectionChangedListeners) {
	    listener.selectionChanged(new SelectionChangedEvent(this, selection));
	}
    }

    @Override
    public void stateChanged(ChangeEvent event) {
	firePropertyChange(PROP_DIRTY);
    }

    /**
     * Gets the image provider for this editor.
     * 
     * @return The image provider, not <code>null</code>.
     */
    public ImageProvider getImageProvider() {
	return imageProvider;
    }

}
