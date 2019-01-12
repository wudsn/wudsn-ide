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

package com.wudsn.ide.gfx.gui;

import java.awt.geom.AffineTransform;
import java.awt.geom.NoninvertibleTransformException;
import java.awt.geom.Point2D;

import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;

/**
 * Utility for Java2d transform used by{@link ImageCanvas}.
 * 
 * @author Peter Dell
 * @author Chengdong Li: cli4@uky.edu
 * 
 */
final class ImageCanvasUtility {

    /**
     * Creation is private.
     */
    private ImageCanvasUtility() {
    }

    /**
     * Apply an affine transform to an SWT rectangle. The resulting SWT
     * rectangle will have positive width and positive height.
     * 
     * @param affineTransform
     *            The affine transform, not <code>null</code>.
     * @param sourceRectangle
     *            The SWT source rectangle, not <code>null</code>.
     * @return The SWT rectangle after transform with positive width and height,
     *         not <code>null</code>.
     */
    public static Rectangle transformRectangle(AffineTransform affineTransform,
	    Rectangle sourceRectangle) {
	if (affineTransform == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'transform' must not be null.");
	}
	if (sourceRectangle == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'sourceRectangle' must not be null.");
	}
	Rectangle result = new Rectangle(0, 0, 0, 0);
	sourceRectangle = absoluteRectangle(sourceRectangle);
	Point point = new Point(sourceRectangle.x, sourceRectangle.y);
	point = transformPoint(affineTransform, point);
	result.x = point.x;
	result.y = point.y;
	result.width = (int) (sourceRectangle.width * affineTransform
		.getScaleX());
	result.height = (int) (sourceRectangle.height * affineTransform
		.getScaleY());
	return result;
    }

    /**
     * Apply the inverse of an affine transform to an SWT rectangle. The
     * resulting SWT rectangle will have positive width and positive height.
     * 
     * @param affineTransform
     *            The affine transform, not <code>null</code>.
     * @param sourceRectangle
     *            The SWT source rectangle, not <code>null</code>.
     * @return The SWT rectangle after transform with positive width and height,
     *         not <code>null</code>.
     */
    public static Rectangle inverseTransformRectangle(
	    AffineTransform affineTransform, Rectangle sourceRectangle) {
	if (affineTransform == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'transform' must not be null.");
	}
	if (sourceRectangle == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'sourceRectangle' must not be null.");
	}
	Rectangle result = new Rectangle(0, 0, 0, 0);
	sourceRectangle = absoluteRectangle(sourceRectangle);
	Point p1 = new Point(sourceRectangle.x, sourceRectangle.y);
	p1 = inverseTransformPoint(affineTransform, p1);
	result.x = p1.x;
	result.y = p1.y;
	result.width = (int) (sourceRectangle.width / affineTransform
		.getScaleX());
	result.height = (int) (sourceRectangle.height / affineTransform
		.getScaleY());
	return result;
    }

    /**
     * Apply an affine transform to an SWT point.
     * 
     * @param affineTransform
     *            The affine transform, not <code>null</code>.
     * @param sourcePoint
     *            The SWT source point, not <code>null</code>.
     * @return The SWT point after transform, not <code>null</code>.
     */
    public static Point transformPoint(AffineTransform affineTransform,
	    Point sourcePoint) {
	if (affineTransform == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'affineTransform' must not be null.");
	}
	if (sourcePoint == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'sourcePoint' must not be null.");
	}
	Point2D src = new Point2D.Float(sourcePoint.x, sourcePoint.y);
	Point2D dest = affineTransform.transform(src, null);
	Point result = new Point((int) Math.floor(dest.getX()), (int) Math
		.floor(dest.getY()));
	return result;
    }

    /**
     * Apply the inverse of an affine transform to an SWT point.
     * 
     * @param affineTransform
     *            The affine transform, not <code>null</code>.
     * @param sourcePoint
     *            The SWT source point, not <code>null</code>.
     * @return The SWT point after transform, not <code>null</code>.
     */
    public static Point inverseTransformPoint(AffineTransform affineTransform,
	    Point sourcePoint) {

	if (affineTransform == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'affineTransform' must not be null.");
	}
	if (sourcePoint == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'sourcePoint' must not be null.");
	}
	Point2D src = new Point2D.Float(sourcePoint.x, sourcePoint.y);

	Point2D dest;
	try {
	    dest = affineTransform.inverseTransform(src, null);
	} catch (NoninvertibleTransformException ex) {
	    throw new RuntimeException("Invalid transformation", ex);
	}
	Point result = new Point((int) Math.floor(dest.getX()), (int) Math
		.floor(dest.getY()));
	return result;
    }

    /**
     * Given arbitrary SWT rectangle, return a rectangle with upper-left start
     * and positive width and height.
     * 
     * @param sourceRectangle
     *            The SWT source rectangle, not <code>null</code>.
     * @return result The equivalent SWT rectangle with positive width and
     *         height, not <code>null</code>.
     */
    private static Rectangle absoluteRectangle(Rectangle sourceRectangle) {
	if (sourceRectangle == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'sourceRectangle' must not be null.");
	}
	Rectangle result = new Rectangle(0, 0, 0, 0);
	if (sourceRectangle.width < 0) {
	    result.x = sourceRectangle.x + sourceRectangle.width + 1;
	    result.width = -sourceRectangle.width;
	} else {
	    result.x = sourceRectangle.x;
	    result.width = sourceRectangle.width;
	}
	if (sourceRectangle.height < 0) {
	    result.y = sourceRectangle.y + sourceRectangle.height + 1;
	    result.height = -sourceRectangle.height;
	} else {
	    result.y = sourceRectangle.y;
	    result.height = sourceRectangle.height;
	}
	return result;
    }
}
