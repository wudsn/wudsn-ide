package libsidplay.components.mos656x;

import java.util.HashMap;
import java.util.Map;

/**
 * <p>
 * Generates PAL VIC colors from first principles. The VIC colors are
 * constructed on a YUV color wheel at certain luminance levels that depend on
 * precise chip revision, and at certain fixed angles in the UV plane, which are
 * fixed for all chips. Additionally, several effects observed on true PAL
 * systems are emulated.
 * 
 * <ol>
 * <li>
 * The construction of the S-video signal reduces bandwidth of both luminance
 * and chrominance. This is achieved by filtering these components in the
 * horizontal direction. The luminance component is modified in order to allow
 * dot-creep or black bleed like effects by shifting the filter kernel at bright
 * colors towards right.
 * 
 * <li>
 * PAL encoding which the VIC implements only partially and which causes color
 * blending effects: the U and V components of succeeding lines become in effect
 * averaged by the monitor's PAL decoder, because in PAL the color is encoded as
 * difference to the previous line's color, but VIC keeps no memory of the color
 * angles it generated for the preceding line.
 * 
 * <li>
 * The imperfect generation of the color angles for the odd lines. The color
 * wheel should be inverted between each row to allow difference encoding, but
 * in practice the odd rows are not rotated perfectly.
 * 
 * <li>
 * Color saturation for every second line is allowed to vary subtly.
 * </ol>
 * 
 * <p>
 * To implement these effects, U and V are simply averaged within each 3x2 pixel
 * block, and Y is filtered according to a gaussian at the top row's 3x1 pixel
 * block.
 * 
 * <p>
 * To do this, helper tables are constructed which describe the filtered colors
 * and luminances in the 3x1 block, and another helper table that can quickly
 * look up averages between succeeding rows to achieve the full 3x2 filter. The
 * YUV colors are converted to RGB colors on the second conversion.
 * 
 * <p>
 * To keep table sizes small, the pal emulation works on a 128 color palette per
 * line. Any 3 pixel block is reduced to a single color on a 128-color palette,
 * and two such colors (from current line and preceding line) are put side by
 * side and used as index to look up the final color.
 * 
 * <p>
 * Since odd and even rows have slightly different colors, the colors 0..127 are
 * assigned for even rows and colors 128..255 for odd rows. They are treated
 * independently at the color generation and quantization procedure. The highest
 * bit of the current row's generated color is used to identify odd/even rows.
 * 
 * @author alankila
 */

@SuppressWarnings({ "javadoc", "boxing" })
public class Palette {
    /* YUV generation defaults */
    private float saturation = 0.5f;
    private float phaseShift = -15f;
    private float offset = 0.9f;
    private float tint = 0f;
    /** Gauss parameter C for luminance spread */
    private float luminanceC = 0.5f;
    private float dotCreep = 0.5f;

    /* YUV -> RGB conversion parameters */
    private float brightness = 0f;
    private float contrast = 1f;
    private float gamma = 2.0f;

    /**
     * The nominal PAL gamma is 2.8. However, there is some disagreement with
     * what the value really is. 2.8 makes bright colors painfully bright. Many
     * emulators have chosen 2.5. I will follow suit to not appear too
     * different.
     */
    private static final float NOMINAL_PAL_GAMMA = 2.5f;

    /**
     * This tunable is used to trade between the reproduced accuracy of rarely
     * used colors to the accuracy of common blends. 256 colors per line are
     * nowhere near enough, so this kind of tunable is surprisingly necessary.
     */
    private static final int PALETTE_PURITY = 256;

    /* Official C64 color angles (degrees) */
    private static final float ANGLE_RED = 112.5f;
    private static final float ANGLE_GRN = -135.0f;
    private static final float ANGLE_BLU = 0.0f;
    private static final float ANGLE_ORN = -45.0f; /* inverted! */
    private static final float ANGLE_BRN = 157.5f;

    /** 4x1 raster block to palette at even rows */
    private byte[] evenFiltered;
    /** 4x1 raster block to palette at odd rows */
    private byte[] oddFiltered;
    /** Blend of 2 yuvPalette values targeting odd rows */
    private int[] oddLineTable;
    /** Blend of 2 yuvPalette values targeting even rows */
    private int[] evenLineTable;

    /**
     * Simulate VIC chip colors and some common distortions to the colors.
     * 
     * @author alankila
     */
    protected static class PaletteEntry {
	private final float luminance;
	private final float angle;
	private final int direction;
	private final String name;

	protected PaletteEntry(final float luminance, final float angle, final int direction, final String name) {

	    this.luminance = luminance;
	    this.angle = angle;
	    this.direction = direction;
	    this.name = name;
	}

