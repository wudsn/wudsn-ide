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

package com.wudsn.ide.asm.compiler.writer;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.runtime.CoreException;

import com.webcodepro.applecommander.storage.Disk;
import com.webcodepro.applecommander.storage.DiskFullException;
import com.webcodepro.applecommander.storage.FileEntry;
import com.webcodepro.applecommander.storage.FormattedDisk;
import com.wudsn.ide.asm.Texts;
import com.wudsn.ide.asm.compiler.CompilerFileWriter;
import com.wudsn.ide.asm.compiler.CompilerFiles;
import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.MarkerUtility;
import com.wudsn.ide.base.common.StringUtility;

/**
 * Compiler file writer for Apple II
 * 
 * @author Peter Dell
 * @since 1.6.3
 */
public final class AppleFileWriter extends CompilerFileWriter {

    private final static String HELLO_ENTRY_NAME = "HELLO";
    private final static String OUTPUT_IMAGE_ENTRY_NAME = "WORLD";

    private final class AppleSoftTokens {
	public final static byte PRINT = (byte) 0xba;
	public final static byte CHRS = (byte) 0xe7;
	public final static byte CALL = (byte) 0x8c;

	// public String[] tokenNames = { "END", "FOR ", "NEXT ", "DATA ",
	// "INPUT ", "DEL", "DIM ", "READ ", "GR", "TEXT", "PR#", "IN#",
	// "CALL ", "PLOT", "HLIN ", "VLIN ", "HGR2", "HGR", "HCOLOR=",
	// "HPLOT ", "DRAW ", "XDRAW ", "HTAB ", "HOME", "ROT=", "SCALE=",
	// "SHLOAD", "TRACE", "NOTRACE", "NORMAL", "INVERSE", "FLASH",
	// "COLOR=", "POP", "VTAB ", "HIMEM:", "LOMEM:", "ONERR ",
	// "RESUME", "RECALL", "STORE", "SPEED=", "LET ", "GOTO ", "RUN",
	// "IF ", "RESTORE", "& ", "GOSUB ", "RETURN", "REM ", "STOP",
	// "ON ", "WAIT", "LOAD", "SAVE", "DEF", "POKE ", "PRINT ",
	// "CONT", "LIST", "CLEAR", "GET ", "NEW", "TAB(", "TO ", "FN",
	// "SPC(", "THEN ", "AT ", "NOT ", "STEP ", "+ ", "- ", "* ",
	// "/ ", "^ ", "AND ", "OR ", "> ", "= ", "< ", "SGN", "INT",
	// "ABS", "USR", "FRE", "SCRN(", "PDL", "POS ", "SQR", "RND",
	// "LOG", "EXP", "COS", "SIN", "TAN", "ATN", "PEEK", "LEN",
	// "STR$", "VAL", "ASC", "CHR$", "LEFT$", "RIGHT$", "MID$" };

	// public int[] tokenAddresses = { 0xD870, 0xD766, 0xDCF9, 0xD995,
	// 0xDBB2,
	// 0xF331, 0xDFD9, 0xDBE2, 0xF390, 0xF399, 0xF1E5, 0xF1DE, 0xF1D5,
	// 0xF225, 0xF232, 0xF241, 0xF3D8, 0xF3E2, 0xF6E9, 0xF6FE, 0xF769,
	// 0xF76F, 0xF7E7, 0xFC58, 0xF721, 0xF727, 0xF775, 0xF26D, 0xF26F,
	// 0xF273, 0xF277, 0xF280, 0xF24F, 0xD96B, 0xF256, 0xF286, 0xF2A6,
	// 0xF2CB, 0xF318, 0xF3BC, 0xF39F, 0xF262, 0xDA46, 0xD93E, 0xD912,
	// 0xD9C9, 0xD849, 0x03F5, 0xD921, 0xD96B, 0xD9DC, 0xD86E, 0xD9EC,
	// 0xE784, 0xD8C9, 0xD8B0, 0xE313, 0xE77B, 0xFDAD5, 0xD896,
	// 0xD6A5, 0xD66A, 0xDBA0, 0xD649, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	// 0, 0, 0, 0, 0, 0, 0, 0, 0xEB90, 0xEC23, 0xEBAF, 0x000A, 0xE2DE,
	// 0xD412, 0xDFCD, 0xE2FF, 0xEE8D, 0xEFAE, 0xE941, 0xEF09, 0xEFEA,
	// 0xEFF1, 0xF03A, 0xF09E, 0xE764, 0xE6D6, 0xE3C5, 0xE707, 0xE6E5,
	// 0xE646, 0xE65A, 0xE686, 0xE691 };
    }

