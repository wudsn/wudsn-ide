package com.wudsn.ide.gfx.gui;

import java.awt.geom.AffineTransform;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ControlAdapter;
import org.eclipse.swt.events.ControlEvent;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.PaintEvent;
import org.eclipse.swt.events.PaintListener;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.ScrollBar;

/**
 * A scrollable SWT image canvas that extends org.eclipse.swt.graphics.Canvas.
 * 
 * @author Peter Dell
 * @author Chengdong Li: cli4@uky.edu
 */
public final class ImageCanvas extends Canvas {

    // Zoom settings
    private boolean shrinkToFit;
    private boolean zoomToFit;

    // Original image
    private Image sourceImage;

    // Affine transform applied to the source image.
    private AffineTransform transform;

    // Screen image
    private Image screenImage;

    /**
     * Constructor for ScrollableCanvas.
     * 
     * @param parent
     *            The parent of this control, not <code>null</code>.
     * @param style
     *            The style of this control.
     */
    public ImageCanvas(final Composite parent, int style) {
	super(parent, style | SWT.BORDER | SWT.V_SCROLL | SWT.H_SCROLL
		| SWT.NO_BACKGROUND);

	// Register a resize listener
	addControlListener(new ControlAdapter() {
	    @Override
	    public void controlResized(ControlEvent event) {
		updateSize();
	    }
	});
	// Register a paint listener
	addPaintListener(new PaintListener() {
	    @Override
	    public void paintControl(final PaintEvent event) {
		paint(event.gc);
	    }
	});

	// Start with the identity transformation.
	transform = new AffineTransform();
	initScrollBars();
    }

    /**
     * Dispose the garbage here
     */
    @Override
    public void dispose() {
	if (sourceImage != null && !sourceImage.isDisposed()) {
	    sourceImage.dispose();
	    sourceImage = null;
	}
	if (screenImage != null && !screenImage.isDisposed()) {
	    screenImage.dispose();
	    screenImage = null;
	}
    }

    /* Paint function */
    void paint(GC gc) {
	// Canvas' painting area
	Rectangle clientRectangle = getClientArea();

	if (sourceImage != null) {
	    Rectangle imageRectangle = ImageCanvasUtility
		    .inverseTransformRectangle(transform, clientRectangle);
	    // Find a better start point to render
	    int gap = 2;
	    imageRectangle.x -= gap;
	    imageRectangle.y -= gap;
	    imageRectangle.width += 2 * gap;
	    imageRectangle.height += 2 * gap;

	    Rectangle imageBounds = sourceImage.getBounds();
	    imageRectangle = imageRectangle.intersection(imageBounds);
	    Rectangle destRect = ImageCanvasUtility.transformRectangle(
		    transform, imageRectangle);

	    if (screenImage != null) {
		screenImage.dispose();
	    }
	    screenImage = new Image(getDisplay(), clientRectangle.width,
		    clientRectangle.height);
	    GC newGC = new GC(screenImage);
	    newGC.setBackground(getBackground());
	    newGC.fillRectangle(clientRectangle);
	    newGC.setClipping(clientRectangle);
	    newGC.drawImage(sourceImage, imageRectangle.x, imageRectangle.y,
		    imageRectangle.width, imageRectangle.height, destRect.x,
		    destRect.y, destRect.width, destRect.height);
	    newGC.dispose();

	    gc.drawImage(screenImage, 0, 0);
	} else {
	    gc.setClipping(clientRectangle);
	    gc.fillRectangle(clientRectangle);
	    initScrollBars();
	}
    }

    /**
     * Initializes the scrollbars and registers the listeners.
     */
    private void initScrollBars() {
	ScrollBar horizontal = getHorizontalBar();
	horizontal.setEnabled(false);
	horizontal.addSelectionListener(new SelectionAdapter() {
	    @Override
	    public void widgetSelected(SelectionEvent event) {
		scrollHorizontally((ScrollBar) event.widget);
	    }
	});
	ScrollBar vertical = getVerticalBar();
	vertical.setEnabled(false);
	vertical.addSelectionListener(new SelectionAdapter() {
	    @Override
	    public void widgetSelected(SelectionEvent event) {
		scrollVertically((ScrollBar) event.widget);
	    }
	});
    }

    /* Scroll horizontally */
    void scrollHorizontally(ScrollBar scrollBar) {
	if (sourceImage == null)
	    return;

	AffineTransform af = transform;
	double tx = af.getTranslateX();
	double select = -scrollBar.getSelection();
	af.preConcatenate(AffineTransform.getTranslateInstance(select - tx, 0));
	transform = af;
	synchronizeScrollBars();
    }

    /* Scroll vertically */
    void scrollVertically(ScrollBar scrollBar) {
	if (sourceImage == null)
	    return;

	AffineTransform af = transform;
	double ty = af.getTranslateY();
	double select = -scrollBar.getSelection();
	af.preConcatenate(AffineTransform.getTranslateInstance(0, select - ty));
	transform = af;
	synchronizeScrollBars();
    }

