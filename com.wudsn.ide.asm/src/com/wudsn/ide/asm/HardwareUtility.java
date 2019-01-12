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
package com.wudsn.ide.asm;

import org.eclipse.jface.resource.ImageDescriptor;

import com.wudsn.ide.asm.compiler.CompilerFileWriter;
import com.wudsn.ide.asm.compiler.writer.AppleFileWriter;

/**
 * Map value of {@link Hardware} to icon paths and descriptors.
 * 
 * @author Peter Dell
 * 
 */
public final class HardwareUtility {

    /**
     * Creation is private.
     */
    private HardwareUtility() {
    }

    /**
     * Gets the default file extension for executable files on a hardware.
     * 
     * @param hardware
     *            The hardware, not <code>null</code>.
     * @return The default file extension, may be empty, not <code>null</code>.
     * 
     * @since 1.6.1
     */
    public static String getDefaultFileExtension(Hardware hardware) {
	if (hardware == null) {
	    throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
	}
	switch (hardware) {
	case APPLE2:
	    // AppleDos 3.3 binary file
	    // start-lo,start-hi,length-lo,length-hi,data
	    return ".b";
	case ATARI2600:
	    // Atari VCS ROM cartridge
	    return ".bin";
	case ATARI7800:
	    // Atari 7800 ROM cartridge
	    return ".bin";
	case ATARI8BIT:
	    // AtariDOS 2.5 compound file,
	    // $ff,$ff,start-lo,start-hi,end-lo,end-hi,data
	    return ".xex";
	case C64:
	    // C64 program file
	    // start-lo,start-hi,data
	    return ".prg";
	case NES:
	    // NES ROM file
	    return ".nes";
	case TEST:
	    return ".tst";
	default:
	    return "";
	}
    }

    /**
     * Gets the image path for a hardware image.
     * 
     * @param hardware
     *            The hardware, not <code>null</code>.
     * @return The image path for the hardware image, not empty and not
     *         <code>null</code>.
     */
    public static String getImagePath(Hardware hardware) {
	if (hardware == null) {
	    throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
	}
	String path;
	switch (hardware) {
	case GENERIC:
	    path = "hardware-generic-16x16.gif";
	    break;
	case APPLE2:
	    path = "hardware-apple2-16x16.gif";
	    break;
	case ATARI2600:
	    path = "hardware-atari2600-16x16.gif";
	    break;
	case ATARI7800:
	    path = "hardware-atari7800-16x16.gif";
	    break;
	case ATARI8BIT:
	    path = "hardware-atari8bit-16x16.gif";
	    break;
	case C64:
	    path = "hardware-c64-16x16.gif";
	    break;
	case NES:
	    path = "hardware-nes-16x16.gif";
	    break;
	case TEST:
	    path = "hardware-test-16x16.gif";
	    break;
	default:
	    throw new IllegalArgumentException("Unknown hardware " + hardware + ".");
	}
	return path;
    }

    /**
     * Gets the image descriptor for a hardware image.
     * 
     * @param hardware
     *            The hardware, not <code>null</code>.
     * @return The image descriptor for the hardware image, not
     *         <code>null</code>.
     */
    public static ImageDescriptor getImageDescriptor(Hardware hardware) {
	if (hardware == null) {
	    throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
	}
	ImageDescriptor result;
	result = AssemblerPlugin.getInstance().getImageDescriptor(getImagePath(hardware));
	return result;
    }

    /**
     * Gets the compiler file writer a hardware.
     * 
     * @param hardware
     *            The hardware, not <code>null</code>.
     * @return The image descriptor for the hardware image, not
     *         <code>null</code>.
     * @since 1.6.4
     */
    public static CompilerFileWriter getCompilerFileWriter(Hardware hardware) {
	if (hardware == null) {
	    throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
	}
	CompilerFileWriter compilerFileWriter;
	if (hardware.equals(Hardware.APPLE2)) {
	    compilerFileWriter = new AppleFileWriter();
	} else {
	    compilerFileWriter = new CompilerFileWriter();
	}
	return compilerFileWriter;
    }
}
