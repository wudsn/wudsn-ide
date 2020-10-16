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

package com.wudsn.ide.snd;

import java.util.Map;
import java.util.TreeMap;

import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.content.IContentType;
import org.eclipse.core.runtime.content.IContentTypeManager;
import org.osgi.framework.BundleContext;

import com.wudsn.ide.base.common.AbstractIDEPlugin;
import com.wudsn.ide.snd.player.SoundPlayer;
import com.wudsn.ide.snd.player.atari8.ASAPPlayer;
import com.wudsn.ide.snd.player.c64.SIDPlayer;

public final class SoundPlugin extends AbstractIDEPlugin {

    /**
     * The plugin id.
     */
    public static final String ID = "com.wudsn.ide.snd";

    /**
     * Creates a new instance. Must be public for dynamic instantiation.
     */
    private static SoundPlugin plugin;

    private Map<String, Class<? extends SoundPlayer>> soundPlayers;
    private SoundPlayer currentPlayer;

    public SoundPlugin() {
	soundPlayers = new TreeMap<String, Class<? extends SoundPlayer>>();
	soundPlayers.put("com.wudsn.ide.snd.player.atari8bit.Atari8BitSoundFile", ASAPPlayer.class);
	soundPlayers.put("com.wudsn.ide.snd.player.c64.C64SoundFile", SIDPlayer.class);
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
    public static SoundPlugin getInstance() {
	if (plugin == null) {
	    throw new IllegalStateException("Plugin not initialized or already stopped");
	}
	return plugin;
    }

    /**
     * Creates a new sound player based on the extension of the file name. A
     * previously created sound player is stopped and freed first.
     * 
     * @param fileName
     *            The file name, may be empty, not <code>null</code>.
     * 
     * @return The new sound player or <code>null</code>.
     */
    public SoundPlayer createSoundPlayer(String fileName) {
	if (fileName == null) {
	    throw new IllegalArgumentException("Parameter 'fileName' must not be null.");
	}
	IContentTypeManager contentTypeManager = Platform.getContentTypeManager();

	synchronized (this) {
	    if (currentPlayer != null) {
		currentPlayer.stop();
	    }

	    currentPlayer = null;
	    for (String contentTypeName : soundPlayers.keySet()) {
		IContentType contentType = contentTypeManager.getContentType(contentTypeName);
		if (contentType == null) {
		    throw new IllegalArgumentException("Content type '" + contentTypeName + "' is unknown.");
		}
		if (contentType.isAssociatedWith(fileName)) {
		    try {
			currentPlayer = soundPlayers.get(contentTypeName).newInstance();
		    } catch (Exception ex) {
			throw new RuntimeException("Cannot create sound player for content type '" + contentTypeName
				+ "'", ex);
		    }
		    break; // for
		}
	    }
	    return currentPlayer;
	}
    }
}
