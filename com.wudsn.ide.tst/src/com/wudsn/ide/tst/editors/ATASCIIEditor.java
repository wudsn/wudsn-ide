package com.wudsn.ide.tst.editors;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.editors.text.TextEditor;
import org.eclipse.ui.texteditor.AbstractDecoratedTextEditor;
import org.eclipse.swt.graphics.Font;
import com.wudsn.ide.base.hardware.HardwareCharacterSet;

public class ATASCIIEditor extends AbstractDecoratedTextEditor {

	public ATASCIIEditor() {
		super();

		setDocumentProvider(new ATASCIDocumentProvider());

	}
	/*
	 * @see
	 * org.eclipse.ui.texteditor.AbstractTextEditor.createPartControl(Composite)
	 */

	@Override
	public void createPartControl(Composite parent) {

		super.createPartControl(parent);
//		Font font = HardwareCharacterSet.ATARI_ATASCII.getFont();
//		get
//		PlatformUI.getWorkbench().getHelpSystem().setHelp(parent, "message");
	}

}