    @Override
    public boolean createOrUpdateDiskImage(CompilerFiles files) {
	String imageFilePath = files.outputFilePathWithoutExtension + ".dsk";
	String outputImageEntryName = OUTPUT_IMAGE_ENTRY_NAME;
	String outputImageEntryTitle = "Loading " + files.outputFileNameWithoutExtension;
	boolean autoCreate = true;

	if (StringUtility.isSpecified(imageFilePath)) {
	    File imageFile = new File(imageFilePath);
	    if (!imageFile.exists()) {

		// When auto creation is active, we copy a template file.
		// This is the only way to get a disk image which is not only
		// formatted but also has a boot loader which runs "HELLO".
		if (autoCreate) {
		    String resource = "/lib/AppleDos.dsk";
		    InputStream inputStream = Disk.class.getClassLoader().getResourceAsStream(resource);
		    if (inputStream == null) {
			throw new RuntimeException("Cannot get input stream for '" + resource + "'");
		    }
		    ByteArrayOutputStream bos = new ByteArrayOutputStream();
		    byte[] buffer = new byte[8192];
		    int count;
		    do {
			try {
			    count = inputStream.read(buffer);
			} catch (IOException ex) {
			    throw new RuntimeException("Cannot read input stream for '" + resource + "'", ex);
			}

			if (count > 0) {
			    bos.write(buffer, 0, count);

			}
		    } while (count > -1);

		    try {
			bos.close();
		    } catch (IOException ex) {
			throw new RuntimeException(ex);
		    }

		    try {
			FileUtility.writeBytes(imageFile, bos.toByteArray());
		    } catch (CoreException ex) {
			MarkerUtility.createMarker(files.mainSourceFile.iFile, 0, ex.getStatus().getSeverity(), "{0}",
				ex.getStatus().getMessage());
			return false;
		    }

		} else { // no auto creation

		    // ERROR: Disk image file '{0}' does not exist. Create a
		    // bootable disk image where the output file '{1}' can be
		    // stored.
		    MarkerUtility.createMarker(files.mainSourceFile.iFile, 0, IMarker.SEVERITY_ERROR,
			    Texts.MESSAGE_E132, imageFilePath, outputImageEntryName);
		    return false;
		}
	    }
	    if (!imageFile.canWrite()) {
		// ERROR: Disk image file '{0}' is not writeable. Make the disk
		// image file writeable, so the output file '{1}' can be stored.
		MarkerUtility.createMarker(files.mainSourceFile.iFile, 0, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E133,
			imageFilePath, outputImageEntryName);
		return false;
	    }
	}
	Disk disk;
	try {
	    disk = new Disk(imageFilePath);
	} catch (IOException ex) {
	    // ERROR: Disk image file '{0}' cannot be opened for reading. System
	    // error: {1}
	    MarkerUtility.createMarker(files.mainSourceFile.iFile, 0, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E134,
		    imageFilePath, ex.getMessage());
	    return false;
	}

	FormattedDisk[] formattedDisks = disk.getFormattedDisks();
	if (formattedDisks == null || formattedDisks.length == 0) {
	    // ERROR: Disk image file '{0}' does not contain a valid file
	    // system. Make sure the disk image is properly formatted, so
	    // the output file '{1}' can be stored.
	    MarkerUtility.createMarker(files.mainSourceFile.iFile, 0, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E135,
		    imageFilePath, outputImageEntryName);
	    return false;
	}

	byte[] outputFileContent;
	try {
	    outputFileContent = FileUtility.readBytes(files.outputFile, 65536, true);
	} catch (CoreException ex) {
	    // ERROR: Cannot read output file.
	    MarkerUtility.createMarker(files.mainSourceFile.iFile, 0, ex.getStatus().getSeverity(), "{0}", ex
		    .getStatus().getMessage());
	    return false;
	}

	FormattedDisk formattedDisk;
	try {
	    formattedDisk = formattedDisks[0];
	    // Create HELLO with dummy address.
	    createHello(formattedDisk, outputImageEntryName, outputImageEntryTitle, 1234);

	    FileEntry entry = formattedDisk.getFile(outputImageEntryName);
	    if (entry == null) {
		entry = formattedDisk.createFile();
		// TODO This is required due to a BUG in AppleCommander
		entry.setFilename(outputImageEntryName);
	    }
	    entry.setFiletype("B");

	    String fileName = files.outputFileName.toLowerCase();
	    int length = outputFileContent.length;
	    byte[] content = outputFileContent;
	    if (entry.needsAddress()) {
		int address;
		if (fileName.endsWith(".b") && length > 4) {
		    // // AppleDos 3.3 binary file:
		    // start-lo,start-hi,length-lo,length-hi,data
		    address = getWord(outputFileContent, 0);
		    length = length - 4;
		    content = getData(outputFileContent, 4);
		} else if (fileName.endsWith(".prg") && length > 2) {
		    // C64 program file
		    // start-lo,start-hi,data
		    address = getWord(outputFileContent, 0);
		    length = length - 2;
		    content = getData(outputFileContent, 2);
		} else if (fileName.endsWith(".xex") && length > 6
			&& ((getWord(outputFileContent, 0) & 0xffff) == 0xffff)) {
		    // AtariDOS 2.5 binary file:
		    // $ff,$ff,start-lo,start-hi,end-lo,end-hi,data
		    address = getWord(outputFileContent, 2);
		    length = length - 6;
		    content = getData(outputFileContent, 6);
		} else {
		    // ERROR: Output file {0} has unknown executable file
		    // extension or content. File extensions ".b", ".prg" and
		    // ".xex" are allowed.
		    MarkerUtility.createMarker(files.mainSourceFile.iFile, 0, IMarker.SEVERITY_ERROR,
			    Texts.MESSAGE_E138, files.outputFilePath);
		    return false;
		}
		// Method setAddress must be called after method setFileData!
		entry.setFileData(content);
		entry.setAddress(address);
		// Update HELLO with acual start address.
		createHello(formattedDisk, outputImageEntryName, outputImageEntryTitle, address);
	    } else {
		entry.setFileData(outputFileContent);

	    }

	} catch (DiskFullException ex) {
	    // ERROR: Disk image file '{0}' is full. System
	    // error: {1}
	    MarkerUtility.createMarker(files.mainSourceFile.iFile, 0, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E136,
		    imageFilePath, ex.getMessage());
	    return false;

	}

	try {
	    formattedDisk.save();

	} catch (IOException ex) {

	    // ERROR: Disk image file '{0}' cannot be opened for writing. System
	    // error: {1}
	    MarkerUtility.createMarker(files.mainSourceFile.iFile, 0, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E137,
		    imageFilePath, ex.getMessage());
	    return false;
	}

	return true;

    }

