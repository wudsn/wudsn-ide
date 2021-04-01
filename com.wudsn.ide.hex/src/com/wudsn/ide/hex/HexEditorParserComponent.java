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
package com.wudsn.ide.hex;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.jface.preference.JFacePreferences;
import org.eclipse.jface.viewers.StyledString;
import org.eclipse.jface.viewers.StyledString.Styler;
import org.eclipse.swt.graphics.TextStyle;

import com.wudsn.ide.base.BasePlugin;
import com.wudsn.ide.base.common.EnumUtility;
import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.Profiler;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.base.gui.MessageManager;
import com.wudsn.ide.base.hardware.HardwareCharacterSet;
import com.wudsn.ide.hex.HexEditor.MessageIds;
import com.wudsn.ide.hex.parser.AtariDiskImageKFileParser;
import com.wudsn.ide.hex.parser.AtariMADSParser;
import com.wudsn.ide.hex.parser.AtariParser;
import com.wudsn.ide.hex.parser.AtariSDXParser;

final class HexEditorParserComponent {

    public static final long UNDEFINED_OFFSET = -1;
    private final static int BYTES_PER_ROW = 16;

    // Callback API.
    private MessageManager messageManager;

    // Style components.
    private Styler offsetStyler;
    private Styler addressStyler;
    private Styler charStyler;
    private Styler errorStyler;

    // File content and state.
    private boolean fileContentParsed;
    private HexEditorFileContentMode fileContentMode;
    private byte[] fileContent;
    private int bytesPerRow;
    private HardwareCharacterSet characterSet;

    // Previous state with regards to parsing.
    private HexEditorFileContentMode oldFileContentMode;
    private byte[] oldFileContent;
    private int oldBytesPerRow;
    private HardwareCharacterSet oldCharacterSet;

    // Parsing state.
    private List<HexEditorFileContentMode> possibleFileContentModes;
    private List<HexEditorContentOutlineTreeObject> outlineBlocks;
    private long[] byteTextOffsets;
    private int byteTextIndex;

    // Line buffers for binary to hex and char conversion.
    private char[] hexChars;
    private char[] hexBuffer;
    private char[] charBuffer;

