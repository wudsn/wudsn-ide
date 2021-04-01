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

import java.io.File;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.jface.dialogs.IInputValidator;
import org.eclipse.jface.dialogs.InputDialog;
import org.eclipse.jface.window.Window;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.FileDialog;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Scale;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorSite;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.part.EditorPart;

import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.base.gui.Action;
import com.wudsn.ide.base.gui.Application;
import com.wudsn.ide.base.gui.IntegerField;
import com.wudsn.ide.base.gui.MessageManager;
import com.wudsn.ide.base.gui.SWTFactory;
import com.wudsn.ide.base.gui.TextField;
import com.wudsn.ide.snd.SoundPlugin;
import com.wudsn.ide.snd.Texts;
import com.wudsn.ide.snd.player.Clock;
import com.wudsn.ide.snd.player.EmptyPlayer;
import com.wudsn.ide.snd.player.FileType;
import com.wudsn.ide.snd.player.SoundInfo;
import com.wudsn.ide.snd.player.SoundPlayer;
import com.wudsn.ide.snd.player.SoundPlayerListener;

/**
 * Sound file editor, i.e. editor part for the visualization of the
 * {@link SoundPlayer}.
 * 
 * @author Peter Dell
 * 
 * @since 1.6.1
 */
public final class SoundEditor extends EditorPart implements Application, SoundPlayerListener {

    public final class MessageIds {

	/**
	 * Creation is private.
	 */
	private MessageIds() {
	}

	public static final int TITLE = 1;
	public static final int FORMAT = 2;
    }

    public final class Actions {

	/**
	 * Creation is private.
	 */
	private Actions() {
	}

	public static final int PLAY = 100;
	public static final int TOGGLE_PAUSE = 101;
	public static final int STOP = 102;
	public static final int EXPORT = 103;

    }

    private static class PositionScaleSelectionListener implements SelectionListener {
	private Scale scale;
	private SoundPlayer player;

	public PositionScaleSelectionListener(Scale scale, SoundPlayer player) {
	    if (scale == null) {
		throw new IllegalArgumentException("Parameter 'scale' must not be null.");
	    }
	    if (player == null) {
		throw new IllegalArgumentException("Parameter 'player' must not be null.");
	    }
	    this.scale = scale;
	    this.player = player;
	}

	@Override
	public void widgetSelected(SelectionEvent e) {
	    int position = scale.getSelection();
	    if ((e.stateMask & SWT.BUTTON1) != 0) {
		if (Math.abs(position - player.getPosition()) < SoundPlayerListener.POSITION_UPDATE_INCREMENT) {
		    return;
		}
	    }
	    player.seekPosition(scale.getSelection());

	    if (player.isPaused()) {
		player.togglePause();
	    }

	}

	@Override
	public void widgetDefaultSelected(SelectionEvent e) {

	}

    }

    // ID of the editor in the plugin manifest.
    public static final String ID = "com.wudsn.ide.snd.editor.SoundEditor"; //$NON-NLS-1$

    private MessageManager messageManager;
    private SoundPlayer player;

    private boolean partControlCreated;
    private Composite mainComposite;
    private TextField titleField;
    private TextField formatField;

    private TextField authorField;
    private TextField dateField;
    private TextField channelsField;
    private DecimalFormat playerFrequencyFieldHertzFormat;
    private TextField playerFrequencyField;

    private TextField initAddressField;
    private IntegerField playerAddressField;
    private TextField musicAddressField;

    private SongTableView songTableView;

    private DateFormat positionFieldFormat;
    private TextField positionField;
    private Scale positionScale;

    private VUMeterField vuMeterField;

    private ToolItem playButton;
    private ToolItem pauseButton;
    private ToolItem stopButton;
    private ToolItem exportButton;
    private FileDialog exportFileDialog;

    public SoundEditor() {
	super();
	messageManager = new MessageManager(this);
    }

    // @Override
    @Override
    public MessageManager getMessageManager() {
	return messageManager;
    }

    // @Override
    @Override
    public void performAction(Action action) {
	if (action == null) {
	    throw new IllegalArgumentException("Parameter 'action' must not be null."); //$NON-NLS-1$
	}
	messageManager.clearMessages();
	switch (action.getId()) {
	case Actions.PLAY:
	    try {
		player.play(songTableView.getSelectedSong(), SoundEditor.this);
	    } catch (CoreException ex) {
		messageManager.sendMessage(MessageIds.TITLE, ex);
	    }
	    break;
	case Actions.TOGGLE_PAUSE:
	    player.togglePause();
	    break;
	case Actions.STOP:
	    player.stop();
	    break;
	case Actions.EXPORT:
	    exportFileContentAs();
	    break;

	}
	dataToUI();
	messageManager.displayMessages();
    }

