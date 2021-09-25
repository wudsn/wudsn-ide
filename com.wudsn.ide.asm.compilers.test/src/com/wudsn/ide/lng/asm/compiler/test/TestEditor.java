package com.wudsn.ide.lng.asm.compiler.test;

import com.wudsn.ide.lng.editor.LanguageEditor;

public final class TestEditor extends LanguageEditor {

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
