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

package com.wudsn.ide.asm.editor;

import java.util.Set;

import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.text.rules.RuleBasedScanner;
import org.eclipse.jface.text.rules.Token;

import com.wudsn.ide.asm.AssemblerPlugin;
import com.wudsn.ide.asm.preferences.AssemblerPreferences;
import com.wudsn.ide.asm.preferences.TextAttributeConverter;

/**
 * Rule based scanner for comments and strings.
 * 
 * @author Peter Dell
 * @author Daniel Mitte
 */
final class AssemblerRuleBasedScanner extends RuleBasedScanner {

    /** Default Token for the text attributes * */
    private Token defaultToken;

    /** Key for preference store * */
    private String preferencesKey;

    /**
     * Creates a new instance. Called by
     * {@link AssemblerSourceViewerConfiguration}.
     * 
     * @param preferencesKey
     *            The preference key to listen to for text attribute changes,
     *            not <code>null</code>..
     */
    AssemblerRuleBasedScanner(String preferencesKey) {

	if (preferencesKey == null) {
	    throw new IllegalArgumentException("Parameter 'preferencesKey' must not be null.");
	}

	this.preferencesKey = preferencesKey;

	AssemblerPreferences preferences = AssemblerPlugin.getInstance().getPreferences();
	defaultToken = new Token(preferences.getEditorTextAttribute(preferencesKey));

	super.setDefaultReturnToken(defaultToken);
    }

    /**
     * Dispose UI resources.
     */
    final void dispose() {
	TextAttributeConverter.dispose((TextAttribute) defaultToken.getData());
    }

    /**
     * Update the token based on the preferences. Called by
     * {@link AssemblerSourceViewerConfiguration}.
     * 
     * @param preferences
     *            The preferences, not <code>null</code>.
     * @param changedPropertyNames
     *            The set of changed property names, not <code>null</code>.
     * 
     * @return <code>true</code> If the editor has to be refreshed.
     */
    final boolean preferencesChanged(AssemblerPreferences preferences, Set<String> changedPropertyNames) {
	if (preferences == null) {
	    throw new IllegalArgumentException("Parameter 'preferences' must not be null.");
	}
	if (changedPropertyNames == null) {
	    throw new IllegalArgumentException("Parameter 'changedPropertyNames' must not be null.");
	}
	boolean refresh = false;
	if (changedPropertyNames.contains(preferencesKey)) {
	    TextAttributeConverter.dispose((TextAttribute) defaultToken.getData());
	    defaultToken.setData(preferences.getEditorTextAttribute(preferencesKey));
	    refresh = true;
	}
	return refresh;

    }
}
