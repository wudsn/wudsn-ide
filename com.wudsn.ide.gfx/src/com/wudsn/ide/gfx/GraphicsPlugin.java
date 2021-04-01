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

package com.wudsn.ide.gfx;

import org.osgi.framework.BundleContext;

import com.wudsn.ide.base.common.AbstractIDEPlugin;
import com.wudsn.ide.gfx.converter.ConverterConsole;
import com.wudsn.ide.gfx.converter.ConverterRegistry;
import com.wudsn.ide.gfx.converter.ConverterScript;
import com.wudsn.ide.gfx.converter.ImageConverterData;

/**
 * The activator class controls the plug-in life cycle. This plugin uses classes
 * from the Mozilla Rhino in the classes {@link ConverterScript} and
 * {@link ImageConverterData}. See <a href=
 * "https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino/Download_Rhino"
 * >https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino/
 * Download_Rhino"</a>.
 * 
 * TODO RHino is  embedded in J2SE 6 as the default Java scripting engine.: 
 */
public final class GraphicsPlugin extends AbstractIDEPlugin {

    /**
     * The plugin id.
     */
    public static final String ID = "com.wudsn.ide.gfx";

    /**
     * Creates a new instance. Must be public for dynamic instantiation.
     */
    private static GraphicsPlugin plugin;

    /**
     * The converter registry.
     */
    private ConverterRegistry converterRegistry;

    /**
     * The converter console.
     */
    private ConverterConsole converterConsole;

    /**
     * The constructor
     */
    public GraphicsPlugin() {
	converterRegistry = new ConverterRegistry();
    }

    @Override
    protected String getPluginId() {
	return ID;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void start(BundleContext context) throws Exception {
	super.start(context);
	plugin = this;
	converterRegistry.init();
	converterConsole = new ConverterConsole();
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
    public static GraphicsPlugin getInstance() {
	if (plugin == null) {
	    throw new IllegalStateException("Plugin not initialized or already stopped");
	}
	return plugin;
    }

    /**
     * Gets the converter registry for this plugin.
     * 
     * @return The converter registry, not <code>null</code>.
     */
    public ConverterRegistry getConverterRegistry() {
	if (converterRegistry == null) {
	    throw new IllegalStateException("Field 'converterRegistry' must not be null.");
	}
	return converterRegistry;
    }

    /**
     * Gets the converter console for this plugin.
     * 
     * @return The converter console, not <code>null</code>.
     */
    public ConverterConsole getConverterConsole() {
	return converterConsole;
    }
}
