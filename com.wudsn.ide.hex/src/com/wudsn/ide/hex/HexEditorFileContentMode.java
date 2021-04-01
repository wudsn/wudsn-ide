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

package com.wudsn.ide.hex;

import java.lang.reflect.InvocationTargetException;

import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.base.hardware.HardwareCharacterSet;
import com.wudsn.ide.hex.parser.*;

enum HexEditorFileContentMode {

	BINARY(Hardware.GENERIC, BinaryParser.class), ATARI_COM_FILE(Hardware.ATARI8BIT, AtariCOMParser.class),
	ATARI_DISK_IMAGE(Hardware.ATARI8BIT, AtariDiskImageParser.class),
	ATARI_DISK_IMAGE_K_FILE(Hardware.ATARI8BIT, AtariDiskImageKFileParser.class),
	ATARI_MADS_FILE(Hardware.ATARI8BIT, AtariMADSParser.class),
	ATARI_SDX_FILE(Hardware.ATARI8BIT, AtariSDXParser.class), ATARI_SAP_FILE(Hardware.ATARI8BIT, AtariSAPParser.class),
	C64_PRG_FILE(Hardware.C64, C64PRGParser.class), IFF_FILE(Hardware.GENERIC, IFFParser.class);

	private Hardware hardware;
	private Class<? extends HexEditorParser> parserClass;

	private HexEditorFileContentMode(Hardware hardware, Class<? extends HexEditorParser> parserClass) {
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (parserClass == null) {
			throw new IllegalArgumentException("Parameter 'parserClass' must not be null.");
		}
		this.hardware = hardware;
		this.parserClass = parserClass;
	}

	public Hardware getHardware() {
		return hardware;
	}

	/**
	 * Determines the default character set for a given file content mode.
	 * 
	 * @return The default character set, not <code>null</code>.
	 */
	public HardwareCharacterSet getDefaultCharacterSet() {

		switch (hardware) {
		case ATARI8BIT:
			return HardwareCharacterSet.ATARI_ATASCII;
		case C64:
			return HardwareCharacterSet.CBM_PETSCII_UPPER_CASE;
		default:
			return HardwareCharacterSet.ASCII;
		}
	}

	public HexEditorParser createParser() {
		try {
			return parserClass.getDeclaredConstructor().newInstance();
		} catch (NoSuchMethodException ex) {
			throw new RuntimeException(ex);
		} catch (InvocationTargetException ex) {
			throw new RuntimeException(ex);
		} catch (InstantiationException ex) {
			throw new RuntimeException(ex);
		} catch (IllegalAccessException ex) {
			throw new RuntimeException(ex);
		}
	}
}
