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

package com.wudsn.ide.asm.compiler.parser;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.rules.EndOfLineRule;
import org.eclipse.jface.text.rules.FastPartitioner;
import org.eclipse.jface.text.rules.IPredicateRule;
import org.eclipse.jface.text.rules.IRule;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.MultiLineRule;
import org.eclipse.jface.text.rules.RuleBasedPartitionScanner;
import org.eclipse.jface.text.rules.SingleLineRule;
import org.eclipse.jface.text.rules.Token;

import com.wudsn.ide.asm.compiler.syntax.CompilerSyntax;
import com.wudsn.ide.asm.editor.AssemblerEditor;

/**
 * A partition scanner for the comments and strings.
 * 
 * @author Peter Dell
 * @author Andy Reek
 */
public final class CompilerSourcePartitionScanner extends RuleBasedPartitionScanner {

    /**
     * Name for the single line comment partition.
     */
    public static final String PARTITION_COMMENT_SINGLE = "partition.comment.single"; //$NON-NLS-1$

    /**
     * Name for the multiple lines comment partition.
     */
    public static final String PARTITION_COMMENT_MULTIPLE = "partition.comment.multiple"; //$NON-NLS-1$

    /**
     * Name for the string partition.
     */
    public static final String PARTITION_STRING = "partition.string"; //$NON-NLS-1$

    /**
     * Creates a new instance.
     * 
     * Called by
     * {@link AssemblerEditor#init(org.eclipse.ui.IEditorSite, org.eclipse.ui.IEditorInput)}
     * .
     * 
     * @param compilerSyntax
     *            The compiler syntax, not <code>null</code>.
     */
    public CompilerSourcePartitionScanner(CompilerSyntax compilerSyntax) {
	if (compilerSyntax == null) {
	    throw new IllegalArgumentException("Parameter 'compilerSyntax' must not be null.");
	}
	IToken commentSingleToken = new Token(PARTITION_COMMENT_SINGLE);
	IToken commentMultipleToken = new Token(PARTITION_COMMENT_MULTIPLE);
	IToken stringToken = new Token(PARTITION_STRING);

	List<IRule> rules = new ArrayList<IRule>();
	for (String singleLineCommentDelimiter : compilerSyntax.getSingleLineCommentDelimiters()) {

	    // A "*" is only a comment start token if it is followed by a space
	    // or a tab.
	    // It is allowed as part of an expression to refer to the program
	    // counter.
	    if (singleLineCommentDelimiter.equals("*")) {
		rules.add(new EndOfLineRule(singleLineCommentDelimiter + " ", commentSingleToken));
		rules.add(new EndOfLineRule(singleLineCommentDelimiter + "\t", commentSingleToken));
	    } else {
		rules.add(new EndOfLineRule(singleLineCommentDelimiter, commentSingleToken));
	    }
	}
	List<String> multipleLinesCommentDelimiters = compilerSyntax.getMultipleLinesCommentDelimiters();
	for (int i = 0; i < multipleLinesCommentDelimiters.size();) {
	    String startSequence = multipleLinesCommentDelimiters.get(i++);
	    String endSequence = multipleLinesCommentDelimiters.get(i++);
	    rules.add(new MultiLineRule(startSequence, endSequence, commentMultipleToken));
	}

	for (String stringDelimiter : compilerSyntax.getStringDelimiters()) {
	    rules.add(new SingleLineRule(stringDelimiter, stringDelimiter, stringToken));
	}

	IPredicateRule[] rulesArray = new IPredicateRule[rules.size()];
	rules.toArray(rulesArray);
	setPredicateRules(rulesArray);
    }

    /**
     * Creates a new FastPartitioner based on this partition scanner and
     * connects it to the document.
     * 
     * @param document
     *            The document, not <code>null</code>.
     */
    public void createDocumentPartitioner(IDocument document) {

	if (document == null) {
	    throw new IllegalArgumentException("Parameter 'document' must not be null.");
	}
	FastPartitioner partitioner = new FastPartitioner(this, new String[] {
		CompilerSourcePartitionScanner.PARTITION_COMMENT_SINGLE,
		CompilerSourcePartitionScanner.PARTITION_COMMENT_MULTIPLE,
		CompilerSourcePartitionScanner.PARTITION_STRING });
	partitioner.connect(document);
	document.setDocumentPartitioner(partitioner);

    }
}
