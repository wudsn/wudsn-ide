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

package com.wudsn.ide.gfx.converter;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;

import com.wudsn.ide.base.common.IPathUtility;
import com.wudsn.ide.gfx.model.ConverterDirection;
import com.wudsn.ide.gfx.model.ConverterMode;

public final class ConverterData {

    private static final class Defaults {

	/**
	 * Creation is private.
	 */
	private Defaults() {
	}

	public static final ConverterMode CONVERTER_MODE = ConverterMode.NONE;
    }

    private IFile file;
    private IPath filePathPrefix;

    private ConverterMode converterMode;
    private ConverterParameters parameters;
    private ConverterParameters parametersBackup;

    private FilesConverterData filesConverterData;
    private ImageConverterData imageConverterData;

    ConverterData() {
	parameters = new ConverterParameters();
	parametersBackup = new ConverterParameters();
	filesConverterData = new FilesConverterData(this);
	imageConverterData = new ImageConverterData(this);
	clear();
    }

    public void setFile(IFile file) {
	this.file = file;
	if (file != null) {
	    filePathPrefix = file.getFullPath().removeLastSegments(1);
	} else {
	    filePathPrefix = IPathUtility.createEmptyPath();

	}
    }

    public IFile getFile() {
	return file;
    }

    public IPath getFilePathPrefix() {
	return filePathPrefix;
    }

    public boolean isValid() {
	return file != null;
    }

    public void setConverterMode(ConverterMode value) {
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}
	this.converterMode = value;
    }

    public ConverterMode getConverterMode() {
	return converterMode;
    }

    public boolean isValidFile() {
	return isValid() && (converterMode == ConverterMode.RAW_FILE || converterMode == ConverterMode.CNV);
    }

    public boolean isValidImage() {
	return isValid() && (converterMode == ConverterMode.RAW_IMAGE || converterMode == ConverterMode.CNV);
    }

    public boolean isValidConversion() {
	return isValid() && converterMode == ConverterMode.CNV;
    }

    public ConverterDirection getConverterDirection() {

	return parameters.getConverterDirection();
    }

    public ConverterParameters getParameters() {
	return parameters;
    }

    public ConverterCommonData getConverterCommonData() {
	switch (parameters.getConverterDirection()) {
	case FILES_TO_IMAGE:
	    return filesConverterData;
	case IMAGE_TO_FILES:
	    return imageConverterData;
	default:
	    throw new IllegalStateException("Unknown converter direction " + parameters.getConverterDirection() + ".");
	}
    }

    public FilesConverterData getFilesConverterData() {
	return filesConverterData;
    }

    public ImageConverterData getImageConverterData() {
	return imageConverterData;
    }

    public void clear() {
	file = null;
	clearContent();
    }

    public void clearContent() {
	converterMode = Defaults.CONVERTER_MODE;
	parameters.setDefaults();
	filesConverterData.clear();
	imageConverterData.clear();

    }

    final void copyParametersToBackup() {
	parametersBackup.setDefaults();
	parameters.copyTo(parametersBackup);
    }

    public boolean isChanged() {
	boolean result;
	result = !parameters.equals(parametersBackup);
	return result;
    }

}
