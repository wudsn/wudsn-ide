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

package com.wudsn.ide.base.editor.hex;

import java.io.File;
import java.util.Iterator;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.StyledString;
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.events.FocusEvent;
import org.eclipse.swt.events.FocusListener;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorSite;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IPathEditorInput;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.part.EditorPart;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;

import com.wudsn.ide.base.BasePlugin;
import com.wudsn.ide.base.Texts;
import com.wudsn.ide.base.common.ByteArrayUtility;
import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.Profiler;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.base.gui.Action;
import com.wudsn.ide.base.gui.Application;
import com.wudsn.ide.base.gui.EnumField;
import com.wudsn.ide.base.gui.IntegerField;
import com.wudsn.ide.base.gui.MessageManager;
import com.wudsn.ide.base.gui.SWTFactory;
import com.wudsn.ide.base.gui.TextField;

/**
 * The Hex Editor. This editor offset and outline view for the block of the file
 * and a context menu for copying the current selection clip board in different
 * formats.
 * 
 * TODO Complete copy & paste, complete documentation
 * 
 * @author Peter Dell
 */
public final class HexEditor extends EditorPart implements ISelectionProvider, Application {

    private static final String LABEL_SUFFIX = ": ";

    public final class MessageIds {

	/**
	 * Creation is private.
	 */
	private MessageIds() {
	}

	public static final int FILE_CONTENT_MODE = 1;
	public static final int CHARACTER_SET = 2;
	public static final int BYTES_PER_LINE = 3;
    }

    public final class Actions {

	/**
	 * Creation is private.
	 */
	private Actions() {
	}

	public static final int FILE_CONTENT_MODE_CHANGED = 1000;
	public static final int CHARACTER_SET_TYPE_CHANGED = 1001;
	public static final int BYTES_PER_ROW_CHANGED = 1002;
    }

    public static final String ID = "com.wudsn.ide.base.editor.hex.HexEditor";

    private static final String CONTEXT_MENU_ID = "#HexEditorContext";
    private static final long MAX_FILE_SIZE = 8 * ByteArrayUtility.MB;

    private MessageManager messageManager;
    private HexEditorParserComponent parserComponent;

    // Editor content outline page.
    private HexEditorContentOutlinePage contentOutlinePage;

    // Editor header area.
    private TextField fileContentSizeField;
    private EnumField<HexEditorFileContentMode> fileContentModeField;
    private EnumField<HexEditorCharacterSet> characterSetField;
    private IntegerField bytesPerRowField;

    private StyledText textField;

    // File source.
    private IFile iFile;
    private File ioFile;

    /**
     * This main method is for testing the speed of the source file parser
     * component only.
     * 
     * @param args
     *            Not used, not <code>null</code>.
     * @throws Exception
     *             If anything goes terribly wrong.
     */
    public static void main(String[] args) throws Exception {

	// Initialize for stand alone usage.
	new BasePlugin().start(null);

	HexEditorParserComponent parser = new HexEditorParserComponent(new MessageManager(new HexEditor()));
	parser.setFileContent(new byte[100000]);
	parser.determinePossibleFileContentModes();

	long startTimeMillis = System.currentTimeMillis();
	parser.setFileContentMode(HexEditorFileContentMode.BINARY);
	parser.parseFileContent();
	long duration = System.currentTimeMillis() - startTimeMillis;
	System.out.println(duration);
	System.exit(0);

    }

    /**
     * Creation is public. Called by extension point
     * "org.eclipse.ui.popupMenus".
     */
    public HexEditor() {
	super();

	messageManager = new MessageManager(this);

	parserComponent = new HexEditorParserComponent(messageManager);

    }

    /**
     * @see org.eclipse.ui.IEditorPart#init(IEditorSite, IEditorInput)
     */
    @Override
    public void init(IEditorSite site, IEditorInput input) throws PartInitException {
	setSite(site);
	setInput(input);

	try {
	    load();
	} catch (CoreException ex) {
	    BasePlugin.getInstance().showError(site.getShell(), ex.getMessage(), ex);
	}
    }