    @Override
    public void dispose() {
	player.stop();
	mainComposite.dispose();
	partControlCreated = false;
    }

    @Override
    public void doSave(IProgressMonitor monitor) {

    }

    @Override
    public void doSaveAs() {

    }

    @Override
    public void init(IEditorSite site, IEditorInput input) throws PartInitException {
	if (site == null) {
	    throw new IllegalArgumentException("Parameter 'site' must not be null."); //$NON-NLS-1$
	}
	setSite(site);
	setInput(input);

	if (input != null) {
	    setPartName(input.getName());
	} else {
	    setPartName(""); //$NON-NLS-1$
	}

	messageManager.clearMessages();
	try {
	    if (input instanceof IFileEditorInput) {
		IFileEditorInput fileEditorInput = (IFileEditorInput) input;
		IFile file = fileEditorInput.getFile();
		String fileName = file.getName();
		player = SoundPlugin.getInstance().createSoundPlayer(file.getName());

		if (player == null) {
		    // ERROR: MESSAGE_E500: No player registered for sound file
		    // {0}.
		    messageManager.sendMessage(MessageIds.TITLE, IStatus.ERROR, Texts.MESSAGE_E500, fileName);
		    player = new EmptyPlayer(fileName);
		} else {
		    try {
			player.load(fileName, file.getContents());
		    } catch (CoreException ex) {
			// If loading fails, there should not be a real player.
			player = new EmptyPlayer(fileName);
			messageManager.sendMessage(MessageIds.TITLE, ex);

		    }
		}
		if (partControlCreated) {
		    dataToUI();
		}

		// If a module was loaded successfully, then there is a defaul
		// song.
		if (player.getInfo().getDefaultSong() >= 0) {
		    try {
			player.play(player.getInfo().getDefaultSong(), this);

		    } catch (CoreException ex) {
			messageManager.sendMessage(MessageIds.TITLE, ex);
		    }
		}
	    }
	} catch (RuntimeException ex) {
	    SoundPlugin.getInstance().logError("Error during initilization of SoundEditor", null, ex);
	}

	messageManager.displayMessages();
    }

    @Override
    public boolean isDirty() {
	return false;
    }

    @Override
    public boolean isSaveAsAllowed() {
	return false;
    }

