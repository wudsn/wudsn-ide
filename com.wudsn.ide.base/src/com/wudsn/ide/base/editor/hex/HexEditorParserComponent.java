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
package com.wudsn.ide.base.editor.hex;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.jface.preference.JFacePreferences;
import org.eclipse.jface.viewers.StyledString;
import org.eclipse.jface.viewers.StyledString.Styler;
import org.eclipse.swt.graphics.TextStyle;

import com.wudsn.ide.base.Texts;
import com.wudsn.ide.base.common.EnumUtility;
import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.Profiler;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.base.editor.hex.HexEditor.MessageIds;
import com.wudsn.ide.base.editor.hex.parser.AtariCOMParser;
import com.wudsn.ide.base.editor.hex.parser.AtariDiskImageKFileParser;
import com.wudsn.ide.base.editor.hex.parser.AtariDiskImageParser;
import com.wudsn.ide.base.editor.hex.parser.AtariMADSParser;
import com.wudsn.ide.base.editor.hex.parser.AtariParser;
import com.wudsn.ide.base.editor.hex.parser.AtariSAPParser;
import com.wudsn.ide.base.editor.hex.parser.AtariSDXParser;
import com.wudsn.ide.base.editor.hex.parser.BinaryParser;
import com.wudsn.ide.base.editor.hex.parser.C64PRGParser;
import com.wudsn.ide.base.gui.MessageManager;

final class HexEditorParserComponent {

	public static final int UNDEFINED_OFFSET = -1;
	private final static int BYTES_PER_ROW = 16;
	private static final int INT_FF = 0xff;

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
	private HexEditorCharacterSet characterSet;

	// Previous state with regards to parsing.
	private HexEditorFileContentMode oldFileContentMode;
	private byte[] oldFileContent;
	private int oldBytesPerRow;
	private HexEditorCharacterSet oldCharacterSet;

	// Parsing state.
	private List<HexEditorFileContentMode> possibleFileContentModes;
	private List<HexEditorContentOutlineTreeObject> outlineBlocks;
	private int[] byteTextOffsets;
	private int byteTextIndex;

	// Line buffers for binary to hex and char conversion.
	private char[] hexChars;
	private char[] hexBuffer;
	private char[] charBuffer;

	public HexEditorParserComponent(MessageManager messageManager) {
		if (messageManager == null) {
			throw new IllegalArgumentException(
					"Parameter 'messageManager' must not be null.");
		}
		this.messageManager = messageManager;

		// Get static stylers for the styled string.
		offsetStyler = StyledString.createColorRegistryStyler(
				JFacePreferences.COUNTER_COLOR, null);
		addressStyler = StyledString.createColorRegistryStyler(
				JFacePreferences.QUALIFIER_COLOR, null);
		charStyler = StyledString.createColorRegistryStyler(
				JFacePreferences.HYPERLINK_COLOR, null);

		charStyler = new Styler() {

			@Override
			public void applyStyles(TextStyle textStyle) {
				textStyle.font = null;

			}

		};

		errorStyler = StyledString.createColorRegistryStyler(
				JFacePreferences.ERROR_COLOR, null);

		// Initialize hex chars and normal character set type.
		hexChars = new char[] { '0', '1', '2', '3', '4', '5', '6', '7', '8',
				'9', 'A', 'B', 'C', 'D', 'E', 'F' };
		characterSet = HexEditorCharacterSet.ASCII;

		clear();

	}

