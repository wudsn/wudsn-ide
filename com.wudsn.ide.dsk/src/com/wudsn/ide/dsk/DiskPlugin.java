package com.wudsn.ide.dsk;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

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

/**
 * The activator class controls the plug-in life cycle
 */
public class DiskPlugin extends AbstractUIPlugin {

    /**
     * The plugin id.
     */
    public static final String PLUGIN_ID = "com.wudsn.ide.dsk"; //$NON-NLS-1$

    /**
     * The shared instance.
     */
    private static DiskPlugin plugin;

    /**
     * The constructor
     */
    public DiskPlugin() {
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void start(BundleContext context) throws Exception {
	super.start(context);
	plugin = this;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void stop(BundleContext context) throws Exception {
	plugin = null;
	super.stop(context);
    }

    /**
     * Gets the shared plugin instance.
     * 
     * @return The plug-in, not <code>null</code>.
     */
    public static DiskPlugin getInstance() {
	return plugin;
    }

}
