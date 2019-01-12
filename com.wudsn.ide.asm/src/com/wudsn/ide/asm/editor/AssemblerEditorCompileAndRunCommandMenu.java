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

package com.wudsn.ide.asm.editor;

import java.util.Date;
import java.util.List;

import org.eclipse.e4.ui.di.AboutToShow;
import org.eclipse.e4.ui.model.application.ui.menu.MDirectMenuItem;
import org.eclipse.e4.ui.model.application.ui.menu.MMenuElement;
import org.eclipse.e4.ui.model.application.ui.menu.MMenuFactory;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.menus.WorkbenchWindowControlContribution;

// TODO: Dynamic menu contribution is not working!
public final class AssemblerEditorCompileAndRunCommandMenu extends WorkbenchWindowControlContribution {

    public AssemblerEditorCompileAndRunCommandMenu() {
	new Exception().printStackTrace();
    }

    public AssemblerEditorCompileAndRunCommandMenu(String id) {
	super(id);
    }

    @AboutToShow
    public void aboutToShow(List<MMenuElement> items) {
	MDirectMenuItem dynamicItem = MMenuFactory.INSTANCE.createDirectMenuItem();
	dynamicItem.setLabel("Dynamic Menu Item (" + new Date() + ")");
	dynamicItem.setContributorURI("platform:/plugin/at.descher.eclipse.bug389063");
	dynamicItem
		.setContributionURI("bundleclass://at.descher.eclipse.bug389063/at.descher.eclipse.bug389063.dynamic.DirectMenuItemAHandler");
	items.add(dynamicItem);

    }

    @Override
    protected Control createControl(Composite parent) {
	// TODO Auto-generated method stub
	return null;
    }

}
