/**
 * Copyright (C) 2009 - 2014 <a href="http://www.wudsn.com" target="_top">Peter Dell</a>
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

package com.wudsn.ide.asm.editor;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.debug.ui.actions.IToggleBreakpointsTarget;
import org.eclipse.debug.ui.actions.IToggleBreakpointsTargetFactory;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.ui.IWorkbenchPart;

import com.wudsn.ide.asm.Texts;

/**
 * Factory for {@AssemblerBreakpointsTarget}
 * instances. Used by extension
 * "org.eclipse.debug.ui.toggleBreakpointsTargetFactories"
 * 
 * @author Peter Dell
 * @since 1.6.1
 */
public final class AssemblerBreakpointAdapterFactory implements
	IToggleBreakpointsTargetFactory {

    private String TARGET_ID = AssemblerBreakpointsTarget.class.getName();
    private Set<String> defaultSet;

    public AssemblerBreakpointAdapterFactory() {
	defaultSet = new HashSet<String>();
	defaultSet.add(TARGET_ID);
    }

    @Override
    public Set<String> getToggleTargets(IWorkbenchPart part,
	    ISelection selection) {
	if (part instanceof AssemblerEditor) {
	    return defaultSet;
	}
	return Collections.emptySet();
    }

    @Override
    public String getDefaultToggleTarget(IWorkbenchPart part,
	    ISelection selection) {
	if (part instanceof AssemblerEditor) {
	    return TARGET_ID;
	}
	return null;
    }

    @Override
    public IToggleBreakpointsTarget createToggleTarget(String targetID) {
	if (TARGET_ID.equals(targetID)) {
	    return new AssemblerBreakpointsTarget();
	}
	return null;
    }

    @Override
    public String getToggleTargetName(String targetID) {
	return Texts.ASSEMBLER_BREAKPOINT_TOGGLE_TYPE_MENU_TEXT;
    }

    @Override
    public String getToggleTargetDescription(String targetID) {
	return TARGET_ID;
    }

}
