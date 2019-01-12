package com.wudsn.ide.gfx.converter.atari8bit;

import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Rectangle;

// TODO Class Atari8BitPaletteUtility2 is currently not used
public class Atari8BitPaletteUtility2 {

    private final int PAL_ENTRIES_NO = 256;
    private final int BAR_LINES_NO = 16;
    private final int BAR_ENTRIES_NO = (PAL_ENTRIES_NO / BAR_LINES_NO);

    static class RGB {
	int R, G, B;

	public static RGB FromArgb(int r1, int g1, int b1) {
	    RGB color = new RGB();
	    color.R = r1;
	    color.G = g1;
	    color.B = b1;
	    return color;
	}
    }

    private RGB[] actual_pal = new RGB[PAL_ENTRIES_NO];

    class LAB {
	public double L;
	public double a;
	public double b;
    }

    private LAB[] cielab = new LAB[PAL_ENTRIES_NO];

    private int min_y = 0, max_y = 0xf0;
    private int colintens = 100;
    private int colshift = 30;

    // public int BlackLevel
    // {
    // get { return min_y; }
    // set { min_y = value; CalcPaletteFromSettings(); Highlight =
    // highlightColor; }
    // }
    //
    // public int WhiteLevel
    // {
    // get { return max_y; }
    // set { max_y = value; CalcPaletteFromSettings(); Highlight =
    // highlightColor; }
    // }
    //
    // public int Saturation
    // {
    // get { return colintens; }
    // set { colintens = value; CalcPaletteFromSettings(); Highlight =
    // highlightColor; }
    // }
    //
    // public int ColorShift
    // {
    // get { return colshift; }
    // set { colshift = value; CalcPaletteFromSettings(); Highlight =
    // highlightColor; }
    // }

