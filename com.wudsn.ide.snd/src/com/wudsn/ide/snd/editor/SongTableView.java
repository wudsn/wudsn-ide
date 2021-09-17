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

package com.wudsn.ide.snd.editor;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableColumn;
import org.eclipse.swt.widgets.TableItem;

import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.gui.Action;
import com.wudsn.ide.snd.Texts;
import com.wudsn.ide.snd.editor.SoundEditor.Actions;
import com.wudsn.ide.snd.player.LoopMode;
import com.wudsn.ide.snd.player.SoundInfo;

/**
 * Song table view.
 * 
 * @author Peter Dell
 * 
 * @since 1.6.1
 * 
 */
final class SongTableView {

	/**
	 * Data container for a row in the table view.
	 * 
	 * @author Peter Dell
	 * 
	 */
	private static final class Data {
		private int id;
		private String title;
		private String duration;
		private LoopMode loopMode;

		public Data(int id, String title, String duration, LoopMode loopMode) {

			this.id = id;
			this.title = title;
			this.duration = duration;
			this.loopMode = loopMode;
		}

		public int getId() {
			return id;
		}

		public String getTitle() {
			return title;
		}

		public String getDuration() {
			return duration;
		}

		public LoopMode getLoopMode() {
			return loopMode;
		}

	}

	// Standard width of a column.
	private static final int WIDTH = 80;

	// Objects created in the constructor.
	private final Table table;
	private final TableColumn idColumn;
	private final TableColumn defaultSongColumn;
	private final DateFormat durationColumnFormat;
	private final TableColumn durationColumn;
	private final TableColumn loopColumn;

	// The data list containing the converted image color histogram data.
	private List<SongTableView.Data> dataList;

	public SongTableView(Composite parent, final SoundEditor owner) {
		if (parent == null) {
			throw new IllegalArgumentException("Parameter 'parent' must not be null."); //$NON-NLS-1$
		}
		if (owner == null) {
			throw new IllegalArgumentException("Parameter 'owner' must not be null."); //$NON-NLS-1$
		}

		table = new Table(parent, SWT.BORDER | SWT.SINGLE | SWT.FULL_SELECTION);
		table.setHeaderVisible(true);
		RowData layoutData = new RowData();
		layoutData.width = 640;
		table.setLayoutData(layoutData);
		/*
		 * NOTE: MeasureItem, PaintItem and EraseItem are called repeatedly. Therefore,
		 * it is critical for performance that these methods be as efficient as
		 * possible.
		 */
		table.addListener(SWT.PaintItem, new Listener() {
			// @Override
			@Override
			public void handleEvent(Event event) {

				paintItem(event);
			}
		});

		table.addSelectionListener(new Action(Actions.PLAY, owner));

		// The first column is always left aligned in SWT due to a
		// restriction in windows.
		// This is a trick to come round this restriction.
		TableColumn dummyColumn;
		dummyColumn = new TableColumn(table, SWT.LEFT);
		dummyColumn.setWidth(0);

		idColumn = new TableColumn(table, SWT.RIGHT);
		idColumn.setText(Texts.SOUND_EDITOR_SONG_ID_LABEL);
		defaultSongColumn = new TableColumn(table, SWT.RIGHT);
		defaultSongColumn.setText(Texts.SOUND_EDITOR_DEFAULT_SONG_LABEL);
		durationColumnFormat = new SimpleDateFormat(Texts.SOUND_EDITOR_DURATION_PATTERN);
		durationColumn = new TableColumn(table, SWT.RIGHT);
		durationColumn.setText(Texts.SOUND_EDITOR_DURATION_LABEL);
		loopColumn = new TableColumn(table, SWT.RIGHT);
		loopColumn.setText(Texts.SOUND_EDITOR_LOOP_LABEL);

		idColumn.setWidth(WIDTH);
		defaultSongColumn.setWidth(WIDTH);
		durationColumn.setWidth(WIDTH);
		loopColumn.setWidth(WIDTH);

		dataList = new ArrayList<SongTableView.Data>();
	}

	/**
	 * Gets the selected song.
	 * 
	 * @return The selected song, a non-negative number, or <code>-1</code> if no
	 *         song is selected.
	 */
	public int getSelectedSong() {
		int index = table.getSelectionIndex();
		if (index < 0) {
			return -1;
		}
		return dataList.get(index).getId();
	}

	/**
	 * Gets the selected song.
	 * 
	 * @param song The selected song, a non-negative number, or <code>-1</code> if
	 *             no song is selected.
	 */
	public void setSelectedSong(int song) {
		table.setSelection(song);
	}

	void paintItem(Event event) {
		if (event == null) {
			throw new IllegalArgumentException("Parameter 'event' must not be null."); //$NON-NLS-1$
		}
		TableItem item = (TableItem) event.item;
		int i = table.indexOf(item);
		SongTableView.Data data = dataList.get(i);
		item.setData(data);
		// Number of songs starts with 1 in the table, but with 0 in the model.
		item.setText(1, NumberUtility.getLongValueDecimalString(data.getId() + 1));
		item.setText(2, data.getTitle());
		item.setText(3, data.getDuration());
		String text;
		switch (data.getLoopMode()) {
		case YES:
			text = Texts.SOUND_EDITOR_LOOP_YES;
			break;
		case NO:
			text = Texts.SOUND_EDITOR_LOOP_NO;
			break;
		default:
			text = Texts.SOUND_EDITOR_UNKNOWN;
			break;
		}
		item.setText(4, text);
	}

	public void setInfo(SoundInfo info) {
		if (info == null) {
			throw new IllegalArgumentException("Parameter 'info' must not be null."); //$NON-NLS-1$
		}

		// Create data list.
		int size = info.getSongs();
		for (int i = 0; i < size; i++) {
			int duration = info.getDuration(i);
			SongTableView.Data data = new Data(i, i == info.getDefaultSong() ? Texts.SOUND_EDITOR_DEFAULT : "",

					duration == 0 ? Texts.SOUND_EDITOR_UNKNOWN : durationColumnFormat.format(new Date(duration)),
					info.getLoopMode(i));
			dataList.add(data);
		}

		table.setItemCount(dataList.size());
		table.setSelection(info.getDefaultSong());
	}
}