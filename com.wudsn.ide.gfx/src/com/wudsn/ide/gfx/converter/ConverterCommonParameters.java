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

package com.wudsn.ide.gfx.converter;

import com.wudsn.ide.gfx.model.Aspect;
import com.wudsn.ide.gfx.model.GraphicsPropertiesSerializer;

public abstract class ConverterCommonParameters {

	/**
	 * Names of the attributes.
	 * 
	 * @author Peter Dell
	 * 
	 */
	public static final class Attributes {

		/**
		 * Creation is private.
		 */
		private Attributes() {
		}

		public static final String CONVERTER_ID = "converterId";

		public static final String IMAGE_ASPECT = "imageAspect";

		// Display attributes.
		public static final String DISPLAY_ASPECT = "displayAspect";
		public static final String DISPLAY_SHRINK_TO_FIT = "displayShrinkToFit";
		public static final String DISPLAY_ZOOM_TO_FIT = "displayZoomToFit";
	}

	/**
	 * Defaults of the attributes.
	 * 
	 * @author Peter Dell
	 * 
	 */
	private static final class Defaults {

		/**
		 * Creation is protected.
		 */
		private Defaults() {
		}

		public static final String CONVERTER_ID = "";

		public static final Aspect IMAGE_ASPECT = new Aspect(1, 1);
		public static final Aspect DISPLAY_ASPECT = new Aspect(1, 1);
		public static final boolean DISPLAY_SHRINK_TO_FIT = false;
		public static final boolean DISPLAY_ZOOM_TO_FIT = true;
	}

	/**
	 * Message ids of the attributes.
	 * 
	 * @author Peter Dell
	 * 
	 */
	public static final class MessageIds {

		/**
		 * Creation is private.
		 */
		private MessageIds() {
		}

		public static final int CONVERTER_ID = 1000;
		public static final int IMAGE_ASPECT = 1001;
		public static final int DISPLAY_ASPECT = 1002;
	}

	protected String converterId;

	private Aspect imageAspect;
	private Aspect displayAspect;
	private boolean displayShrinkToFit;
	private boolean displayZoomToFit;

	ConverterCommonParameters() {
	}

	protected void setDefaults() {
		converterId = Defaults.CONVERTER_ID;
		imageAspect = Defaults.IMAGE_ASPECT;
		displayAspect = Defaults.DISPLAY_ASPECT;
		displayShrinkToFit = Defaults.DISPLAY_SHRINK_TO_FIT;
		displayZoomToFit = Defaults.DISPLAY_ZOOM_TO_FIT;
	}

	public abstract void setConverterId(String value);

	public final String getConverterId() {
		return converterId;
	}

	public final void setImageAspect(Aspect value) {
		if (value == null) {
			throw new IllegalArgumentException("Parameter 'value' must not be null.");
		}
		this.imageAspect = value;
	}

	public final Aspect getImageAspect() {
		return imageAspect;
	}

	public final void setDisplayAspect(Aspect value) {
		if (value == null) {
			throw new IllegalArgumentException("Parameter 'value' must not be null.");
		}
		this.displayAspect = value;
	}

	public final Aspect getDisplayAspect() {
		return displayAspect;
	}

	public final void setDisplayShrinkToFit(boolean displayShrinkToFit) {
		this.displayShrinkToFit = displayShrinkToFit;
	}

	public final boolean isDisplayShrinkToFit() {
		return displayShrinkToFit;
	}

	public final void setDisplayZoomToFit(boolean displayZoomToFit) {
		this.displayZoomToFit = displayZoomToFit;
	}

	public final boolean isDisplayZoomToFit() {
		return displayZoomToFit;
	}

	protected void copyTo(ConverterCommonParameters target) {
		if (target == null) {
			throw new IllegalArgumentException("Parameter 'target' must not be null.");
		}

		target.setConverterId(converterId);
		target.setImageAspect(imageAspect);
		target.setDisplayAspect(displayAspect);
		target.setDisplayShrinkToFit(displayShrinkToFit);
		target.setDisplayZoomToFit(displayZoomToFit);
	}

	protected boolean equals(ConverterCommonParameters target) {
		if (target == null) {
			throw new IllegalArgumentException("Parameter 'target' must not be null.");
		}
		boolean result;

		result = target.getImageAspect().equals(imageAspect);
		result = result && target.getDisplayAspect().equals(displayAspect);
		result = result && target.isDisplayShrinkToFit() == displayShrinkToFit;
		result = result && target.isDisplayZoomToFit() == displayZoomToFit;
		return result;
	}

	protected void serialize(GraphicsPropertiesSerializer serializer, String key) {
		if (serializer == null) {
			throw new IllegalArgumentException("Parameter 'serializer' must not be null.");
		}
		if (key == null) {
			throw new IllegalArgumentException("Parameter 'key' must not be null.");
		}
		GraphicsPropertiesSerializer ownSerializer;

		ownSerializer = new GraphicsPropertiesSerializer();
		ownSerializer.writeString(Attributes.CONVERTER_ID, converterId);
		ownSerializer.writeAspect(Attributes.IMAGE_ASPECT, imageAspect);
		ownSerializer.writeAspect(Attributes.DISPLAY_ASPECT, displayAspect);
		ownSerializer.writeBoolean(Attributes.DISPLAY_SHRINK_TO_FIT, displayShrinkToFit);
		ownSerializer.writeBoolean(Attributes.DISPLAY_ZOOM_TO_FIT, displayZoomToFit);

		serializer.writeProperties(key, ownSerializer);
	}

	protected void deserialize(GraphicsPropertiesSerializer serializer, String key) {
		if (serializer == null) {
			throw new IllegalArgumentException("Parameter 'serializer' must not be null.");
		}
		if (key == null) {
			throw new IllegalArgumentException();
		}

		GraphicsPropertiesSerializer ownSerializer;
		ownSerializer = new GraphicsPropertiesSerializer();
		serializer.readProperties(key, ownSerializer);

		setConverterId(ownSerializer.readString(Attributes.CONVERTER_ID, Defaults.CONVERTER_ID));

		imageAspect = ownSerializer.readXYFactor(Attributes.IMAGE_ASPECT, Defaults.IMAGE_ASPECT);
		displayAspect = ownSerializer.readXYFactor(Attributes.DISPLAY_ASPECT, Defaults.DISPLAY_ASPECT);
		displayShrinkToFit = ownSerializer.readBoolean(Attributes.DISPLAY_SHRINK_TO_FIT,
				Defaults.DISPLAY_SHRINK_TO_FIT);
		displayZoomToFit = ownSerializer.readBoolean(Attributes.DISPLAY_ZOOM_TO_FIT, Defaults.DISPLAY_ZOOM_TO_FIT);
	}
}
