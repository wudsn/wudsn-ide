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
package com.wudsn.ide.asm;

import org.eclipse.jface.resource.ImageDescriptor;

import com.wudsn.ide.asm.compiler.CompilerFileWriter;
import com.wudsn.ide.asm.compiler.writer.AppleFileWriter;
import com.wudsn.ide.base.hardware.Hardware;

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
	 * Gets the compiler file writer a hardware.
	 * 
	 * @param hardware The hardware, not <code>null</code>.
	 * @return The image descriptor for the hardware image, not <code>null</code>.
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
