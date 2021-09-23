package com.wudsn.ide.lng.asm.compiler.test;

import com.wudsn.ide.lng.editor.AssemblerEditor;

public final class TestEditor extends AssemblerEditor {

	/**
	 * Creation is public. Called by the extension "org.eclipse.ui.editors".
	 */
	public TestEditor() {

	}

	@Override
	public String getCompilerId() {
		return "test";
	}
}