    private static int[] real_pal = { 0x323132, 0x3f3e3f, 0x4d4c4d, 0x5b5b5b, 0x6a696a, 0x797879, 0x888788, 0x979797,
	    0xa1a0a1, 0xafafaf, 0xbebebe, 0xcecdce, 0xdbdbdb, 0xebeaeb, 0xfafafa, 0xffffff, 0x612e00, 0x6c3b00,
	    0x7a4a00, 0x885800, 0x94670c, 0xa5761b, 0xb2842a, 0xc1943a, 0xca9d43, 0xdaad53, 0xe8bb62, 0xf8cb72,
	    0xffd87f, 0xffe88f, 0xfff79f, 0xffffae, 0x6c2400, 0x773000, 0x844003, 0x924e11, 0x9e5d22, 0xaf6c31,
	    0xbc7b41, 0xcc8a50, 0xd5935b, 0xe4a369, 0xf2b179, 0xffc289, 0xffcf97, 0xffdfa6, 0xffedb5, 0xfffdc4,
	    0x751618, 0x812324, 0x8f3134, 0x9d4043, 0xaa4e50, 0xb85e60, 0xc66d6f, 0xd57d7f, 0xde8787, 0xed9596,
	    0xfca4a5, 0xffb4b5, 0xffc2c4, 0xffd1d3, 0xffe0e1, 0xffeff0, 0x620e71, 0x6e1b7c, 0x7b2a8a, 0x8a3998,
	    0x9647a5, 0xa557b5, 0xb365c3, 0xc375d1, 0xcd7eda, 0xdc8de9, 0xea97f7, 0xf9acff, 0xffbaff, 0xffc9ff,
	    0xffd9ff, 0xffe8ff, 0x560f87, 0x611d90, 0x712c9e, 0x7f3aac, 0x8d48ba, 0x9b58c7, 0xa967d5, 0xb877e5,
	    0xc280ed, 0xd090fc, 0xdf9fff, 0xeeafff, 0xfcbdff, 0xffccff, 0xffdbff, 0xffeaff, 0x461695, 0x5122a0,
	    0x6032ac, 0x6e41bb, 0x7c4fc8, 0x8a5ed6, 0x996de3, 0xa87cf2, 0xb185fb, 0xc095ff, 0xcfa3ff, 0xdfb3ff,
	    0xeec1ff, 0xfcd0ff, 0xffdfff, 0xffefff, 0x212994, 0x2d359f, 0x3d44ad, 0x4b53ba, 0x5961c7, 0x686fd5,
	    0x777ee2, 0x878ef2, 0x9097fa, 0x96a6ff, 0xaeb5ff, 0xbfc4ff, 0xcdd2ff, 0xdae3ff, 0xeaf1ff, 0xfafeff,
	    0x0f3584, 0x1c418d, 0x2c509b, 0x3a5eaa, 0x486cb7, 0x587bc5, 0x678ad2, 0x7699e2, 0x80a2eb, 0x8fb2f9,
	    0x9ec0ff, 0xadd0ff, 0xbdddff, 0xcbecff, 0xdbfcff, 0xeaffff, 0x043f70, 0x114b79, 0x215988, 0x2f6896,
	    0x3e75a4, 0x4d83b2, 0x5c92c1, 0x6ca1d2, 0x74abd9, 0x83bae7, 0x93c9f6, 0xa2d8ff, 0xb1e6ff, 0xc0f5ff,
	    0xd0ffff, 0xdeffff, 0x005918, 0x006526, 0x0f7235, 0x1d8144, 0x2c8e50, 0x3b9d60, 0x4aac6f, 0x59bb7e,
	    0x63c487, 0x72d396, 0x82e2a5, 0x92f1b5, 0x9ffec3, 0xaeffd2, 0xbeffe2, 0xcefff1, 0x075c00, 0x146800,
	    0x227500, 0x328300, 0x3f910b, 0x4fa01b, 0x5eae2a, 0x6ebd3b, 0x77c644, 0x87d553, 0x96e363, 0xa7f373,
	    0xb3fe80, 0xc3ff8f, 0xd3ffa0, 0xe3ffb0, 0x1a5600, 0x286200, 0x367000, 0x457e00, 0x538c00, 0x629b07,
	    0x70a916, 0x80b926, 0x89c22f, 0x99d13e, 0xa8df4d, 0xb7ef5c, 0xc5fc6b, 0xd5ff7b, 0xe3ff8b, 0xf3ff99,
	    0x334b00, 0x405700, 0x4d6500, 0x5d7300, 0x6a8200, 0x7a9100, 0x889e0f, 0x98ae1f, 0xa1b728, 0xbac638,
	    0xbfd548, 0xcee458, 0xdcf266, 0xebff75, 0xfaff85, 0xffff95, 0x4b3c00, 0x584900, 0x655700, 0x746500,
	    0x817400, 0x908307, 0x9f9116, 0xaea126, 0xb7aa2e, 0xc7ba3e, 0xd5c74d, 0xe5d75d, 0xf2e56b, 0xfef47a,
	    0xffff8b, 0xffff9a, 0x602e00, 0x6d3a00, 0x7a4900, 0x895800, 0x95670a, 0xa4761b, 0xb2832a, 0xc2943a,
	    0xcb9d44, 0xdaac53, 0xe8ba62, 0xf8cb73, 0xffd77f, 0xffe791, 0xfff69f, 0xffffaf, };

    private int highlightIndex = -1;

    // public short A8Hue
    // {
    // get { return (short)(highlightIndex >> 4); }
    // }
    //
    // public short A8Saturation
    // {
    // get { return (short)(highlightIndex & 15); }
    // }

