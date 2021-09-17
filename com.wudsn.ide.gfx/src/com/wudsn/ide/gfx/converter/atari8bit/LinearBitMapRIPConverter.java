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

package com.wudsn.ide.gfx.converter.atari8bit;

import com.wudsn.ide.gfx.converter.FilesConverterData;
import com.wudsn.ide.gfx.converter.PaletteMapper;
import com.wudsn.ide.gfx.converter.generic.LinearBitMapConverter;
import com.wudsn.ide.gfx.model.Palette;
import com.wudsn.ide.gfx.model.RBGUtility;

/**
 * <u>RIP picture format description</u><br/>
 * 
 * Original text by Rocky of Madteam taken from Syzygy Magazine <br/>
 * RIP picture was shown first time in Orneta of Poland in '97 in Igor demo by
 * Madteam. There we copied several disks of RIP images. RIP is a new graphics
 * storage format on Atari 8-bit. It is based on already famous HIP picture
 * format (Gr.9 + Gr.10). Theoretically it is possible to get 144 colors (there
 * are about 40 in practice) with resolution of 160x238 (RIP mode 32; 16 lum x 9
 * col). RIP is more complicated than HIP, because of the header which contains
 * a lot of information about colors, resolution and a note from the author. RIP
 * can have various vertical sizes (max. 238 lines) which cause less space on
 * disk and faster reading. <br/>
 * <br/>
 * 
 * (E.g. we have a logo with 50 lines. Our logo will be saved with 200 lines as
 * HIP and takes about 16kB but saved as RIP - only 4kB plus several bytes of
 * header. That's a difference, isn't it?) In addition RIP can be colored and
 * HIP can only be grey scaled. (HIP can also be colored but there is no room
 * for color info in the header.) The first one can still be packed (algorithm
 * in end phase) for RIP dedicated Visage viewer which is able to recognize its
 * size, colors, compression method and displaying on screen. Saving HIP as RIP
 * is no problem 'couse of similar data format. Adapting existing HIP viewers
 * for RIP pictures shouldn't be problematic too; Only what has to be done is
 * format recognition, displaying of various image height and setting colors
 * (for Gr.10) from the header (see below). <br/>
 * <br/>
 * 
 * <u>How to make a RIP picture?</u><br/>
 * 
 * It can be quite difficult. There is a converter for Amiga and PC. This is not
 * a real converter from any graphics format (GIF, IFF or Jpeg) to RIP. To make
 * a RIP picture, you will have to use programs not only dedicated to RIP. The
 * best for Amiga is Personal Paint and for PC - Display. It's quite a large
 * job. One picture has to be divided into two others. Next: size modification,
 * color palette reduction (one of these two pictures has to be 16 grey scales
 * what can be done with almost all programs and the other picture has to be in
 * 9 colors, what most programs for the Amiga and PC simply cannot do). The
 * effect can be very satisfactory, but it might also be completely bad, which
 * happens quite often (none of the pics is perfect). You can then always create
 * a HIP picture, which is better in this case (grey scale is easier to do) but
 * you will be limited to 200 lines. Well, life is brutal... <br/>
 * <br/>
 * <u>Header description:</u><br/>
 * In 'Description' filed text with quotes (") is pure ASCII string.
 * 
 * <pre>
 *  Offset | Len | Description
 * --------------------------------------------
 *       0 |  3  | "RIP" - RIP image identifier
 *       3 |  4  | version:
 *         |     |         "1.x " - standard RIP
 *         |     |         "2.0 " - Multi RIP
 *       7 |  1  | graphics mode:
 *         |     |         $20 - RIP or HIP
 *         |     |         $30 - Multi RIP, palette at the end of file
 *         |     |         $0f - Graphics  8
 *         |     |         $4f - Graphics  9
 *         |     |         $8f - Graphics 10
 *         |     |         $cf - Graphics 11
 *         |     |         $0e - Graphics 15
 *       8 |  2  | compression method:
 *         |     |         0, 0 - no compress
 *         |     |         0, 1 - RIPPCK
 *      10 |  2  | header length in bytes, MSB/LSB !!!
 *      12 |  1  | not used
 *      13 |  1  | image width in pixels (max. 80)     *see below
 *      14 |  1  | not used
 *      15 |  1  | image height in lines (max. 238)
 *      16 |  1  | display option (?), standard set to $20
 *      17 |  1  | author note length in bytes (max. 256)
 *      18 |  2  | "T:" - text identifier
 *      20 |  n  | author note
 *    20+n |  1  | number of colors (fixed = 9 from Gr.10)
 *    21+n |  3  | "CM:" - color map identifier
 *    24+n |  9  | color values                        **see below
 *    33+n |  3  | "PCK" - Multi RIP packed file only, means packed
 *         |     |         images data
 * </pre>
 * 
 * Directly after header images data are stored. First Gr.10, next Gr.9.
 * 
 * HIP and RIP are 80 pixels wide pictures with shifted 9-color plan (Gr.10)
 * relativelly to 16-grey shaded plan (Gr.9) for half pixel right. Thus, they
 * appear as 160x200, but one pic has only 80x200;
 * 
 * Number of colors is fixed to 9 now but it may change. So, take number of
 * colors from 20+n byte of header (n - length of author note) for safety. (RIP
 * mode 48 has more colors !!)
 * 
 * Displaying RIP "1.x" picture routine is similar to HIP routine. The only
 * difference is to set color registers with values put behind "CM:" while Gr.10
 * line.
 * 
 * Information above is enough for writing own procedure showing RIP 1.x
 * picture. For now I don't have any info about Multi RIP especially for
 * compression algorithm and color palette. The only thing I know for sure is
 * the palette should be changed every 2 scanlines. Maybe someone else knows a
 * little bit more about Multi RIP (or RIP mode 48 with many more colors than
 * mode 32)...
 * 
 * Note: This implementation is based on FAIL 1.0.1 and allows 239 lines tough
 * the specification above states 238 as the maximum.
 */
