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

package com.wudsn.ide.gfx.converter;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Path;
import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.ImageLoader;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.base.BasePlugin;
import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.IPathUtility;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.gui.MessageManager;
import com.wudsn.ide.gfx.GraphicsPlugin;
import com.wudsn.ide.gfx.converter.FilesConverterParameters.SourceFile;
import com.wudsn.ide.gfx.converter.ImageConverterParameters.TargetFile;
import com.wudsn.ide.gfx.converter.atari8bit.LinearBitMapGraphics8Converter;
import com.wudsn.ide.gfx.model.ConverterDirection;
import com.wudsn.ide.gfx.model.ConverterMode;

public final class ConverterDataLogic {
    private MessageManager messageManager;
    private FilesConverterDataLogic filesConverterDataLogic;

    /**
     * Helper class to detect the support image file formats by their extension.
     * 
     * @author Peter Dell
     */
    private static final class ImageExtensions {
	public static final String CNV = "cnv";
	public static final String BMP = "bmp";
	public static final String ICO = "ico";
	public static final String GIF = "gif";
	public static final String JPG = "jpg";
	public static final String PNG = "png";

	public static final int UNKNOWN_FORMAT = -1;

	public static int getImageFormat(IPath filePath) {
	    int result;

	    String fileExtension = filePath.getFileExtension();
	    if (fileExtension == null) {
		result = UNKNOWN_FORMAT;
	    } else if (fileExtension.equalsIgnoreCase(BMP)) {
		result = SWT.IMAGE_BMP;
	    } else if (fileExtension.equalsIgnoreCase(ICO)) {
		result = SWT.IMAGE_ICO;
	    } else if (fileExtension.equalsIgnoreCase(GIF)) {
		result = SWT.IMAGE_GIF;
	    } else if (fileExtension.equalsIgnoreCase(JPG)) {
		result = SWT.IMAGE_JPEG;
	    } else if (fileExtension.equalsIgnoreCase(PNG)) {
		result = SWT.IMAGE_PNG;
	    } else {
		result = UNKNOWN_FORMAT;
	    }
	    return result;
	}
    }

    public ConverterDataLogic(MessageManager messageManager) {
	if (messageManager == null) {
	    throw new IllegalArgumentException("Parameter 'messageManager' must not be null.");
	}
	this.messageManager = messageManager;
	filesConverterDataLogic = new FilesConverterDataLogic();
    }

    public ConverterData createData() {
	return new ConverterData();
    }

    public void load(ConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}

	data.clearContent();

	IFile file = data.getFile();
	String fileName = file.getFullPath().lastSegment();
	String extension = file.getFileExtension();
	if (extension == null) {
	    extension = "";
	} else {
	    extension = extension.toLowerCase();
	}

