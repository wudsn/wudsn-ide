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

package com.wudsn.ide.gfx.editor;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IMenuCreator;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Region;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.ColorDialog;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableColumn;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.ui.ISelectionListener;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.part.ViewPart;

import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.gfx.Texts;
import com.wudsn.ide.gfx.converter.ImageColorHistogram;
import com.wudsn.ide.gfx.gui.ImageCanvas;
import com.wudsn.ide.gfx.model.Palette;
import com.wudsn.ide.gfx.model.PaletteType;
import com.wudsn.ide.gfx.model.PaletteUtility;

/**
 * This class displays the palette of the image from a {@link ImageProvider}.
 * 
 * @author Peter Dell
 * @see ImageCanvas
 */

public final class ImagePaletteView extends ViewPart implements
	ISelectionListener {

    private final class PaletteMenuCreator implements IMenuCreator,
	    SelectionListener {
	private Menu menu;
	private Map<String, Image> images;

	public PaletteMenuCreator() {
	    images = new HashMap<String, Image>(10);
	}

	@Override
	public Menu getMenu(Menu parent) {
	    return null;
	}

	@Override
	public Menu getMenu(Control parent) {
	    if (menu != null) {
		menu.dispose();
		menu = null;
	    }
	    menu = new Menu(parent);
	    createMenuItem("Hires-1", PaletteUtility.getPaletteColors(
		    PaletteType.ATARI_DEFAULT, Palette.HIRES_1, null));
	    createMenuItem("Hires-2", PaletteUtility.getPaletteColors(
		    PaletteType.ATARI_DEFAULT, Palette.HIRES_2, null));

	    createMenuItem("Multi-1", PaletteUtility.getPaletteColors(
		    PaletteType.ATARI_DEFAULT, Palette.MULTI_1, null));
	    createMenuItem("Multi-2", PaletteUtility.getPaletteColors(
		    PaletteType.ATARI_DEFAULT, Palette.MULTI_2, null));
	    createMenuItem("Multi-3", PaletteUtility.getPaletteColors(
		    PaletteType.ATARI_DEFAULT, Palette.MULTI_3, null));
	    createMenuItem("Multi-4", PaletteUtility.getPaletteColors(
		    PaletteType.ATARI_DEFAULT, Palette.MULTI_4, null));
	    createMenuItem("Multi-5", PaletteUtility.getPaletteColors(
		    PaletteType.ATARI_DEFAULT, Palette.MULTI_5, null));
	    createMenuItem("Multi-6", PaletteUtility.getPaletteColors(
		    PaletteType.ATARI_DEFAULT, Palette.MULTI_6, null));
	    return menu;
	}

	private void createMenuItem(String text, RGB[] rgbs) {
	    MenuItem item = new MenuItem(menu, SWT.NONE);
	    Image image = images.get(text);
	    if (image == null) {
		int size = 16;
		int width = rgbs.length * size;
		int height = size;
		PaletteData paletteData = new PaletteData(rgbs);
		ImageData imageData = new ImageData(width, height, 8,
			paletteData);
		for (int i = 0; i < rgbs.length; i++) {
		    for (int y = 0; y < size; y++) {
			for (int x = 0; x < size; x++) {
			    imageData.setPixel(i * size + x, y, i);
			}
		    }
		}
		image = new Image(Display.getCurrent(), imageData);
		images.put(text, image);
	    }
	    item.setImage(image);
	    item.setData(rgbs);
	    item.addSelectionListener(this);
	}

	@Override
	public void dispose() {
	    if (menu != null) {
		menu.dispose();
	    }
	    menu = null;
	    if (images != null) {
		for (Image image : images.values()) {
		    image.dispose();
		}
		images = null;
	    }
	}

	@Override
	public void widgetSelected(SelectionEvent e) {
	    MenuItem item = (MenuItem) e.widget;
	    imageProvider.setPaletteRGBs((RGB[]) item.getData());
	}

	@Override
	public void widgetDefaultSelected(SelectionEvent e) {

	}
    }

    /**
     * 
     * @author Peter Dell
     * 
     */
    private static final class TableView {

	/**
	 * Data container for a row in the table view.
	 * 
	 * @author Peter Dell
	 * 
	 */
	private static final class Data {
	    private int index;
	    private int pixelColor;
	    private RGB rgb;
	    private int pixelColorCount;
	    private int pixelColorCountPercent;

	    public Data(int index, Integer pixelColor, RGB rgb,
		    int pixelColorCount, int pixelColorCountPercent) {
		if (pixelColor == null) {
		    throw new IllegalArgumentException(
			    "Parameter 'pixelColor' must not be null.");
		}
		if (rgb == null) {
		    throw new IllegalArgumentException(
			    "Parameter 'rgb' must not be null.");
		}
		this.index = index;
		this.pixelColor = pixelColor.intValue();
		this.rgb = rgb;
		this.pixelColorCount = pixelColorCount;
		this.pixelColorCountPercent = pixelColorCountPercent;
	    }

	    public int getIndex() {
		return index;
	    }

	    public int getPixelColor() {
		return pixelColor;
	    }

	    public RGB getRGB() {
		return rgb;
	    }

	    public int getPixelColorCount() {
		return pixelColorCount;
	    }

	    public int getPixelColorCountPercent() {
		return pixelColorCountPercent;
	    }
	}

	/**
	 * Comparator to sort lists of {@link Data}.
	 * 
	 * @author Peter Dell
	 * 
	 */
	private class DataComparator implements Comparator<Data> {

	    private TableColumn sortColumn;
	    private int sortDirection;

	    /**
	     * Creates a new comparator.
	     * 
	     * @param sortColumn
	     *            The column to sort by, not <code>null</code>.
	     * @param direction
	     *            The direction to sort by, see {@link SWT#UP} or
	     *            {@link SWT#DOWN}.
	     */
	    public DataComparator(TableColumn sortColumn, int direction) {
		if (sortColumn == null) {
		    throw new IllegalArgumentException(
			    "Parameter 'sortColumn' must not be null.");
		}
		this.sortColumn = sortColumn;
		this.sortDirection = direction == SWT.UP ? 1 : -1;
	    }

	    @Override
	    public int compare(Data o1, Data o2) {
		if (sortColumn == indexColumn) {
		    return (o1.getIndex() - o2.getIndex()) * sortDirection;
		} else if (sortColumn == pixelColorHexColumn
			|| sortColumn == pixelColorBinaryColumn) {
		    return (o1.getPixelColor() - o2.getPixelColor())
			    * sortDirection;
		} else if (sortColumn == rgbColorColumn) {
		    // Sort by brightness
		    float b1 = o1.getRGB().getHSB()[2];
		    float b2 = o2.getRGB().getHSB()[2];
		    if (b1 > b2) {
			return sortDirection;
		    } else if (b1 < b2) {
			return -sortDirection;
		    }
		    return 0;
		} else if (sortColumn == pixelColorCountColumn
			|| sortColumn == pixelColorCountPercentColumn) {
		    return (o1.getPixelColorCount() - o2.getPixelColorCount())
			    * sortDirection;
		}
		return 0;
	    }

	}

	// Standard width of a column.
	private static final int WIDTH = 47;

	// Objects created in the constructor.
	private final ImagePaletteView owner;
	private final Table table;
	private final Listener defaultSelectionListener;
	final TableColumn indexColumn;
	final TableColumn pixelColorHexColumn;
	final TableColumn pixelColorBinaryColumn;
	final TableColumn rgbColorColumn;
	final TableColumn pixelColorCountColumn;
	final TableColumn pixelColorCountPercentColumn;

	// The image cache map.
	private Map<RGB, Image> images;

	// The image color histogram containing the original data.
	private ImageColorHistogram imageColorHistogram;

	// The data list containing the converted image color histogram data.
	private List<Data> dataList;

	public TableView(Composite parent, final ImagePaletteView owner) {
	    if (parent == null) {
		throw new IllegalArgumentException(
			"Parameter 'parent' must not be null.");
	    }
	    if (owner == null) {
		throw new IllegalArgumentException(
			"Parameter 'owner' must not be null.");
	    }
	    this.owner = owner;

	    table = new Table(parent, SWT.VIRTUAL | SWT.BORDER | SWT.SINGLE
		    | SWT.FULL_SELECTION);
	    table.setLayoutData(new GridData(GridData.FILL_BOTH));

	    table.setHeaderVisible(true);

	    /*
	     * NOTE: MeasureItem, PaintItem and EraseItem are called repeatedly.
	     * Therefore, it is critical for performance that these methods be
	     * as efficient as possible.
	     */
	    table.addListener(SWT.EraseItem, new Listener() {
		@Override
		public void handleEvent(Event event) {
		    eraseItem(event);
		}
	    });

	    defaultSelectionListener = new Listener() {
		@Override
		public void handleEvent(Event e) {
		    editColor();
		}
	    };

	    // The first column is always left aligned in SWT due to a
	    // restriction in windows.
	    // This is a trick to come round this restriction.
	    TableColumn dummyColumn;
	    dummyColumn = new TableColumn(table, SWT.LEFT);
	    dummyColumn.setWidth(0);

	    indexColumn = new TableColumn(table, SWT.RIGHT);
	    indexColumn.setText("Index");
	    indexColumn.setText(Texts.IMAGE_PALETTE_VIEW_COLUMN_INDEX_TEXT);
	    pixelColorHexColumn = new TableColumn(table, SWT.RIGHT);
	    pixelColorHexColumn.setText("Hex");
	    pixelColorHexColumn
		    .setText(Texts.IMAGE_PALETTE_VIEW_COLUMN_COLOR_HEX_TEXT);
	    pixelColorBinaryColumn = new TableColumn(table, SWT.RIGHT);
	    pixelColorBinaryColumn
		    .setText(Texts.IMAGE_PALETTE_VIEW_COLUMN_COLOR_BINARY_TEXT);
	    rgbColorColumn = new TableColumn(table, SWT.RIGHT);
	    rgbColorColumn
		    .setText(Texts.IMAGE_PALETTE_VIEW_COLUMN_RGB_COLOR_TEXT);
	    pixelColorCountColumn = new TableColumn(table, SWT.RIGHT);
	    pixelColorCountColumn
		    .setText(Texts.IMAGE_PALETTE_VIEW_COLUMN_COLOR_COUNT_TEXT);
	    pixelColorCountPercentColumn = new TableColumn(table, SWT.RIGHT);
	    pixelColorCountPercentColumn
		    .setText(Texts.IMAGE_PALETTE_VIEW_COLUMN_COLOR_COUNT_PERCENT_TEXT);

	    indexColumn.setWidth(WIDTH);
	    pixelColorHexColumn.setWidth(WIDTH);
	    pixelColorBinaryColumn.setWidth(WIDTH);
	    rgbColorColumn.setWidth(90);
	    pixelColorCountColumn.setWidth(WIDTH);
	    pixelColorCountPercentColumn.setWidth(WIDTH);

	    table.addListener(SWT.SetData, new Listener() {
		@Override
		public void handleEvent(Event event) {

		    updateTableItem(event);
		}
	    });

	    // Add sort indicator and sort data when column selected
	    Listener sortListener = new Listener() {
		@Override
		public void handleEvent(Event event) {
		    sortTableColumn(event);
		}
	    };
	    indexColumn.addListener(SWT.Selection, sortListener);
	    pixelColorHexColumn.addListener(SWT.Selection, sortListener);
	    pixelColorBinaryColumn.addListener(SWT.Selection, sortListener);
	    rgbColorColumn.addListener(SWT.Selection, sortListener);
	    pixelColorCountColumn.addListener(SWT.Selection, sortListener);
	    pixelColorCountPercentColumn.addListener(SWT.Selection,
		    sortListener);

	    table.setSortColumn(indexColumn);
	    table.setSortDirection(SWT.UP);

	    images = new HashMap<RGB, Image>();
	    imageColorHistogram = null;
	    dataList = new ArrayList<Data>();
	}

	public void clear() {
	    if (!table.isDisposed()) {
		table.setItemCount(0);
		table.clearAll();
	    }

	    for (Image image : images.values()) {
		image.dispose();
	    }
	    images.clear();

	    imageColorHistogram = null;
	    dataList.clear();
	}

	public void setFocus() {
	    table.setFocus();
	}

	void updateTableItem(Event event) {
	    if (event == null) {
		throw new IllegalArgumentException(
			"Parameter 'event' must not be null.");
	    }
	    TableItem item = (TableItem) event.item;
	    Font font = JFaceResources.getTextFont();
	    int i = table.indexOf(item);
	    Data data = dataList.get(i);
	    item.setData(data);
	    item.setText(1,
		    NumberUtility.getLongValueDecimalString(data.getIndex()));

	    // Pixel color values are uninteresting for direct palettes.
	    if (!imageColorHistogram.isDirectPalette()) {
		item.setText(2,
			HexUtility.getLongValueHexString(data.getPixelColor()));
		item.setFont(2, font);
		item.setText(3, Integer.toBinaryString(data.getPixelColor()));
		item.setFont(3, font);
	    }
	    RGB rgb = data.getRGB();

	    // Images are resources which have to be disposed, so handle
	    Image image = images.get(rgb);
	    if (image == null) {
		PaletteData paletteData = new PaletteData(new RGB[] { rgb });
		ImageData imageData = new ImageData(32, 16, 1, paletteData);
		image = new Image(table.getDisplay(), imageData);
		images.put(rgb, image);
	    }
	    item.setImage(4, image);
	    item.setText(4, PaletteUtility.getPaletteColorText(rgb));
	    item.setFont(4, font);
	    item.setText(5, NumberUtility.getLongValueDecimalString(data
		    .getPixelColorCount()));
	    item.setText(6, NumberUtility.getLongValueDecimalString(data
		    .getPixelColorCountPercent()));

	}

	void eraseItem(Event event) {
	    if (event == null) {
		throw new IllegalArgumentException(
			"Parameter 'event' must not be null.");
	    }
	    event.detail &= ~SWT.HOT;
	    if ((event.detail & SWT.SELECTED) != 0) {
		GC gc = event.gc;
		Rectangle area = table.getClientArea();
		/*
		 * If you wish to paint the selection beyond the end of last
		 * column, you must change the clipping region.
		 */
		int columnCount = table.getColumnCount();
		if (event.index == columnCount - 1 || columnCount == 0) {
		    int width = area.x + area.width - event.x;
		    if (width > 0) {
			Region region = new Region();
			gc.getClipping(region);
			region.add(event.x, event.y, width, event.height);
			gc.setClipping(region);
			region.dispose();
		    }
		}
		gc.setAdvanced(true);
		if (gc.getAdvanced()) {
		    gc.setAlpha(127);
		}
		Rectangle rect = event.getBounds();
		Color foreground = gc.getForeground();

		gc.setForeground(table.getDisplay().getSystemColor(
			SWT.COLOR_RED));
		gc.fillRectangle(0, rect.y, 500, rect.height - 1);

		// Restore colors for subsequent drawing
		gc.setForeground(foreground);
		// Mark event as handled
		event.detail &= ~SWT.SELECTED;
	    }
	}

	void sortTableColumn(Event event) {
	    if (event == null) {
		throw new IllegalArgumentException(
			"Parameter 'event' must not be null.");
	    }
	    // determine new sort column and direction
	    TableColumn sortColumn = table.getSortColumn();
	    TableColumn currentColumn = (TableColumn) event.widget;
	    int direction = table.getSortDirection();
	    if (sortColumn == currentColumn) {
		direction = direction == SWT.UP ? SWT.DOWN : SWT.UP;
	    } else {
		table.setSortColumn(currentColumn);
		direction = SWT.UP;
	    }
	    table.setSortDirection(direction);

	    Collections.sort(dataList, new DataComparator(
		    table.getSortColumn(), table.getSortDirection()));
	    // Update data displayed in table
	    table.clearAll();
	}

	void editColor() {
	    TableItem[] selection = table.getSelection();
	    if (selection.length == 1) {
		Data data = (Data) selection[0].getData();
		ColorDialog colorDialog = new ColorDialog(table.getShell());
		colorDialog.setRGB(data.getRGB());
		RGB newRGB = colorDialog.open();

		if (newRGB != null) {
		    owner.imageProvider.setPaletteRGB(data.getPixelColor(),
			    newRGB);
		}
	    }
	}

	public void setImageColorHistogram(
		ImageColorHistogram imageColorHistogram,
		boolean paletteChangeable, boolean showUnusedColors,
		boolean force) {
	    if (imageColorHistogram == null) {
		clear();
	    } else if (this.imageColorHistogram != imageColorHistogram || force) {
		clear();
		this.imageColorHistogram = imageColorHistogram;

		// Register double click only if palette is changeable.
		table.removeListener(SWT.DefaultSelection,
			defaultSelectionListener);
		if (paletteChangeable) {
		    table.addListener(SWT.DefaultSelection,
			    defaultSelectionListener);
		}

		// For direct palette, display only used pixel colors.
		// For indexed palette, display either all pixel colors or only
		// used pixel colors.
		List<Integer> pixelColors;
		if (imageColorHistogram.isDirectPalette()) {
		    pixelColors = imageColorHistogram.getUsedPixelColors();
		} else {
		    if (showUnusedColors) {
			pixelColors = imageColorHistogram
				.getPalettePixelColors();
		    } else {
			pixelColors = imageColorHistogram.getUsedPixelColors();
		    }
		}

		// Hide unused column in direct palette mode.
		if (imageColorHistogram.isDirectPalette()) {
		    pixelColorHexColumn.setWidth(0);
		    pixelColorBinaryColumn.setWidth(0);
		} else {
		    pixelColorHexColumn.setWidth(WIDTH);
		    pixelColorBinaryColumn.setWidth(WIDTH);
		}

		// Create data list.
		int size = pixelColors.size();
		int pixelCount = imageColorHistogram.getPixelCount();
		for (int i = 0; i < size; i++) {
		    Integer pixelColor = pixelColors.get(i);
		    int pixelColorCount = imageColorHistogram
			    .getPixelColorCount(pixelColor);
		    int pixelColorCountPercent = ((pixelColorCount * 100) / pixelCount);
		    RGB rgb = imageColorHistogram.getRGB(pixelColor);
		    Data data = new Data(i, pixelColor, rgb, pixelColorCount,
			    pixelColorCountPercent);
		    dataList.add(data);
		}

		Collections.sort(
			dataList,
			new DataComparator(table.getSortColumn(), table
				.getSortDirection()));
		table.setItemCount(dataList.size());
		table.setSelection(0);
	    }

	}
    }

    // ID of this view in the plugin manifest.
    public static final String ID = ImagePaletteView.class.getName();

    // UI components, not final because they are created outside of the
    // constructor.
    private IAction editColorAction;
    private IAction showUnusedColorsAction;
    private Label infoLabel;
    private TableView tableView;

    // The currently active image provider or null.
    ImageProvider imageProvider;

    /**
     * Creation is private.
     */
    public ImagePaletteView() {
    }

    @Override
    public void createPartControl(Composite parent) {

	IToolBarManager toolBarManager = getViewSite().getActionBars()
		.getToolBarManager();

	editColorAction = new Action(
		Texts.IMAGE_PALETTE_VIEW_EDIT_COLOR_ACTION_LABEL,
		IAction.AS_DROP_DOWN_MENU) {
	    @Override
	    public void run() {
		editColor();
	    }
	};
	editColorAction
		.setToolTipText(Texts.IMAGE_PALETTE_VIEW_EDIT_COLOR_ACTION_TOOLTIP);
	editColorAction.setMenuCreator(new PaletteMenuCreator());

	showUnusedColorsAction = new Action(
		Texts.IMAGE_PALETTE_VIEW_UNUSED_COLORS_ACTION_LABEL,
		IAction.AS_CHECK_BOX) {
	    @Override
	    public void run() {
		showUnusedColors();
	    }
	};
	showUnusedColorsAction
		.setToolTipText(Texts.IMAGE_PALETTE_VIEW_UNUSED_COLORS_ACTION_TOOLTIP);

	toolBarManager.add(editColorAction);
	toolBarManager.add(showUnusedColorsAction);

	// presetColorsAction.setText("Test");

	GridLayout gridLayout = new GridLayout();
	gridLayout.marginWidth = 0;
	gridLayout.marginHeight = 0;
	parent.setLayout(gridLayout);

	Composite infoComposite = new Composite(parent, SWT.NONE);
	gridLayout = new GridLayout(1, false);
	gridLayout.marginHeight = 0;
	infoComposite.setLayout(gridLayout);
	GridData gd = new GridData(GridData.FILL_HORIZONTAL);
	infoComposite.setLayoutData(gd);
	infoLabel = new Label(infoComposite, SWT.NONE);
	infoLabel.setLayoutData(gd);

	tableView = new TableView(parent, this);

	// Add this as a global selection listener
	getSite().getPage().addSelectionListener(this);

	// Preset based on current selection
	selectionChanged(null, getSite().getPage().getSelection());

    }

    void editColor() {
	tableView.editColor();
    }

    void showUnusedColors() {
	ImageColorHistogram imageColorHistogram = imageProvider
		.getImageColorHistogram();
	boolean paletteChangeable = imageProvider.isPaletteChangeable();
	tableView.setImageColorHistogram(imageColorHistogram,
		paletteChangeable, showUnusedColorsAction.isChecked(), true);
    }

    @Override
    public void setFocus() {
	tableView.setFocus();
    }

    @Override
    public void dispose() {

	if (tableView != null) {
	    tableView.clear();
	}

	if (imageProvider != null) {
	    imageProvider.setImagePaletteView(null);
	    imageProvider = null;
	}

	editColorAction.getMenuCreator().dispose();
	getSite().getPage().removeSelectionListener(this);
	super.dispose();
    }

    @Override
    public void selectionChanged(IWorkbenchPart part, ISelection selection) {

	if (part == null) {
	    setImageProvider(null);
	} else {
	    if (part instanceof GraphicsEditor) {
		GraphicsEditor graphicsEditor = ((GraphicsEditor) part);
		setImageProvider(graphicsEditor.getImageProvider());
	    }
	}
    }

    /**
     * Sets the image provider.
     * 
     * @param imageProvider
     *            The image provider or <code>null</code>.
     */
    public void setImageProvider(ImageProvider imageProvider) {
	if (imageProvider != this.imageProvider) {
	    // Unregister from old provider
	    if (this.imageProvider != null) {
		this.imageProvider.setImagePaletteView(null);
		this.imageProvider = null;
	    }

	    // Register with new provider
	    if (imageProvider != null) {
		this.imageProvider = imageProvider;
		this.imageProvider.setImagePaletteView(this);
	    }
	}
	dataToUI();
    }

    /**
     * Retrieve the current status from the image provider and display it.
     * 
     */
    public void dataToUI() {
	boolean enabled;

	if (imageProvider != null) {
	    ImageColorHistogram imageColorHistogram = imageProvider
		    .getImageColorHistogram();
	    boolean paletteChangeable = imageProvider.isPaletteChangeable();
	    editColorAction.setEnabled(paletteChangeable);

	    enabled = (imageColorHistogram != null)
		    && !imageColorHistogram.isDirectPalette();
	    showUnusedColorsAction.setEnabled(enabled);

	    String text;
	    if (imageColorHistogram != null) {
		int palettBits = imageColorHistogram.getPaletteBits();
		if (imageColorHistogram.isDirectPalette()) {
		    text = TextUtility
			    .format(Texts.IMAGE_PALETTE_VIEW_INFO_DIRECT_PALETTE_IMAGE,
				    NumberUtility
					    .getLongValueDecimalString(palettBits),
				    NumberUtility
					    .getLongValueDecimalString(imageColorHistogram
						    .getUsedPixelColors()
						    .size()));
		} else {
		    text = TextUtility
			    .format(Texts.IMAGE_PALETTE_VIEW_INFO_INDEXED_PALETTE_IMAGE,
				    NumberUtility
					    .getLongValueDecimalString(palettBits),

				    NumberUtility
					    .getLongValueDecimalString(imageColorHistogram
						    .getUsedPixelColors()
						    .size()),
				    NumberUtility
					    .getLongValueDecimalString(1 << palettBits));
		}
	    } else {
		text = Texts.IMAGE_PALETTE_VIEW_INFO_NO_IMAGE;
	    }
	    infoLabel.setText(text);

	    tableView.setImageColorHistogram(imageColorHistogram,
		    paletteChangeable, showUnusedColorsAction.isChecked(),
		    false);
	} else {
	    editColorAction.setEnabled(false);
	    showUnusedColorsAction.setEnabled(false);
	    infoLabel.setText(Texts.IMAGE_PALETTE_VIEW_INFO_NO_IMAGE);
	    tableView.clear();
	}

    }

}