package com.wudsn.ide.hex;

import org.osgi.framework.BundleContext;

import com.wudsn.ide.base.common.AbstractIDEPlugin;

/**
 * The activator class controls the plug-in life cycle
 */
public class HexPlugin extends AbstractIDEPlugin {

    // The plug-in ID
    public static final String ID = "com.wudsn.ide.hex"; //$NON-NLS-1$

    // The shared instance
    private static HexPlugin plugin;

    /**
     * The constructor
     */
    public HexPlugin() {
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
     * Gets the shared plugin instance
     * 
     * @return The plug-in, not <code>null</code>.
     */
    public static HexPlugin getInstance() {
	if (plugin == null) {
	    throw new IllegalStateException("Plugin not initialized or already stopped");
	}
	return plugin;
    }

}
