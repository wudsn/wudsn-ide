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

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;

/**
 * Message queue
 * 
 * @author Peter Dell
 * 
 */
public final class MessageQueue {

	public static final class Entry {

		private int messageId;
		private int severity;
		private String message;
		private String[] parameters;
		private Throwable throwable;

		public Entry(int messageId, int severity, String message, String[] parameters,
				Throwable throwable) {
			this.messageId = messageId;
			this.severity = severity;
			this.message = message;
			this.parameters = parameters;
			this.throwable = throwable;
		}

		public int getMessageId() {
			return messageId;
		}

		public int getSeverity() {
			return severity;
		}

		public String getMessage() {
			return message;
		}

		public String[] getParameters() {
			return parameters;
		}

		public Throwable getThrowable() {
			return throwable;
		}

	}

	private List<Entry> entriesList;
	private boolean error;

	public MessageQueue() {
		entriesList = new ArrayList<Entry>();
		error = false;
	}

	public void clear() {
		entriesList.clear();
		error = false;
	}

	/**
	 * Sends a message to the message queue.
	 * 
	 * @param messageId  The message id identifying the target UI element of the
	 *                   message.
	 * @param severity   The severity, see
	 *                   {@link IStatus#INFO},{@link IStatus#WARNING} ,
	 *                   {@link IStatus#ERROR}.
	 * @param message    The message text, not <code>null</code>.
	 * @param parameters The message parameters, may be empty or null.
	 */
	public void sendMessage(int messageId, int severity, String message, String... parameters) {
		if (message == null) {
			throw new IllegalArgumentException("Parameter 'message' must not be null.");
		}
		Entry messageQueueEntry;
		messageQueueEntry = new Entry(messageId, severity, message, parameters, null);
		addMessageQueueEntry(messageQueueEntry);
	}

	/**
	 * Sends a message to the message queue based on a core exception.
	 * 
	 * @param messageId     The message id identifying the target UI element of the
	 *                      message.
	 * @param coreException The core exception with the status and text information,
	 *                      not <code>null</code>.
	 */
	public void sendMessage(int messageId, CoreException coreException) {
		if (coreException == null) {
			throw new IllegalArgumentException("Parameter 'coreException' must not be null.");
		}
		Entry messageQueueEntry;
		messageQueueEntry = new Entry(messageId, coreException.getStatus().getSeverity(),
				coreException.getStatus().getMessage(), null, coreException);
		addMessageQueueEntry(messageQueueEntry);

	}

	private void addMessageQueueEntry(Entry messageQueueEntry) {
		if (messageQueueEntry == null) {
			throw new IllegalArgumentException("Parameter 'messageQueueEntry' must not be null.");
		}
		entriesList.add(messageQueueEntry);
		if (messageQueueEntry.getSeverity() == IStatus.ERROR) {
			error = true;
		}
	}

	public boolean containsError() {
		return error;
	}

	public List<Entry> getEntries() {
		return Collections.unmodifiableList(entriesList);
	}
}
