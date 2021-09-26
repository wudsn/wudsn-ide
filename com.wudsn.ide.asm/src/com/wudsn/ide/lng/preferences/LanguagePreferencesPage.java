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

package com.wudsn.ide.lng.preferences;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import org.eclipse.jface.preference.ColorSelector;
import org.eclipse.jface.preference.FieldEditor;
import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.RadioGroupFieldEditor;
import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.util.PropertyChangeEvent;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.TabFolder;
import org.eclipse.swt.widgets.TabItem;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;
import org.eclipse.ui.model.WorkbenchViewerComparator;

import com.wudsn.ide.base.common.ProcessWithLogs;
import com.wudsn.ide.base.gui.SWTFactory;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.Language;
import com.wudsn.ide.lng.Texts;
import com.wudsn.ide.lng.compiler.CompilerDefinition;
import com.wudsn.ide.lng.compiler.CompilerRegistry;
import com.wudsn.ide.lng.editor.LanguageContentAssistProcessorDefaultCase;
import com.wudsn.ide.lng.editor.LanguageEditor;
import com.wudsn.ide.lng.editor.LanguageEditorCompileCommandPositioningMode;

/**
 * Visual editor page for the language preferences.
 * 
 * @author Peter Dell
 */
public abstract class LanguagePreferencesPage extends FieldEditorPreferencePage implements IWorkbenchPreferencePage {

	private abstract class TextAttributeSelectionListener implements SelectionListener {

		/**
		 * Creation is public.
		 */
		public TextAttributeSelectionListener() {
		}

		@Override
		public void widgetDefaultSelected(SelectionEvent e) {
		}

		@Override
		public void widgetSelected(SelectionEvent e) {
			TextAttributeListItem item = getTextAttributeListItem();
			if (item == null) {
				throw new IllegalStateException("No item selected.");
			}
			updateItem(item);
			textAttributeListItemsViewer.refresh();
			addChangedProperty(item.getPreferencesKey());
		}

		abstract protected void updateItem(TextAttributeListItem item);
	}

	/**
	 * The language.
	 */
	private Language language;
	
	/**
	 * The owning plugin.
	 */
	private LanguagePlugin plugin;

	/**
	 * The set of property names for which the value was changed since the page was
	 * opened.
	 */
	private Set<String> changedPropertyNames;

	/**
	 * The id of the compiler to be used as default.
	 */
	private String activeCompilerId;

	/**
	 * The list of all text attributes and the corresponding preferences keys.
	 */
	private String[][] textAttributeListItemKeys;

	/**
	 * List for text attribute items.
	 */
	List<TextAttributeListItem> textAttributeListItems;

	/**
	 * Highlighting color list viewer
	 */
	TableViewer textAttributeListItemsViewer;

	/**
	 * Color selector for foreground color.
	 */
	ColorSelector textAttributeForegroundColorSelector;

	/**
	 * Check box for bold setting.
	 */
	Button textAttributeBoldCheckBox;

	/**
	 * Check box for italic setting.
	 */
	Button textAttributeItalicCheckBox;