    @Override
    public void createPartControl(Composite parent) {

	parent.setLayout(new FillLayout(SWT.VERTICAL));
	// parent.setLayout(new RowLayout(SWT.VERTICAL));
	// parent.setLayoutData(null);

	mainComposite = new Composite(parent, SWT.NONE);
	mainComposite.setLayout(new FillLayout(SWT.VERTICAL));

	Composite topComposite = createRowComposite(mainComposite, SWT.VERTICAL);

	// Fields
	Composite fieldsComposite = new Composite(topComposite, SWT.NONE);
	fieldsComposite.setLayout(new GridLayout(4, true));

	titleField = new TextField(fieldsComposite, Texts.SOUND_EDITOR_TITLE_LABEL, SWT.READ_ONLY);
	messageManager.registerField(titleField, MessageIds.TITLE);
	formatField = new TextField(fieldsComposite, Texts.SOUND_EDITOR_FORMAT_LABEL, SWT.READ_ONLY);
	messageManager.registerField(formatField, MessageIds.FORMAT);

	authorField = new TextField(fieldsComposite, Texts.SOUND_EDITOR_AUTHOR_LABEL, SWT.READ_ONLY);
	dateField = new TextField(fieldsComposite, Texts.SOUND_EDITOR_DATE_LABEL, SWT.READ_ONLY);

	channelsField = new TextField(fieldsComposite, Texts.SOUND_EDITOR_CHANNELS_LABEL, SWT.READ_ONLY);
	playerFrequencyFieldHertzFormat = new DecimalFormat(Texts.SOUND_EDITOR_FREQUENCY_HERTZ_PATTERN);
	playerFrequencyField = new TextField(fieldsComposite, Texts.SOUND_EDITOR_FREQUENCY_LABEL, SWT.READ_ONLY);

	initAddressField = new TextField(fieldsComposite, Texts.SOUND_EDITOR_INIT_ADDRESS_LABEL, SWT.READ_ONLY);
	playerAddressField = new IntegerField(fieldsComposite, Texts.SOUND_EDITOR_PLAYER_ADDRESS_LABEL, null, true, 4,
		SWT.READ_ONLY);
	musicAddressField = new TextField(fieldsComposite, Texts.SOUND_EDITOR_MUSIC_ADDRESS_LABEL, SWT.READ_ONLY);
	SWTFactory.createLabels(fieldsComposite, 2);

	// Position
	positionFieldFormat = new SimpleDateFormat(Texts.SOUND_EDITOR_DURATION_PATTERN);
	positionField = new TextField(fieldsComposite, Texts.SOUND_EDITOR_PLAYING_TIME_LABEL, SWT.READ_ONLY);
	Label label = new Label(fieldsComposite, SWT.NONE);
	label.setText(Texts.SOUND_EDITOR_PLAYYING_POSITION_LABEL);
	positionScale = new Scale(fieldsComposite, SWT.HORIZONTAL);
	positionScale.addSelectionListener(new PositionScaleSelectionListener(positionScale, player));
	positionScale.setLayoutData(new GridData(SWT.CENTER, SWT.CENTER, true, false));

	ToolBar toolbar = new ToolBar(topComposite, SWT.HORIZONTAL);

	playButton = new ToolItem(toolbar, SWT.PUSH);
	playButton.setImage(Icons.PLAY);
	playButton.setToolTipText(Texts.SOUND_EDITOR_PLAY_BUTTON_TOOLTIP);
	playButton.addSelectionListener(new Action(Actions.PLAY, SoundEditor.this));

	pauseButton = new ToolItem(toolbar, SWT.PUSH);
	pauseButton.setImage(Icons.PAUSE);
	pauseButton.setToolTipText(Texts.SOUND_EDITOR_PAUSE_BUTTON_TOOLTIP);
	pauseButton.addSelectionListener(new Action(Actions.TOGGLE_PAUSE, SoundEditor.this));

	stopButton = new ToolItem(toolbar, SWT.PUSH);
	stopButton.setImage(Icons.STOP);
	stopButton.setToolTipText(Texts.SOUND_EDITOR_STOP_BUTTON_TOOLTIP);
	stopButton.addSelectionListener(new Action(Actions.STOP, SoundEditor.this));

	exportButton = new ToolItem(toolbar, SWT.PUSH);
	exportButton.setImage(Icons.EXPORT);
	exportButton.setToolTipText(Texts.SOUND_EDITOR_EXPORT_BUTTON_TOOLTIP);
	exportButton.addSelectionListener(new Action(Actions.EXPORT, SoundEditor.this));

	songTableView = new SongTableView(topComposite, this);
	songTableView.setInfo(player.getInfo());

	// Volume control
	vuMeterField = new VUMeterField(mainComposite, false, Texts.SOUND_EDITOR_VOLUME_LABEL, SWT.NONE);

	partControlCreated = true;
	dataToUI();
	playerUpdated(SoundPlayerListener.ALL);
    }

    private Composite createRowComposite(Composite parent, int type) {
	Composite result = new Composite(parent, SWT.NONE);
	RowLayout layout = new RowLayout(type);
	layout.spacing = layout.marginLeft = layout.marginRight = layout.marginTop = layout.marginBottom = 0;
	layout.wrap = false;
	layout.justify = false;
	result.setLayout(layout);
	return result;
    }

    @Override
    public void setFocus() {
	mainComposite.setFocus();
    }

