package com.wudsn.ide.hex;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;

import org.eclipse.swt.dnd.ByteArrayTransfer;
import org.eclipse.swt.dnd.TransferData;

public final class HexEditorSelectionTransfer extends ByteArrayTransfer {

    private static final String HEX_EDITOR_SELECTION_NAME = "HexEditorSelection";
    private static final int HEX_EDITOR_SELECTION_ID = registerType(HEX_EDITOR_SELECTION_NAME);
    private static HexEditorSelectionTransfer instance = new HexEditorSelectionTransfer();

    private HexEditorSelectionTransfer() {
    }

    public static HexEditorSelectionTransfer getInstance() {
	return instance;
    }

    @Override
    public void javaToNative(Object object, TransferData transferData) {
	if (object == null || !(object instanceof HexEditorSelection))
	    return;

	if (isSupportedType(transferData)) {
	    HexEditorSelection hexEditorSelection = (HexEditorSelection) object;
	    try {
		// write data to a byte array and then ask super to convert to
		// pMedium
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		DataOutputStream writeOut = new DataOutputStream(out);
		byte[] bytes = hexEditorSelection.getBytes();
		writeOut.writeLong(hexEditorSelection.getStartOffset());
		writeOut.writeLong(hexEditorSelection.getEndOffset());
		writeOut.writeInt(bytes.length);
		writeOut.write(bytes);

		byte[] buffer = out.toByteArray();
		writeOut.close();

		super.javaToNative(buffer, transferData);

	    } catch (IOException e) {
	    }
	}
    }

    @Override
    public Object nativeToJava(TransferData transferData) {

	if (isSupportedType(transferData)) {

	    byte[] buffer = (byte[]) super.nativeToJava(transferData);
	    if (buffer == null) {
		return null;
	    }

	    HexEditorSelection hexEditorSelection;
	    hexEditorSelection = null;
	    try {
		ByteArrayInputStream in = new ByteArrayInputStream(buffer);
		DataInputStream readIn = new DataInputStream(in);
		while (readIn.available() > 0) {
		    long startOffset = readIn.readLong();
		    long endOffset = readIn.readLong();
		    int size = readIn.readInt();
		    byte[] bytes = new byte[size];
		    readIn.read(bytes);
		    hexEditorSelection = new HexEditorSelection(startOffset, endOffset, bytes);

		}
		readIn.close();
	    } catch (IOException ex) {
		hexEditorSelection = null;
	    }
	    return hexEditorSelection;
	}

	return null;
    }

    @Override
    protected String[] getTypeNames() {
	return new String[] { HEX_EDITOR_SELECTION_NAME };
    }

    @Override
    protected int[] getTypeIds() {
	return new int[] { HEX_EDITOR_SELECTION_ID };
    }
}
