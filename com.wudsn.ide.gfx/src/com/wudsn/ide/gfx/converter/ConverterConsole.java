/**
 * Copyright (C) 2009 - 2021 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

package com.wudsn.ide.gfx.converter;

import java.io.PrintStream;

import org.eclipse.ui.console.ConsolePlugin;
import org.eclipse.ui.console.IConsole;
import org.eclipse.ui.console.IConsoleManager;
import org.eclipse.ui.console.IConsoleView;
import org.eclipse.ui.console.MessageConsole;
import org.eclipse.ui.console.MessageConsoleStream;

import com.wudsn.ide.gfx.Texts;

/**
 * The console to show the user the output from the converter.
 * 
 * @author Peter Dell
 */
public final class ConverterConsole {

    private IConsoleManager consoleManager;
    public MessageConsole console;

    private MessageConsoleStream messageStream;
    private PrintStream printStream;

    /**
     * Create a new console-window.
     * 
     */
    public ConverterConsole() {
	consoleManager = ConsolePlugin.getDefault().getConsoleManager();
	console = new MessageConsole(Texts.CONVERTER_CONSOLE_TITLE, null);
	consoleManager.addConsoles(new IConsole[] { console });

	messageStream = console.newMessageStream();
	messageStream.setActivateOnWrite(false);
	messageStream.print("");
	printStream = new PrintStream(messageStream);
    }

    /**
     * Brings this console view instance to front in the console view editor
     * part.
     * 
     * @param consoleView
     *            The console view editor part, not <code>null</code>.
     */

    public void display(IConsoleView consoleView) {
	if (consoleView == null) {
	    throw new IllegalArgumentException("Parameter 'consoleView' must not be null.");
	}
	consoleView.display(console);

    }

    /**
     * Add a line to console.
     * 
     * @param message
     *            The message to print, not <code>null</code>.
     */
    public void println(String message) {
	if (message == null) {
	    throw new IllegalArgumentException("Parameter 'message' must not be null.");
	}
	messageStream.println(message);
    }

    /**
     * Gets a print messageStream to write to this console.
     * 
     * @return The print messageStream, not <code>null</code>.
     */
    public PrintStream getPrintStream() {
	return printStream;
    }

}