// TODO Verify against FAIL 1.0.2, check if the spurious grey spot and bugs are
// gone
public class LinearBitMapRIPConverter extends LinearBitMapConverter {

	private final static class RIPFile {
		public static final byte RIP = 0x20;
		public static final byte MULTI_RIP = 0x30;

		private int graphicsMode;
		private int width;
		private int height;
		private int[] palette;
		private byte[] unpackedImage;

		private RIPFile(int graphicsMode, int width, int height, int[] palette, byte[] unpacked_image) {
			this.graphicsMode = graphicsMode;
			this.width = width;
			this.height = height;
			this.palette = palette;
			this.unpackedImage = unpacked_image;

		}

		public static RIPFile createInstance(byte[] bytes) {
			if (bytes == null) {
				throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
			}
			if (bytes.length < 23) {
				return null;
			}
			int graphicsMode = bytes[7];
			int headerLength = (bytes[11] & 0xff) + 256 * (bytes[12] & 0xff);
			int width = bytes[13] & 0xff;
			int height = bytes[15] & 0xff;
			int textLength = bytes[17] & 0xff;
			if (bytes.length < 20 + textLength) {
				return null;
			}
			int paletteLength = bytes[20 + textLength] & 0xff;
			int dataLength = bytes.length - headerLength;

			if (bytes[0] != 'R' || bytes[1] != 'I' || bytes[2] != 'P' || width > 80 || height > 239 || textLength > 152
					|| bytes[18] != 'T' || bytes[19] != ':' || paletteLength != 9 || bytes[21 + textLength] != 'C'
					|| bytes[22 + textLength] != 'M' || bytes[23 + textLength] != ':') {
				return null;
			}

			byte[] unpackedImage = new byte[24576];

			// Check compression mode.
			switch (bytes[9]) {
			case 0:
				// No compression.
				if (dataLength > unpackedImage.length) {
					return null;
				}
				System.arraycopy(bytes, headerLength, unpackedImage, 0, dataLength);
				break;

			// Compression
			case 1:
				if (!ShannonFano.unpack(bytes, headerLength, dataLength, unpackedImage)) {
					return null;
				}
				break;

			default:
				return null;
			}

			// Check graphic mode
			switch (graphicsMode) {
			case RIP:
				break;
			case MULTI_RIP:
				int frame_len = (width / 2) * height;
				for (int y = 0; y < height; y++) {
					for (int x = 0; x < 8; x++) {
						int ix = 2 * frame_len + y * 8 + x;
						if (y > 0 && unpackedImage[ix] == 0)
							unpackedImage[ix] = unpackedImage[ix - 8];
					}
				}
				break;
			default:
				return null;
			}

			int[] palette = new int[paletteLength];
			for (int i = 0; i < paletteLength; i++) {
				palette[i] = bytes[24 + textLength + i] & 0xff;
			}
			RIPFile result = new RIPFile(graphicsMode, width, height, palette, unpackedImage);
			return result;
		}

