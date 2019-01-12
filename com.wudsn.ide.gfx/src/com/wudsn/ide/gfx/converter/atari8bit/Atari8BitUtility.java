package com.wudsn.ide.gfx.converter.atari8bit;

/**
 * Copyright (C) 2009 - 2014 <a href="http://www.wudsn.com" target="_top">Peter
 * Dell</a>
 * 
 * This file is part of WUDSN IDE.
 * 
 * WUDSN IDE is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version.
 * 
 * WUDSN IDE is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * WUDSN IDE. If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Utility class for Atari 8-bit specifics.
 * 
 * @since 1.6.0
 */
public final class Atari8BitUtility {

    /**
     * Mapping of the 4 bit pixel values to the corresponding color register.
     * Make sure not to modify contents of this array.
     */
    public final static int[] GRAPHICS_10_REGISTERS = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 8, 8, 8, 4, 5, 6, 7 };

    /**
     * Creation is private.
     * 
     * @since 1.6.0
     */
    private Atari8BitUtility() {

    }

    /**
     * Gets a word stored lo/hi order.
     * 
     * @param bytes
     *            The byte array, not empty and not <code>null</code>.
     * @param offset
     *            The offset within the byte array, a non-negative integer.
     * @return The length of the block header, a non-negative integer.
     * 
     * @since 1.6.0
     */
    public static int getWord(byte[] bytes, int offset) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	return (bytes[offset] & 0xff) | ((bytes[offset + 1] & 0xff) << 8);
    }

    /**
     * Gets the length of a binary COM block header within a byte array.
     * 
     * @param bytes
     *            The byte array, may be empty, not <code>null</code>.
     * @param offset
     *            The offset within the byte array, a non-negative integer.
     * @return The length of the block header or <code>-1</code> if there is no
     *         valid block at the given offset.
     * 
     * @since 1.6.0
     */
    public static int getLengthFromBinaryHeader(byte[] bytes, int offset) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	if (offset < 0) {
	    throw new IllegalArgumentException("Parameter 'offset' must not be negative, specified value is " + offset
		    + ".");
	}
	if (bytes.length >= offset + 6 && (bytes[offset + 0] & 0xff) == 0xff && (bytes[offset + 1] & 0xff) == 0xff) {
	    int startAddress = getWord(bytes, offset + 2);
	    int endAddress = getWord(bytes, offset + 4);
	    int length = endAddress - startAddress + 1;
	    return length;
	}
	return -1;
    }

    /**
     * Unpack a Koala Painter compressed picture.
     * 
     * @param data
     *            The byte array with the packed data, may be empty, not
     *            <code>null</code>.
     * @param dataOffset
     *            The offset within data to start unpacking, a non-negative
     *            integer.
     * @param dataLength
     *            The length of the data to be unpacked, a positive integer.
     * @param cprtype
     *            The CPR packing type, either 0,1 or 2.
     * @param unpackedData
     *            The byte array for the unpack data, must be 7680 bytes long.
     * @return <code>true</code> if the data was unpacked successfully,
     *         <code>false</code> otherwise.
     * 
     * @since 1.6.0
     */
    public static boolean unpackKoala(byte[] data, int dataOffset, int dataLength, int cprtype, byte[] unpackedData) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	if (dataOffset < 0) {
	    throw new IllegalArgumentException("Parameter 'dataOffset' must not be negative. Specified value is "
		    + dataOffset + ".");
	}
	if (dataLength < 1) {
	    throw new IllegalArgumentException("Parameter 'dataLength' must be positive. Specified value is "
		    + dataLength + ".");
	}
	int i;
	int d;
	switch (cprtype) {
	case 0:
	    if (dataLength != 7680) {
		return false;
	    }
	    System.arraycopy(data, dataOffset, unpackedData, 0, 7680);
	    return true;
	case 1:
	case 2:
	    break;
	default:
	    return false;
	}

	i = 0;
	d = dataOffset;
	int dataEnd = d + dataLength;
	for (;;) {
	    int c;
	    int len;
	    int b;
	    c = data[d++] & 0xff;
	    if (d > dataEnd) {
		return false;
	    }
	    len = c & 0x7f;
	    if (len == 0) {
		int h;
		h = data[d++] & 0xff;
		if (d > dataEnd) {
		    return false;
		}
		len = data[d++] & 0xff;

		if (d > dataEnd) {
		    return false;
		}
		len += h << 8;
		if (len == 0) {
		    return false;
		}
	    }

	    b = -1;
	    do {
		/*
		 * get byte of uncompressed block or if starting RLE block
		 */
		if (c >= 0x80 || b < 0) {
		    b = data[d++] & 0xff;
		    if (d > dataEnd) {
			return false;
		    }
		}
		unpackedData[i] = (byte) b;
		/* return if last byte written */
		if (i >= 7679) {
		    return true;
		}
		if (cprtype == 2) {
		    i++;
		} else {
		    i += 80;
		    if (i >= 7680) {
			/*
			 * if in line 192, back to odd lines in the same column;
			 * if in line 193, go to even lines in the next column
			 */
			i -= (i < 7720) ? 191 * 40 : 193 * 40 - 1;
		    }
		}
	    } while (--len > 0);
	}
    }

    /**
     * Unpack a compressed CIN picture.
     * 
     * @param data
     *            The byte array with the packed data, may be empty, not
     *            <code>null</code>.
     * @param dataOffset
     *            The offset within data to start unpacking, a non-negative
     *            integer.
     * @param dataLength
     *            The length of the data to be unpacked, a positive integer.
     * @param step
     *            The number of "columns", a non-negative integer.
     * @param count
     *            The number of "lines", a non-negative integer.
     * @param unpackedData
     *            The byte array for the unpack data, must be 7680 bytes long.
     * @param unpackedDataOffset
     *            The offset within unpackedData to start unpacking, a
     *            non-negative integer.
     * @return <code>true</code> if the data was unpacked successfully,
     *         <code>false</code> otherwise.
     * 
     * @since 1.6.0
     */
    public static boolean unpackCCI(byte data[], int dataOffset, int dataLength, int step, int count,
	    byte unpackedData[], int unpackedDataOffset) {
	int i = 0;
	int d = 2;
	int size = step * count;
	int block_count = getWord(data, dataOffset);
	while (block_count > 0) {
	    int c;
	    int len;
	    int b;
	    if (d > dataLength) {
		return false;
	    }
	    c = data[dataOffset + d++] & 0xff;
	    len = (c & 0x7f) + 1;
	    b = -1;
	    do {
		/*
		 * get byte if uncompressed block or if starting RLE block
		 */
		if (c < 0x80 || b < 0) {
		    if (d > dataLength) {
			return false;
		    }
		    b = data[dataOffset + d++] & 0xff;
		}
		unpackedData[unpackedDataOffset + i] = (byte) b;
		/* return if last byte written */
		if (i >= size - 1) {
		    return true;
		}
		i += step;
		if (i >= size) {
		    i -= size - 1;
		}
	    } while (--len > 0);
	    block_count--;
	}
	if (d == dataLength) {
	    return true;
	}
	return false;
    }

    /**
     * Determines if a byte array represents a valid Atari charset.
     * 
     * @param bytes
     *            The byte array, may be empty, not <code>null</code>.
     * @return <code>true</code> if the byte array represents a valid Atari
     *         charset, <code>false</code> otherwise.
     * 
     * @since 1.6.0
     */
    public static boolean isAtariCharset(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	return bytes.length == 1024
		|| (bytes.length == 1024 + 6 && Atari8BitUtility.getLengthFromBinaryHeader(bytes, 0) == 1024);
    }

}