	private void clear() {
		// Initialize with empty file.
		fileContentParsed = false;
		fileContentMode = HexEditorFileContentMode.BINARY;
		setFileContent(new byte[0]);
		characterSet = HexEditorCharacterSet.ASCII;
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
			throw new IllegalArgumentException(
					"Parameter 'fileContent' must not be null.");
		}
		this.fileContent = fileContent;
		initByteTextOffsets();
	}

	/**
	 * Reserve enough space for the lookup table that maps text offsets to file
	 * offsets.
	 */
	private void initByteTextOffsets() {
		// Twice the space, because some format display the content twice, for
		// example ATARI_DISK_IMAGE_K_FILE.
		byteTextOffsets = new int[fileContent.length * 2];
		byteTextIndex = 0;
	}

	/**
	 * Gets the current file content.
	 * 
	 * @return The file content, may be empty or <code>null</code>.
	 */
	public byte[] getFileContent() {
		return fileContent;
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

		// COM header present?
		if (fileContent.length > 6) {
			// AtariDOS COM file?
			if (getFileContentWord(0) == AtariParser.COM_HEADER) {
				int startAddress = getFileContentWord(2);
				int endAddress = getFileContentWord(4);
				if (startAddress >= 0 && endAddress >= startAddress) {
					defaultMode = HexEditorFileContentMode.ATARI_COM_FILE;
					possibleFileContentModes.add(defaultMode);

					if (fileContent.length > 16) {
						if (getFileContentWord(6) == AtariMADSParser.RELOC_HEADER) {
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
			else if (getFileContentWord(0) == AtariSDXParser.NON_RELOC_HEADER) {
				int startAddress = getFileContentWord(2);
				int endAddress = getFileContentWord(4);
				if (startAddress > 0 && endAddress >= startAddress) {
					defaultMode = HexEditorFileContentMode.ATARI_SDX_FILE;
					possibleFileContentModes.add(defaultMode);
					// New default?
					if (result.equals(HexEditorFileContentMode.BINARY)) {
						result = defaultMode;
					}
				}
			} // SpartaDOS X relocatable file?
			else if (getFileContentWord(0) == AtariSDXParser.RELOC_HEADER
					&& fileContent.length > 8) {
				int blockNumber = getFileContentByte(2);
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
		if ((fileContent.length > 16 && getFileContentByte(0) == 0x96 && getFileContentByte(1) == 0x02)) {
			defaultMode = HexEditorFileContentMode.ATARI_DISK_IMAGE;
			possibleFileContentModes.add(defaultMode);

			// Special case of k-file (converted COM file)
			int offset = AtariDiskImageKFileParser.ATARI_DISK_IMAGE_K_FILE_COM_FILE_OFFSET;
			if (fileContent.length > offset + 2
					&& getFileContentWord(offset) == 0xffff) {
				final int[] kFileBootHeader = new int[] { 0x00, 0x03, 0x00,
						0x07, 0x14, 0x07, 0x4C, 0x14, 0x07 };
				boolean kFileBootHeaderFound = true;
				for (int i = 0; i < kFileBootHeader.length; i++) {
					if (getFileContentByte(16 + i) != kFileBootHeader[i]) {
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
		if ((fileContent.length > 11 && getFileContentByte(0) == 0x53 && getFileContentByte(1) == 0x41)
				&& getFileContentByte(2) == 0x50) {
			possibleFileContentModes
					.add(HexEditorFileContentMode.ATARI_SAP_FILE);
			// New default?
			if (result.equals(HexEditorFileContentMode.BINARY)) {
				result = HexEditorFileContentMode.ATARI_SAP_FILE;
			}
		}

		// PRG header present?
		if ((fileContent.length > 2 && getFileContentWord(0)
				+ getFileContent().length - 2 < 0x10000)) {
			possibleFileContentModes.add(HexEditorFileContentMode.C64_PRG_FILE);
			int loadAddress = getFileContentWord(0);
			if (result.equals(HexEditorFileContentMode.BINARY)
					&& loadAddress >= 0x800 && loadAddress < 0x2000) {
				result = HexEditorFileContentMode.C64_PRG_FILE;
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
			throw new IllegalArgumentException(
					"Parameter 'fileContentMode' must not be null.");
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
	public void setCharacterSet(HexEditorCharacterSet characterSet) {
		if (characterSet == null) {
			throw new IllegalArgumentException(
					"Parameter 'characterSet' must not be null.");
		}

		this.characterSet = characterSet;
	}

	/**
	 * Gets the character set type.
	 * 
	 * @return characterSet The character set type, not <code>null</code>.
	 */
	public HexEditorCharacterSet getCharacterSet() {
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
					"Parameter 'bytesPerRow' must not be positive. Specified valie was "
							+ bytesPerRow + ".");
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
		return !fileContentParsed
				|| !Arrays.equals(fileContent, oldFileContent)
				|| !fileContentMode.equals(oldFileContentMode)
				|| !characterSet.equals(oldCharacterSet)
				|| bytesPerRow != oldBytesPerRow;
	}

	/**
	 * Parse the file content set with {@link #setFileContent(byte[])} according
	 * to the parameters set with
	 * {@link #setFileContentMode(HexEditorFileContentMode)},
	 * {@link #setBytesPerRow(int)} and
	 * {@link #setCharacterSet(HexEditorCharacterSet)}.
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
			messageManager.sendMessage(MessageIds.FILE_CONTENT_MODE,
					IStatus.ERROR, Texts.MESSAGE_E300,
					EnumUtility.getText(fileContentMode));
			return contentBuilder;
		}

		if (fileContent.length > 0) {
			boolean error;
			HexEditorParser parser;
			if (fileContentMode.equals(HexEditorFileContentMode.ATARI_COM_FILE)) {
				parser = new AtariCOMParser();
			} else if (fileContentMode
					.equals(HexEditorFileContentMode.ATARI_DISK_IMAGE)) {
				parser = new AtariDiskImageParser();
			} else if (fileContentMode
					.equals(HexEditorFileContentMode.ATARI_DISK_IMAGE_K_FILE)) {
				parser = new AtariDiskImageKFileParser();
			} else if (fileContentMode
					.equals(HexEditorFileContentMode.ATARI_MADS_FILE)) {
				parser = new AtariMADSParser();
			} else if (fileContentMode
					.equals(HexEditorFileContentMode.ATARI_SDX_FILE)) {
				parser = new AtariSDXParser();
			} else if (fileContentMode
					.equals(HexEditorFileContentMode.ATARI_SAP_FILE)) {
				parser = new AtariSAPParser();
			} else if (fileContentMode
					.equals(HexEditorFileContentMode.C64_PRG_FILE)) {
				parser = new C64PRGParser();
			} else {
				parser = new BinaryParser();
			}

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
				messageManager.sendMessage(MessageIds.FILE_CONTENT_MODE,
						IStatus.ERROR, Texts.MESSAGE_E301,
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
	 * Gets a byte from the file content.
	 * 
	 * @param offset
	 *            The offset, a non-negative integer.
	 * @return The byte from the file content.
	 */
	final int getFileContentByte(int offset) {
		return fileContent[offset] & INT_FF;
	}

	/**
	 * Gets a word from the file content.
	 * 
	 * @param offset
	 *            The offset, a non-negative integer.
	 * @return The word from the file content.
	 */
	final int getFileContentWord(int offset) {
		return getFileContentByte(offset) + 256
				* getFileContentByte(offset + 1);
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
	final HexEditorContentOutlineTreeObject printBlockHeader(
			StyledString contentBuilder, StyledString headerStyledString,
			int offset) {

		if (contentBuilder == null) {
			throw new IllegalArgumentException(
					"Parameter 'contentBuilder' must not be null.");
		}
		if (headerStyledString == null) {
			throw new IllegalArgumentException(
					"Parameter 'styledString' must not be null.");
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
	final void printBlockWithError(StyledString contentBuilder,
			String errorText, int length, int offset) {
		if (contentBuilder == null) {
			throw new IllegalArgumentException(
					"Parameter 'contentBuilder' must not be null.");
		}

		if (errorText == null) {
			throw new IllegalArgumentException(
					"Parameter 'errorText' must not be null.");
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
		offset = printBytes(treeObject, contentBuilder, offset, length - 1,
				true, 0);
	}

	final void skipByteTextIndex(int offset) {
		byteTextIndex += offset;
	}

	final int printBytes(HexEditorContentOutlineTreeObject treeObject,
			StyledString contentBuilder, int offset, int maxOffset,
			boolean withStartAddress, int startAddress) {

		if (offset < 0) {
			throw new IllegalArgumentException(
					"Parameter 'offset' must not be negative, specified value is "
							+ offset + ".");
		}
		if (maxOffset < 0) {
			throw new IllegalArgumentException(
					"Parameter 'offset' must not be negative, specified value is "
							+ maxOffset + ".");
		}
		int length = Math.max(4, HexUtility.getLongValueHexLength(maxOffset));
		char[] characterMapping = characterSet.getCharacterMapping();
		while (offset <= maxOffset) {
			int contentBuilderLineStartOffset = contentBuilder.length();

			contentBuilder.append(
					HexUtility.getLongValueHexString(offset, length),
					offsetStyler);

			if (withStartAddress) {
				contentBuilder.append(" : ");
				contentBuilder.append(
						HexUtility.getLongValueHexString(startAddress, length),
						addressStyler);

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
					int byteValue = getFileContentByte(offset);
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

		int startOffset = UNDEFINED_OFFSET;
		int endOffset = UNDEFINED_OFFSET;
		int textOffset = 0;
		for (int i = 0; i < byteTextIndex
				&& (startOffset == UNDEFINED_OFFSET || endOffset == UNDEFINED_OFFSET); i++) {
			int nextTextOffset;
			if (i < byteTextIndex - 1) {
				nextTextOffset = byteTextOffsets[i + 1];
			} else {
				nextTextOffset = Integer.MAX_VALUE;
			}
			if (startOffset == UNDEFINED_OFFSET && textOffset - 1 <= x
					&& x < nextTextOffset - 1) {
				startOffset = i;
			}
			if (startOffset != UNDEFINED_OFFSET
					&& endOffset == UNDEFINED_OFFSET && textOffset < y
					&& y <= nextTextOffset) {
				endOffset = i;
			}
			textOffset = nextTextOffset;

		}

		if (startOffset == UNDEFINED_OFFSET) {
			return null;
		}
		int length;
		byte[] bytes;

		length = endOffset - startOffset + 1;
		// BasePlugin.getInstance().log("HexEditor.getSelection(): startOffset={0} endoffset={1} length={2}",
		// new Object[] { String.valueOf(startOffset),
		// String.valueOf(endOffset), String.valueOf(length) });
		// Length not empty and selection does not cross file end boundary.
		if (length > 0 && endOffset < fileContent.length) {
			// Reposition into first occurrence of in the file.
			// This is relevant for the format that display the content more
			// than once.
			bytes = new byte[length];
			// startOffset = startOffset % fileContent.length;
			// endOffset = endOffset % fileContent.length;
			// length = endOffset - startOffset + 1;
			System.arraycopy(fileContent, startOffset, bytes, 0, length);

			// BasePlugin.getInstance().log(
			// "HexEditor startOffset={0} endoffset={1} length={2}",
			// new Object[] { String.valueOf(startOffset),
			// String.valueOf(endOffset), String.valueOf(length) });

		} else {
			endOffset = startOffset;
			bytes = new byte[0];
		}
		HexEditorSelection hexEditorSelection = new HexEditorSelection(
				startOffset, endOffset, bytes);
		return hexEditorSelection;
	}

	/**
	 * Gets the text offset for a byte offset.
	 * 
	 * @param byteOffset
	 *            The byte offset in the original byte array.
	 * @return The text offset where the byte is represented or <code>-1</code>
	 *         if there is no such text offset.
	 */
	public int getByteTextOffset(int byteOffset) {
		if (byteOffset < byteTextOffsets.length) {
			return byteTextOffsets[byteOffset];
		}
		return -1;
	}

}