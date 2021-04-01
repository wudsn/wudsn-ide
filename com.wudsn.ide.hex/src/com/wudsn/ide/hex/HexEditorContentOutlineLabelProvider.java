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

import org.eclipse.jface.viewers.DelegatingStyledCellLabelProvider;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.StyledString;
import org.eclipse.swt.graphics.Image;

/**
 * Label provider for the tree objects in the outline page.
 * 
 * @author Peter Dell
 */
final class HexEditorContentOutlineLabelProvider extends DelegatingStyledCellLabelProvider {

    /** Outline segment image */
    private final Image segmentImage;

    private static class HexEditorStyledLabelProvider extends LabelProvider implements IStyledLabelProvider {

	/**
	 * Creation is local.
	 */
	HexEditorStyledLabelProvider() {

	}

	@Override
	public StyledString getStyledText(Object element) {
	    if (element == null) {
		throw new IllegalArgumentException("Parameter 'element' must not be null.");
	    }
	    HexEditorContentOutlineTreeObject treeObject;
	    treeObject = (HexEditorContentOutlineTreeObject) element;
	    return treeObject.getStyledString();
	}
    }

    /**
     * Creates a new instance.
     * 
     * Called by
     * {@link HexEditorContentOutlinePage#createControl(org.eclipse.swt.widgets.Composite)}
     * .
     */
    HexEditorContentOutlineLabelProvider() {
	super(new HexEditorStyledLabelProvider());
	HexPlugin plugin;
	plugin = HexPlugin.getInstance();
	segmentImage = plugin.getImage("hex-editor-segment-16x16.gif");
    }

    @Override
    public Image getImage(Object element) {
	Image result;

	result = segmentImage;

	return result;
    }

}