    private void dataToUI() {
	SoundInfo info;
	info = player.getInfo();

	titleField.setValue(StringUtility.isSpecified(info.getTitle()) ? info.getTitle() : getPartName());
	if (StringUtility.isSpecified(info.getModuleFileType())) {
	    formatField.setValue(TextUtility.format(Texts.SOUND_EDITOR_FORMAT_PATTERN, info.getModuleTypeDescription(),
		    info.getModuleFileType()));
	} else {
	    formatField.setValue(Texts.SOUND_EDITOR_UNKNOWN);
	}
	authorField.setValue(StringUtility.isSpecified(info.getAuthor()) ? info.getAuthor()
		: Texts.SOUND_EDITOR_UNKNOWN);
	dateField.setValue(StringUtility.isSpecified(info.getDate()) ? info.getDate() : Texts.SOUND_EDITOR_UNKNOWN);
	String channels;
	switch (info.getChannels()) {
	case 0:
	    channels = "";
	    break;
	case 1:
	    channels = Texts.SOUND_EDITOR_CHANNELS_MONO;
	    break;
	case 2:
	    channels = Texts.SOUND_EDITOR_CHANNELS_STEREO;
	    break;
	default:
	    channels = NumberUtility.getLongValueDecimalString(info.getChannels());
	}
	channelsField.setValue(channels);

	String scanLines = String.valueOf(info.getPlayerRateScanLines());
	String hertz = playerFrequencyFieldHertzFormat.format(info.getPlayerRateHertz());
	String norm = info.getPlayerClock() == Clock.NTSC ? Texts.SOUND_EDITOR_NORM_NTSC : Texts.SOUND_EDITOR_NORM_PAL;
	playerFrequencyField.setValue(TextUtility.format(Texts.SOUND_EDITOR_FREQUENCY_PATTERN, hertz, scanLines, norm));

	String value = HexUtility.getLongValueHexString(info.getInitAddress(), 4);
	if (info.isInitFulltime()) {
	    value = value + Texts.SOUND_EDITOR_INIT_ADDRESS_FULLTIME;
	}
	initAddressField.setValue(value);
	playerAddressField.setValue(info.getPlayerAddress());

	value = info.getMusicAddress() >= 0 ? HexUtility.getLongValueHexString(info.getMusicAddress(), 4) : "";
	musicAddressField.setValue(value);

	playButton.setEnabled(player.isLoaded());
	pauseButton.setEnabled(player.isPlaying());
	stopButton.setEnabled(player.isPlaying());

	positionScale.setEnabled(player.isPlaying() && player.getMaximumPosition() > 0 && player.isSeekSupported());
	List<FileType> fileTypes = info.getSupportedExportFileTypes();
	exportButton.setEnabled(!fileTypes.isEmpty());

	if (player.isPlaying()) {
	    songTableView.setSelectedSong(player.getPlayingSong());
	}

    }

    // @Override
    @Override
    public void playerUpdated(int mode) {

	final boolean stateUpdated;
	final boolean positionUpdated;
	final String position;
	final int maxPositionValue;
	final int positionValue;
	final String positionText;
	final boolean volumeUpdated;
	final int[] channelVolumnes;

	if (partControlCreated) {
	    stateUpdated = (mode & SoundPlayerListener.STATE) != 0;
	    positionUpdated = (mode & SoundPlayerListener.POSITION) != 0;
	    volumeUpdated = (mode & SoundPlayerListener.VOLUME) != 0;

	    // State dependent
	    maxPositionValue = player.getMaximumPosition();

	    // Position dependent
	    if ((stateUpdated || positionUpdated) && (player.isPlaying() || player.isPaused())) {
		if (maxPositionValue > 0) {
		    positionValue = player.getPosition() % maxPositionValue; // Modulo
									     // for
									     // looping
									     // sounds
		} else {
		    positionValue = player.getPosition();
		}
		synchronized (positionFieldFormat) {
		    position = positionFieldFormat.format(new Date(positionValue));
		}
		if (player.isPaused()) {
		    positionText = position + Texts.SOUND_EDITOR_PAUSED;
		} else {
		    positionText = position;
		}

	    } else {
		positionValue = 0;
		positionText = Texts.SOUND_EDITOR_STOPPED;
	    }

	    // Volume dependent
	    channelVolumnes = player.getChannelVolumes();

	    Runnable updater = new Runnable() {
		// @Override
		@Override
		public void run() {
		    playerUpdatedWithValues(stateUpdated, maxPositionValue, positionUpdated, positionValue,
			    positionText, volumeUpdated, channelVolumnes);
		}
	    };
	    // Updates to widgets must be performed in the display
	    // thread.
	    Display.getDefault().asyncExec(updater);

	}
    }

    void playerUpdatedWithValues(final boolean stateUpdated, final int maxPositionValue, final boolean positionUpdated,
	    final int positionValue, final String positionText, final boolean volumeUpdated, final int[] channelVolumnes) {
	if (partControlCreated) {
	    if (stateUpdated) {
		pauseButton.setEnabled(player.isPlaying());
		stopButton.setEnabled(player.isPlaying());
		positionScale.setMaximum(maxPositionValue);
		positionScale.setIncrement(SoundPlayerListener.POSITION_UPDATE_INCREMENT);
		positionScale.setPageIncrement(maxPositionValue > 0 ? maxPositionValue / 10 + 1 : 0);
	    }

	    if (positionUpdated) {
		positionScale.setSelection(maxPositionValue > 0 ? positionValue : 0);
	    }

	    if (stateUpdated || positionUpdated) {
		positionField.setValue(positionText);
		positionField.getControl().pack();
	    }

	    if (volumeUpdated) {
		vuMeterField.setValue(channelVolumnes);
	    }
	}
    }

