package com.wudsn.ide.lng;

import org.osgi.framework.BundleContext;

import com.wudsn.ide.base.common.AbstractIDEPlugin;

/**
 * The activator class controls the plug-in life cycle
 */
public class LanguagePlugin extends AbstractIDEPlugin {

	// The plug-in ID
	public static final String ID = "com.wudsn.ide.lng"; //$NON-NLS-1$

	// The shared instance
	private static LanguagePlugin plugin;

	/**
	 * The constructor
	 */
	public LanguagePlugin() {
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
	public static LanguagePlugin getInstance() {
		if (plugin == null) {
			throw new IllegalStateException("Plugin not initialized or already stopped");
		}
		return plugin;
	}

}