    /**
     * @see org.eclipse.ui.IWorkbenchPart#createPartControl(Composite)
     */
    @Override
    public void createPartControl(Composite parent) {

	getSite().setSelectionProvider(this);

	GridLayout gridLayout = new GridLayout(1, true);
	gridLayout.marginWidth = 0;
	parent.setLayout(gridLayout);
	GridData gd = new GridData(GridData.VERTICAL_ALIGN_BEGINNING);
	gd.horizontalSpan = 1;
	parent.setLayoutData(gd);

	Composite header = SWTFactory.createComposite(parent, 8, 1, GridData.FILL_HORIZONTAL);
	FillLayout fillLayout = new FillLayout(SWT.HORIZONTAL);
	fillLayout.marginWidth = 10;
	header.setLayout(fillLayout);

	fileContentSizeField = new TextField(header, Texts.HEX_EDITOR_FILE_CONTENT_SIZE_FIELD_LABEL + LABEL_SUFFIX,
		SWT.READ_ONLY);
	fileContentSizeField.getLabel().setAlignment(SWT.RIGHT);

	fileContentModeField = new EnumField<HexEditorFileContentMode>(header,
		Texts.HEX_EDITOR_FILE_CONTENT_MODE_FIELD_LABEL + LABEL_SUFFIX, HexEditorFileContentMode.class, null);
	fileContentModeField.getLabel().setAlignment(SWT.RIGHT);

	messageManager.registerField(fileContentModeField, MessageIds.FILE_CONTENT_MODE);
	fileContentModeField.addSelectionAction(new Action(Actions.FILE_CONTENT_MODE_CHANGED, this));

	characterSetField = new EnumField<HexEditorCharacterSet>(header,
		Texts.HEX_EDITOR_CHARACTER_SET_TYPE_FIELD_LABEL + LABEL_SUFFIX, HexEditorCharacterSet.class, null);
	characterSetField.getLabel().setAlignment(SWT.RIGHT);
	messageManager.registerField(characterSetField, MessageIds.CHARACTER_SET);
	characterSetField.addSelectionAction(new Action(Actions.CHARACTER_SET_TYPE_CHANGED, this));

	bytesPerRowField = new IntegerField(header, Texts.HEX_EDITOR_BYTES_PER_ROW_FIELD_LABEL + LABEL_SUFFIX, null,
		false, 1, SWT.NONE);
	bytesPerRowField.getLabel().setAlignment(SWT.RIGHT);
	messageManager.registerField(characterSetField, MessageIds.BYTES_PER_LINE);
	bytesPerRowField.getControl().addKeyListener(new KeyListener() {

	    @Override
	    public void keyReleased(KeyEvent e) {
		if (e.keyCode == '\r') {
		    performAction(new Action(Actions.BYTES_PER_ROW_CHANGED, HexEditor.this));
		}

	    }

	    @Override
	    public void keyPressed(KeyEvent e) {

	    }
	});
	bytesPerRowField.getControl().addFocusListener(new FocusListener() {

	    @Override
	    public void focusLost(FocusEvent e) {
		performAction(new Action(Actions.BYTES_PER_ROW_CHANGED, HexEditor.this));

	    }

	    @Override
	    public void focusGained(FocusEvent e) {
	    }
	});

	// SWT.WRAP is very slow, so it's not used.
	textField = new StyledText(parent, SWT.SCROLL_LINE | SWT.V_SCROLL | SWT.H_SCROLL | SWT.READ_ONLY);
	gd = new GridData(GridData.FILL_VERTICAL | GridData.FILL_HORIZONTAL);
	gd.horizontalIndent = 0;
	textField.setLayoutData(gd);
	textField.setIndent(10);
	textField.setLineSpacing(0);

	// Create a menu manager for the context menu.
	MenuManager manager = new MenuManager(CONTEXT_MENU_ID, CONTEXT_MENU_ID);
	manager.setRemoveAllWhenShown(true);

	// Create menu and link to the field.
	Menu textContextMenu = manager.createContextMenu(textField);
	textField.setMenu(textContextMenu);

	getEditorSite().registerContextMenu(CONTEXT_MENU_ID, manager, this, false);
	messageManager.clearMessages();
	dataToUi();
    }

