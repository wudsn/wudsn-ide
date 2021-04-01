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

package com.wudsn.ide.dsk.apple2;

import java.io.File;
import java.io.IOException;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.CTabFolder;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorSite;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IPathEditorInput;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.part.EditorPart;

import com.webcodepro.applecommander.storage.Disk;
import com.webcodepro.applecommander.storage.FormattedDisk;
import com.webcodepro.applecommander.ui.swt.DiskExplorerTab;
import com.webcodepro.applecommander.ui.swt.DiskInfoTab;
import com.webcodepro.applecommander.ui.swt.DiskMapTab;
import com.webcodepro.applecommander.ui.swt.DiskWindow;
import com.webcodepro.applecommander.ui.swt.util.ImageManager;
import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.dsk.Texts;

/**
 * Editor wrapper for AppleCommander. This version is tweaked to correctly run
 * with the SWT version included in AppleCommander-1.3.5.jar.
 * 
 * @author Peter Dell
 * @since 1.6.3
 */
public final class Apple2DiskImageEditor extends EditorPart {

    private static class DummyDiskWindow extends DiskWindow {

	public DummyDiskWindow() {
	    super(null, null, null);
	}

	@Override
	public void setStandardWindowTitle() {

	}

    }

    private ImageManager imageManager;
    private CTabFolder tabFolder;
    private DiskExplorerTab diskExplorerTab;
    private DiskMapTab[] diskMapTabs;
    private DiskInfoTab diskInfoTab;

    private String diskImageFilePath;

    public Apple2DiskImageEditor() {
    }

    @Override
    public void doSave(IProgressMonitor monitor) {

    }

    @Override
    public void doSaveAs() {

    }

    @Override
    public void init(IEditorSite site, IEditorInput input) throws PartInitException {
	// Clear fields.
	File ioFile;
	IFile iFile;
	ioFile = null;
	iFile = null;

	setSite(site);
	setInput(input);

	String fileName = "";
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

	setPartName(fileName);
	if (ioFile != null) {
	    diskImageFilePath = FileUtility.getCanonicalFile(ioFile).getPath();
	} else {
	    diskImageFilePath = "";
	}
    }

    @Override
    public boolean isDirty() {
	return false;
    }

    @Override
    public boolean isSaveAsAllowed() {
	return false;
    }

    @Override
    public void createPartControl(Composite parent) {
	FormattedDisk[] formattedDisks;
	String errorText;

	formattedDisks = new FormattedDisk[0];
	errorText = null;
	if (StringUtility.isEmpty(diskImageFilePath)) {
	    // ERROR: The editor input is not a file in the file system.
	    errorText = Texts.MESSAGE_E100;

	} else {

	    try {
		Disk disk = new Disk(diskImageFilePath);
		formattedDisks = disk.getFormattedDisks();
		if (formattedDisks.length == 0) {
		    // ERROOR: The file is not a valid disk image.
		    errorText = Texts.MESSAGE_E101;
		}
	    } catch (IOException ex) {
		errorText = ex.getMessage();

	    } catch (IllegalArgumentException ex) {
		// Caused by
		// com.webcodepro.applecommander.storage.Disk.isProdosFormat(Disk.java:379)
		errorText = ex.getMessage();
	    } catch (ArrayIndexOutOfBoundsException ex) {
		// Caused by
		// com.webcodepro.applecommander.storage.Disk.isProdosFormat(Disk.java:379)
		errorText = Texts.MESSAGE_E101;
	    }
	}

	if (errorText != null) {
	    Text text = new Text(parent, SWT.READ_ONLY);
	    text.setText(errorText);
	    return;
	}

	imageManager = new ImageManager(parent.getDisplay());
	tabFolder = new CTabFolder(parent, SWT.BOTTOM);
	diskExplorerTab = new DiskExplorerTab(tabFolder, formattedDisks, imageManager, new DummyDiskWindow());
	diskMapTabs = new DiskMapTab[formattedDisks.length];
	for (int i = 0; i < formattedDisks.length; i++) {
	    if (formattedDisks[i].supportsDiskMap()) {
		diskMapTabs[i] = new DiskMapTab(tabFolder, formattedDisks[i]);
	    }
	}
	diskInfoTab = new DiskInfoTab(tabFolder, formattedDisks);
	tabFolder.setSelection(tabFolder.getItems()[0]);
    }

    @Override
    public void setFocus() {
	if (tabFolder != null) {
	    tabFolder.setFocus();
	}
    }

    @Override
    public void dispose() {
	if (diskExplorerTab != null) {
	    diskExplorerTab.dispose();
	    diskExplorerTab = null;
	}
	if (diskMapTabs != null) {
	    for (int i = 0; i < diskMapTabs.length; i++) {
		if (diskMapTabs[i] != null)
		    diskMapTabs[i].dispose();
	    }
	    diskMapTabs = null;
	}
	if (diskInfoTab != null) {
	    diskInfoTab.dispose();
	    diskInfoTab = null;
	}
	if (imageManager != null) {
	    imageManager.dispose();
	    imageManager = null;
	}
    }

}