    public HexEditorParserComponent(MessageManager messageManager) {
	if (messageManager == null) {
	    throw new IllegalArgumentException("Parameter 'messageManager' must not be null.");
	}
	this.messageManager = messageManager;

	// Get static stylers for the styled string.
	offsetStyler = StyledString.createColorRegistryStyler(JFacePreferences.COUNTER_COLOR, null);
	addressStyler = StyledString.createColorRegistryStyler(JFacePreferences.QUALIFIER_COLOR, null);
	charStyler = StyledString.createColorRegistryStyler(JFacePreferences.HYPERLINK_COLOR, null);

	charStyler = new Styler() {

	    @Override
	    public void applyStyles(TextStyle textStyle) {
		textStyle.font = null;

	    }

	};

	errorStyler = StyledString.createColorRegistryStyler(JFacePreferences.ERROR_COLOR, null);

	// Initialize hex chars and normal character set type.
	hexChars = new char[] { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
	characterSet = HardwareCharacterSet.ASCII;

	clear();

    }

    private void clear() {
	// Initialize with empty file.
	fileContentParsed = false;
	fileContentMode = HexEditorFileContentMode.BINARY;
	setFileContent(new byte[0]);
	characterSet = HardwareCharacterSet.ASCII;
	bytesPerRow = BYTES_PER_ROW;

	oldFileContentMode = null;
	oldFileContent = null;
	oldCharacterSet = null;
	oldBytesPerRow = 0;

	possibleFileContentModes = new ArrayList<HexEditorFileContentMode>();
	outlineBlocks = new ArrayList<HexEditorContentOutlineTreeObject>();
    }

    public void setFileContent(byte[] fileContent) {
	if (fileContent == null) {
	    throw new IllegalArgumentException("Parameter 'fileContent' must not be null.");
	}
	this.fileContent = fileContent;
	initByteTextOffsets();
    }

    /**
     * Reserve enough space for the lookup table that maps text offsets to file
     * offsets.
     */
    private void initByteTextOffsets() {
	// Twice the space, because some formats display the content twice, for
	// example ATARI_DISK_IMAGE_K_FILE.
	byteTextOffsets = new long[fileContent.length * 2];
	Arrays.fill(byteTextOffsets, -1);
	byteTextIndex = 0;
    }

    /**
     * Determines the possible file content modes based on the file content.
     * 
     * @return The suggested default file content mode, not <code>null</code>.
     */
    public HexEditorFileContentMode determinePossibleFileContentModes() {

	HexEditorFileContentMode result = HexEditorFileContentMode.BINARY;
	possibleFileContentModes.clear();
	possibleFileContentModes.add(fileContentMode);

	HexEditorFileContentMode defaultMode = result;
	FileContent fileContent = getFileContent();
	// COM header present?
	if (fileContent.getLength() > 6) {
	    // AtariDOS COM file?
	    if (fileContent.getWord(0) == AtariParser.COM_HEADER) {
		int startAddress = fileContent.getWord(2);
		int endAddress = fileContent.getWord(4);
		if (startAddress >= 0 && endAddress >= startAddress) {
		    defaultMode = HexEditorFileContentMode.ATARI_COM_FILE;
		    possibleFileContentModes.add(defaultMode);

		    if (fileContent.getLength() > 16) {
			if (fileContent.getWord(6) == AtariMADSParser.RELOC_HEADER) {
			    defaultMode = HexEditorFileContentMode.ATARI_MADS_FILE;
			    possibleFileContentModes.add(defaultMode);
			}
		    }
		    // New default?
		    if (result.equals(HexEditorFileContentMode.BINARY)) {
			result = defaultMode;
		    }
		}
	    } // SpartaDOS X non relocatable file?
	    else if (fileContent.getWord(0) == AtariSDXParser.NON_RELOC_HEADER) {
		int startAddress = fileContent.getWord(2);
		int endAddress = fileContent.getWord(4);
		if (startAddress > 0 && endAddress >= startAddress) {
		    defaultMode = HexEditorFileContentMode.ATARI_SDX_FILE;
		    possibleFileContentModes.add(defaultMode);
		    // New default?
		    if (result.equals(HexEditorFileContentMode.BINARY)) {
			result = defaultMode;
		    }
		}
	    } // SpartaDOS X relocatable file?
	    else if (fileContent.getWord(0) == AtariSDXParser.RELOC_HEADER && fileContent.getLength() > 8) {
		int blockNumber = fileContent.getByte(2);
		if (blockNumber > 0) {
		    defaultMode = HexEditorFileContentMode.ATARI_SDX_FILE;
		    possibleFileContentModes.add(defaultMode);
		    // New default?
		    if (result.equals(HexEditorFileContentMode.BINARY)) {
			result = defaultMode;
		    }
		}
	    }
	}

	// ATR header present?
	if ((fileContent.getLength() > 16 && fileContent.getByte(0) == 0x96 && fileContent.getByte(1) == 0x02)) {
	    defaultMode = HexEditorFileContentMode.ATARI_DISK_IMAGE;
	    possibleFileContentModes.add(defaultMode);

	    // Special case of k-file (converted COM file)
	    int offset = AtariDiskImageKFileParser.ATARI_DISK_IMAGE_K_FILE_COM_FILE_OFFSET;
	    if (fileContent.getLength() > offset + 2 && fileContent.getWord(offset) == 0xffff) {
		final int[] kFileBootHeader = new int[] { 0x00, 0x03, 0x00, 0x07, 0x14, 0x07, 0x4C, 0x14, 0x07 };
		boolean kFileBootHeaderFound = true;
		for (int i = 0; i < kFileBootHeader.length; i++) {
		    if (fileContent.getByte(16 + i) != kFileBootHeader[i]) {
			kFileBootHeaderFound = false;
		    }
		}
		if (kFileBootHeaderFound) {
		    defaultMode = HexEditorFileContentMode.ATARI_DISK_IMAGE_K_FILE;
		    possibleFileContentModes.add(defaultMode);
		}
	    }

	    // New default?
	    if (result.equals(HexEditorFileContentMode.BINARY)) {
		result = defaultMode;
	    }
	}

	// SAP header present?
	if ((fileContent.getLength() > 11 && fileContent.getByte(0) == 0x53 && fileContent.getByte(1) == 0x41)
		&& fileContent.getByte(2) == 0x50) {
	    possibleFileContentModes.add(HexEditorFileContentMode.ATARI_SAP_FILE);
	    // New default?
	    if (result.equals(HexEditorFileContentMode.BINARY)) {
		result = HexEditorFileContentMode.ATARI_SAP_FILE;
	    }
	}

	// PRG header present?
	if ((fileContent.getLength() > 2 && fileContent.getWord(0) + fileContent.getLength() - 2 < 0x10000)) {
	    possibleFileContentModes.add(HexEditorFileContentMode.C64_PRG_FILE);
	    int loadAddress = fileContent.getWord(0);
	    if (result.equals(HexEditorFileContentMode.BINARY) && loadAddress >= 0x800 && loadAddress < 0x2000) {
		result = HexEditorFileContentMode.C64_PRG_FILE;
	    }
	}

	// IFF files always have an even number of bytes
	if (fileContent.getLength() > 8 && (fileContent.getLength() & 0x1) == 0) {
	    possibleFileContentModes.add(HexEditorFileContentMode.IFF_FILE);
	    char[] id = new char[4];
	    id[0] = (char) fileContent.getByte(0);
	    id[1] = (char) fileContent.getByte(1);
	    id[2] = (char) fileContent.getByte(2);
	    id[3] = (char) fileContent.getByte(3);
	    String chunk = String.copyValueOf(id);
	    boolean iff = chunk.equals("FORM") || chunk.equals("LIST") || chunk.equals("CAT ");
	    if (result.equals(HexEditorFileContentMode.BINARY) && iff) {
		result = HexEditorFileContentMode.IFF_FILE;
	    }
	}
	return result;
    }

    /**
     * Sets the file content for {@link #parseFileContent()}.
     * 
     * @param fileContentMode
     *            The file content mode, not <code>null</code>.
     */
    public void setFileContentMode(HexEditorFileContentMode fileContentMode) {
	if (fileContentMode == null) {
	    throw new IllegalArgumentException("Parameter 'fileContentMode' must not be null.");
	}
	this.fileContentMode = fileContentMode;
    }

    /**
     * Gets the file content for {@link #parseFileContent()}.
     * 
     * @return fileContentMode The file content mode, not <code>null</code>.
     */
    public HexEditorFileContentMode getFileContentMode() {
	return fileContentMode;
    }

    /**
     * Sets the character set type.
     * 
     * @param characterSet
     *            The character set type, not <code>null</code>.
     */
    public void setCharacterSet(HardwareCharacterSet characterSet) {
	if (characterSet == null) {
	    throw new IllegalArgumentException("Parameter 'characterSet' must not be null.");
	}

	this.characterSet = characterSet;
    }

    /**
     * Gets the character set type.
     * 
     * @return characterSet The character set type, not <code>null</code>.
     */
    public HardwareCharacterSet getCharacterSet() {
	return characterSet;
    }

    /**
     * Sets the number of bytes per row for {@link #parseFileContent()}.
     * 
     * @param bytesPerRow
     *            The number of bytes per row, a positive integer.
     */
    public void setBytesPerRow(int bytesPerRow) {
	if (bytesPerRow < 1) {
	    throw new IllegalArgumentException(
		    "Parameter 'bytesPerRow' must not be positive. Specified valie was " + bytesPerRow + ".");
	}
	this.bytesPerRow = bytesPerRow;
    }

    /**
     * Gets the number of bytes per row for {@link #parseFileContent()}.
     * 
     * @return The number of bytes per row, a positive integer.
     */
    public int getBytesPerRow() {
	return bytesPerRow;
    }

    /**
     * Determines if parsing is required.
     * 
     * @return <code>true</code> if parsing is required, <code>false</code>
     *         otherwise.
     */
    public boolean isParsingFileContentRequired() {
	return !fileContentParsed || !Arrays.equals(fileContent, oldFileContent)
		|| !fileContentMode.equals(oldFileContentMode) || !characterSet.equals(oldCharacterSet)
		|| bytesPerRow != oldBytesPerRow;
    }

    /**
     * Parse the file content set with {@link #setFileContent(byte[])} according
     * to the parameters set with
     * {@link #setFileContentMode(HexEditorFileContentMode)},
     * {@link #setBytesPerRow(int)} and
     * {@link #setCharacterSet(HardwareCharacterSet)}.
     * 
     * @return The styles string representing the content.
     */
    public StyledString parseFileContent() {

	Profiler profiler = new Profiler(this);
	profiler.begin("parseFileContent", fileContent.length + " bytes");

	outlineBlocks.clear();
	initByteTextOffsets();

	StyledString contentBuilder = new StyledString();
	HexEditorContentOutlineTreeObject treeObject;
	String text = TextUtility.format(Texts.HEX_EDITOR_FILE_SIZE,
		HexUtility.getLongValueHexString(fileContent.length),
		NumberUtility.getLongValueDecimalString(fileContent.length));
	contentBuilder.append(text);
	treeObject = new HexEditorContentOutlineTreeObject(contentBuilder);
	treeObject.setFileStartOffset(0);
	treeObject.setTextStartOffset(contentBuilder.length());
	outlineBlocks.add(treeObject);

	contentBuilder = new StyledString();
	if (!possibleFileContentModes.contains(fileContentMode)) {
	    messageManager.sendMessage(MessageIds.FILE_CONTENT_MODE, IStatus.ERROR, Texts.MESSAGE_E300,
		    EnumUtility.getText(fileContentMode));
	    return contentBuilder;
	}

	if (fileContent.length > 0) {
	    boolean error;
	    HexEditorParser parser = fileContentMode.createParser();

	    // Initialize the buffers for the hex and char conversion.
	    hexBuffer = new char[3 + bytesPerRow * 3 + 2];
	    for (int i = 0; i < hexBuffer.length; i++) {
		hexBuffer[i] = ' ';
	    }
	    hexBuffer[1] = ':';
	    hexBuffer[hexBuffer.length - 2] = '|';
	    charBuffer = new char[bytesPerRow + 1];
	    charBuffer[charBuffer.length - 1] = '\n';

	    parser.init(this, offsetStyler, addressStyler);
	    error = parser.parse(contentBuilder);
	    if (error) {
		messageManager.sendMessage(MessageIds.FILE_CONTENT_MODE, IStatus.ERROR, Texts.MESSAGE_E301,
			EnumUtility.getText(fileContentMode));
	    }
	}

	profiler.end("parseFileContent");

	// Copy current state to state backup for change detection in {@link
	// #isParsingFileContentRequired},
	fileContentParsed = true;
	oldFileContentMode = fileContentMode;
	oldFileContent = fileContent;
	oldCharacterSet = characterSet;
	oldBytesPerRow = bytesPerRow;

	return contentBuilder;
    }

    /**
     * Gets the file content.
     * 
     * @return The file content, not <code>null</code>.
     */
    final FileContent getFileContent() {
	return new FileContentImpl(fileContent); // TODO Do not create newly
    }

    /**
     * Prints a block header in the context area and adds a block to the
     * outline.
     * 
     * @param contentBuilder
     *            The content builder, not <code>null</code>.
     * @param headerStyledString
     *            The style string for the block header in the outline, not
     *            <code>null</code>.
     * @param offset
     *            The start offset, a non-negative integer.
     * 
     * @return The tree object representing the block.
     */
    final HexEditorContentOutlineTreeObject printBlockHeader(StyledString contentBuilder,
	    StyledString headerStyledString, long offset) {

	if (contentBuilder == null) {
	    throw new IllegalArgumentException("Parameter 'contentBuilder' must not be null.");
	}
	if (headerStyledString == null) {
	    throw new IllegalArgumentException("Parameter 'styledString' must not be null.");
	}
	HexEditorContentOutlineTreeObject treeObject;

	treeObject = new HexEditorContentOutlineTreeObject(headerStyledString);
	treeObject.setFileStartOffset(offset);
	treeObject.setTextStartOffset(contentBuilder.length());
	outlineBlocks.add(treeObject);
	return treeObject;
    }

    /**
     * Prints the last block in case if contains an error like the wrong number
     * of bytes.
     * 
     * @param contentBuilder
     *            The content builder, not <code>null</code>.
     * @param errorText
     *            The error text, not empty and not <code>null</code>.
     * @param length
     *            The length of the last block, a non-negative integer.
     * @param offset
     *            The offset of the last block, a non-negative integer.
     */
    final void printBlockWithError(StyledString contentBuilder, String errorText, long length, long offset) {
	if (contentBuilder == null) {
	    throw new IllegalArgumentException("Parameter 'contentBuilder' must not be null.");
	}

	if (errorText == null) {
	    throw new IllegalArgumentException("Parameter 'errorText' must not be null.");
	}
	HexEditorContentOutlineTreeObject treeObject;
	StyledString styledString = new StyledString(errorText, errorStyler);
	treeObject = new HexEditorContentOutlineTreeObject(styledString);
	treeObject.setFileStartOffset(UNDEFINED_OFFSET);
	treeObject.setFileEndOffset(UNDEFINED_OFFSET);
	treeObject.setTextStartOffset(contentBuilder.length());
	treeObject.setTextEndOffset(contentBuilder.length());

	outlineBlocks.add(treeObject);
	contentBuilder.append(styledString);
	contentBuilder.append("\n");
	offset = printBytes(treeObject, contentBuilder, offset, length - 1, true, 0);
    }

    final void skipByteTextIndex(long offset) {
	byteTextIndex += offset;
    }

    final long printBytes(HexEditorContentOutlineTreeObject treeObject, StyledString contentBuilder, long offset,
	    long maxOffset, boolean withStartAddress, int startAddress) {

	if (offset < 0) {
	    throw new IllegalArgumentException(
		    "Parameter 'offset' must not be negative, specified value is " + offset + ".");
	}
	if (maxOffset < 0) {
	    throw new IllegalArgumentException(
		    "Parameter 'offset' must not be negative, specified value is " + maxOffset + ".");
	}
	int length = Math.max(4, HexUtility.getLongValueHexLength(fileContent.length));
	char[] characterMapping = characterSet.getCharacterMapping();
	while (offset <= maxOffset) {
	    int contentBuilderLineStartOffset = contentBuilder.length();

	    contentBuilder.append(HexUtility.getLongValueHexString(offset, length), offsetStyler);

	    if (withStartAddress) {
		contentBuilder.append(" : ");
		contentBuilder.append(HexUtility.getLongValueHexString(startAddress, length), addressStyler);

	    }

	    // Remember byte offset where the new line starts.
	    int contentBuilderStartOffset = contentBuilder.length();
	    int h = 3;
	    for (int b = 0; b < bytesPerRow; b++) {
		char highChar;
		char lowChar;
		char charValue;
		if (offset > maxOffset) {
		    highChar = ' ';
		    lowChar = ' ';
		    charValue = ' ';
		} else {
		    int byteValue = getFileContent().getByte(offset);
		    highChar = hexChars[byteValue >> 4];
		    lowChar = hexChars[byteValue & 0xf];
		    charValue = characterMapping[byteValue];
		    byteTextOffsets[byteTextIndex++] = (b == 0 ? contentBuilderLineStartOffset
			    : contentBuilderStartOffset + h);
		    offset++;
		    startAddress++;
		}
		hexBuffer[h++] = highChar;
		hexBuffer[h++] = lowChar;
		h++;
		charBuffer[b] = charValue;
	    }
	    contentBuilder.append(hexBuffer);
	    contentBuilder.append(charBuffer, charStyler);
	}
	treeObject.setFileEndOffset(offset);
	treeObject.setTextEndOffset(contentBuilder.length());
	return offset;
    }

    /**
     * Gets the list of outline blocks determined by {@link #parseFileContent()}
     * .
     * 
     * @return The list of outline blocks, may be empty, not <code>null</code>.
     */
    public List<HexEditorContentOutlineTreeObject> getOutlineBlocks() {
	return outlineBlocks;
    }

    /**
     * Gets the selection represented by the start and end offset in the text
     * field.
     * 
     * @param x
     *            is the offset of the first selected character
     * @param y
     *            is the offset after the last selected character.
     * @return The selection or <code>null</code>.
     */
    public HexEditorSelection getSelection(int x, int y) {

	if (x > y) {
	    throw new IllegalArgumentException("x is greater than y");
	}
	long startOffset = UNDEFINED_OFFSET;
	for (long i = 0; i < byteTextIndex; i++) {
	    // BasePlugin.getInstance().log(
	    // "HexEditor.getSelection(): i={0} textOffset={1}
	    // nextTextOffset={2} startOffset={3} endOffset={4}",
	    // new Object[] { String.valueOf(i), String.valueOf(textOffset),
	    // String.valueOf(nextTextOffset),
	    // String.valueOf(startOffset), String.valueOf(endOffset) });
	    if (getByteTextOffset(i) >= x) {
		startOffset = i;
		break;
	    }
	}

	if (startOffset == UNDEFINED_OFFSET) {
	    return null;
	}

	long endOffset = UNDEFINED_OFFSET;
	for (long i = startOffset; i < byteTextIndex; i++) {
	    // BasePlugin.getInstance().log(
	    // "HexEditor.getSelection(): i={0} textOffset={1}
	    // nextTextOffset={2} startOffset={3} endOffset={4}",
	    // new Object[] { String.valueOf(i), String.valueOf(textOffset),
	    // String.valueOf(nextTextOffset),
	    // String.valueOf(startOffset), String.valueOf(endOffset) });

	    if (getByteTextOffset(i) >= y ) {
		endOffset = i;
		break;
	    }
	}

	if (endOffset == UNDEFINED_OFFSET) {
	    return null;
	}

	long length;
	byte[] bytes;

	length = endOffset - startOffset + 1;
	BasePlugin.getInstance().log("HexEditor.getSelection(): startOffset={2} endoffset={3} length={4}",
		new Object[] { String.valueOf(x), String.valueOf(y), String.valueOf(startOffset),
			String.valueOf(endOffset), String.valueOf(length) });

	// Length not empty or negative?
	if (length > 0 && length < fileContent.length) {
	    // Reposition into first occurrence of in the file.
	    // This is relevant for the format that display the content more
	    // than once.
	    startOffset = startOffset % fileContent.length;
	    endOffset = endOffset % fileContent.length;
	    // Selection does not cross file end boundary?
	    if (startOffset <= endOffset) {
		bytes = new byte[(int) length];
		System.arraycopy(fileContent, (int) startOffset, bytes, 0, bytes.length);

	    } else {

		endOffset = startOffset;
		bytes = new byte[0];

	    }
	} else {
	    endOffset = startOffset;
	    bytes = new byte[0];
	}
	HexEditorSelection hexEditorSelection = new HexEditorSelection(startOffset, endOffset, bytes);
	return hexEditorSelection;
    }

    /**
     * Gets the text offset for a byte offset.
     * 
     * @param byteOffset
     *            The byte offset in the original byte array.
     * @return The text offset where the byte is represented or
     *         <code>UNDEFINED_OFFSET</code> if there is no such text offset.
     */
    public long getByteTextOffset(long byteOffset) {
	if (byteOffset < byteTextOffsets.length) {
	    return byteTextOffsets[(int) byteOffset];
	}
	return UNDEFINED_OFFSET;
    }

}