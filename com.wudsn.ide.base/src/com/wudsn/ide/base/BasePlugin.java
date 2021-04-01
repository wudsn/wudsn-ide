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

package com.wudsn.ide.base;

import org.osgi.framework.BundleContext;

import com.wudsn.ide.base.common.AbstractIDEPlugin;

/**
 * The activator class controls the plug-in life cycle
 */
public final class BasePlugin extends AbstractIDEPlugin {

    /**
     * The plugin id.
     */
    public static final String ID = "com.wudsn.ide.base";

    /**
     * The shared instance.
     */
    private static BasePlugin plugin;

    /**
     * Creates a new instance. Must be public for dynamic instantiation.
     */
    public BasePlugin() {
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected String getPluginId() {
	return ID;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void start(BundleContext context) throws Exception {
	if (context != null) {
	    super.start(context);
	}
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
     * Gets the shared plugin instance
     * 
     * @return The plug-in, not <code>null</code>.
     */
    public static BasePlugin getInstance() {
	if (plugin == null) {
	    throw new IllegalStateException("Plugin not initialized or already stopped");
	}
	return plugin;
    }

}