	protected YUVEntry toYUV(final float saturation, float phase, final float baseTint) {
	    final float y = luminance;

	    if (direction == 0) {
		return new YUVEntry(y, 0, baseTint);
	    }

	    phase += direction < 0 ? angle + 180 : angle;

	    float u = (float) (saturation * Math.cos(phase * Math.PI / 180.0));
	    float v = (float) (saturation * Math.sin(phase * Math.PI / 180.0));

	    // scale to range -0.5 to .. 0.5 to avoid overflow
	    u *= 0.5f;
	    v *= 0.5f;
	    v += baseTint;

	    return new YUVEntry(y, u, v);
	}

	protected String getName() {
	    return name;
	}
    }

    protected static class YUVEntry {
	protected final float y, u, v;

	/**
	 * Construct YUV color from components.
	 * 
	 * @param y
	 *            range 0 .. 1
	 * @param u
	 *            range -0.5 .. 0.5
	 * @param v
	 *            range -0.5 .. 0.5
	 */
	protected YUVEntry(final float y, final float u, final float v) {
	    this.y = y;
	    this.u = u;
	    this.v = v;
	}

	/**
	 * Construct YUV color from packed format.
	 * 
	 * @param yuvPacked
	 *            The packed approximation as 0x00YYUUVV.
	 */
	protected YUVEntry(final int yuvPacked) {
	    y = (yuvPacked >> 20 & 0x3ff) / 1023f;
	    u = (yuvPacked >> 10 & 0x3ff) / 1023f - 0.5f;
	    v = (yuvPacked & 0x3ff) / 1023f - 0.5f;
	}

	/**
	 * Convert this color to 30-bit quantized packed approximation.
	 * 
	 * @return YUV color
	 */
	protected int toPacked() {
	    int yi = Math.round(y * 1023);
	    int ui = Math.round((u + 0.5f) * 1023);
	    int vi = Math.round((v + 0.5f) * 1023);

	    yi = Math.max(0, Math.min(yi, 1023));
	    ui = Math.max(0, Math.min(ui, 1023));
	    vi = Math.max(0, Math.min(vi, 1023));

	    return yi << 20 | ui << 10 | vi;
	}

	/**
	 * Convert to RGB with parameters
	 * 
	 * @return
	 */
	protected int toRGB(final float brightness, final float contrast, final float gamma) {
	    float rf = y + 1.13983f * v;
	    float gf = y - 0.39465f * u - 0.58060f * v;
	    float bf = y + 2.03211f * u;

	    rf += brightness;
	    gf += brightness;
	    bf += brightness;

	    rf *= contrast;
	    gf *= contrast;
	    bf *= contrast;

	    rf = (float) Math.pow(rf, NOMINAL_PAL_GAMMA / gamma);
	    gf = (float) Math.pow(gf, NOMINAL_PAL_GAMMA / gamma);
	    bf = (float) Math.pow(bf, NOMINAL_PAL_GAMMA / gamma);

	    int r = Math.round(rf * 255);
	    int g = Math.round(gf * 255);
	    int b = Math.round(bf * 255);

	    r = Math.max(0, Math.min(255, r));
	    g = Math.max(0, Math.min(255, g));
	    b = Math.max(0, Math.min(255, b));

	    return r << 16 | g << 8 | b;
	}
    }

    @SuppressWarnings("unused")
    private byte[] calculatePaletteInternal(final PaletteEntry[] colors, YUVEntry[] yuv, float saturation,
	    float phaseShift, float tint) {
	final YUVEntry[] palette = new YUVEntry[16];
	for (int i = 0; i < colors.length; i++) {
	    final PaletteEntry pe = colors[i];
	    palette[i] = pe.toYUV(saturation, phaseShift, tint);
	}

	final int[] filteredYuv = generateFilteredPalette(palette);
	/* Quantize the palette. */
	OctreeQuantization q = new OctreeQuantization(256);
	for (int i = 0; i < filteredYuv.length; i++) {

	    int w = 1;
	    for (int c1 = 0; c1 < 12; c1 += 4) {
		for (int c2 = c1 + 4; c2 < 16; c2 += 4) {
		    if ((i >> c1 & 0xf) == (i >> c2 & 0xf)) {
			w *= PALETTE_PURITY;
			break;
		    }
		}
	    }

	    q.addColor(filteredYuv[i], w);
	}

	int[] yuvPalette = q.getPalette();

	/*
	 * calculate palette rgb->index map we can use to map colors in reverse
	 * direction.
	 */
	Map<Integer, Byte> yuvToIndex = new HashMap<Integer, Byte>();
	for (int i = 0; i < 256; i++) {
	    yuv[i] = new YUVEntry(yuvPalette[i]);
	    yuvToIndex.put(yuvPalette[i], (byte) i);
	}

	/* Now map every filteredEven/Odd to indexed palette using closest match */
	return replaceColorsByPalette(filteredYuv, q, yuvToIndex);
    }