	/**
	 * Creation must be public default.
	 */
	public LanguagePreferencesPage(Language language) {
		super(GRID);
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		this.language = language;
		plugin = LanguagePlugin.getInstance();
		setPreferenceStore(plugin.getPreferenceStore());
		changedPropertyNames = new TreeSet<String>();
		textAttributeListItemKeys = new String[][] {
				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_COMMENT_NAME,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_COMMENT },
				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_NUMBER_NAME,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_NUMBER },
				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_STRING_NAME,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_STRING },
				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_DIRECTIVE,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_DIRECTVE },
				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_OPCODE_LEGAL_NAME,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_OPCODE_LEGAL },
				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_OPCODE_ILLEGAL_NAME,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_OPCODE_ILLEGAL },
				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_OPCODE_PSEUDO_NAME,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_OPCODE_PSEUDO },

				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_EQUATE,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_EQUATE },
				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_LABEL,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_LABEL },
				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_ENUM_DEFINITION_SECTION,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_ENUM_DEFINITION_SECTION },
				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_STRUCTURE_DEFINITION_SECTION,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_STRUCTURE_DEFINITION_SECTION },
				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_LOCAL_SECTION,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_LOCAL_SECTION },
				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_MACRO_DEFINITION_SECTION,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_MACRO_DEFINITION_SECTION },
				{ Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_PROCEDURE_DEFINITION_SECTION,
						LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_PROCEDURE_DEFINITION_SECTION } };
	}

	@Override
	public void init(IWorkbench workbench) {
		IEditorPart editor = workbench.getActiveWorkbenchWindow().getActivePage().getActiveEditor();
		if (editor instanceof LanguageEditor) {
			LanguageEditor languageEditor;
			languageEditor = (LanguageEditor) editor;
			activeCompilerId = languageEditor.getCompilerDefinition().getId();

		}
		changedPropertyNames.clear();
	}

	@Override
	public void createFieldEditors() {

		Composite parent = getFieldEditorParent();

		parent = SWTFactory.createComposite(parent, 1, 1, GridData.FILL_BOTH);
		initializeTextAttributesList();
		createSyntaxHighlightingGroup(parent);
		createEditorGroup(parent);
		createCompilersGroup(parent);
	}

	void addChangedProperty(String key) {
		if (key == null) {
			throw new IllegalArgumentException("Parameter 'key' must not be null.");
		}
		changedPropertyNames.add(key);
	}

	@Override
	public void dispose() {

		disposeTextAttributesList();
		super.dispose();
	}

	/**
	 * Creates all visual controls.
	 * 
	 * @param parent The parent object, not <code>null</code>.
	 */
	private void createSyntaxHighlightingGroup(Composite parent) {
		if (parent == null) {
			throw new IllegalArgumentException("Parameter 'parent' must not be null.");
		}
		Group group = SWTFactory.createGroup(parent, Texts.PREFERENCES_SYNTAX_HIGHLIGHTING_GROUP_TITLE, 2, 1,
				GridData.FILL_HORIZONTAL);
		Label label;
		GridLayout layout;
		GridData gd;

		textAttributeListItemsViewer = new TableViewer(group,
				SWT.SINGLE | SWT.V_SCROLL | SWT.BORDER | SWT.FULL_SELECTION);
		textAttributeListItemsViewer.setLabelProvider(new TextAttributeListItemProvider());
		textAttributeListItemsViewer.setContentProvider(new TextAttributeListContentProvider());
		textAttributeListItemsViewer.setComparator(new WorkbenchViewerComparator());
		gd = new GridData(SWT.BEGINNING, SWT.FILL, false, true);
		gd.heightHint = convertHeightInCharsToPixels(textAttributeListItems.size());
		textAttributeListItemsViewer.getControl().setLayoutData(gd);

		Composite stylesComposite = new Composite(group, SWT.NONE);
		layout = new GridLayout();
		layout.marginHeight = 0;
		layout.marginWidth = 0;
		layout.numColumns = 2;
		stylesComposite.setLayout(layout);
		stylesComposite.setLayoutData(new GridData(SWT.BEGINNING, SWT.BEGINNING, false, false));

		gd = new GridData(GridData.FILL_HORIZONTAL);
		gd.horizontalAlignment = GridData.BEGINNING;
		gd.horizontalSpan = 2;

		label = new Label(stylesComposite, SWT.LEFT);
		label.setText(Texts.PREFERENCES_FOREGROUND_COLOR_LABEL);
		gd = new GridData(GridData.HORIZONTAL_ALIGN_BEGINNING);
		gd.horizontalIndent = 20;
		label.setLayoutData(gd);

		textAttributeForegroundColorSelector = new ColorSelector(stylesComposite);
		Button foregroundColorButton = textAttributeForegroundColorSelector.getButton();
		gd = new GridData(GridData.HORIZONTAL_ALIGN_BEGINNING);
		foregroundColorButton.setLayoutData(gd);

		textAttributeBoldCheckBox = new Button(stylesComposite, SWT.CHECK);
		textAttributeBoldCheckBox.setText(Texts.PREFERENCES_BOLD_LABEL);
		gd = new GridData(GridData.HORIZONTAL_ALIGN_BEGINNING);
		gd.horizontalIndent = 20;
		gd.horizontalSpan = 2;
		textAttributeBoldCheckBox.setLayoutData(gd);

		textAttributeItalicCheckBox = new Button(stylesComposite, SWT.CHECK);
		textAttributeItalicCheckBox.setText(Texts.PREFERENCES_ITALIC_LABEL);
		gd = new GridData(GridData.HORIZONTAL_ALIGN_BEGINNING);
		gd.horizontalIndent = 20;
		gd.horizontalSpan = 2;
		textAttributeItalicCheckBox.setLayoutData(gd);

		textAttributeListItemsViewer.addSelectionChangedListener(new ISelectionChangedListener() {
			@Override
			public void selectionChanged(SelectionChangedEvent event) {
				handleSyntaxColorListSelection();
			}
		});

		foregroundColorButton.addSelectionListener(new TextAttributeSelectionListener() {
			@Override
			protected void updateItem(TextAttributeListItem item) {
				if (item == null) {
					throw new IllegalArgumentException("Parameter 'item' must not be null.");
				}
				TextAttribute textAttribute = item.getTextAttribute();
				Color foreground = textAttribute.getForeground();
				foreground.dispose();
				foreground = new Color(Display.getCurrent(), textAttributeForegroundColorSelector.getColorValue());
				item.setTextAttribute(new TextAttribute(foreground, textAttribute.getBackground(),
						textAttribute.getStyle(), textAttribute.getFont()));
			}

		});

		textAttributeBoldCheckBox.addSelectionListener(new TextAttributeSelectionListener() {
			@Override
			protected void updateItem(TextAttributeListItem item) {
				if (item == null) {
					throw new IllegalArgumentException("Parameter 'item' must not be null.");
				}
				TextAttribute textAttribute = item.getTextAttribute();
				int style = (textAttribute.getStyle() & ~SWT.BOLD)
						| (textAttributeBoldCheckBox.getSelection() ? SWT.BOLD : SWT.NONE);
				Font font = textAttribute.getFont();
				FontData fontData = font.getFontData()[0];
				fontData = new FontData(fontData.getName(), fontData.getHeight(), style);
				font.dispose();
				font = new Font(Display.getCurrent(), fontData);
				item.setTextAttribute(
						new TextAttribute(textAttribute.getForeground(), textAttribute.getBackground(), style, font));
			}
		});

		textAttributeItalicCheckBox.addSelectionListener(new TextAttributeSelectionListener() {
			@Override
			protected void updateItem(TextAttributeListItem item) {
				if (item == null) {
					throw new IllegalArgumentException("Parameter 'item' must not be null.");
				}
				TextAttribute textAttribute = item.getTextAttribute();
				int style = (textAttribute.getStyle() & ~SWT.ITALIC)
						| (textAttributeItalicCheckBox.getSelection() ? SWT.ITALIC : SWT.NONE);
				Font font = textAttribute.getFont();
				FontData fontData = font.getFontData()[0];
				fontData = new FontData(fontData.getName(), fontData.getHeight(), style);
				font.dispose();
				font = new Font(Display.getCurrent(), fontData);
				item.setTextAttribute(
						new TextAttribute(textAttribute.getForeground(), textAttribute.getBackground(), style, font));
			}
		});

		inittialzeTextAttributesListViewer();

		parent.layout();

	}

	/**
	 * FIll the list items view an set the selection to the first item.
	 */
	private void inittialzeTextAttributesListViewer() {
		textAttributeListItemsViewer.setInput(textAttributeListItems);
		textAttributeListItemsViewer
				.setSelection(new StructuredSelection(textAttributeListItemsViewer.getElementAt(0)));
	}

	/**
	 * Dispose the text attribute list.
	 */
	private void disposeTextAttributesList() {
		if (textAttributeListItems == null) {
			throw new IllegalStateException("Attribute 'textAttributeListItems' must not be null.");
		}
		for (TextAttributeListItem item : textAttributeListItems) {
			TextAttributeConverter.dispose(item.getTextAttribute());
		}
		textAttributeListItems = null;
	}

	/**
	 * Setup the text attribute list.
	 */
	private void initializeTextAttributesList() {
		if (textAttributeListItems != null) {
			throw new IllegalStateException("Attribute 'textAttributeListItems' must be null.");
		}
		textAttributeListItems = new ArrayList<TextAttributeListItem>(textAttributeListItemKeys.length);

		for (int i = 0, n = textAttributeListItemKeys.length; i < n; i++) {
			String data;
			TextAttribute textAttribute;
			TextAttributeListItem item;

			data = getPreferenceStore().getString(textAttributeListItemKeys[i][1]);
			textAttribute = TextAttributeConverter.fromString(data);

			item = new TextAttributeListItem(textAttributeListItemKeys[i][0], textAttributeListItemKeys[i][1]);
			item.setTextAttribute(textAttribute);
			textAttributeListItems.add(item);
		}
	}

	private void createEditorGroup(Composite parent) {
		if (parent == null) {
			throw new IllegalArgumentException("Parameter 'parent' must not be null.");
		}
		Group group = SWTFactory.createGroup(parent, Texts.PREFERENCES_EDITOR_GROUP_TITLE, 1, 1,
				GridData.FILL_HORIZONTAL);

		Composite space = SWTFactory.createComposite(group, 2, 1, GridData.FILL_HORIZONTAL);

		String[][] labelsAndValues;
		labelsAndValues = new String[][] { {

				Texts.PREFERENCES_CONTENT_ASSIST_PROCESSOR_DEFAULT_CASE_LOWER_CASE_TEXT,
				LanguageContentAssistProcessorDefaultCase.LOWER_CASE },
				{

						Texts.PREFERENCES_CONTENT_ASSIST_PROCESSOR_DEFAULT_CASE_UPPER_CASE_TEXT,
						LanguageContentAssistProcessorDefaultCase.UPPER_CASE }

		};

		FieldEditor choiceFieldEditor = new RadioGroupFieldEditor(
				LanguagePreferencesConstants.EDITOR_CONTENT_ASSIST_PROCESSOR_DEFAULT_CASE,
				Texts.PREFERENCES_CONTENT_ASSIST_PROCESSOR_DEFAULT_CASE_LABEL, 2, labelsAndValues, space);
		addField(choiceFieldEditor);

		labelsAndValues = new String[][] { {

				Texts.PREFERENCES_COMPILE_COMMAND_POSITIONING_MODE_FIRST_ERROR_OR_WARNING_TEXT,
				LanguageEditorCompileCommandPositioningMode.FIRST_ERROR_OR_WARNING },
				{

						Texts.PREFERENCES_COMPILE_COMMAND_POSITIONING_MODE_FIRST_ERROR_TEXT,
						LanguageEditorCompileCommandPositioningMode.FIRST_ERROR }

		};

		choiceFieldEditor = new RadioGroupFieldEditor(
				LanguagePreferencesConstants.EDITOR_COMPILE_COMMAND_POSITIONING_MODE,
				Texts.PREFERENCES_COMPILE_COMMAND_POSITIONING_MODE_LABEL, 2, labelsAndValues, space);
		addField(choiceFieldEditor);

	}

	private void createCompilersGroup(Composite parent) {
		if (parent == null) {
			throw new IllegalArgumentException("Parameter 'parent' must not be null.");
		}
		TabFolder tabFolder = new TabFolder(parent, SWT.NONE);
		TabItem selectedTabItem = null;

		// Create the editors for all compilers of the hardware.
		CompilerRegistry compilerRegistry = plugin.getCompilerRegistry();
		List<CompilerDefinition> compilerDefinitions = compilerRegistry.getCompilerDefinitions(language);

		for (CompilerDefinition compilerDefinition : compilerDefinitions) {
			String compilerId = compilerDefinition.getId();
			TabItem tabItem = new TabItem(tabFolder, SWT.NONE);
			tabItem.setText(compilerDefinition.getName());

			Composite tabContent;
			tabContent = SWTFactory.createComposite(tabFolder, 1, 1, GridData.FILL_HORIZONTAL);
			tabItem.setControl(tabContent);

			Composite composite;

			String name;
			name = LanguagePreferencesConstants.getCompilerExecutablePathName(compilerId);

			// Field: executablePath
			composite = SWTFactory.createComposite(tabContent, 4, 2, GridData.FILL_HORIZONTAL);
			FileFieldDownloadEditor fileFieldEditor = new FileFieldDownloadEditor(name,
					Texts.PREFERENCES_COMPILER_EXECUTABLE_PATH_LABEL, composite);
			fileFieldEditor.setFileExtensions(ProcessWithLogs.getExecutableExtensions());

			addField(fileFieldEditor);

			// Set URL only after editor was added.
			String url = compilerDefinition.getHomePageURL();
			fileFieldEditor.setLinkURL(url);

			if (compilerId.equals(activeCompilerId)) {
				selectedTabItem = tabItem;
			}
		}

		// Default to selected tab item.
		if (selectedTabItem != null) {
			tabFolder.setSelection(selectedTabItem);
		}
	}

	/**
	 * {@inheritDoc}
	 * 
	 * This method is called when "Apply" or "OK" is pressed.
	 */
	@Override
	public boolean performOk() {
		if (super.performOk()) {
			saveChanges();
			plugin.firePreferencesChangeEvent(changedPropertyNames);
			return true;
		}
		return false;
	}

	/**
	 * The field editor preference page implementation of a
	 * <code>PreferencePage</code> method loads all the field editors with their
	 * default values.
	 */
	@Override
	protected void performDefaults() {

		super.performDefaults();

		IPreferenceStore preferencesStore = getPreferenceStore();
		for (int i = 0, n = textAttributeListItemKeys.length; i < n; i++) {
			String key = textAttributeListItemKeys[i][1];
			preferencesStore.setValue(key, preferencesStore.getDefaultString(key));
			addChangedProperty(key);
		}

		disposeTextAttributesList();
		initializeTextAttributesList();
		inittialzeTextAttributesListViewer();
	}

	/**
	 * Saves all changes to the {@link IPreferenceStore}.
	 */
	private void saveChanges() {
		String data;
		IPreferenceStore store = getPreferenceStore();

		for (TextAttributeListItem listItem : textAttributeListItems) {
			data = TextAttributeConverter.toString(listItem.getTextAttribute());
			store.setValue(listItem.getPreferencesKey(), data);

		}

		plugin.savePreferences();

	}

	@Override
	public void propertyChange(PropertyChangeEvent event) {
		super.propertyChange(event);
		if (event.getSource() instanceof FieldEditor) {
			FieldEditor fieldEditor = (FieldEditor) event.getSource();
			addChangedProperty(fieldEditor.getPreferenceName());
		}
	}

	/**
	 * Update controls after item select.
	 */
	void handleSyntaxColorListSelection() {
		TextAttributeListItem item = getTextAttributeListItem();

		if (item == null) {
			return;
		}

		Color color;
		boolean bold;
		boolean italic;

		TextAttribute textAttribute = item.getTextAttribute();
		color = textAttribute.getForeground();
		bold = (textAttribute.getStyle() & SWT.BOLD) == SWT.BOLD;
		italic = (textAttribute.getStyle() & SWT.ITALIC) == SWT.ITALIC;

		textAttributeForegroundColorSelector.setColorValue(color.getRGB());
		textAttributeBoldCheckBox.setSelection(bold);
		textAttributeItalicCheckBox.setSelection(italic);

		textAttributeForegroundColorSelector.getButton().setEnabled(true);
		textAttributeBoldCheckBox.setEnabled(true);
		textAttributeItalicCheckBox.setEnabled(true);
	}

	/**
	 * Returns the current highlighting color list item.
	 * 
	 * @return The current highlighting color list item or <code>null</code>.
	 */
	TextAttributeListItem getTextAttributeListItem() {
		TextAttributeListItem listItem;
		IStructuredSelection selection = (IStructuredSelection) textAttributeListItemsViewer.getSelection();
		listItem = (TextAttributeListItem) selection.getFirstElement();
		return listItem;
	}

}
