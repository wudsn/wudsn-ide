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

package com.wudsn.ide.asm.runner.atari8;

import java.io.File;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.debug.core.model.IBreakpoint;

import com.wudsn.ide.asm.compiler.CompilerFiles;
import com.wudsn.ide.asm.editor.AssemblerBreakpoint;
import com.wudsn.ide.asm.runner.Runner;

/**
 * Runner for Altirra 2.0 and above which support source line breakpoints.
 * 
 * @author Peter Dell
 * @since 1.6.1
 */
public final class Altirra extends Runner {

    @Override
    public File createBreakpointsFile(CompilerFiles files) {
	if (files == null) {
	    throw new IllegalArgumentException("Parameter 'files' must not be null.");
	}
	return new File(files.outputFilePathWithoutExtension + ".atdbg");
    }

    @Override
    public int createBreakpointsFileContent(AssemblerBreakpoint[] breakpoints, StringBuilder breakpointBuilder) {
	if (breakpoints == null) {
	    throw new IllegalArgumentException("Parameter 'breakpoints' must not be null.");
	}
	int activeBreakpoints = 0;
	breakpointBuilder.append(".sourcemode on\n");
	breakpointBuilder.append(".echo\n");
	breakpointBuilder.append(".echo \"Loading executable...\"\n");
	breakpointBuilder.append(".echo\n");
	breakpointBuilder.append("bc *\n");
	breakpointBuilder.append(".onexerun .echo \"Launching executable...\"\n");
	for (IBreakpoint breakpoint : breakpoints) {
	    try {
		if (breakpoint.isEnabled()) {
		    AssemblerBreakpoint assemberBreakpoint = (AssemblerBreakpoint) breakpoint;
		    IMarker marker = breakpoint.getMarker();
		    String sourceFilePath = marker.getResource().getLocation().toOSString();
		    breakpointBuilder.append("bp \"`" + sourceFilePath + ":" + assemberBreakpoint.getLineNumber()
			    + "`\"\n");
		    activeBreakpoints++;
		}
	    } catch (CoreException ex) {
		throw new RuntimeException(ex);
	    }

	}
	return activeBreakpoints;
    }

}