    private void exportFileContentAs() {

	// ASCIIfy title to obtain a valid file name
	SoundInfo info = player.getInfo();
	String title = info.getTitle();
	StringBuilder builder = new StringBuilder();
	for (int i = 0; i < title.length(); i++) {
	    char c = title.charAt(i);
	    if (Character.isLetter(c) || Character.isDigit(c) || c == '-' || c == '_') {
		builder.append(c);
	    }
	}

	// Appending the module file type does unfortunately not have any effect
	// on the default selected in the dialog. So we stick to the first
	// selected type.
	String fileName = builder.toString();

	// Create the file dialog only once, so it keeps the selected folder
	// when exporting multiple times.
	if (exportFileDialog == null) {
	    exportFileDialog = new FileDialog(getSite().getShell(), SWT.SAVE);
	}
	exportFileDialog.setFileName(fileName);

	// Get list of file type sorted by description.
	List<FileType> fileTypes = player.getInfo().getSupportedExportFileTypes();
	if (fileTypes.isEmpty()) {
	    throw new IllegalStateException("Method must not be called if there are no supported export file types.");
	}
	// Convert list to dialog format.
	int size = fileTypes.size();
	String[] extensions = new String[size];
	String[] descriptions = new String[size];
	for (int i = 0; i < size; i++) {
	    FileType fileType = fileTypes.get(i);
	    extensions[i] = "*" + fileType.getExtension();
	    descriptions[i] = fileType.getDescription() + " (" + fileType.getExtension() + ")";
	}
	exportFileDialog.setFilterExtensions(extensions);
	exportFileDialog.setFilterNames(descriptions);

	fileName = exportFileDialog.open();
	if (fileName == null) {
	    return; // Canceled
	}

	// Find selected file type.
	String extension = FileUtility.getFileExtension(fileName);
	FileType selectedFileType = null;
	for (FileType fileType : fileTypes) {
	    if (fileType.getExtension().equalsIgnoreCase(extension)) {
		selectedFileType = fileType;
		break;
	    }
	}
	if (selectedFileType == null) {
	    // ERROR: Cannot export sound file as '{0}'. {1}
	    messageManager.sendMessage(MessageIds.FORMAT, IStatus.ERROR,
		    TextUtility.format(Texts.MESSAGE_E506, extension), "");
	    return;
	}

	int musicAddress = info.getMusicAddress();
	if (musicAddress >= 0 && selectedFileType.isMusicAddressChangeable()) {
	    String initialValue = HexUtility.getLongValueHexString(musicAddress, 4);
	    InputDialog inputDialog = new InputDialog(mainComposite.getShell(), TextUtility.format(Texts.MESSAGE_I507,
		    selectedFileType.getDescription()), Texts.MESSAGE_I508, initialValue, new IInputValidator() {

		@Override
		public String isValid(String newText) {
		    // ERROR: This is not a valid music address. Specify
		    // a hexadecimal value between '0000' and 'FFFF'.
		    try {
			int value = Integer.parseInt(newText, 16);
			if (value >= 0x0000 && value <= 0xffff) {
			    return null;
			}
		    } catch (NumberFormatException ignore) {

		    }
		    return TextUtility.format(Texts.MESSAGE_E509);
		}

	    });
	    if (inputDialog.open() != Window.OK) {
		return;
	    }
	    musicAddress = Integer.parseInt(inputDialog.getValue(), 16);

	}

	// Perform actual export.
	byte[] binary;
	try {
	    binary = player.getExportFileContent(selectedFileType, musicAddress);
	} catch (Exception ex) {
	    // ERROR: Cannot export sound file as '{0}'. {1}
	    messageManager.sendMessage(MessageIds.FORMAT, IStatus.ERROR,
		    TextUtility.format(Texts.MESSAGE_E506, selectedFileType.getDescription(), ex.getMessage()));
	    return;
	}

	File file = new File(fileName).getAbsoluteFile();
	try {
	    FileUtility.writeBytes(file, binary);
	} catch (CoreException ex) {
	    messageManager.sendMessage(MessageIds.FORMAT, ex);
	    return;
	}
	// INFO: Sound file exported as file '{0}' of type '{1}'.
	messageManager.sendMessage(MessageIds.FORMAT, IStatus.INFO, Texts.MESSAGE_I505, file.getPath(),
		selectedFileType.getDescription());

    }
}
