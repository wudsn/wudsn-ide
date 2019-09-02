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
package com.wudsn.ide.pas.editor;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.widgets.Display;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.text.presentation.PresentationReconciler;
import org.eclipse.jface.text.rules.DefaultDamagerRepairer;
import org.eclipse.jface.text.rules.IRule;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.NumberRule;
import org.eclipse.jface.text.rules.PatternRule;
import org.eclipse.jface.text.rules.RuleBasedScanner;
import org.eclipse.jface.text.rules.SingleLineRule;
import org.eclipse.jface.text.rules.Token;

/**
 * 
 * @author Peter Dell
 * @since 1.7.1
 */
public class PascalReconciler extends PresentationReconciler {

	private IToken quoteToken = new Token(new TextAttribute(new Color(Display.getCurrent(), new RGB(139, 69, 19))));
	private IToken numberToken = new Token(new TextAttribute(new Color(Display.getCurrent(), new RGB(0, 0, 255))));
	private IToken commentToken = new Token(new TextAttribute(new Color(Display.getCurrent(), new RGB(0, 100, 0))));
	private IToken keywordToken = new Token(
			new TextAttribute(new Color(Display.getCurrent(), new RGB(150, 0, 85)), null, SWT.BOLD));

	public PascalReconciler() {

		RuleBasedScanner scanner = new RuleBasedScanner();

		List<IRule> rules = new ArrayList<IRule>();
		rules.add(new SingleLineRule("'", "'", quoteToken));
		rules.add(new PatternRule("//", null, commentToken, (char) 0, true));
		rules.add(new NumberRule(numberToken));
		rules.add(new PascalWordRule(keywordToken));
		scanner.setRules(rules.toArray(new IRule[rules.size()]));

		DefaultDamagerRepairer dr = new DefaultDamagerRepairer(scanner);
		this.setDamager(dr, IDocument.DEFAULT_CONTENT_TYPE);
		this.setRepairer(dr, IDocument.DEFAULT_CONTENT_TYPE);
	}
}
