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

package com.wudsn.ide.base.common;

import java.io.IOException;
import java.io.OutputStream;
import java.util.*;

import com.wudsn.ide.base.BasePlugin;

/**
 * Writes to the input stream of a system process, queueing output if the stream
 * is blocked.
 * 
 * The input stream monitor writes to system in via an output stream.
 * 
 * @author Peter Dell
 */
final class InputStreamMonitor {

	/**
	 * The stream which is being written to (connected to system in).
	 */
	private OutputStream outputStream;

	/**
	 * Whether the underlying output stream has been closed
	 */
	private boolean outputStreamClosed;

	/**
	 * The queue of output.
	 */
	private List<String> outputQueue;
	/**
	 * A lock for ensuring that writes to the queue are contiguous
	 */
	private Object outputQueueLock;

	/**
	 * The thread which writes to the stream.
	 */
	private Thread thread;

	/**
	 * Creates an input stream monitor which writes to system in via the given
	 * output stream.
	 * 
	 * @param outputStream output stream
	 */
	public InputStreamMonitor(OutputStream outputStream) {
		if (outputStream == null) {
			throw new IllegalArgumentException("Parameter 'outputStream' must not be null.");
		}
		this.outputStream = outputStream;
		outputQueue = new ArrayList<String>();
		outputQueueLock = new Object();
	}

	/**
	 * Appends the given text to the stream, or queues the text to be written at a
	 * later time if the stream is blocked.
	 * 
	 * @param text text to append
	 */
	public void write(String text) {
		synchronized (outputQueueLock) {
			outputQueue.add(text);
			outputQueueLock.notifyAll();
		}
	}

	/**
	 * Starts a thread which writes the stream.
	 */
	public void startMonitoring() {
		if (thread == null) {
			thread = new Thread(new RunnableWithLogging() {
				@Override
				public void runWithLogging() {
					write();
				}
			}, "InputStreamMonitor");
			thread.setDaemon(true);
			thread.start();
		}
	}

	/**
	 * Close all communications between this monitor and the underlying stream.
	 */
	public void close() {
		if (thread != null) {
			Thread thread = this.thread;
			this.thread = null;
			thread.interrupt();
		}
	}

	/**
	 * Continuously writes to the stream.
	 */
	protected void write() {
		while (thread != null) {
			writeNext();
		}
		if (!outputStreamClosed) {
			try {
				outputStream.close();
			} catch (IOException ex) {
				BasePlugin.getInstance().logError("IOException during write()", null, ex);
			}
		}
	}

	/**
	 * Write the text in the queue to the stream.
	 */
	protected void writeNext() {
		while (!outputQueue.isEmpty() && !outputStreamClosed) {
			String text = outputQueue.get(0);
			outputQueue.remove(0);
			try {
				outputStream.write(text.getBytes());
				outputStream.flush();
			} catch (IOException ex) {
				BasePlugin.getInstance().logError("IOException during writeNext()", null, ex);
			}
		}
		try {
			synchronized (outputQueueLock) {
				outputQueueLock.wait();
			}
		} catch (InterruptedException e) {
		}
	}

	/**
	 * Closes the output stream attached to the standard input stream of this
	 * monitor's process.
	 * 
	 * @exception IOException if an exception occurs closing the input stream
	 */
	public void closeInputStream() throws IOException {
		if (!outputStreamClosed) {
			outputStreamClosed = true;
			outputStream.close();
		} else {
			throw new IOException();
		}

	}
}
