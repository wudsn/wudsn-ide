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

package com.wudsn.ide.snd.player;

import com.wudsn.ide.base.common.EnumUtility;

/**
 * @author Peter Dell
 */
public enum FileType {

	// ATARI file Types, alphabethical order:
	// cm3, cmc, cmr, cms, dlt, dmc, fc, mpd, mpt, rmt, tmc, tm2, tm8, sap
	// XEX is an export only format, not registered in the content type.

	CM3(".cm3"), CMC(".cmc"), CMR(".cmr"), CMS(".cms"), DLT(".dlt"), DMC(".dmc"), FC(".fc"), MPD(".mpd"), MPT(".mpt"),
	RMT(".rmt"), SAP(".sap"), TM2(".tm2"), TM8(".tm8"), TMC(".tmc"), XEX(".xex"),

	// C64 File Types, alphabethical order:
	// prg, sid
	// PRG is an export only format, not registered in the content type.

	PRG(".prg"), SID(".sid");

	private final String extension;

	private FileType(String extension) {
		if (extension == null) {
			throw new IllegalArgumentException("Parameter 'extension' must not be null.");
		}
		this.extension = extension;
	}

	/**
	 * Gets an instance based on the extension.
	 * 
	 * @param extension the extension, lower case with a leading dot, not
	 *                  <code>null</code>.
	 * @return The file type, or <code>null</code> if not matching file type exists.
	 */
	public static FileType getInstanceByExtension(String extension) {
		if (extension == null) {
			throw new IllegalArgumentException("Parameter 'extension' must not be null.");
		}
		for (FileType fileType : values()) {
			if (fileType.getExtension().equals(extension)) {
				return fileType;
			}
		}
		return null;
	}

	public String getExtension() {
		return extension;
	}

	public String getDescription() {
		return EnumUtility.getText(this);
	}

	public boolean isMusicAddressChangeable() {
		switch (this) {
		case CMC:
		case CM3:
		case CMR:
		case CMS:
		case DMC:
		case DLT:
		case MPT:
		case MPD:
		case RMT:
		case TMC:
		case TM8:
		case TM2:
			return true;
		default:
			return false;
		}

	}
}