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

package com.wudsn.ide.base.common;

import java.net.URL;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.jface.dialogs.ErrorDialog;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;
import org.osgi.service.prefs.BackingStoreException;

import com.wudsn.ide.base.Texts;

/**
 * The plugin base class for IDE plugins.
 * 
 * @author Peter Dell
 */
public abstract class AbstractIDEPlugin extends AbstractUIPlugin {

    private Map<String, Image> images;

    /**
     * Creates a new instance. Must be public for dynamic instantiation.
     */
    protected AbstractIDEPlugin() {
	images = new HashMap<String, Image>();

    }

    /**
     * Gets the plugin id.
     * 
     * @return The plugin id, not empty and not <code>null</code>.
     */
    protected abstract String getPluginId();

    /**
     * {@inheritDoc}
     */
    @Override
    public void start(BundleContext context) throws Exception {
	super.start(context);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void stop(BundleContext context) throws Exception {
	super.stop(context);
    }

    /**
     * Logs an info message to the plugin log and the standard output stream.
     * 
     * @param message
     *            The message, not <code>null</code>.
     * @param parameters
     *            The message parameters, may be empty or <code>null</code>.
     */
    public final void log(String message, Object[] parameters) {
	if (message == null) {
	    throw new IllegalArgumentException("Parameter 'message' must not be null.");
	}
	message = format(message, parameters);
	getLog().log(new Status(IStatus.INFO, getPluginId(), IStatus.OK, message, null));
//	System.out.println(message);
    }

    /**
     * Logs an error message and an exception to the plugin log and the standard
     * error stream.
     * 
     * @param message
     *            The message, not <code>null</code>.
     * @param parameters
     *            The message parameters, may be empty or <code>null</code>.
     * @param th
     *            The throwable or <code>null</code>.
     */
    public final void logError(String message, Object[] parameters, Throwable th) {
	if (message == null) {
	    throw new IllegalArgumentException("Parameter 'message' must not be null.");
	}

	message = format(message, parameters);
	if (th != null) {
	    message = message + "\n" + th.getMessage();
	}
	getLog().log(new Status(IStatus.ERROR, getPluginId(), IStatus.ERROR, message, th));
	// System.err.println(message);
	// if (th != null) {
	// th.printStackTrace(System.err);
	// }
	// System.err.flush();

    }

    private String format(String message, Object... parameters) {
	if (parameters == null) {
	    parameters = new String[0];
	}
	String[] stringParameters = new String[parameters.length];
	for (int i = 0; i < parameters.length; i++) {
	    Object parameter = parameters[i];
	    String stringParameter;
	    if (parameter == null) {
		stringParameter = "null";
	    } else {
		stringParameter = parameter.toString();
	    }
	    stringParameters[i] = stringParameter;
	}
	message = TextUtility.format(message, stringParameters);
	return message;
    }

    /**
     * Shows error message and an exception as error dialog and logs them to the
     * plugin log and the standard error stream.
     * 
     * @param shell
     *            The shell, not <code>null</code>.
     * 
     * @param message
     *            The message, not <code>null</code>.
     * @param th
     *            The throwable, not <code>null</code>.
     */
    public final void showError(Shell shell, String message, Throwable th) {
	if (shell == null) {
	    throw new IllegalArgumentException("Parameter 'shell' must not be null.");
	}
	if (message == null) {
	    throw new IllegalArgumentException("Parameter 'message' must not be null.");
	}
	if (th == null) {
	    throw new IllegalArgumentException("Parameter 'th' must not be null.");
	}

	Status status = new Status(IStatus.ERROR, getPluginId(), message);

	ErrorDialog.openError(shell, Texts.DIALOG_TITLE, th.getClass().getName() + ": " + th.getMessage()
		+ "\nCheck the .log file in the .metadata folder of the workspace for details.", status);
	logError(message, null, th);
    }

    public final void savePreferences() {
	String pluginId;
	pluginId = getPluginId();
	try {
	    InstanceScope.INSTANCE.getNode(pluginId).flush();
	} catch (BackingStoreException ex) {

	    throw new RuntimeException("Cannot store preferences for plugin '" + pluginId + "'", ex);
	}
    }

    /**
     * Gets the image for the specified plug-in relative path.
     * 
     * @param path
     *            The plug-in relative path, not <code>null</code>.
     * 
     * @return The image, not <code>null</code>.
     */
    public final Image getImage(String path) {
	if (path == null) {
	    throw new IllegalArgumentException("Parameter 'path' must not be null.");
	}
	Image result;
	synchronized (images) {
	    result = images.get(path);
	    if (result == null) {

		ImageDescriptor imageDescriptor;
		imageDescriptor = getImageDescriptor(path);
		if (imageDescriptor == null) {
		    throw new RuntimeException("Image '" + path + "' not found.");
		}
		result = imageDescriptor.createImage();
		images.put(path, result);
	    }
	}

	return result;

    }

    /**
     * Gets the image for the specified plug-in relative path.
     * 
     * @param path
     *            The plug-in relative path, not <code>null</code>.
     * 
     * @return The image descriptor or <code>null</code> if no image resource
     *         was found.
     */
    public final ImageDescriptor getImageDescriptor(String path) {
	ImageDescriptor imageDescriptor;
	imageDescriptor = AbstractUIPlugin.imageDescriptorFromPlugin(getPluginId(), "icons/" + path);
	return imageDescriptor;
    }

    /**
     * Gets the absolute path of a entry from the plugin's directory.
     * 
     * @param fileName
     *            The name of a file or directory, no compound name like
     *            "dir1\dir2" or "dir1\file1", not <code>null</code>.
     * 
     * @return The absolute path of the file or directory in the plugin's
     *         directory, may be empty, not <code>null</code>.
     */
    public final String getFilePathFromPlugin(String fileName) {
	if (fileName == null) {
	    throw new IllegalArgumentException("Parameter 'entry' must not be null.");
	}
	URL url = null;
	IPath path = null;
	String result = "";

	Enumeration<URL> enu = getBundle().findEntries("/", fileName, true);
	if (enu != null && enu.hasMoreElements()) {
	    url = enu.nextElement();
	}

	if (url == null) {
	    return "";
	}

	try {
	    path = new Path(FileLocator.toFileURL(url).getPath());
	    result = path.makeAbsolute().toOSString();
	} catch (Exception ex) {
	    result = "";
	}

	return result;
    }

}