		public int getGraphicsMode() {
			return graphicsMode;
		}

		public int getWidth() {
			return width;
		}

		public int getHeight() {
			return height;
		}

		public int[] getPalette() {
			return palette;
		}

		public byte[] getUnpackedImage() {
			return unpackedImage;
		}

	}

	private static final class ShannonFano {

		private static void unpack_cnibl(byte data[], int dataOffset, int size, int output[]) {
			int x = dataOffset;
			int y = 0;
			while (y < size) {
				int a = data[x++] & 0xff;
				output[y++] = a >>> 4;
				output[y++] = a & 0x0f;
			}
		}

		private static void unpack_sort(byte data[], int dataOffset, int size, int tre01[], int tre02[]) {
			int[] pom = new int[16];
			int y;
			int x;
			int md_ = 0;
			int md = 0;

			unpack_cnibl(data, dataOffset, size, tre02);

			for (y = 0; y < size; y++) {
				pom[tre02[y]]++;
			}

			x = 0;
			do {
				y = 0;
				do {
					if (x == tre02[y]) {
						tre01[md_++] = y;
					}
					y++;
				} while (y < size);
				x++;
			} while (x < 16);

			x = 0;
			do {
				y = pom[x];
				while (y != 0) {
					tre02[md++] = x;
					y--;
				}
				x++;
			} while (x < 16);
		}

		private static void unpack_fano(byte data[], int dataOffset, int size, int tre01[], int tre02[], int l0[],
				int h0[], int l1[], int h1[], int lhOffset) {
			int p;
			int err;
			int l;
			int nxt;
			int y;

			unpack_sort(data, dataOffset, size, tre01, tre02);

			clearMemory(l0, lhOffset, size);
			clearMemory(l1, lhOffset, size);
			clearMemory(h0, lhOffset, size);
			clearMemory(h1, lhOffset, size);

			p = 0;
			err = 0;
			l = 0;
			nxt = 0;
			y = 0;
			do {
				if (tre02[y] != 0) {
					int x;
					int tmp;
					int val;
					int a;
					p += err;
					x = tre02[y];
					if (x != l) {
						l = x;
						err = 0x10000 >>> x;
					}
					tmp = p;
					val = tre01[y];
					x = tre02[y];
					a = 0;
					for (;;) {
						int z = lhOffset + a;
						x--;
						tmp <<= 1;
						if (tmp < 0x10000) {
							if (x == 0) {
								a = val;
								l0[z] = a;
								break;
							}
							a = h0[z];
							if (a == 0) {
								a = ++nxt;
								h0[z] = a;
							}
						} else {
							tmp &= 0xFFFF;
							if (x == 0) {
								a = val;
								l1[z] = a;
								break;
							}
							a = h1[z];
							if (a == 0) {
								a = ++nxt;
								h1[z] = a;
							}
						}
					}
				}
				y++;
			} while (y < size);
		}

		private static void clearMemory(int[] array, int offset, int size) {
			for (int i = 0; i < size; i++) {
				array[offset + i] = 0;
			}

		}

