/**
 * Copyright (C) 2009 - 2020 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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
package com.wudsn.ide.base.common;

import java.io.IOException;
import java.io.PrintStream;

/**
 * Wrapper around the input and output stream of a process. The stream a
 * redirected to the corresponding {@link InputStreamMonitor} and
 * {@link OutputStreamMonitor}
 * 
 * @author Peter Dell
 */
final class StreamsProxy {

    private OutputStreamMonitor outputMonitor;
    private OutputStreamMonitor errorMonitor;
    private InputStreamMonitor inputMonitor;
    private boolean closed;

    public StreamsProxy(Process process, String encoding, PrintStream out, PrintStream err) {
	if (process == null) {
	    throw new IllegalArgumentException("Parameter 'process' must not be null");
	}
	if (out == null) {
	    throw new IllegalArgumentException("Parameter 'out' must not be null.");
	}
	if (err == null) {
	    throw new IllegalArgumentException("Parameter 'err' must not be null.");
	}
	outputMonitor = new OutputStreamMonitor(process.getInputStream(), encoding, out);
	errorMonitor = new OutputStreamMonitor(process.getErrorStream(), encoding, err);
	inputMonitor = new InputStreamMonitor(process.getOutputStream());
	outputMonitor.startMonitoring();
	errorMonitor.startMonitoring();
	inputMonitor.startMonitoring();

    }

    public void close() {
	if (!closed) {
	    closed = true;
	    outputMonitor.close();
	    errorMonitor.close();
	    inputMonitor.close();
	}
    }

    public void kill() {
	closed = true;
	outputMonitor.kill();
	errorMonitor.kill();
	inputMonitor.close();
    }

    public OutputStreamMonitor getErrorStreamMonitor() {
	return errorMonitor;
    }

    public OutputStreamMonitor getOutputStreamMonitor() {
	return outputMonitor;
    }

    public void write(String input) throws IOException {
	if (!closed) {
	    inputMonitor.write(input);
	} else {
	    throw new IOException("StreamsProxy alsready closed");
	}
    }

    public void closeInputStream() throws IOException {
	if (!closed) {
	    inputMonitor.closeInputStream();
	} else {
	    throw new IOException("StreamsProxy alsready closed");
	}
    }

}
