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

package com.wudsn.ide.gfx.editor;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.jface.action.ControlContribution;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.ISelectionListener;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.part.ViewPart;

import com.wudsn.ide.base.gui.Action;
import com.wudsn.ide.base.gui.ActionListener;
import com.wudsn.ide.base.gui.MessageManager;
import com.wudsn.ide.base.gui.SWTFactory;
import com.wudsn.ide.gfx.Texts;
import com.wudsn.ide.gfx.converter.ConverterCommonParameters;
import com.wudsn.ide.gfx.gui.AspectField;
import com.wudsn.ide.gfx.gui.ImageCanvas;
import com.wudsn.ide.gfx.model.Aspect;

/**
 * This ImageView class shows the image from an {@link ImageProvider} in an
 * {@link ImageCanvas}.
 * 
 * @author Peter Dell
 * @author Chengdong Li: cli4@uky.edu
 * 
 * @see ImageCanvas
 */

public final class ImageView extends ViewPart implements ISelectionListener {

	private final class AspectControlContribution extends ControlContribution implements ActionListener {

		private boolean enabled;
		private Aspect value;
		private AspectField aspectField;
		private Action action;

		public AspectControlContribution() {
			super("com.wudsn.ide.gfx.editor.ImageViewAspect");
			enabled = false;
			value = new Aspect(1, 1);
		}

		@Override
		protected Control createControl(Composite parent) {
			Composite composite = SWTFactory.createComposite(parent, 2, 1, GridData.FILL_HORIZONTAL);
			GridLayout gridLayout = (GridLayout) composite.getLayout();
			gridLayout.marginHeight = 0;
			aspectField = new AspectField(composite, Texts.IMAGE_VIEW_ASPECT_LABEL);
			aspectField.setEnabled(enabled);
			aspectField.setValue(value);
			action = new Action(1, this);
			aspectField.addSelectionAction(action);

			messageManager.registerField(aspectField, ConverterCommonParameters.MessageIds.DISPLAY_ASPECT);
			return composite;
		}

		public void setEnabled(boolean enabled) {
			this.enabled = enabled;
			if (aspectField != null) {
				aspectField.setEnabled(enabled);
			}
		}

		public void setValue(Aspect value) {
			this.value = value;
			if (aspectField != null) {
				aspectField.setValue(value);
			}
		}

		@Override
		public void performAction(Action action) {
			imageProvider.setAspect(aspectField.getValue());
		}
	}

	public static final String ID = ImageView.class.getName();
	MessageManager messageManager;

	private AspectControlContribution aspectControlContribution;
	IAction shrinkToFitAction;
	IAction zoomToFitAction;
	private ImageCanvas imageCanvas;

	ImageProvider imageProvider;

	/**
	 * Creation is private.
	 */
	public ImageView() {
		messageManager = new MessageManager(this);
	}

	@Override
	public void createPartControl(Composite parent) {

		IToolBarManager toolBarManager = getViewSite().getActionBars().getToolBarManager();

		aspectControlContribution = new AspectControlContribution();

		shrinkToFitAction = new org.eclipse.jface.action.Action("Shrink", IAction.AS_CHECK_BOX) {
			@Override
			public void run() {
				imageProvider.setShrinkToFit(shrinkToFitAction.isChecked());
			}
		};
		zoomToFitAction = new org.eclipse.jface.action.Action("Zoom", IAction.AS_CHECK_BOX) {
			@Override
			public void run() {
				imageProvider.setZoomToFit(zoomToFitAction.isChecked());
			}
		};

		toolBarManager.add(aspectControlContribution);
		toolBarManager.add(shrinkToFitAction);
		toolBarManager.add(zoomToFitAction);

		imageCanvas = new ImageCanvas(parent, SWT.NONE);

		// Currently there's no use-case for reacting on the mouse position.
		// imageCanvas.addMouseMoveListener(new MouseMoveListener() {
		// public void mouseMove(MouseEvent event) {
		// Point point;
		// messageManager.clearMessages();
		//
		// point = imageCanvas.getPoint(event);
		// messageManager.sendMessage(
		// 0,
		// IStatus.INFO,
		// "x={0} y={1}",
		// new String[] {
		// NumberUtility
		// .getLongValueDecimalString(point.x),
		//
		// NumberUtility
		// .getLongValueDecimalString(point.y) });
		// messageManager.displayMessages();
		//
		// }
		// });

		// Add this as a global selection listener
		getSite().getPage().addSelectionListener(this);

		// Preset based on current selection
		selectionChanged(null, getSite().getPage().getSelection());
	}