		public static boolean unpack(byte data[], int dataOffset, int dataLength, byte unpackedData[]) {
			if (data == null) {
				throw new IllegalArgumentException("Parameter 'data' must not be null.");
			}
			if (dataOffset < 0) {
				throw new IllegalArgumentException(
						"Parameter 'dataOffset' must not be negative, specified value is " + dataOffset + ".");
			}
			if (unpackedData == null) {
				throw new IllegalArgumentException("Parameter 'unpackedData' must not be null.");
			}
			int[] adl0 = new int[576];
			int[] adh0 = new int[576];
			int[] adl1 = new int[576];
			int[] adh1 = new int[576];

			int[] tre01 = new int[256];
			int[] tre02 = new int[256];

			int unpacked_len;
			int sx, sxend;
			int cx, dx;
			int lic, csh, c;

			// "PCK" header (16 bytes) + 288 bytes shannon-fano
			if (dataLength < 16 + 288 || data[dataOffset + 0] != 'P' || data[dataOffset + 1] != 'C'
					|| data[dataOffset + 2] != 'K') {
				return false;
			}

			unpacked_len = (data[dataOffset + 4] & 0xff) + 256 * (data[dataOffset + 5] & 0xff) - 33;
			if (unpacked_len > 0x5EFE) {
				return false;
			}

			// Buggy pictures?!
			if (unpacked_len == 16811) {
				unpacked_len = 16800;
			}

			unpack_fano(data, dataOffset + 16, 64, tre01, tre02, adl0, adh0, adl1, adh1, 0);
			unpack_fano(data, dataOffset + 16 + 32, 256, tre01, tre02, adl0, adh0, adl1, adh1, 64);
			unpack_fano(data, dataOffset + 16 + 160, 256, tre01, tre02, adl0, adh0, adl1, adh1, 320);

			sx = dataOffset + 16 + 288;
			sxend = dataOffset + dataLength + 1;

			dx = 0;
			lic = -1;
			csh = 0;

			do {
				// GBIT();
				if (--lic < 0) {
					if (sx >= sxend) {
						return false;
					}
					csh = data[sx++] & 0xff;
					lic = 7;
				}
				c = (csh & (1 << lic));

				if (c == 0) {
					int a = 0;
					for (;;) {
						int y = a;

						// GBIT();
						if (--lic < 0) {
							if (sx >= sxend) {
								return false;
							}
							csh = data[sx++] & 0xff;
							lic = 7;
						}
						c = (csh & (1 << lic));

						if (c == 0) {
							if ((a = adh0[320 + y]) == 0) {
								unpackedData[dx] = (byte) adl0[320 + y];
								break;
							}
						} else {
							if ((a = adh1[320 + y]) == 0) {
								unpackedData[dx] = (byte) adl1[320 + y];
								break;
							}
						}
					}
					++dx;
				} else {
					int a = 0;
					for (;;) {
						int y = a;

						// GBIT();
						if (--lic < 0) {
							if (sx >= sxend) {
								return false;
							}
							csh = data[sx++] & 0xff;
							lic = 7;
						}
						c = (csh & (1 << lic));

						if (c == 0) {
							if ((a = adh0[64 + y]) == 0) {
								a = adl0[64 + y];
								break;
							}
						} else {
							if ((a = adh1[64 + y]) == 0) {
								a = adl1[64 + y];
								break;
							}
						}
					}
					cx = dx - (a + 2);
					a = 0;
					for (;;) {
						int y = a;

						// GBIT();
						if (--lic < 0) {
							if (sx >= sxend) {
								return false;
							}
							csh = data[sx++] & 0xff;
							lic = 7;
						}
						c = (csh & (1 << lic));

						if (c == 0) {
							if ((a = adh0[y]) == 0) {
								a = adl0[y];
								break;
							}
						} else {
							if ((a = adh1[y]) == 0) {
								a = adl1[y];
								break;
							}
						}
					}

					if (cx > 0) {
						System.arraycopy(unpackedData, cx, unpackedData, dx, a + 2);
					}
					dx += a + 2;
				}
			} while (dx < unpacked_len);

			return true;
		}
	}

	public LinearBitMapRIPConverter() {

	}

	@Override
	public boolean canConvertToImage(byte[] bytes) {
		if (bytes == null) {
			throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
		}

		RIPFile ripFile = RIPFile.createInstance(bytes);
		if (ripFile == null) {
			return false;
		}
		return true;
	}

