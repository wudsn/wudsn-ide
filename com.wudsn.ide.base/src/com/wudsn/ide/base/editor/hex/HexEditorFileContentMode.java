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

package com.wudsn.ide.base.editor.hex;

enum HexEditorFileContentMode {

    BINARY(Hardware.GENERIC), ATARI_COM_FILE(Hardware.ATARI8BIT), ATARI_DISK_IMAGE(Hardware.ATARI8BIT), ATARI_DISK_IMAGE_K_FILE(
	    Hardware.ATARI8BIT), ATARI_MADS_FILE(Hardware.ATARI8BIT), ATARI_SDX_FILE(Hardware.ATARI8BIT), ATARI_SAP_FILE(
	    Hardware.ATARI8BIT), C64_PRG_FILE(Hardware.C64);

    private Hardware hardware;

    private HexEditorFileContentMode(Hardware hardware) {
	if (hardware == null) {
	    throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
	}
	this.hardware = hardware;
    }

    public Hardware getHardware() {
	return hardware;
    }
}
