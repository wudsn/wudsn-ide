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

import java.util.HashMap;
import java.util.Map;

import com.wudsn.ide.base.BasePlugin;

public final class Profiler {

	public static final String PROPERTY_NAME = "com.wudsn.ide.common.base.Profiler";

	private static final class Entry {

		public final long startTimeMillis;
		public final String description;

		public Entry(String description) {
			if (description == null) {
				throw new IllegalArgumentException("Parameter 'description' must not be null.");
			}
			startTimeMillis = System.currentTimeMillis();
			this.description = description;
		}
	}

	private Object owner;
	private Map<String, Entry> statistics;

	public Profiler(Object owner) {
		if (owner == null) {
			throw new IllegalArgumentException("Parameter 'owner' must not be null.");
		}
		this.owner = owner;
		statistics = new HashMap<String, Entry>();
	}

	public void end(String key) {
		Entry entry = statistics.get(key);
		if (entry == null) {
			throw new IllegalStateException("No begin for key '" + key + "'.");
		}

		if (Boolean.getBoolean(PROPERTY_NAME)) {
			Long duration = Long.valueOf((System.currentTimeMillis() - entry.startTimeMillis));
			if (entry.description.isEmpty()) {
				BasePlugin.getInstance().log("Time for '{0}:{1}' is {2}ms", new Object[] { owner, key, duration });
			} else {
				BasePlugin.getInstance().log("Time for '{0}:{1}' of {2} is {3}ms",
						new Object[] { owner, key, entry.description, duration });
			}
		}

	}

	public void begin(String key) {
		begin(key, "");
	}

	public void begin(String key, String description) {
		statistics.put(key, new Entry(description));

	}
}