	@Override
	public void convertToImageSizeAndPalette(FilesConverterData data, byte[] bytes) {
		if (data == null) {
			throw new IllegalArgumentException("Parameter 'data' must not be null.");
		}
		if (bytes == null) {
			throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
		}

		RIPFile ripFile = RIPFile.createInstance(bytes);
		if (ripFile == null) {
			throw new IllegalStateException("canConvertToImage() not called");
		}

		int columns;
		int rows;
		columns = (ripFile.getWidth() + 1) / 2;
		rows = ripFile.getHeight();

		setImageSizeAndPalette(data, columns, rows, Palette.TRUE_COLOR, null);
	}

	@Override
	public void convertToImageDataSize(FilesConverterData data) {
		data.setImageDataWidth(data.getParameters().getColumns() * 4 + 1);
		data.setImageDataHeight(data.getParameters().getRows());
	}

	@Override
	public boolean convertToImageData(FilesConverterData data) {
		if (data == null) {
			throw new IllegalArgumentException("Parameter 'data' must not be null.");
		}

		int rows = data.getParameters().getRows();
		int columns = data.getParameters().getColumns();
		PaletteMapper paletteMapper = new Atari8BitPaletteMapper();

		// Compute palette.
		RIPFile ripFile = RIPFile.createInstance(data.getSourceFileBytes(BIT_MAP_FILE));
		if (ripFile == null) {
			return false;
		}

		byte[] unpackedImage = ripFile.getUnpackedImage();
		int[] graphics10Colors;
		switch (ripFile.getGraphicsMode()) {
		case RIPFile.RIP:
			graphics10Colors = ripFile.getPalette();
			break;
		case RIPFile.MULTI_RIP:
			graphics10Colors = new int[ripFile.getPalette().length];
			break;
		default:
			throw new IllegalStateException("Unsupported graphics mode " + ripFile.getGraphicsMode() + ".");

		}

		// Compute the offsets in the file.
		int offset9, offset10;
		int frameSize = rows * columns;
		offset10 = 0;
		offset9 = offset10 + frameSize;

		int[] buffer1 = new int[columns * 4 + 1];
		int[] buffer2 = new int[columns * 4 + 1];
		for (int y1 = 0; y1 < rows; y1++) {

			// MultiRIP mode?
			if (ripFile.getGraphicsMode() == RIPFile.MULTI_RIP) {
				int offset = frameSize * 2 + ((y1 >>> 1) << 3);
				for (int i = 0; i < graphics10Colors.length - 1; i++) {
					graphics10Colors[i + 1] = unpackedImage[offset + i] & 0xff;
				}
			}

			for (int x1 = 0; x1 < columns; x1++) {
				if (offset9 >= unpackedImage.length) {
					return true;
				}
				int byte9 = unpackedImage[offset9++];
				if (offset10 >= unpackedImage.length) {
					return true;
				}
				int byte10 = unpackedImage[offset10++];

				// Byte 1 is the GTIA 9 byte, take the values as brightness
				// values
				int color1 = (byte9 & mask_4bit[0]) >>> shift_4bit[0];
				int color2 = (byte9 & mask_4bit[1]) >>> shift_4bit[1];

				// Byte 2 is the GTIA 10 byte, take the values from the GTIA 10
				// palette
				int color3 = (byte10 & mask_4bit[0]) >>> shift_4bit[0];
				int color4 = (byte10 & mask_4bit[1]) >>> shift_4bit[1];
				color3 = graphics10Colors[Atari8BitUtility.GRAPHICS_10_REGISTERS[color3]];
				color4 = graphics10Colors[Atari8BitUtility.GRAPHICS_10_REGISTERS[color4]];

				// Put the color values in the row buffer, shifted by 1 pixel
				int x = x1 << 2;
				buffer1[x + 0] = color1;
				buffer1[x + 1] = color1;
				buffer1[x + 2] = color2;
				buffer1[x + 3] = color2;

				buffer2[x + 1] = color3;
				buffer2[x + 2] = color3;
				buffer2[x + 3] = color4;
				buffer2[x + 4] = color4;
			}

			// Merge the two buffers into combined color values.
			for (int x = 0; x < buffer1.length; x++) {
				int atariColor = RBGUtility.combineRGBColor(paletteMapper.getRGBColor(buffer1[x]),
						paletteMapper.getRGBColor(buffer2[x]));
				data.setDirectPixel(x, y1, atariColor);
			}
		}
		return true;

	}
}
