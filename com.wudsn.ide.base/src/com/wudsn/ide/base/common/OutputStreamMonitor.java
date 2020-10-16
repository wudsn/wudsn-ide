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

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;

import com.wudsn.ide.base.BasePlugin;

/**
 * Monitors the output stream of a system process and notifies listeners of
 * additions to the stream.
 * 
 * The output stream monitor reads system out (or err) via and input stream.
 * 
 * @author Peter Dell
 */
final class OutputStreamMonitor {

    /**
     * The stream being monitored (connected system out or err).
     */
    private InputStream inputStream;

    /**
     * The stream to which the output is sent.
     */
    private PrintStream outputStream;

    /**
     * The encoding of the stream to which the output is sent.
     */
    private String outputStreamEncoding;
    /**
     * The local copy of the stream contents
     */
    private StringBuilder bufferedContent;

    /**
     * The thread which reads from the stream
     */
    private Thread thread;

    /**
     * The size of the read buffer
     */
    private static final int BUFFER_SIZE = 8192;

    /**
     * Whether or not this monitor has been killed. When the monitor is killed,
     * it stops reading from the stream immediately.
     */
    private boolean killed;

    /**
     * Creates an output stream monitor on the given stream (connected to system
     * out or err).
     * 
     * @param inputStream
     *            The input stream to read from, not <code>null</code>.
     * @param outputStreamEncoding
     *            The stream encoding or <code>null</code> for system default.
     * @param outputStream
     *            The output stream, not <code>null</code>.
     */
    public OutputStreamMonitor(InputStream inputStream, String outputStreamEncoding, PrintStream outputStream) {
	if (inputStream == null) {
	    throw new IllegalArgumentException("Parameter 'stream' must not be null.");
	}
	if (outputStream == null) {
	    throw new IllegalArgumentException("Parameter 'outputStream' must not be null.");
	}
	this.inputStream = new BufferedInputStream(inputStream, BUFFER_SIZE);
	this.outputStreamEncoding = outputStreamEncoding;
	this.outputStream = outputStream;
	bufferedContent = new StringBuilder();
    }

    /**
     * Causes the monitor to close all communications between it and the
     * underlying stream by waiting for the thread to terminate.
     */
    protected void close() {
	if (this.thread != null) {
	    Thread thread = this.thread;
	    this.thread = null;
	    try {
		thread.join();
	    } catch (InterruptedException ie) {
	    }
	}
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.eclipse.debug.core.model.IStreamMonitor#getContents()
     */
    public String getContents() {
	synchronized (bufferedContent) {
	    return bufferedContent.toString();
	}
    }

    /**
     * Continually reads from the stream.
     * <p>
     * This method, along with the <code>startReading</code> method is used to
     * allow <code>OutputStreamMonitor</code> to implement <code>Runnable</code>
     * without publicly exposing a <code>run</code> method.
     */
    void read() {
	long lastSleep = System.currentTimeMillis();
	byte[] bytes = new byte[8192];
	int read = 0;
	while (read >= 0) {
	    try {
		if (killed) {
		    break;
		}
		read = inputStream.read(bytes);
		if (read > 0) {
		    String text;
		    if (outputStreamEncoding != null) {
			text = new String(bytes, 0, read, outputStreamEncoding);
		    } else {
			text = new String(bytes, 0, read);
		    }
		    synchronized (bufferedContent) {
			bufferedContent.append(text);
			outputStream.print(text);
			outputStream.flush();
		    }
		}
	    } catch (IOException ioe) {
		if (!killed) {
		    BasePlugin.getInstance().logError("IOException occured", null, ioe);
		}
		return;
	    } catch (NullPointerException ex) {
		// killing the stream monitor while reading can cause an NPE
		// when reading from the stream
		if (!killed && this.thread != null) {
		    BasePlugin.getInstance().logError("Cannot read from stream", null, ex);
		}
		return;
	    }

	    long currentTime = System.currentTimeMillis();
	    if (currentTime - lastSleep > 1000) {
		lastSleep = currentTime;
		try {
		    Thread.sleep(100); // just give up CPU to maintain UI
		    // responsiveness.
		} catch (InterruptedException e) {
		}
	    }
	}
	try {
	    inputStream.close();
	} catch (IOException ex) {
	    BasePlugin.getInstance().logError("Cannot close input stream.", null, ex);
	}

    }

    protected void kill() {
	killed = true;
    }

    /**
     * Starts a thread which reads from the stream
     */
    protected void startMonitoring() {
	if (this.thread == null) {
	    this.thread = new Thread(new RunnableWithLogging() {
		@Override
		public void runWithLogging() {
		    read();
		}
	    }, "OutputStreamMonitor");
	}
	this.thread.setDaemon(true);
	this.thread.setPriority(Thread.MIN_PRIORITY);
	this.thread.start();
    }
}