    @SuppressWarnings("unchecked")
    @Override
    public <T> T getAdapter(Class<T> adapter) {
	if (adapter != null && IContentOutlinePage.class.equals(adapter)) {
	    if (contentOutlinePage == null) {

		contentOutlinePage = new HexEditorContentOutlinePage(this);
		contentOutlinePage.setInput(parserComponent.getOutlineBlocks());
	    }

	    return (T) contentOutlinePage;
	}
	return super.getAdapter(adapter);
    }

    /**
     * @see org.eclipse.ui.IWorkbenchPart#setFocus()
     */
    @Override
    public void setFocus() {
	textField.setFocus();
    }

    private void load() throws CoreException {

	// Clear fields.
	ioFile = null;
	iFile = null;

	String fileName = "";
	IEditorInput input = getEditorInput();
	if (input instanceof IFileEditorInput) {
	    // Input file found in Eclipse Workspace.
	    iFile = ((IFileEditorInput) input).getFile();
	    ioFile = iFile.getRawLocation().toFile();
	    fileName = iFile.getName();
	} else if (input instanceof IPathEditorInput) {
	    // Input file is outside the Eclipse Workspace
	    IPathEditorInput pathEditorInput = (IPathEditorInput) input;
	    IPath path = pathEditorInput.getPath();
	    ioFile = path.toFile();
	    fileName = ioFile.getName();

	} else {
	    // Not supported.
	}

	byte[] fileContent;
	Profiler profiler = new Profiler(this);
	profiler.begin("readBytes", fileName);
	if (ioFile != null) {
	    fileContent = FileUtility.readBytes(ioFile, MAX_FILE_SIZE, false);
	} else if (iFile != null) {
	    fileContent = FileUtility.readBytes(iFile, MAX_FILE_SIZE, false);
	} else {
	    fileContent = new byte[0];
	}
	profiler.end("readBytes");

	// Set the content, determine the default file content mode and
	// character set.
	parserComponent.setFileContent(fileContent);
	HexEditorFileContentMode defaultFileContentMode = parserComponent.determinePossibleFileContentModes();
	HexEditorCharacterSet defaultCharacterSet = HexEditorCharacterSet
		.getDefaultCharacterSet(defaultFileContentMode);
	parserComponent.setFileContentMode(defaultFileContentMode);
	parserComponent.setCharacterSet(defaultCharacterSet);

	setPartName(fileName);

    }

    public int getBytesPerRow() {
	return parserComponent.getBytesPerRow();
    }

    @Override
    public void addSelectionChangedListener(ISelectionChangedListener listener) {
	// Nothing.
    }

    @Override
    public void removeSelectionChangedListener(ISelectionChangedListener listener) {
	// Nothing.
    }

    @Override
    public HexEditorSelection getSelection() {

	Point selection = textField.getSelection();

	// if (selection.x == selection.y) {
	// return null;
	// }

	// BasePlugin.getInstance().log(
	// "HexEditor selection.x={0} selection.y={1}",
	// new Object[] { String.valueOf(selection.x),
	// String.valueOf(selection.y) });

	return parserComponent.getSelection(selection.x, selection.y);
    }

