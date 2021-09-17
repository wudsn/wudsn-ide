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

/**
 * Square block of character which shall be inverse
 * 
 * @author Peter Dell
 */
public final class InverseBlock {

	private int column1;
	private int column2;
	private int row1;
	private int row2;
	private Integer inverseColor;
	private boolean inverseIfConflict;

	InverseBlock(int column1, int column2, int row1, int row2, Integer inverseColor, boolean inverseIfConflict) {
		this.column1 = column1;
		this.column2 = column2;
		this.row1 = row1;
		this.row2 = row2;
		this.inverseColor = inverseColor;
		this.inverseIfConflict = inverseIfConflict;

	}

	public int getColumn1() {
		return column1;
	}

	public int getColumn2() {
		return column2;
	}

	public int getRow1() {
		return row1;
	}

	public int getRow2() {
		return row2;
	}

	public Integer getInverseColor() {
		return inverseColor;
	}

	public boolean isInverseIfConflict() {
		return inverseIfConflict;
	}
}
