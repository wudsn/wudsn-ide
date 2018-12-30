/**
* Copyright (C) 2009 - 2014 <a href="http://www.wudsn.com" target="_top">Peter Dell</a>
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

package com.wudsn.ide.base.gui;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.jface.action.IStatusLineManager;
import org.eclipse.jface.fieldassist.ControlDecoration;
import org.eclipse.jface.fieldassist.FieldDecorationRegistry;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IViewPart;
import org.eclipse.ui.IWorkbenchPart;

import com.wudsn.ide.base.BasePlugin;
import com.wudsn.ide.base.common.TextUtility;

/**
 * Message manager for an work benach part of type {@link IEditorPart} or
 * {@link IViewPart}.
 * 
 * @author Peter Dell
 * 
 */
public final class MessageManager {

    private final static class FieldRegistryEntry {

	private Field field;
	private int messageId;

	private ControlDecoration controlDecoration;

	public FieldRegistryEntry(Field field, int messageId) {
	    if (field == null) {
		throw new IllegalArgumentException(
			"Parameter 'field' must not be null.");
	    }
	    if (messageId < 0) {
		throw new IllegalArgumentException(
			"Parameter 'messageId' must not be negative.");
	    }
	    this.field = field;
	    this.messageId = messageId;

	    Control control = field.getControl();

	    controlDecoration = new ControlDecoration(control, SWT.RIGHT
		    | SWT.TOP);
	    controlDecoration.setShowHover(true);
	}

	public Field getField() {
	    return field;
	}

	public int getMessageId() {
	    return messageId;
	}

	public ControlDecoration getControlDecoration() {
	    return controlDecoration;

	}
    }

    private static final class MessageQueueEntry {

	private int messageId;
	private int severity;
	private String message;
	private String[] parameters;
	private Throwable throwable;

