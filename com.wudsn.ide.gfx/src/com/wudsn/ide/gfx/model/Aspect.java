/**
 * Copyright (C) 2009 - 2020 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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
package com.wudsn.ide.gfx.model;

public final class Aspect {

    private int factorX;
    private int factorY;

    public Aspect(int factorX, int factorY) {
	this.factorX = factorX;
	this.factorY = factorY;
    }

    public int getFactorX() {
	return factorX;
    }

    public int getFactorY() {
	return factorY;
    }

    public int getValidFactorX() {
	if (isValid()) {
	    return factorX;
	}
	return 1;
    }

    public int getValidFactorY() {
	if (isValid()) {
	    return factorY;
	}
	return 1;
    }

    public boolean isValid() {
	return factorX > 0 && factorX < 32 && factorY > 0 && factorY < 32;
    }

    @Override
    public boolean equals(Object obj) {

	if (obj instanceof Aspect) {
	    Aspect aspect;
	    aspect = (Aspect) obj;
	    if (aspect.getFactorX() == factorX && aspect.getFactorY() == factorY) {
		return true;
	    }
	}
	return false;
    }

    @Override
    public int hashCode() {

	return factorX + 17 * factorY;
    }

    @Override
    public String toString() {
	return factorX + "x" + factorY;
    }

}