    @Override
    public void setSelection(ISelection selection) {
	// Single range selection?
	if (selection instanceof HexEditorSelection) {
	    HexEditorSelection hexEditorSelection = (HexEditorSelection) selection;
	    long textStartOffset = parserComponent.getByteTextOffset(hexEditorSelection.getStartOffset());
	    long textEndOffset = parserComponent.getByteTextOffset(hexEditorSelection.getEndOffset());
	    setSelectionOffsets(textStartOffset, textEndOffset);
	    // Range of outline tree objects?
	} else if (selection instanceof IStructuredSelection) {
	    IStructuredSelection structuredSelection = (IStructuredSelection) selection;

	    if (structuredSelection.getFirstElement() instanceof HexEditorContentOutlineTreeObject) {
		Iterator<?> i = ((IStructuredSelection) selection).iterator();

		long textStartOffset = Long.MAX_VALUE;
		long textEndOffset = Long.MIN_VALUE;
		while (i.hasNext()) {
		    HexEditorContentOutlineTreeObject treeObject = (HexEditorContentOutlineTreeObject) i.next();
		    textStartOffset = Math.min(treeObject.getTextStartOffset(), textStartOffset);
		    textEndOffset = Math.max(treeObject.getTextEndOffset(), textEndOffset);
		}
		setSelectionOffsets(textStartOffset, textEndOffset);
	    }

	}
	setFocus();
    }

    private void setSelectionOffsets(long textStartOffset, long textEndOffset) {
	if (textStartOffset < 0 || textEndOffset > Integer.MAX_VALUE) {
	    throw new IllegalArgumentException("Parameter textStartOffset=" + textStartOffset + " is out of range");
	}
	if (textEndOffset < 0 || textEndOffset > Integer.MAX_VALUE) {
	    throw new IllegalArgumentException("Parameter textStartOffset=" + textStartOffset + " is out of range");
	}
	try {
	    // Mark complete selection area. This also scrolls to
	    // the end of the area.
	    textField.setSelection(new Point((int) textStartOffset, (int) textEndOffset));
	    //
	    // // But we want to see start of the selection are, so
	    // // position explicitly.
	    textField.setTopIndex(textField.getContent().getLineAtOffset((int) textStartOffset));
	} catch (IllegalArgumentException x) {
	    // Ignore
	}
    }

    /**
     * Gets the file path for saving the current selection. Called by
     * {@link HexEditorSaveSelectionAsCommandHandler }.
     * 
     * @return The file path, not <code>null</code>.
     */
    public String getSelectionSaveFilePath() {
	String result = "Selection";
	String extension = ".bin";
	if (parserComponent.getFileContentMode().equals(HexEditorFileContentMode.ATARI_DISK_IMAGE_K_FILE)) {
	    extension = ".xex";
	}

	if (ioFile != null) {
	    result = ioFile.getAbsolutePath();
	    int index = result.lastIndexOf('.');
	    if (index >= 0) {
		result = result.substring(0, index);
	    }
	}

	result += extension;

	return result;
    }

    @Override
    public boolean isDirty() {
	return false;
    }

    @Override
    public void doSave(IProgressMonitor monitor) {
	// Nothing.

    }

    @Override
    public boolean isSaveAsAllowed() {
	return false;
    }