	public MessageQueueEntry(int messageId, int severity, String message,
		String[] parameters, Throwable throwable) {
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

    private IWorkbenchPart workbenchPart;

    private IStatusLineManager statusLineManager;

    private List<FieldRegistryEntry> fieldRegistryEntries;

    private List<MessageQueueEntry> messageQueueEntries;
    private boolean messageQueueError;

    private Color yellow;
    private Color red;

    public MessageManager(IWorkbenchPart workbenchPart) {
	if (workbenchPart == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'workbenchPart' must not be null.");
	}
	this.workbenchPart = workbenchPart;

	fieldRegistryEntries = new ArrayList<FieldRegistryEntry>();
	messageQueueEntries = new ArrayList<MessageQueueEntry>();
	messageQueueError = false;

	yellow = new Color(Display.getDefault(), 0, 255, 255);
	red = new Color(Display.getDefault(), 255, 0, 0);

    }

    public void dispose() {
	for (FieldRegistryEntry fieldRegistryEntry : fieldRegistryEntries) {
	    ControlDecoration controlDecoration;
	    controlDecoration = fieldRegistryEntry.getControlDecoration();
	    controlDecoration.hide();
	    controlDecoration.dispose();
	}
	fieldRegistryEntries.clear();

	yellow.dispose();
	red.dispose();
    }

    private void initStatusLineManager() {
	if (statusLineManager == null) {
	    if (workbenchPart instanceof IEditorPart) {
		statusLineManager = ((IEditorPart) workbenchPart)
			.getEditorSite().getActionBars().getStatusLineManager();
	    } else if (workbenchPart instanceof IViewPart) {
		statusLineManager = ((IViewPart) workbenchPart).getViewSite()
			.getActionBars().getStatusLineManager();
	    } else {
		throw new IllegalStateException("Workbench part "
			+ workbenchPart + " has an unsupported type.");
	    }
	}
    }

    public void registerField(Field field, int messageId) {
	if (field == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'field' must not be null.");
	}
	if (messageId < 0) {
	    throw new IllegalArgumentException(
		    "Parameter 'messageId' must not be negative.");
	}
	FieldRegistryEntry fieldRegistryEntry = new FieldRegistryEntry(field,
		messageId);
	fieldRegistryEntries.add(fieldRegistryEntry);
    }

    public void clearMessages() {
	messageQueueEntries.clear();
	messageQueueError = false;

	for (FieldRegistryEntry fieldRegistryEntry : fieldRegistryEntries) {

	    Control control = fieldRegistryEntry.getField().getControl();
	    control.setForeground(control.getParent().getForeground());
	    ControlDecoration controlDecoration;
	    controlDecoration = fieldRegistryEntry.getControlDecoration();
	    controlDecoration.hide();
	}

	initStatusLineManager();
	statusLineManager.setMessage(null);
	statusLineManager.setErrorMessage(null);

    }

    /**
     * Sends a message to the message queue.
     * 
     * @param messageId
     *            The message id identifying the target UI element of the
     *            message.
     * @param severity
     *            The severity, see {@link IStatus#INFO},{@link IStatus#WARNING}
     *            , {@link IStatus#ERROR}.
     * @param message
     *            The message text, not <code>null</code>.
     * @param parameters
     *            The message parameters, may be empty or null.
     */
    public void sendMessage(int messageId, int severity, String message,
	    String... parameters) {
	if (message == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'message' must not be null.");
	}
	MessageQueueEntry messageQueueEntry;
	messageQueueEntry = new MessageQueueEntry(messageId, severity, message,
		parameters, null);
	addMessageQueueEntry(messageQueueEntry);
    }

    /**
     * Sends a message to the message queue based on a core exception.
     * 
     * @param messageId
     *            The message id identifying the target UI element of the
     *            message.
     * @param coreException
     *            The core exception with the status and text information, not
     *            <code>null</code>.
     */
    public void sendMessage(int messageId, CoreException coreException) {
	if (coreException == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'coreException' must not be null.");
	}
	MessageQueueEntry messageQueueEntry;
	messageQueueEntry = new MessageQueueEntry(messageId, coreException
		.getStatus().getSeverity(), coreException.getStatus()
		.getMessage(), null, coreException);
	addMessageQueueEntry(messageQueueEntry);

    }

    private void addMessageQueueEntry(MessageQueueEntry messageQueueEntry) {
	if (messageQueueEntry == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'messageQueueEntry' must not be null.");
	}
	messageQueueEntries.add(messageQueueEntry);
	if (messageQueueEntry.getSeverity() == IStatus.ERROR) {
	    messageQueueError = true;
	}
    }

    public boolean containsError() {
	return messageQueueError;
    }

    public void displayMessages() {

	initStatusLineManager();

	FieldDecorationRegistry fieldDecorationRegistry = FieldDecorationRegistry
		.getDefault();
	Image informationImage = fieldDecorationRegistry.getFieldDecoration(
		FieldDecorationRegistry.DEC_INFORMATION).getImage();
	Image warningImage = fieldDecorationRegistry.getFieldDecoration(
		FieldDecorationRegistry.DEC_INFORMATION).getImage();
	Image errorImage = fieldDecorationRegistry.getFieldDecoration(
		FieldDecorationRegistry.DEC_ERROR).getImage();

	for (MessageQueueEntry messageQueueEntry : messageQueueEntries) {

	    String messageText = TextUtility.format(
		    messageQueueEntry.getMessage(),
		    messageQueueEntry.getParameters());

	    BasePlugin plugin = BasePlugin.getInstance();

	    switch (messageQueueEntry.getSeverity()) {
	    case IStatus.OK:
		statusLineManager.setMessage(messageText);

		plugin.log(messageQueueEntry.getMessage(),
			messageQueueEntry.getParameters());
		break;

	    case IStatus.INFO:
	    case IStatus.WARNING:
	    case IStatus.ERROR:
		Image image;
		switch (messageQueueEntry.getSeverity()) {
		case IStatus.INFO:
		    image = informationImage;
		    break;
		case IStatus.WARNING:
		    image = warningImage;
		    break;
		case IStatus.ERROR:
		    image = errorImage;
		    break;
		default:
		    image = null;
		}
		for (FieldRegistryEntry fieldRegistryEntry : fieldRegistryEntries) {
		    if (fieldRegistryEntry.getMessageId() == messageQueueEntry
			    .getMessageId()) {

			ControlDecoration controlDecoration;
			Control control;
			control = fieldRegistryEntry.getField().getControl();

			if (messageQueueEntry.getSeverity() == IStatus.ERROR) {
			    control.setForeground(red);
			} else {
			    control.setForeground(control.getParent()
				    .getForeground());
			}

			controlDecoration = fieldRegistryEntry
				.getControlDecoration();

			controlDecoration.setImage(image);
			controlDecoration.setDescriptionText(messageText);
			controlDecoration.show();
		    }
		}
		if (messageQueueEntry.getSeverity() == IStatus.ERROR) {
		    statusLineManager.setErrorMessage(messageText);
		} else {
		    statusLineManager.setMessage(messageText);

		}
		plugin.logError(messageQueueEntry.getMessage(),
			messageQueueEntry.getParameters(),
			messageQueueEntry.getThrowable());
		break;
	    default:
		throw new IllegalStateException("Severity "
			+ messageQueueEntry.getSeverity()
			+ " is not supported.");
	    }

	}
    }
}