	if (extension.equals(ImageExtensions.CNV)) {
	    data.setConverterMode(ConverterMode.CNV);
	    try {

		data.getParameters().read(file);

	    } catch (CoreException ex) {
		messageManager.sendMessage(0, ex);
	    }
	    loadSources(data, true);
	} else {
	    int imageFormat = ImageExtensions.getImageFormat(file.getFullPath());
	    if (imageFormat != ImageExtensions.UNKNOWN_FORMAT) {
		data.setConverterMode(ConverterMode.RAW_IMAGE);
		data.getParameters().setConverterDirection(ConverterDirection.IMAGE_TO_FILES);
		data.getImageConverterData().getParameters().setImageFilePath(fileName);
		data.getImageConverterData().getParameters()
			.setConverterId(LinearBitMapGraphics8Converter.class.getName());
		loadSources(data, true);

	    } else {
		data.setConverterMode(ConverterMode.RAW_FILE);
		data.getParameters().setConverterDirection(ConverterDirection.FILES_TO_IMAGE);
		data.getFilesConverterData().getParameters().setDefaultSourceFilePath(fileName);
		data.getFilesConverterData().getParameters().setImageFilePath(fileName + "." + ImageExtensions.PNG);
		findDefaultFileConverter(data);
		loadSources(data, true);
	    }

	}

    }

    public void findDefaultFileConverter(ConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	FilesConverterData filesConverterData;
	filesConverterData = data.getFilesConverterData();
	FilesConverterParameters fileConverterParameters = filesConverterData.getParameters();

	IPath filePathPrefix = filesConverterData.getFilePathPrefix();

	SourceFile sourceFile = fileConverterParameters.getSourceFile(0);
	IPath filePath = Path.fromPortableString(sourceFile.getPath());
	filePath = IPathUtility.makeAbsolute(filePath, filePathPrefix, false);
	byte[] bytes = loadSourceFile(sourceFile.getPathMessageId(), filePath);

	// TODO: If bytes is null or length is 0, an error message should be displayed instead.
	if (bytes != null) {
	    String fileExtension = filePath.getFileExtension();
	    if (fileExtension != null) {
		fileExtension = fileExtension.toLowerCase();
	    } else {
		fileExtension = "";
	    }
	    filesConverterDataLogic.findDefaultFileConverter(filesConverterData, bytes, fileExtension);

	}
    }

    public boolean loadSources(ConverterData data, boolean copyToBackup) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	boolean success;

	success = true;
	switch (data.getConverterDirection()) {
	case FILES_TO_IMAGE:

	    FilesConverterData filesConverterData;
	    filesConverterData = data.getFilesConverterData();
	    FilesConverterParameters fileConverterParameters = filesConverterData.getParameters();

	    IPath filePathPrefix = filesConverterData.getFilePathPrefix();
	    for (int i = 0; i < fileConverterParameters.getSourceFilesSize(); i++) {
		SourceFile sourceFile = fileConverterParameters.getSourceFile(i);
		IPath filePath = Path.fromPortableString(sourceFile.getPath());
		filePath = IPathUtility.makeAbsolute(filePath, filePathPrefix, false);
		byte[] bytes = loadSourceFile(sourceFile.getPathMessageId(), filePath);
		filesConverterData.setSourceFileBytes(sourceFile.getId(), bytes);
		if (bytes == null) {
		    success = false;
		}
	    }

	    break;
	case IMAGE_TO_FILES:
	    ImageConverterData imageConverterData;
	    imageConverterData = data.getImageConverterData();

	    filePathPrefix = imageConverterData.getFilePathPrefix();
	    IPath filePath = Path.fromPortableString(imageConverterData.getParameters().getImageFilePath());
	    filePath = IPathUtility.makeAbsolute(filePath, filePathPrefix, false);
	    ImageData imageData = loadSourceImage(ImageConverterParameters.MessageIds.IMAGE_FILE_PATH, filePath);
	    imageConverterData.setImageData(imageData);
	    if (imageData != null) {
		// Remember last loaded state.
		success = true;

	    } else {
		success = false;
	    }
	    break;
	default:
	    throw new RuntimeException("Unknown converter direction '" + data.getConverterDirection() + "'.");

	}

	// Remember last loaded state.
	if (success && copyToBackup) {
	    data.copyParametersToBackup();
	}

	return success;
    }

    /**
     * Applies the converter based default values after the converter has been
     * selected.
     * 
     * @param data
     *            The converter data, not <code>null</code>.
     */
    public void applyDefaults(ConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}

	switch (data.getConverterDirection()) {
	case FILES_TO_IMAGE:
	    filesConverterDataLogic.applyDefaults(data.getFilesConverterData());

	    break;
	case IMAGE_TO_FILES:

	    break;
	default:
	    throw new RuntimeException("Unknown converter direction '" + data.getConverterDirection() + "'.");
	}
    }

    public ConverterData createConversion(ConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	if (!data.isValid()) {
	    throw new IllegalStateException("Converter data is not valid.");
	}
	if (data.getConverterMode() != ConverterMode.RAW_FILE && data.getConverterMode() != ConverterMode.RAW_IMAGE) {
	    throw new IllegalStateException("Converter data is not in mode RAW_FILE or RAW_IMAGE.");
	}

	// Compute new file name.
	IWorkspaceRoot workspaceRoot = ResourcesPlugin.getWorkspace().getRoot();
	IPath saveAsPath = data.getFile().getFullPath().addFileExtension(ImageExtensions.CNV);
	IFile saveAsFile = workspaceRoot.getFile(saveAsPath);

	// Compute new content.
	ConverterData newConverterData = new ConverterData();
	newConverterData.setConverterMode(ConverterMode.CNV);
	newConverterData.setFile(saveAsFile);
	data.getParameters().copyTo(newConverterData.getParameters());

	return newConverterData;
    }

    public IFile saveConversion(ConverterData data, IProgressMonitor monitor) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}

	IFile saveFile;
	String saveFilePath;
	saveFile = data.getFile();
	saveFilePath = saveFile.getFullPath().toString();

	try {
	    InputStream inputStream;
	    inputStream = data.getParameters().getContents(saveFilePath);
	    if (saveFile.exists()) {
		saveFile.setContents(inputStream, false, false, monitor);
	    } else {
		saveFile.create(inputStream, true, monitor);
	    }
	    // Remember last saved state.
	    data.copyParametersToBackup();

	} catch (CoreException ex) {
	    messageManager.sendMessage(0, ex);
	    saveFile = null;
	}
	return saveFile;
    }

    public void saveTargets(ConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	IPath filePathPrefix;
	IPath filePath;
	if (convert(data)) {
	    switch (data.getConverterDirection()) {
	    case FILES_TO_IMAGE:

		FilesConverterData filesConverterData;
		filesConverterData = data.getFilesConverterData();

		filePathPrefix = filesConverterData.getFilePathPrefix();
		filePath = Path.fromPortableString(filesConverterData.getParameters().getImageFilePath());
		filePath = IPathUtility.makeAbsolute(filePath, filePathPrefix, false);
		saveTargetImage(FilesConverterParameters.MessageIds.IMAGE_FILE_PATH, filePath,
			filesConverterData.getImageData());
		break;
	    case IMAGE_TO_FILES:
		ImageConverterData imageConverterData;
		ImageConverterParameters imageConverterParameters;
		imageConverterData = data.getImageConverterData();
		imageConverterParameters = imageConverterData.getParameters();

		filePathPrefix = imageConverterData.getFilePathPrefix();
		int size = imageConverterData.getConverter().getDefinition().getTargetFileDefinitions().size();
		int minSize = Math.min(size, imageConverterParameters.getTargetFilesSize());
		boolean saved = true;
		for (int i = 0; i < minSize; i++) {
		    TargetFile targetFile = imageConverterParameters.getTargetFile(i);
		    filePath = Path.fromPortableString(targetFile.getPath());
		    filePath = IPathUtility.makeAbsolute(filePath, filePathPrefix, false);
		    saved &= saveTargetFile(targetFile.getPathMessageId(), filePath,
			    imageConverterData.getTargetFileBytes(targetFile.getId()));
		}
		if (!saved) {
		    for (int i = 0; i < minSize; i++) {
			TargetFile targetFile = imageConverterParameters.getTargetFile(i);
			messageManager.sendMessage(targetFile.getPathMessageId(), IStatus.ERROR,
				"No target file with file path and content present");
		    }

		}
		break;
	    default:
		throw new RuntimeException("Unknown converter direction '" + data.getConverterDirection() + "'.");

	    }
	}
    }

    /**
     * Saves a target file, if path and content are present. Empty content is
     * allowed, <code>null</code> content is interpreted as missing file.
     * 
     * @param messageId
     *            The message id.
     * @param filePath
     *            The target file path, may be empty, not <code>null</code>.
     * @param bytes
     *            The target file content, may be empty or <code>null</code>.
     * 
     * @return <code>true</code> if the file was save, <code>false</code>
     *         otherwise.
     */
    private boolean saveTargetFile(int messageId, IPath filePath, byte[] bytes) {
	if (filePath == null) {
	    throw new IllegalArgumentException("Parameter 'filePath' must not be null.");
	}
	boolean result;

	if (filePath.isEmpty()) {
	    messageManager.sendMessage(messageId, IStatus.WARNING, "No target file path specified");
	    return false;
	}
	if (bytes == null) {
	    messageManager.sendMessage(messageId, IStatus.INFO, "File {0} not saved as there is no data for this file",
		    filePath.toPortableString());
	    return false;
	}

	IWorkspaceRoot workspaceRoot;
	IFile saveFile;
	IProgressMonitor monitor;

	result = false;
	workspaceRoot = ResourcesPlugin.getWorkspace().getRoot();
	saveFile = workspaceRoot.getFile(filePath);
	monitor = null;

	try {
	    InputStream inputStream;
	    inputStream = new ByteArrayInputStream(bytes);
	    if (saveFile.exists()) {
		saveFile.setContents(inputStream, false, false, monitor);
	    } else {
		saveFile.create(inputStream, true, monitor);
	    }

	} catch (CoreException ex) {
	    messageManager.sendMessage(0, ex);
	    saveFile = null;
	}

	if (saveFile != null) {
	    messageManager.sendMessage(messageId, IStatus.INFO, "File {0} saved with ${1} bytes",
		    filePath.toPortableString(), HexUtility.getLongValueHexString(bytes.length));
	    result = true;
	}
	return result;
    }

    private void saveTargetImage(int messageId, IPath filePath, ImageData imageData) {
	if (filePath == null) {
	    throw new IllegalArgumentException("Parameter 'filePath' must not be null.");
	}
	if (filePath.isEmpty()) {
	    messageManager.sendMessage(messageId, IStatus.ERROR, "No image path specified");
	    return;
	}
	if (imageData == null) {
	    messageManager.sendMessage(messageId, IStatus.ERROR,
		    "Image {0} not saved as there is no data for this image", filePath.toPortableString());
	    return;
	}

	ImageLoader imageLoader = new ImageLoader();
	imageLoader.data = new ImageData[] { imageData };
	int format = ImageExtensions.getImageFormat(filePath);
	if (format == ImageExtensions.UNKNOWN_FORMAT) {
	    messageManager.sendMessage(messageId, IStatus.ERROR,
		    "Image {0} not saved as there is the extension cannot be mapped to a supported image format",
		    filePath.toPortableString());
	    return;
	}

	boolean success = false;
	IFile file = ResourcesPlugin.getWorkspace().getRoot().getFile(filePath);
	try {

	    ByteArrayOutputStream bos = new ByteArrayOutputStream();
	    imageLoader.save(bos, format);
	    bos.close();
	    ByteArrayInputStream bis = new ByteArrayInputStream(bos.toByteArray());
	    if (!file.exists()) {
		file.create(bis, IResource.FORCE, null);
	    } else {
		file.setContents(bis, IResource.FORCE, null);
	    }
	    success = true;
	} catch (Exception ex) {
	    messageManager.sendMessage(messageId, IStatus.ERROR, "Image {0} not saved. {1}",
		    filePath.toPortableString(), ex.getMessage());
	}
	// file.refreshLocal(IResource.DEPTH_ZERO, null);

	if (success) {
	    messageManager.sendMessage(messageId, IStatus.INFO, "Image {0} saved", filePath.toPortableString());
	}
    }

    private ImageData loadSourceImage(int messageId, IPath filePath) {
	if (filePath == null) {
	    throw new IllegalArgumentException("Parameter 'fileSection' must not be null.");
	}
	ImageData imageData = null;
	if (!filePath.isEmpty()) {
	    IFile file = ResourcesPlugin.getWorkspace().getRoot().getFile(filePath);

	    InputStream is;
	    try {
		is = file.getContents(true);
	    } catch (CoreException ex) {
		messageManager.sendMessage(messageId, ex);
		is = null;
	    }

	    if (is != null) {
		try {
		    try {
			imageData = new ImageData(is);

		    } catch (SWTException ex) {
			messageManager.sendMessage(messageId, IStatus.ERROR,
				"Cannot open image file. " + ex.getMessage());

		    }
		} finally {
		    try {
			is.close();
		    } catch (IOException ex) {
			BasePlugin.getInstance().logError("Cannot close input stream for {0}",
				new Object[] { filePath }, ex);
		    }
		}
	    }

	}
	return imageData;
    }

    private byte[] loadSourceFile(int messageId, IPath filePath) {
	if (filePath == null) {
	    throw new IllegalArgumentException("Parameter 'filePath' must not be null.");
	}
	byte[] result;

	if (!filePath.isEmpty()) {
	    try {
		IFile file = ResourcesPlugin.getWorkspace().getRoot().getFile(filePath);

		result = FileUtility.readBytes(file, FileUtility.MAX_SIZE_1MB, true);
	    } catch (CoreException ex) {
		messageManager.sendMessage(messageId, ex);
		result = null;
	    } catch (IllegalArgumentException ex) {
		messageManager.sendMessage(messageId, IStatus.ERROR, ex.getMessage());
		result = null;
	    }

	} else {
	    result = null;
	}
	return result;
    }

    public boolean convert(ConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	ConverterDirection converterDirection;
	converterDirection = data.getConverterDirection();
	boolean result;
	switch (converterDirection) {

	case FILES_TO_IMAGE:
	    result = convertFilesToImage(data);
	    break;

	case IMAGE_TO_FILES:
	    result = convertImageToFiles(data);
	    break;

	default:
	    throw new RuntimeException("Unknown converter direction '" + converterDirection + "'.");
	}
	return result;
    }

    private boolean convertImageToFiles(ConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	if (!data.isValidImage()) {
	    return false;
	}

	ImageConverterData imageConverterData;
	imageConverterData = data.getImageConverterData();

	ImageConverterParameters imageConverterParameters;
	imageConverterParameters = imageConverterData.getParameters();

	// Setup image data fields.
	if (imageConverterData.getImageData() == null) {

	    // Create empty image data.
	    PaletteData palette = new PaletteData(255, 255, 255);
	    data.getImageConverterData().setImageData(new ImageData(320, 256, 8, palette));
	    imageConverterData.setImageColorHistogram(null);

	} else {
	    ImageColorHistogram imageColorHistogram = new ImageColorHistogram();
	    imageColorHistogram.analyze(imageConverterData.getImageData());
	    imageConverterData.setImageColorHistogram(imageColorHistogram);

	}

	imageConverterData.setImageDataWidth(imageConverterData.getImageData().width);
	imageConverterData.setImageDataHeight(imageConverterData.getImageData().height);
	imageConverterData.clearTargetFileBytes();

	Converter converter;

	if (StringUtility.isEmpty(imageConverterParameters.getConverterId())) {
	    messageManager.sendMessage(ConverterCommonParameters.MessageIds.CONVERTER_ID, IStatus.ERROR,
		    "No converter selected");
	    return false;
	}
	converter = imageConverterData.getConverter();
	if (converter == null) {
	    messageManager.sendMessage(ConverterCommonParameters.MessageIds.CONVERTER_ID, IStatus.ERROR,
		    "Converter '{0}' is not registered", String.valueOf(imageConverterParameters.getConverterId()));
	    return false;
	}

	if (messageManager.containsError()) {
	    return false;
	}

	// Default the script if none is specified.
	if (StringUtility.isEmpty(imageConverterParameters.getScript())) {
	    try {
		imageConverterParameters.setScript(ConverterScript.getScript(converter.getClass()));
	    } catch (CoreException ex) {
		messageManager.sendMessage(ImageConverterParameters.MessageIds.SCRIPT, ex);
		return false;
	    }
	}

	try {
	    // Apply default to conversion parameters.
	    if (imageConverterParameters.isUseDefaultScript()
		    || StringUtility.isEmpty(imageConverterParameters.getScript())) {
		String script = ConverterScript.getScript(converter.getClass());
		imageConverterParameters.setScript(script);
	    }

	    ConverterScript.convertToFileData(converter, imageConverterData);
	} catch (CoreException ex) {
	    messageManager.sendMessage(ConverterCommonParameters.MessageIds.CONVERTER_ID, ex);
	    return false;
	} catch (RuntimeException ex) {
	    String message = ex.getMessage();
	    if (message == null) {
		message = ex.getClass().getName();
	    }
	    messageManager.sendMessage(ImageConverterParameters.MessageIds.SCRIPT, IStatus.ERROR, message);
	    return false;
	}

	return true;
    }

    private boolean convertFilesToImage(ConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	if (!data.isValidFile()) {
	    return false;
	}

	FilesConverterData filesConverterData;
	filesConverterData = data.getFilesConverterData();

	filesConverterData.setImageDataValid(false);
	filesConverterData.setImageDataWidth(0);
	filesConverterData.setImageDataHeight(0);
	filesConverterData.setImageData(null);

	FilesConverterParameters filesConverterParameters;
	filesConverterParameters = filesConverterData.getParameters();

	if (filesConverterParameters.getSpacingWidth() < 0) {
	    messageManager.sendMessage(FilesConverterParameters.MessageIds.SPACING_WIDTH, IStatus.ERROR,
		    "Spacing width must not be negative. Current value is {0}",
		    String.valueOf(filesConverterParameters.getSpacingWidth()));
	}

	if (filesConverterParameters.getColumns() <= 0) {
	    messageManager.sendMessage(FilesConverterParameters.MessageIds.COLUMNS, IStatus.ERROR,
		    "Columns count must be positive. Current value is {0}",
		    String.valueOf(filesConverterParameters.getColumns()));
	}
	if (filesConverterParameters.getRows() <= 0) {
	    messageManager.sendMessage(FilesConverterParameters.MessageIds.ROWS, IStatus.ERROR,
		    "Rows count must be positive. Current value is {0}",
		    String.valueOf(filesConverterParameters.getRows()));
	}

	Converter converter;

	if (StringUtility.isEmpty(filesConverterParameters.getConverterId())) {
	    messageManager.sendMessage(ConverterCommonParameters.MessageIds.CONVERTER_ID, IStatus.ERROR,
		    "No converter selected");
	    return false;
	}
	converter = filesConverterData.getConverter();
	if (converter == null) {
	    messageManager.sendMessage(ConverterCommonParameters.MessageIds.CONVERTER_ID, IStatus.ERROR,
		    "Converter '{0}' is not registered", String.valueOf(filesConverterParameters.getConverterId()));
	    return false;
	}

	if (messageManager.containsError()) {
	    return false;
	}
	converter.convertToImageDataSize(filesConverterData);
	if (filesConverterData.getImageDataWidth() <= 0) {
	    messageManager.sendMessage(FilesConverterParameters.MessageIds.COLUMNS, IStatus.ERROR,
		    "Resulting image data with '{0}' is not positive",
		    String.valueOf(filesConverterData.getImageDataWidth()));
	}
	if (filesConverterData.getImageDataHeight() <= 0) {
	    messageManager.sendMessage(FilesConverterParameters.MessageIds.ROWS, IStatus.ERROR,
		    "Resulting image data height '{0}' is not positive",
		    String.valueOf(filesConverterData.getImageDataWidth()));
	}

	int MAX_PIXELS = 1000 * 1000;
	int pixels = filesConverterData.getImageDataWidth() * filesConverterData.getImageDataHeight();
	if (pixels > MAX_PIXELS) {
	    messageManager.sendMessage(FilesConverterParameters.MessageIds.ROWS, IStatus.ERROR,
		    "Resulting image would have {0} pixels and exceed the memory limit of {1} pixels",
		    String.valueOf(pixels), String.valueOf(MAX_PIXELS));
	}

	if (messageManager.containsError()) {
	    return false;
	}

	// Create index or direct palette and image data.
	PaletteData paletteData;
	ImageData imageData;
	int paletteSize;
	paletteSize = filesConverterData.getConverter().getDefinition().getTargetImagePaletteSize();
	if (paletteSize > 0) {
	    // Create 8 bit index palette.
	    RGB[] paletteColors = new RGB[paletteSize];
	    RGB[] currentPaletteColors = filesConverterParameters.getPaletteRGBs();
	    for (int i = 0; i < paletteColors.length; i++) {
		if (i < currentPaletteColors.length) {
		    paletteColors[i] = currentPaletteColors[i];
		} else {
		    paletteColors[i] = new RGB(0, 0, 0);
		}
	    }
	    filesConverterParameters.setPaletteRGBs(paletteColors);

	    RGB[] actualPaletteColors = new RGB[paletteColors.length + 1];
	    System.arraycopy(paletteColors, 0, actualPaletteColors, 0, paletteColors.length);
	    // The color at index actualPaletteColors.length is used as spacing
	    // color in order to keep the original palette index order
	    int spacingColorIndex = paletteColors.length;
	    actualPaletteColors[spacingColorIndex] = filesConverterParameters.getSpacingColor();
	    paletteData = new PaletteData(actualPaletteColors);
	    imageData = new ImageData(filesConverterData.getImageDataWidth(), filesConverterData.getImageDataHeight(),
		    8, paletteData);
	    for (int y = 0; y < filesConverterData.getImageDataHeight(); y++) {
		for (int x = 0; x < filesConverterData.getImageDataWidth(); x++) {
		    imageData.setPixel(x, y, spacingColorIndex);
		}
	    }
	} else {
	    // Create 24 bit direct palette.
	    paletteData = new PaletteData(0xFF0000, 0xFF00, 0xFF);
	    imageData = new ImageData(filesConverterData.getImageDataWidth(), filesConverterData.getImageDataHeight(),
		    24, paletteData);
	}
	filesConverterData.setImageData(imageData);
	boolean conversionResult;
	try {
	    conversionResult = converter.convertToImageData(filesConverterData);
	} catch (RuntimeException ex) {
	    GraphicsPlugin.getInstance().logError("Runtime exception during convertFilesToImage()", null, ex);
	    conversionResult = false;
	}
	filesConverterData.setImageDataValid(conversionResult);

	ImageColorHistogram imageColorHistogram = new ImageColorHistogram();
	imageColorHistogram.analyze(imageData);
	filesConverterData.setImageColorHistogram(imageColorHistogram);
	return conversionResult;
    }
}