    public int CalcHighlightLAB(RGB c) {
	double[] calc = new double[PAL_ENTRIES_NO];
	double l2, a2, b2, m = 0xFFFFFF;
	int i, j = -1;
	LAB lab = new LAB();

	log("Looking for: R=" + c.R + ", G=" + c.G + ", B=" + c.B);
	RGB2LAB(c, lab);
	log("Looking for: L=" + lab.L + ", a=" + lab.a + ", b=" + lab.b);

	for (i = 0; i < PAL_ENTRIES_NO; i++) {
	    l2 = lab.L - cielab[i].L;
	    l2 = l2 * l2;
	    a2 = lab.a - cielab[i].a;
	    a2 = a2 * a2;
	    b2 = lab.b - cielab[i].b;
	    b2 = b2 * b2;
	    calc[i] = l2 + a2 + b2;
	}

	for (i = 0; i < PAL_ENTRIES_NO; i++) {
	    log("Distance to: L=" + cielab[i].L + ", a=" + cielab[i].a + ", b=" + cielab[i].b + " is " + calc[i]);
	    if (calc[i] < m) {
		m = calc[i];
		j = i;
		log(" : New minimum!");
	    } else if (calc[i] == m) {
		log(" : Equal min!");
	    } else {
		log("");
	    }
	}

	log("Closest Color: m=" + m + " (R=" + actual_pal[j].R + ", G=" + actual_pal[j].G + ", B=" + actual_pal[j].B
		+ ")");

	return j;
    }

    public int CalcHighlightRGB(RGB c) {
	long[] calc = new long[PAL_ENTRIES_NO];
	long r2, g2, b2, m = 0xFFFFFF, mg = 0xFFFFFF;
	int i, j = -1, k = -1;

	log("Looking for: R=" + c.R + ", G=" + c.G + ", B=" + c.B);
	for (i = 0; i < PAL_ENTRIES_NO; i++) {
	    // (R-r)*(R-r) + (G-g)*(G-g) + (B-b)*(B-b)
	    r2 = c.R - actual_pal[i].R;
	    r2 = r2 * r2;
	    g2 = c.G - actual_pal[i].G;
	    g2 = g2 * g2;
	    b2 = c.B - actual_pal[i].B;
	    b2 = b2 * b2;
	    // calc[i] = (((512+rm)*r2)>>8) + 4*g2 + (((767-rm)*b2)>>8);
	    calc[i] = (2 * r2) + (4 * g2) + (3 * b2);
	}

	for (i = 0; i < 16; i++) {
	    log("Distance to: R=" + actual_pal[i].R + ", G=" + actual_pal[i].G + ", B=" + actual_pal[i].B + " is "
		    + calc[i]);
	    if (calc[i] < mg) {
		mg = calc[i];
		k = i;
		log(" : New minimum!");
	    } else if (calc[i] == mg) {
		log(" : Equal min!");
	    } else {
		log("");
	    }
	}

	for (i = 16; i < 256; i++) {
	    log("Distance to: R=" + actual_pal[i].R + ", G=" + actual_pal[i].G + ", B=" + actual_pal[i].B + " is "
		    + calc[i]);
	    if (calc[i] < m) {
		m = calc[i];
		j = i;
		log(" : New minimum!");
	    } else if (calc[i] == m) {
		log(" : Equal min!");
	    } else {
		log("");
	    }
	}

	log("Closest Grey: mg=" + mg + " (R=" + actual_pal[k].R + ", G=" + actual_pal[k].G + ", B=" + actual_pal[k].B
		+ ")");
	log("Closest Color: m=" + m + " (R=" + actual_pal[j].R + ", G=" + actual_pal[j].G + ", B=" + actual_pal[j].B
		+ ")");

	return j; // (mg < m) ? k : j;
    }

    private void log(String string) {
	System.out.println(string);

    }

    void CalcPaletteFromSettings() {
	int i, j;
	/* Make an RGB table from computed values */
	for (i = 0; i < 0x10; i++) {
	    int r, b;
	    double angle;

	    if (i == 0) {
		r = b = 0;
	    } else {
		angle = Math.PI * (i * (1.0 / 7) - colshift * 0.01);
		r = (int) (Math.cos(angle) * colintens);
		b = (int) (Math.cos(angle - Math.PI * (2.0 / 3)) * colintens);
	    }
	    for (j = 0; j < 0x10; j++) {
		int y, r1, g1, b1;

		y = (max_y * j + min_y * (0xf - j)) / 0xf;
		r1 = y + r;
		g1 = y - r - b;
		b1 = y + b;
		if (r1 > 0xff)
		    r1 = 0xff;
		if (r1 < 0)
		    r1 = 0;
		if (g1 > 0xff)
		    g1 = 0xff;
		if (g1 < 0)
		    g1 = 0;
		if (b1 > 0xff)
		    b1 = 0xff;
		if (b1 < 0)
		    b1 = 0;
		actual_pal[i * 16 + j] = RGB.FromArgb(r1, g1, b1);
	    }
	}
    }