    public void calculatePalette(final PaletteEntry[] colors) {
	// YUVEntry[] evenPalette = new YUVEntry[256];
	// YUVEntry[] oddPalette = new YUVEntry[256];

	// Speedup by JAC!
	evenFiltered = new byte[65536]; // ]calculatePaletteInternal(colors,
					// evenPalette, saturation, phaseShift,
					// tint);
	oddFiltered = new byte[65536]; // calculatePaletteInternal(colors,
				       // oddPalette, saturation, -phaseShift,
				       // tint);

	/* Use 2 indexed colors to calculate output color for 2 lines. */
	evenLineTable = new int[256 * 256];
	oddLineTable = new int[256 * 256];
	// for (int above = 0; above < 256; above ++) {
	// for (int below = 0; below < 256; below ++) {
	// int idx = above << 8 | below;
	//
	// YUVEntry aboveColor = oddPalette[above];
	// YUVEntry belowColor = evenPalette[below];
	// evenLineTable[idx] = new YUVEntry(
	// belowColor.y,
	// (aboveColor.u + belowColor.u) * 0.5f,
	// (aboveColor.v + belowColor.v) * 0.5f).toRGB(brightness, contrast,
	// gamma);
	//
	// aboveColor = evenPalette[above];
	// belowColor = oddPalette[below];
	// oddLineTable[idx] = new YUVEntry(
	// belowColor.y,
	// (aboveColor.u + belowColor.u) * offset * 0.5f,
	// (aboveColor.v + belowColor.v) * offset * 0.5f).toRGB(brightness,
	// contrast, gamma);
	// }
	// }
    }

    /**
     * Find closest color according to root mean square from palette.
     * 
     * @param filtered
     * @param yuvPalette
     */
    private static byte[] replaceColorsByPalette(final int[] filtered, final OctreeQuantization q,
	    final Map<Integer, Byte> colorIndex) {

	final byte[] palette = new byte[filtered.length];
	for (int colorName = 0; colorName < filtered.length; colorName++) {
	    final int c = q.lookup(filtered[colorName]);
	    palette[colorName] = colorIndex.get(c);
	}

	return palette;
    }

    /**
     * Gauss
     * 
     * @param b
     *            Position with respect to origo
     * @param c
     *            Width of peak
     * @return Gaussian value
     */
    private static float gauss(float b, float c) {
	b = b * b;
	c = c * c;

	double factor = 1 / Math.sqrt(2 * Math.PI * c);
	return (float) (factor * Math.exp(-b / (2 * c)));
    }

    private float luminanceFilter(final float y0, final float y1, final float y2, final float y3) {
	final float kernelPlacement = 1.5f + (0.5f - (y0 + y1 + y2 + y3) * 0.25f) * dotCreep;
	final float c0 = gauss(kernelPlacement - 0, getLuminanceC());
	final float c1 = gauss(kernelPlacement - 1, getLuminanceC());
	final float c2 = gauss(kernelPlacement - 2, getLuminanceC());
	final float c3 = gauss(kernelPlacement - 3, getLuminanceC());
	return (c0 * y0 + c1 * y1 + c2 * y2 + c3 * y3) / (c0 + c1 + c2 + c3);
    }

    private int[] generateFilteredPalette(final YUVEntry[] p) {
	final int[] filtered = new int[16 * 16 * 16 * 16];

	/* The color x0 appears leftmost on screen and x3 appears rightmost. */
	for (int x0 = 0; x0 < 16; x0++) {
	    final YUVEntry col0 = p[x0];
	    for (int x1 = 0; x1 < 16; x1++) {
		final YUVEntry col1 = p[x1];
		for (int x2 = 0; x2 < 16; x2++) {
		    final YUVEntry col2 = p[x2];
		    for (int x3 = 0; x3 < 16; x3++) {
			final YUVEntry col3 = p[x3];

			final float y = luminanceFilter(col0.y, col1.y, col2.y, col3.y);
			final float u = (col0.u + col1.u + col2.u + col3.u) * 0.25f;
			final float v = (col0.v + col1.v + col2.v + col3.v) * 0.25f;

			final YUVEntry ye = new YUVEntry(y, u, v);
			filtered[x0 << 12 | x1 << 8 | x2 << 4 | x3] = ye.toPacked();
		    }
		}
	    }
	}

	return filtered;
    }

    public byte[] getEvenFiltered() {
	return evenFiltered;
    }

    public byte[] getOddFiltered() {
	return oddFiltered;
    }

