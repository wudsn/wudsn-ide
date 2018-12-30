package com.wudsn.ide.hex;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.net.URL;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.widgets.Display;

final class HexEditorFonts {

    private Font atari8Font;
    private Font c64Font;

    public HexEditorFonts() {

    }

    public void init() {
	Display display = HexPlugin.getInstance().getWorkbench().getDisplay();

	// From http://members.bitstream.net/~marksim/atarimac/fonts.html
	atari8Font = loadFont(display, "fonts/atari8/ATARCC__.TTF", "");

	// From http://style64.org/c64-truetype
	c64Font = loadFont(display, "fonts/c64/C64_Pro_v1.0-STYLE.ttf",
		"C64 Pro Mono");

    }

    public void dispose() {
	atari8Font.dispose();
	c64Font.dispose();
    }

    public Font getFont() {
	return atari8Font;
    }

    private Font loadFont(Display display, String fileName, String fontName) {
	if (display == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'display' must not be null.");
	}
	if (fileName == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'fileName' must not be null.");
	}
	if (fontName == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'fontName' must not be null.");
	}

	URL url;
	url = FileLocator.find(HexPlugin.getInstance().getBundle(), new Path(
		fileName), null);
	try {
	    url = FileLocator.toFileURL(url);
	} catch (IOException ex) {
	    throw new IllegalArgumentException("Cannot load font from '"
		    + fileName + "'.", ex);
	}
	try {
	    File file = new File(url.toURI());
	    fileName = file.getAbsolutePath();
	} catch (URISyntaxException ex) {
	    throw new IllegalArgumentException("Cannot load font from '"
		    + fileName + "'.", ex);
	}
	int fontSize = 8;
	if (display.loadFont(fileName)) {
	    Font result = new Font(display, fontName, fontSize, SWT.NORMAL);
	    return result;
	}
	throw new IllegalArgumentException("Cannot load font from '" + fileName
		+ "'.");
    }

}
