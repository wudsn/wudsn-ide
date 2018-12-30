/**
* Copyright (C) 2009 - 2014 <a href="http://www.wudsn.com" target="_top">Peter Dell</a>
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

import java.util.ArrayList;
import java.util.List;

/**
 * List of square blocks of character which shall be inverse
 * 
 * @author Peter Dell
 */
public final class InverseBlockList {

    private List<InverseBlock> inverseBlocks;

    /**
     * Creates an empty inverse block list.
     */
    public InverseBlockList() {
	inverseBlocks = new ArrayList<InverseBlock>();
    }

    /**
     * Adds a new inverse block to the list.
     * 
     * @param column1
     *            Start column, a non-negative integer
     * @param column2
     *            End column, a non-negative integer
     * @param row1
     *            Start row, a non-negative integer
     * @param row2
     *            End row, a non-negative integer
     * @param inverseColor
     *            The pixel color value which shall be used as inverse color
     * @param inverseIfConflict
     *            <code>true</code> if the inverse color shall also be used in
     *            case of conflict
     */
    public void add(int column1, int column2, int row1, int row2,
	    Integer inverseColor, boolean inverseIfConflict) {
	inverseBlocks.add(new InverseBlock(column1, column2, row1, row2,
		inverseColor, inverseIfConflict));
    }

    /**
     * Get the inverse block at The sequence in which the blocks were added
     * determines, the sequence in which the method checks for matches.
     * 
     * @param column
     *            The column, a non-negative integer.
     * @param row
     *            The column, a non-negative integer.
     * @return The first matching inverse block, or <code>null</code> if no
     *         inverse block matches.
     */
    public InverseBlock getInverseBlock(int column, int row) {

	for (InverseBlock inverseBlock : inverseBlocks) {
	    if (inverseBlock.getColumn1() <= column
		    && column <= inverseBlock.getColumn2()
		    && inverseBlock.getRow1() <= row
		    && row <= inverseBlock.getRow2()) {
		return inverseBlock;
	    }
	}
	return null;
    }

}
