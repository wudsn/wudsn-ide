package com.wudsn.ide.tst.editors;

import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.editors.text.TextEditor;

public class ATASCIIEditor extends TextEditor {

    public ATASCIIEditor() {
	super();

	Display display = Display.getDefault();
	Device device = display;
	device.loadFont("C:\\Users\\D025328\\Documents\\Eclipse\\workspace.jac\\com.wudsn.ide.hex\\fonts\\atari8\\ATARCC__.TTF");
	setDocumentProvider(new ATASCIDocumentProvider());

    }
    

}
