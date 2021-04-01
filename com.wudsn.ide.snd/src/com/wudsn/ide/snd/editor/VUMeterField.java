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
package com.wudsn.ide.snd.editor;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.PaintEvent;
import org.eclipse.swt.events.PaintListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;

import com.wudsn.ide.base.gui.Field;
import com.wudsn.ide.snd.SoundPlugin;

/**
 * VU meter field.
 * 
 * @author Peter Dell
 * @since 1.6.1
 * 
 */
final class VUMeterField extends Field {

    private Label label;
    private Canvas canvas;
    private Color barColor;
    private Color borderColor;
    private int[] channelVolumnes;
    private int[] lastChannelVolumnes;

    public VUMeterField(Composite composite, boolean withLabel, String labelText, int none) {
	if (composite == null) {
	    throw new IllegalArgumentException("Parameter 'composite' must not be null.");
	}
	if (labelText == null) {
	    throw new IllegalArgumentException("Parameter 'labelText' must not be null.");
	}

	if (withLabel) {
	    label = new Label(composite, SWT.NONE);
	    label.setText(labelText);
	}
	canvas = new Canvas(composite, SWT.NO_BACKGROUND);

	// Register a paint listener
	canvas.addPaintListener(new PaintListener() {
	    // @Override
	    @Override
	    public void paintControl(final PaintEvent event) {
		drawVUMeter(event.gc);
	    }
	});

	barColor = composite.getDisplay().getSystemColor(SWT.COLOR_GREEN);
	borderColor = composite.getDisplay().getSystemColor(SWT.COLOR_BLACK);

	channelVolumnes = new int[0];
    }

    public void dispose() {
	canvas.dispose();
	label.dispose();
    }

    @Override
    public Control getControl() {
	return canvas;
    }

    @Override
    public void setEnabled(boolean enabled) {
	label.setEnabled(enabled);
    }

    @Override
    public void setEditable(boolean editable) {

    }

    /**
     * Sets the values for to display.
     * 
     * @param channelVolumes
     *            The array of channel volumes. May be empty, not
     *            <code>null</code>. The minimum volume value is 0. The maximum
     *            volume value is 255.
     */
    public void setValue(int[] channelVolumes) {
	if (channelVolumes == null) {
	    throw new IllegalArgumentException("Parameter 'channelVolumes' must not be null.");
	}
	synchronized (this) {
	    this.channelVolumnes = channelVolumes;
	}

	if (!canvas.isDisposed()) {
	    canvas.redraw();
	}
    }

    final void drawVUMeter(GC gc) {

	Rectangle clientRectangle = canvas.getClientArea();

	Image image = new Image(canvas.getDisplay(), canvas.getClientArea());
	GC imageGC = new GC(image);

	imageGC.setBackground(canvas.getBackground());
	imageGC.fillRectangle(clientRectangle);
	int[] volumes;
	synchronized (this) {
	    volumes = channelVolumnes.clone();

	    // Create the average between the current and the previous volume.
	    if (lastChannelVolumnes != null && lastChannelVolumnes.length == channelVolumnes.length) {
		for (int i = 0; i < volumes.length; i++) {
		    volumes[i] = (volumes[i] + lastChannelVolumnes[i]) / 2;
		}
	    }
	    lastChannelVolumnes = channelVolumnes;
	}
	int voices = volumes.length;
	if (voices > 0) {
	    int voiceWidth = clientRectangle.width / voices;
	    double unitHeight = clientRectangle.height / 256.0d;
	    imageGC.setBackground(barColor);
	    imageGC.setForeground(borderColor);
	    for (int i = 0; i < voices; i++) {
		int volume = volumes[i];
		if (volume < 0) {
		    SoundPlugin.getInstance().logError("Volume {0} is channel {1} is less than 0",
			    new Object[] { Integer.valueOf(volume), Integer.valueOf(i) }, null);
		    volume = 0;
		} else if (volume > 255) {
		    SoundPlugin.getInstance().logError("Volume {0} is channel {1} is larger than 255.",
			    new Object[] { Integer.valueOf(volume), Integer.valueOf(i) }, null);
		    volume = 255;
		}
		int height = (int) (volume * unitHeight) + 1;

		imageGC.fillGradientRectangle(i * voiceWidth + 1, clientRectangle.height - height, voiceWidth - 3,
			height - 1, true);

		imageGC.drawRectangle(i * voiceWidth, clientRectangle.height - height, voiceWidth - 2, height - 1);
	    }
	}
	gc.drawImage(image, clientRectangle.x, clientRectangle.y);

	imageGC.dispose();
	image.dispose();

    }
}