    @Override
    public void doSaveAs() {
	// Nothing.
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public MessageManager getMessageManager() {
	return messageManager;
    }

    private void dataFromUi() {
	messageManager.clearMessages();
	parserComponent.setFileContentMode(fileContentModeField.getValue());
	parserComponent.setCharacterSet(characterSetField.getValue());
	int bytesPerRow = bytesPerRowField.getValue();
	if (bytesPerRow < 1) {
	    bytesPerRow = 16;
	} else if (bytesPerRow > 256) {
	    bytesPerRow = 256;
	}
	parserComponent.setBytesPerRow(bytesPerRow);
    }

    private void dataToUi() {

	// File content size.
	String text = TextUtility.format(Texts.HEX_EDITOR_FILE_CONTENT_SIZE_FIELD_TEXT,
		HexUtility.getLongValueHexString(parserComponent.getFileContent().length),
		NumberUtility.getLongValueDecimalString(parserComponent.getFileContent().length));
	fileContentSizeField.setValue(text);

	// File content mode.
	fileContentModeField.setValue(parserComponent.getFileContentMode());

	// Character set.
	HexEditorCharacterSet characterSet = parserComponent.getCharacterSet();
	characterSetField.setValue(characterSet);
	if (!textField.getFont().equals(characterSet.getFont())) {
	    textField.setFont(characterSet.getFont());
	}

	// Bytes per Row
	bytesPerRowField.setValue(parserComponent.getBytesPerRow());

	if (parserComponent.isParsingFileContentRequired()) {
	    StyledString styledString = parserComponent.parseFileContent();
	    textField.setText(styledString.getString());
	    textField.setStyleRanges(styledString.getStyleRanges());

	    if (contentOutlinePage != null) {
		contentOutlinePage.setInput(parserComponent.getOutlineBlocks());
	    }
	}

	messageManager.displayMessages();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void performAction(Action action) {
	try {

	    ISelection oldSelection = null;
	    dataFromUi();

	    switch (action.getId()) {
	    case Actions.FILE_CONTENT_MODE_CHANGED:
	    case Actions.CHARACTER_SET_TYPE_CHANGED:
	    case Actions.BYTES_PER_ROW_CHANGED:
		oldSelection = getSelection();
		break;
	    }

	    dataToUi();
	    if (oldSelection != null) {
		setSelection(oldSelection);
	    }
	} catch (Exception ex) {
	    BasePlugin.getInstance().showError(getSite().getShell(), "Error in update()", ex);
	}

    }

    /**
     * Called by {@link HexEditorClipboardCommandHandler}.
     * 
     * @param bytes
     *            The byte array to be pasted, may be empty, not
     *            <code>null</code>.
     * 
     *            TODO Hex paste is not working yet
     */
    final void pasteFromClipboard(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	HexEditorSelection selection = getSelection();
	byte[] newFileContent;

	// If there is no end offset, we insert the new bytes.
	if (selection.getEndOffset() != HexEditorParserComponent.UNDEFINED_OFFSET) {
	    int selectionStartOffset = (int) selection.getStartOffset();
	    int selectionEndOffset = (int) selection.getEndOffset();

	    int selectionLength = selectionEndOffset - selectionStartOffset + 1;
	    int newFileContentLength = parserComponent.getFileContent().length - selectionLength + bytes.length;
	    newFileContent = new byte[newFileContentLength];
	    System.arraycopy(parserComponent.getFileContent(), 0, newFileContent, 0, selectionStartOffset);
	    System.arraycopy(bytes, 0, newFileContent, selectionStartOffset, bytes.length);
	    int length = parserComponent.getFileContent().length - selectionEndOffset - 1;
	    if (length > 0) {
		// TODO Hex paste is not working yet
		System.arraycopy(parserComponent.getFileContent(), selectionEndOffset, newFileContent,
			selectionStartOffset + bytes.length, length);
	    }
	    messageManager.sendMessage(0, IStatus.OK,
		    "${0} ({1}) bytes pasted from clipboard to replace ${2} ({3}) bytes ",
		    HexUtility.getLongValueHexString(bytes.length),
		    NumberUtility.getLongValueDecimalString(bytes.length),
		    HexUtility.getLongValueHexString(selectionLength),
		    NumberUtility.getLongValueDecimalString(selectionLength));
	} else {
	    // If there is an end offset, we replace the selection with the new
	    // bytes.
	    newFileContent = parserComponent.getFileContent();
	    messageManager.sendMessage(0, IStatus.OK, "${0} ({1}) bytes inserted from clipboard",
		    HexUtility.getLongValueHexString(bytes.length),
		    NumberUtility.getLongValueDecimalString(bytes.length));
	}

	parserComponent.setFileContent(newFileContent);
	dataToUi();

    }

}