    /**
     * Synchronize the scrollbars with the image. If the transform is out of
     * range, this method will correct it. This function considers only
     * following factors :<b> transform, image size, client area size</b>.
     */
    void synchronizeScrollBars() {
	if (sourceImage == null) {
	    redraw();
	    return;
	}

	AffineTransform af = transform;
	double sx = af.getScaleX(), sy = af.getScaleY();
	double tx = af.getTranslateX(), ty = af.getTranslateY();
	if (tx > 0) {
	    tx = 0;
	}
	if (ty > 0) {
	    ty = 0;
	}

	Rectangle clientArea = getClientArea();

	ScrollBar horizontal = getHorizontalBar();
	horizontal.setIncrement((clientArea.width / 100));
	horizontal.setPageIncrement(clientArea.width);
	Rectangle imageBound = sourceImage.getBounds();
	if (imageBound.width * sx > clientArea.width) {
	    // Image is wider than client area
	    horizontal.setMaximum((int) (imageBound.width * sx));
	    horizontal.setEnabled(true);
	    if (((int) -tx) > horizontal.getMaximum() - clientArea.width) {
		tx = -horizontal.getMaximum() + clientArea.width;
	    }
	} else {
	    // Image is narrower than client area
	    horizontal.setEnabled(false);
	    // Center if too small.
	    tx = (clientArea.width - imageBound.width * sx) / 2;
	}
	horizontal.setSelection((int) (-tx));
	horizontal.setThumb(clientArea.width);

	ScrollBar vertical = getVerticalBar();
	vertical.setIncrement(clientArea.height / 100);
	vertical.setPageIncrement(clientArea.height);
	if (imageBound.height * sy > clientArea.height) {
	    // Image is higher than client area
	    vertical.setMaximum((int) (imageBound.height * sy));
	    vertical.setEnabled(true);
	    if (((int) -ty) > vertical.getMaximum() - clientArea.height) {
		ty = -vertical.getMaximum() + clientArea.height;
	    }
	} else {
	    // Image is not as high as the client area
	    vertical.setEnabled(false);
	    // Center if too small
	    ty = (clientArea.height - imageBound.height * sy) / 2;
	}
	vertical.setSelection((int) (-ty));
	vertical.setThumb(clientArea.height);

	// Update transform using concatenation
	af = AffineTransform.getScaleInstance(sx, sy);
	af.preConcatenate(AffineTransform.getTranslateInstance(tx, ty));
	transform = af;

	redraw();
    }

    /**
     * Sets the shrink to fit property. This will no update the image.
     * 
     * @param shrinkToFit
     *            <code>true</code> to activate the automatic shrinking.
     */
    public void setShrinkToFit(boolean shrinkToFit) {
	this.shrinkToFit = shrinkToFit;
	updateSize();
    }

    /**
     * Sets the zoom to fit property. This will no update the image.
     * 
     * @param zoomToFit
     *            <code>true</code> to activate the automatic zooming.
     */
    public void setZoomToFit(boolean zoomToFit) {
	this.zoomToFit = zoomToFit;
	updateSize();
    }

    /**
     * Reset the image data and update the image
     * 
     * @param data
     *            image data to be set
     */
    public void setImageData(ImageData data) {
	Rectangle oldBounds = new Rectangle(-1, -1, -1, -1);

	if (sourceImage != null) {
	    oldBounds = sourceImage.getBounds();
	    sourceImage.dispose();
	    sourceImage = null;
	}

	if (data != null) {
	    sourceImage = new Image(getDisplay(), data);

	    if (!sourceImage.getBounds().equals(oldBounds)) {
		updateSize();
	    } else {
		redraw();
	    }
	} else {
	    redraw();
	}
    }

    public Image getImage() {
	return sourceImage;
    }

    /**
     * Translates the x,y coordinates from a mouse event to the point
     * coordinates in the original unscaled image.
     * 
     * @param event
     *            The event, not <code>null</code>.
     * @return The point or <code>null</code>.
     */
    public Point getPoint(MouseEvent event) {
	if (event == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'event' must not be null.");
	}
	return new Point(event.x, event.y);
    }

    /**
     * Update the image size and scrollbar positions.
     */
    void updateSize() {
	if (sourceImage == null) {
	    redraw();
	    return;
	}
	Rectangle imageBounds = sourceImage.getBounds();
	Rectangle clientArea = getClientArea();
	double sx = (double) clientArea.width / (double) imageBounds.width;
	double sy = (double) clientArea.height / (double) imageBounds.height;

	if (!shrinkToFit) {
	    sx = Math.max(sx, 1.0);
	    sy = Math.max(sy, 1.0);
	}
	if (!zoomToFit) {
	    sx = Math.min(sx, 1.0);
	    sy = Math.min(sy, 1.0);
	}
	double s = Math.min(sx, sy);
	double dx = 0.5 * clientArea.width;
	double dy = 0.5 * clientArea.height;
	zoom(dx, dy, s, new AffineTransform());
    }

    /**
     * Perform a zooming operation centered on the given point (dx, dy) and
     * using the given scale factor. The given AffineTransform instance is
     * preconcatenated.
     * 
     * @param dx
     *            center x
     * @param dy
     *            center y
     * @param scale
     *            zoom rate
     * @param af
     *            original affinetransform
     */
    private void zoom(double dx, double dy, double scale, AffineTransform af) {
	af.preConcatenate(AffineTransform.getTranslateInstance(-dx, -dy));
	af.preConcatenate(AffineTransform.getScaleInstance(scale, scale));
	af.preConcatenate(AffineTransform.getTranslateInstance(dx, dy));
	transform = af;
	synchronizeScrollBars();
    }

}