	@Override
	public void setFocus() {
		imageCanvas.setFocus();
	}

	@Override
	public void dispose() {

		if (imageProvider != null) {
			imageProvider.setImageView(null);
			imageProvider = null;
		}

		getSite().getPage().removeSelectionListener(this);
		imageCanvas.dispose();
		super.dispose();
	}

	@Override
	public void selectionChanged(IWorkbenchPart part, ISelection selection) {

		if (part == null) {
			setImageProvider(null);
		} else {
			if (part instanceof GraphicsConversionEditor) {
				GraphicsConversionEditor graphicsConversionEditor = ((GraphicsConversionEditor) part);
				setImageProvider(graphicsConversionEditor.getImageProvider());
				System.out.println(this + "" + part + "" + selection);
			}
		}
	}

	/**
	 * Sets the image provider.
	 * 
	 * @param imageProvider The image provider or <code>null</code>.
	 */
	public void setImageProvider(ImageProvider imageProvider) {
		if (imageProvider != this.imageProvider) {
			// Unregister from old provider
			if (this.imageProvider != null) {
				this.imageProvider.setImageView(null);
				this.imageProvider = null;
			}

			// Register with new provider
			if (imageProvider != null) {
				this.imageProvider = imageProvider;
				this.imageProvider.setImageView(this);
			}
		}
		dataToUI();

	}

	/**
	 * Retrieve the current status from the image provider and display it.
	 * 
	 */
	public void dataToUI() {
		ImageData imageData;
		boolean enabled;

		messageManager.clearMessages();
		if (imageProvider != null) {
			imageData = imageProvider.getImageData();
			enabled = (imageData != null);

			aspectControlContribution.setEnabled(enabled);
			aspectControlContribution.setValue(imageProvider.getAspect());
			shrinkToFitAction.setEnabled(false);
			shrinkToFitAction.setChecked(imageProvider.isShrinkToFit());
			shrinkToFitAction.setEnabled(enabled);
			zoomToFitAction.setEnabled(false);
			zoomToFitAction.setChecked(imageProvider.isZoomToFit());
			zoomToFitAction.setEnabled(enabled);
			imageCanvas.setShrinkToFit(imageProvider.isShrinkToFit());
			imageCanvas.setZoomToFit(imageProvider.isZoomToFit());

			boolean valid;
			ImageData displayImageData;

			Aspect aspect = imageProvider.getAspect();
			if (aspect.isValid()) {
				valid = true;
			} else {
				messageManager.sendMessage(ConverterCommonParameters.MessageIds.DISPLAY_ASPECT, IStatus.ERROR,
						"Invalid display aspect");
				valid = false;
			}
			if (valid && imageData != null) {
				int width = imageData.width;
				int height = imageData.height;
				displayImageData = imageData.scaledTo(width * aspect.getValidFactorX(),
						height * aspect.getValidFactorY());
			} else {
				displayImageData = null;
			}

			imageCanvas.setImageData(displayImageData);
		} else {
			aspectControlContribution.setEnabled(false);
			shrinkToFitAction.setEnabled(false);
			zoomToFitAction.setEnabled(false);
			imageCanvas.setImageData(null);
		}
		messageManager.displayMessages();
	}
}