    public void AssignPalette(int[] new_pal) {
	for (int i = 0; i < actual_pal.length; i++) {
	    int c = new_pal[i];
	    int r = (c >> 16) & 255;
	    int g = (c >> 8) & 255;
	    int b = c & 255;
	    actual_pal[i] = RGB.FromArgb(r, g, b);
	}
	CalcLAB();
    }

    private void RGB2LAB(RGB c, LAB lab) {
	double var_R = c.R / 255.0; // R from 0 to 255
	double var_G = c.G / 255.0; // G from 0 to 255
	double var_B = c.B / 255.0; // B from 0 to 255

	if (var_R > 0.04045)
	    var_R = Math.pow(((var_R + 0.055) / 1.055), 2.4);
	else
	    var_R = var_R / 12.92;
	if (var_G > 0.04045)
	    var_G = Math.pow(((var_G + 0.055) / 1.055), 2.4);
	else
	    var_G = var_G / 12.92;
	if (var_B > 0.04045)
	    var_B = Math.pow(((var_B + 0.055) / 1.055), 2.4);
	else
	    var_B = var_B / 12.92;

	var_R = var_R * 100.0;
	var_G = var_G * 100.0;
	var_B = var_B * 100.0;

	// Observer. = 2°, Illuminant = D65
	double X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805;
	double Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722;
	double Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505;

	double var_X = X / 95.047; // ref_X = 95.047 Observer= 2°, Illuminant=
				   // D65
	double var_Y = Y / 100.000; // ref_Y = 100.000
	double var_Z = Z / 108.883; // ref_Z = 108.883

	if (var_X > 0.008856)
	    var_X = Math.pow(var_X, (1.0 / 3.0));
	else
	    var_X = (7.787 * var_X) + (16.0 / 116.0);
	if (var_Y > 0.008856)
	    var_Y = Math.pow(var_Y, (1.0 / 3.0));
	else
	    var_Y = (7.787 * var_Y) + (16.0 / 116.0);
	if (var_Z > 0.008856)
	    var_Z = Math.pow(var_Z, (1.0 / 3.0));
	else
	    var_Z = (7.787 * var_Z) + (16.0 / 116.0);

	lab.L = (116.0 * var_Y) - 16.0;
	lab.a = 500.0 * (var_X - var_Y);
	lab.b = 200.0 * (var_Y - var_Z);
    }

    private void CalcLAB() {
	for (int i = 0; i < PAL_ENTRIES_NO; i++) {
	    RGB2LAB(actual_pal[i], cielab[i]);
	}
    }

    public Atari8BitPaletteUtility2() {
	AssignPalette(real_pal);
    }

    public void MyColorView_Paint(GC gc) {
	int width = 100;
	int height = 100;

	int nWidth = (width - BAR_ENTRIES_NO) / BAR_ENTRIES_NO;
	int nHeight = (height - BAR_LINES_NO) / BAR_LINES_NO;

	int nOffsetX = (width - (nWidth + 1) * BAR_ENTRIES_NO) / 3 + 1;
	int nOffsetY = (height - (nHeight + 1) * BAR_LINES_NO) / 3 + 1;

	for (int i = 0; i < BAR_LINES_NO; i++) {
	    for (int j = 0; j < BAR_ENTRIES_NO; j++) {
		int offset = i * BAR_ENTRIES_NO + j;
		Rectangle rect = new Rectangle(nOffsetX + j * nWidth + j, nOffsetY + i * nHeight + i, nWidth, nHeight);
		// gc.setForeground(actual_pal[offset]);
		gc.fillRectangle(rect);

		if (offset == highlightIndex) {
		    rect = new Rectangle(rect.x - 1, rect.y - 1, rect.width + 1, rect.height + 1);
		    // gc.setForeground(Color.BLACK);
		    gc.fillRectangle(rect);
		}
	    }
	}
    }
}