    private static FileEntry createHello(FormattedDisk formattedDisk, String outputImageEntryName,
	    String outputImageEntryTitle, int runAddress) throws DiskFullException {
	if (formattedDisk == null) {
	    throw new IllegalArgumentException("Parameter 'formattedDisk' must not be null.");
	}
	if (outputImageEntryName == null) {
	    throw new IllegalArgumentException("Parameter 'OUTPUT_IMAGE_ENTRY_NAME' must not be null.");
	}
	if (StringUtility.isEmpty(outputImageEntryName)) {
	    throw new IllegalArgumentException("Parameter 'OUTPUT_IMAGE_ENTRY_NAME' must not be empty.");
	}
	if (outputImageEntryTitle == null) {
	    throw new IllegalArgumentException("Parameter 'outputImageEntryTitle' must not be null.");
	}
	FileEntry entry;

	entry = formattedDisk.getFile(HELLO_ENTRY_NAME);
	if (entry == null) {
	    entry = formattedDisk.createFile();
	    entry.setFilename(HELLO_ENTRY_NAME);
	}
	entry.setFiletype("A");
	byte[] program;
	try {
	    // See "Beneath Apple DOS.pdf", 4-11/12 for the binary and AppleSoft
	    // file format.
	    // See http://www.textfiles.com/apple/ANATOMY/cmd.brun.bload.txt for
	    // the bug in the BRUN routine. Instead of BRUN now BLOAD is sent to
	    // DOS via PRINT CHR$(4) and the program is started via CALL.
	    // 10 PRINT "LOADING <title>" : PRINT CHR$(4);"BRUN WORLD" : CALL
	    // <address>

	    ByteArrayOutputStream bos = new ByteArrayOutputStream();
	    bos.write(new byte[] { 0x00, 0x08, 0x0A, 0x00 });
	    bos.write(new byte[] { AppleSoftTokens.PRINT, '"' });
	    bos.write(outputImageEntryTitle.getBytes("US-ASCII"));
	    bos.write(new byte[] { '"', ':' });
	    bos.write(new byte[] { AppleSoftTokens.PRINT, AppleSoftTokens.CHRS, '(', '4', ')', ';', '"', 'B', 'L', 'O',
		    'A', 'D', ' ' });
	    bos.write(outputImageEntryName.getBytes("US-ASCII"));
	    bos.write(new byte[] { '"', ':', AppleSoftTokens.CALL });
	    bos.write(Integer.toString(runAddress).getBytes("US-ASCII"));
	    bos.write(new byte[] { 0, 0, 0 });
	    program = bos.toByteArray();
	    program[0] = (byte) (program.length);
	} catch (UnsupportedEncodingException ex) {
	    throw new RuntimeException(ex);
	} catch (IOException ex) {
	    throw new RuntimeException(ex);
	}

	// Byte is the line length in bytes
	entry.setFileData(program);
	return entry;
    }

    private static int getWord(byte[] bytes, int index) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}

	return (0xff & bytes[index]) + 256 * (0xff & bytes[index + 1]);
    }

    private static byte[] getData(byte[] bytes, int index) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	int length = bytes.length - index;
	byte[] result = new byte[length];
	System.arraycopy(bytes, index, result, 0, length);
	return result;
    }
}