    public int[] getEvenLines() {
	return evenLineTable;
    }

    public int[] getOddLines() {
	return oddLineTable;
    }

    public float getGamma() {
	return gamma;
    }

    public void setGamma(final float gamma) {
	this.gamma = gamma;
    }

    public float getContrast() {
	return contrast;
    }

    public void setContrast(final float contrast) {
	this.contrast = contrast;
    }

    public float getBrightness() {
	return brightness;
    }

    public void setBrightness(final float brightness) {
	this.brightness = brightness;
    }

    public float getLuminanceC() {
	return luminanceC;
    }

    public void setLuminanceC(final float luminanceC) {
	this.luminanceC = luminanceC;
    }

    public float getTint() {
	return tint;
    }

    public void setTint(final float tint) {
	this.tint = tint;
    }

    public float getPhaseShift() {
	return phaseShift;
    }

    public void setPhaseShift(final float phaseShift) {
	this.phaseShift = phaseShift;
    }

    public float getOffset() {
	return offset;
    }

    public void setOffset(final float offset) {
	this.offset = offset;
    }

    public float getSaturation() {
	return saturation;
    }

    public void setSaturation(final float saturation) {
	this.saturation = saturation;
    }

    public void setDotCreep(final float dotCreep) {
	this.dotCreep = dotCreep;
    }

    public float getDotCreep() {
	return dotCreep;
    }

    public static PaletteEntry[] buildPaletteVariant(final VIC.Model model) {
	/*
	 * http://www.zimmers.net/anonftp/pub/cbm/documents/chipdata/656x-luminances
	 * .txt
	 */
	final float[] lum;
	switch (model) {
	// case MOS6567R56A:
	// lum = new float[] {
	// 560, 1825, 840, 1500, 1180, 1180, 840, 1500,
	// 1180, 840, 1180, 840, 1180, 1500, 1180, 1500 };
	// break;
	case MOS6567R8:
	    lum = new float[] { 590, 1825, 950, 1380, 1030, 1210, 860, 1560, 1030, 860, 1210, 950, 1160, 1560, 1160,
		    1380 };
	    break;
	case MOS6569R1:
	    lum = new float[] { 630, 1850, 900, 1560, 1260, 1260, 900, 1560, 1260, 900, 1260, 900, 1260, 1560, 1260,
		    1560 };
	    break;
	case MOS6569R3:
	    lum = new float[] { 700, 1850, 1090, 1480, 1180, 1340, 1020, 1620, 1180, 1020, 1340, 1090, 1300, 1620,
		    1300, 1480 };
	    break;
	case MOS6569R4:
	    lum = new float[] { 500, 1875, 840, 1300, 920, 1100, 760, 1500, 920, 760, 1100, 840, 1050, 1500, 1050, 1300 };
	    break;
	case MOS6569R5:
	    lum = new float[] { 540, 1850, 900, 1340, 980, 1150, 810, 1520, 980, 810, 1150, 900, 1110, 1520, 1110, 1340 };
	    break;
	default:
	    throw new RuntimeException("Unknown chip");
	}

	final float min = lum[0];
	final float max = lum[1];
	for (int i = 0; i < lum.length; i++) {
	    lum[i] = (lum[i] - min) / (max - min);
	}

	/* Luminances per modern VIC */
	return new PaletteEntry[] { new PaletteEntry(lum[0], ANGLE_ORN, -0, "Black"),
		new PaletteEntry(lum[1], ANGLE_BRN, 0, "White"), new PaletteEntry(lum[2], ANGLE_RED, 1, "Red"),
		new PaletteEntry(lum[3], ANGLE_RED, -1, "Cyan"), new PaletteEntry(lum[4], ANGLE_GRN, -1, "Purple"),
		new PaletteEntry(lum[5], ANGLE_GRN, 1, "Green"), new PaletteEntry(lum[6], ANGLE_BLU, 1, "Blue"),
		new PaletteEntry(lum[7], ANGLE_BLU, -1, "Yellow"), new PaletteEntry(lum[8], ANGLE_ORN, -1, "Orange"),
		new PaletteEntry(lum[9], ANGLE_BRN, 1, "Brown"), new PaletteEntry(lum[10], ANGLE_RED, 1, "Light Red"),
		new PaletteEntry(lum[11], ANGLE_RED, -0, "Dark Grey"),
		new PaletteEntry(lum[12], ANGLE_GRN, -0, "Medium Grey"),
		new PaletteEntry(lum[13], ANGLE_GRN, 1, "Light Green"),
		new PaletteEntry(lum[14], ANGLE_BLU, 1, "Light Blue"),
		new PaletteEntry(lum[15], ANGLE_BLU, -0, "Light Grey"), };
    }
}