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

package com.wudsn.ide.lng.help;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.help.IHelpContentProducer;

import com.wudsn.ide.base.common.EnumUtility;
import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.base.hardware.HardwareUtility;
import com.wudsn.ide.lng.Language;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.LanguageUtility;
import com.wudsn.ide.lng.Target;
import com.wudsn.ide.lng.TargetUtility;
import com.wudsn.ide.lng.Texts;
import com.wudsn.ide.lng.compiler.CompilerDefinition;
import com.wudsn.ide.lng.compiler.CompilerPaths.CompilerPath;
import com.wudsn.ide.lng.compiler.CompilerRegistry;
import com.wudsn.ide.lng.compiler.syntax.CompilerSyntax;
import com.wudsn.ide.lng.compiler.syntax.CompilerSyntaxUtility;
import com.wudsn.ide.lng.compiler.syntax.Directive;
import com.wudsn.ide.lng.compiler.syntax.Instruction;
import com.wudsn.ide.lng.compiler.syntax.InstructionSet;
import com.wudsn.ide.lng.compiler.syntax.InstructionType;
import com.wudsn.ide.lng.compiler.syntax.Opcode;
import com.wudsn.ide.lng.compiler.syntax.Opcode.OpcodeAddressingMode;
import com.wudsn.ide.lng.preferences.LanguagePreferences;
import com.wudsn.ide.lng.runner.RunnerDefinition;
import com.wudsn.ide.lng.runner.RunnerId;
import com.wudsn.ide.lng.runner.RunnerRegistry;

/**
 * Dynamic help content provider. Uses static pages and the meta data from the
 * compiler definitions to build a comprehensive help.
 * 
 * @author Peter Dell
 * 
 * @since 1.6.1
 * 
 *        TODO Complete opcode entries in Compiler.xml, also for extended and
 *        illegal opcodes
 */
public final class LanguageHelpContentProducer implements IHelpContentProducer {

	// In order to get the navigation breadcrumbs automatically,
	// the files have to have this suffix (see BreadcrumbsFilter).
	public static final String EXTENSION = ".html";
	public static final String SECTION_EXTENSION = ".section.html";
	private static final String SECTION_PREFIX = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"
			+ "<html><head>" + "<meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\">"
			+ "<link rel=\"stylesheet\" href=\"../../../content/org.eclipse.platform/book.css\" type=\"text/css\"></link>"
			+ "<style type=\"text/css\">table,tbody,td,th {border-style:solid;border-width:1px;border-collapse:collapse; "
			+ "transition-value: background-color;transition-duration: 0.25s;transition-timing-function: linear;transition-delay: 0ms;} "
			+ "th {background-color:#0074cc;color:#fff } </style>" + "</head><body>";
	private static final String SECTION_SUFFIX = "</body></html>";

	public static final String SCHEMA_COMPILER = "compiler/";
	public static final String SCHEMA_HARDWARE = "hardware/";

	public static final String SECTION_GENERAL = "general";
	public static final String SECTION_INSTRUCTIONS = "instructions";
	public static final String SECTION_MANUAL = "manual";
	public static final String SECTION_MANUAL_FILE = "file";

	public static final String SCHEMA_TARGET = "target/";

	private static final String ICONS_PATH = "/help/topic/com.wudsn.ide.lng/icons/";
	private static final String HARDWARE_ICONS_PATH = "/help/topic/com.wudsn.ide.base/icons/";

	@Override
	public InputStream getInputStream(String pluginID, String href, Locale locale) {
		if (LanguagePlugin.ID.equals(pluginID)) {
			int index = href.indexOf("?");
			if (index >= 0) {
				href = href.substring(0, index);
			}
			if (href.startsWith(SCHEMA_COMPILER)) {
				return getCompilerInputStream(href);
			} else if (href.startsWith(SCHEMA_HARDWARE)) {
				return getHardwareInputStream(href);
			} else if (href.startsWith(SCHEMA_TARGET)) {
				return getTargetInputStream(href);
			} else if (href.endsWith(".html")) { // Web site documents
				return getHTMLInputStream(href);
			}
		}

		return null;
	}

	/**
	 * Gets the HTML input stream for HTML files.
	 * 
	 * @param href The href ending with ".html"
	 * @return The input stream, not <code>null</code>.
	 */
	private InputStream getHTMLInputStream(String href) {
		if (href == null) {
			throw new IllegalArgumentException("Parameter 'href' must not be null.");
		}
		LanguagePlugin plugin = LanguagePlugin.getInstance();
		IPath path = new Path(href);
		InputStream result;
		try {
			result = FileLocator.openStream(plugin.getBundle(), path, false);
			// HTML files that do not have an own <html> and <body> tag must be
			// wrapped.
			if (href.endsWith(SECTION_EXTENSION)) {
				result = new HTMLWrapperInputStream(SECTION_PREFIX, SECTION_SUFFIX, result);
			}
		} catch (IOException ex) {
			plugin.logError("Cannot open stream for {0}", new Object[] { href }, ex);
			result = null;
		}

		return result;
	}

	/**
	 * Create a string build for formatted help content.
	 * 
	 * @return The HTML write, not <code>null</code>.
	 */
	private HTMLWriter createHeader() {
		HTMLWriter writer = new HTMLWriter();

		writer.writeText(HTMLConstants.PREFIX);
		return writer;
	}

	/**
	 * Convert a string builder to an input stream.
	 * 
	 * @param writer The HTML writer, not <code>null</code>.
	 * @return The input stream, not <code>null</code>.
	 */
	private InputStream getInputStream(HTMLWriter writer) {
		if (writer == null) {
			throw new IllegalArgumentException("Parameter 'writer' must not be null.");
		}
		writer.writeText(HTMLConstants.SUFFIX);

		try {
			return new ByteArrayInputStream(writer.toHTML().getBytes(HTMLConstants.UTF8));
		} catch (UnsupportedEncodingException ex) {
			throw new RuntimeException(ex);
		}
	}

	private String getPath(String prefix, String href) {
		if (prefix == null) {
			throw new IllegalArgumentException("Parameter 'prefix' must not be null.");
		}
		if (href == null) {
			throw new IllegalArgumentException("Parameter 'href' must not be null.");
		}
		String path = href.substring(prefix.length());
		int index = path.indexOf("?");
		if (index >= 0) {
			path = path.substring(0, index);
		}

		index = path.lastIndexOf('.');
		if (index > -1) {
			path = path.substring(0, index);
			return path;
		}
		return null;
	}

	private Map<String, List<String>> getQueryParameters(String href) {
		if (href == null) {
			throw new IllegalArgumentException("Parameter 'href' must not be null.");
		}
		Map<String, List<String>> params = new HashMap<String, List<String>>();

		try {
			URI uri;
			try {
				uri = new URI(href);
			} catch (URISyntaxException ex1) {
				throw new RuntimeException("Cannot parse '" + href + "'", ex1);
			}
			String query = uri.getQuery();
			if (query != null) {
				for (String param : query.split("&")) {
					String pair[] = param.split("=");
					String key;

					key = URLDecoder.decode(pair[0], "UTF-8");

					String value = "";
					if (pair.length > 1) {
						value = URLDecoder.decode(pair[1], "UTF-8");
					}
					List<String> values = params.get(key);
					if (values == null) {
						values = new ArrayList<String>();
						params.put(key, values);
					}
					values.add(value);
				}
			}
		} catch (UnsupportedEncodingException ex) {
			throw new RuntimeException(ex);
		}
		return params;
	}

	/**
	 * Gets the href for a compiler.
	 * 
	 * @param section   The section or <code>null</code>.
	 * @param extension The extension or <code>null</code>.
	 * @return The href to a compiler including a trailing slash, not
	 *         <code>null</code>.
	 **/
	public static String getComplierHref(CompilerDefinition compilerDefinition, String section, String extension) {
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		String result = SCHEMA_COMPILER + compilerDefinition.getLanguage() + "/" + compilerDefinition.getId() + "/";
		if (section != null) {
			result += section + (extension == null ? EXTENSION : extension);
		}
		return result;
	}

	/**
	 * Gets the input stream for a compiler.
	 * 
	 * @param href Hyperlink reference in the form
	 *             /compiler/<language>/<compilerId>/section.
	 * @return The input stream or <code>null</code> if the path is not valid.
	 */
	private InputStream getCompilerInputStream(String href) {
		if (href == null) {
			throw new IllegalArgumentException("Parameter 'href' must not be null.");
		}

		String path = getPath(SCHEMA_COMPILER, href);
		if (path == null) {
			return null;
		}
		int index = path.indexOf("/");
		if (index <= 0) {
			return null;
		}
		String languageString = path.substring(0, index);
		path = path.substring(index + 1);
		index = path.indexOf("/");
		if (index <= 0) {
			return null;
		}
		String compilerId = path.substring(0, index);
		path = path.substring(index + 1);

		String section = path;
		LanguagePlugin languagePlugin = LanguagePlugin.getInstance();
		CompilerRegistry compilerRegistry = languagePlugin.getCompilerRegistry();

		// Find non-empty compiler executable path.
		var language = Language.valueOf(languageString);
		var compilerDefinition = compilerRegistry.getCompilerDefinitionById(language, compilerId);
		if (section.startsWith(SECTION_GENERAL)) {
			return getInputStream(getCompilerGeneralSection(compilerDefinition));
		} else if (section.startsWith(SECTION_MANUAL)) {
			LanguagePreferences languagePreferences = languagePlugin.getLanguagePreferences(language);

			try {
				var helpDocDocument = compilerDefinition.getInstalledHelpForCurrentLocale(
						languagePreferences.getCompilerExecutablePathOrDefault(compilerDefinition));
				File file = helpDocDocument.file;
				if (file == null) {
					throw new RuntimeException(
							"Method getCompilerInputStream() must only be called for existing files or folders.");
				}
				// Handle file requests within the help directory.
				List<String> fileNames = getQueryParameters(href).get(SECTION_MANUAL_FILE);
				String fileName;
				if (fileNames != null && fileNames.size() == 1) {
					fileName = fileNames.get(0);
				} else {
					fileName = "";
				}

				if (StringUtility.isSpecified(fileName)) {
					file = new File(file, fileName);
				}
				InputStream inputStream = new FileInputStream(file);

				index = file.getName().indexOf(".");
				if (index == -1 || file.getName().substring(index).equalsIgnoreCase(".txt")) {
					inputStream = new HTMLWrapperInputStream("<html><body><pre>", "</pre></body></html>", inputStream);
				}
				return inputStream;

			} catch (CoreException ex) {
				HTMLWriter writer = createHeader();
				writer.writeText(ex.getMessage());
				return getInputStream(writer);

			} catch (FileNotFoundException ex) {
				HTMLWriter writer = createHeader();
				writer.writeText(ex.getMessage());
				return getInputStream(writer);

			}

		} else if (section.equals(SECTION_INSTRUCTIONS)) {
			return getInputStream(getCompilerInstructionsSection(compilerDefinition));

		}
		return null;
	}

	private HTMLWriter getCompilerGeneralSection(CompilerDefinition compilerDefinition) {
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		HTMLWriter writer = createHeader();

		writer.beginTable(true);

		writer.writeTableRow(Texts.TOC_COMPILER_NAME_LABEL, compilerDefinition.getName());

		writer.writeTableRow(Texts.TOC_COMPILER_HOME_PAGE_LABEL,
				HTMLWriter.getLink(compilerDefinition.getHomePageURL(), compilerDefinition.getHomePageURL()));

		var helpDocuments = compilerDefinition.getHelpDocuments();
		HTMLWriter innerWriter = new HTMLWriter();
		if (!helpDocuments.isEmpty()) {
			innerWriter.beginTable(false);
			for (var helpDocument : helpDocuments) {
				innerWriter.beginTableRow();
				if (helpDocument.isURL()) {
					innerWriter.writeTableCell(HTMLWriter.getLink(helpDocument.path, helpDocument.path));
				} else {
					innerWriter.writeTableCell(helpDocument.path);
				}
				innerWriter.writeTableCell(helpDocument.language);
				innerWriter.end();
			}
			innerWriter.end();
		}
		writer.writeTableRowCode(Texts.TOC_COMPILER_HELP_DOCUMENTS_LABEL, innerWriter.toHTML());

		List<CompilerPath> defaultPaths = compilerDefinition.getDefaultPaths();
		innerWriter = new HTMLWriter();
		if (!defaultPaths.isEmpty()) {
			innerWriter.beginTable(true);
			innerWriter.beginTableRow();
			innerWriter.writeTableHeader(Texts.TOC_COMPILER_DEFAULT_PATHS_OS_LABEL);
			innerWriter.writeTableHeader(Texts.TOC_COMPILER_DEFAULT_PATHS_ARCHITECTURE_LABEL);
			innerWriter.writeTableHeader(Texts.TOC_COMPILER_DEFAULT_PATHS_ABSOULTE_PATH_LABEL);
			innerWriter.writeTableHeader(Texts.TOC_COMPILER_DEFAULT_PATHS_FILE_PRESENT_LABEL);
			innerWriter.end();
			for (CompilerPath compilerPath : defaultPaths) {
				innerWriter.beginTableRow();
				innerWriter.writeTableCell(compilerPath.os);
				innerWriter.writeTableCell(compilerPath.osArch);
				File file = compilerPath.getAbsoluteFile();
				boolean exists = (file != null && file.exists());
				// Display absolute path if available. This should always be the case.
				innerWriter.writeTableCell(file != null ? file.getAbsolutePath() : compilerPath.getRelativePath());
				innerWriter.writeTableCell(exists ? Texts.TOC_COMPILER_DEFAULT_PATHS_FILE_PRESENT_YES_LABEL
						: Texts.TOC_COMPILER_DEFAULT_PATHS_FILE_PRESENT_NO_LABEL);
				innerWriter.end();

			}
			innerWriter.end();
		}
		writer.writeTableRowCode(Texts.TOC_COMPILER_DEFAULT_PATHS_LABEL, innerWriter.toHTML());

		Hardware hardware = compilerDefinition.getDefaultHardware();
		writer.writeTableRow(Texts.TOC_COMPILER_DEFAULT_HARDWARE_LABEL, getHardwareIconImage(hardware));

		List<Target> cpus = compilerDefinition.getSupportedTargets();
		writer.beginTableRow();
		writer.writeTableHeader(Texts.TOC_COMPILER_SUPPORTED_TARGETS_LABEL);
		StringBuilder builder = new StringBuilder();
		for (int i = 0; i < cpus.size(); i++) {
			builder.append(EnumUtility.getText(cpus.get(i)));
			if (i < cpus.size() - 1) {
				builder.append(", ");
			}
		}
		writer.writeTableCell(builder.toString());
		writer.end();

		writer.beginTableRow();
		writer.writeTableHeader(Texts.TOC_COMPILER_DEFAULT_PARAMETERS_LABEL);

		writer.writeTableCell(compilerDefinition.getDefaultParameters());
		writer.end();

		CompilerSyntax compilerSyntax = compilerDefinition.getSyntax();

		writer.writeTableRow(Texts.TOC_COMPILER_SYNTAX_IDENTIFIERS_CASE_SENSITIVE,
				compilerSyntax.areIdentifiersCaseSensitive() ? Texts.TOC_COMPILER_SYNTAX_YES
						: Texts.TOC_COMPILER_SYNTAX_NO);

		writer.writeTableRowCode(Texts.TOC_COMPILER_SYNTAX_IDENTIFIER_START_CHARACTERS,
				getCompilerGeneralCharactersWrapped(compilerSyntax.getIdentifierStartCharacters()));

		writer.writeTableRowCode(Texts.TOC_COMPILER_SYNTAX_IDENTIFIER_PART_CHARACTERS,
				getCompilerGeneralCharactersWrapped(compilerSyntax.getIdentifierPartCharacters()));

		writer.writeTableRowCode(Texts.TOC_COMPILER_SYNTAX_IDENTIFIER_SEPARATOR_CHARACTER,
				compilerSyntax.getIdentifierSeparatorCharacter());

		writer.writeTableRow(Texts.TOC_COMPILER_SYNTAX_INSTRUCTIONS_CASE_SENSITIVE,
				compilerSyntax.areInstructionsCaseSensitive() ? Texts.TOC_COMPILER_SYNTAX_YES
						: Texts.TOC_COMPILER_SYNTAX_NO);

		writer.writeTableRowCode(Texts.TOC_COMPILER_SYNTAX_BLOCK_DEFINITION_CHARACTERS,
				compilerSyntax.getBlockDefinitionCharacters());

		writer.writeTableRowCode(Texts.TOC_COMPILER_SYNTAX_COMPLETION_PROPOSAL_AUTO_ACTIVATION_CHARACTERS,
				new String(compilerSyntax.getCompletionProposalAutoActivationCharacters()));

		writer.writeTableRowCode(Texts.TOC_COMPILER_SYNTAX_LABEL_DEFINITION_SUFFIX_CHARACTER,
				compilerSyntax.getLabelDefinitionSuffixCharacter());

		writer.writeTableRowCode(Texts.TOC_COMPILER_SYNTAX_MACRO_USAGE_PREFIX_CHARACTER,
				compilerSyntax.getMacroUsagePrefixCharacter());

		writer.writeTableRowCode(Texts.TOC_COMPILER_SYNTAX_SOURCE_INCLUDE_DEFAULT_EXTENSION,
				compilerSyntax.getSourceIncludeDefaultExtension());

		writer.writeTableRowCode(Texts.TOC_COMPILER_SYNTAX_MULTIPLE_LINES_COMMENT_DELIMITERS,
				HTMLWriter.getString(compilerSyntax.getMultipleLinesCommentDelimiters()));

		writer.writeTableRowCode(Texts.TOC_COMPILER_SYNTAX_SINGLE_LINE_COMMENT_DELIMITERS,
				HTMLWriter.getString(compilerSyntax.getSingleLineCommentDelimiters()));

		writer.writeTableRowCode(Texts.TOC_COMPILER_SYNTAX_STRING_DELIMITERS,
				HTMLWriter.getString(compilerSyntax.getStringDelimiters()));

		writer.end();

		return writer;

	}

	private String getCompilerGeneralCharactersWrapped(String text) {
		if (text == null) {
			throw new IllegalArgumentException("Parameter 'text' must not be null.");
		}
		int index = text.indexOf('Z');
		if (index > -1 && index < text.length() - 1) {
			text = text.substring(0, index + 1) + " " + text.substring(index + 1);
		}
		return text;
	}

	/**
	 * Creates an HTML string describing all instructions of the compiler.
	 * 
	 * @param compilerDefinition The compiler definition, not <code>null</code>.
	 * @return The HTML string builder describing all instructions of the compiler,
	 *         may be empty, not <code>null</code>.
	 */
	private HTMLWriter getCompilerInstructionsSection(CompilerDefinition compilerDefinition) {
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		HTMLWriter result = createHeader();

		CompilerSyntax syntax = compilerDefinition.getSyntax();
		List<Instruction> directives = new ArrayList<Instruction>();
		List<Instruction> legalOpcodes = new ArrayList<Instruction>();
		List<Instruction> illegalOpcodes = new ArrayList<Instruction>();
		List<Instruction> pseudoOpcodes = new ArrayList<Instruction>();
		List<Instruction> w65816Opcodes = new ArrayList<Instruction>();

		List<Target> cpus = compilerDefinition.getSupportedTargets();
		for (Target target : cpus) {
			for (Instruction instruction : syntax.getInstructionSet(target).getInstructions()) {

				if (instruction instanceof Directive) {
					if (!directives.contains(instruction)) {
						directives.add(instruction);
					}
				}
				if (instruction instanceof Opcode) {
					Opcode opcode = (Opcode) instruction;
					switch (opcode.getType()) {
					case InstructionType.LEGAL_OPCODE:
						if (!opcode.isW65816()) {
							if (!legalOpcodes.contains(instruction)) {

								legalOpcodes.add(opcode);
							}

						} else {
							if (!w65816Opcodes.contains(instruction)) {
								w65816Opcodes.add(opcode);
							}
						}
						break;
					case InstructionType.ILLEGAL_OPCODE:
						if (!illegalOpcodes.contains(instruction)) {

							illegalOpcodes.add(opcode);
						}
						break;
					case InstructionType.PSEUDO_OPCODE:
						if (!pseudoOpcodes.contains(instruction)) {
							pseudoOpcodes.add(opcode);
						}
						break;
					default:

					}
				}
			}
		}

		getCompilerInstructions(result, Texts.TOC_COMPILER_INSTRUCTION_TYPE_DIRECTIVES_LABEL, directives);
		getCompilerInstructions(result, Texts.TOC_COMPILER_INSTRUCTION_TYPE_LEGAL_OPCODES_LABEL, legalOpcodes);
		getCompilerInstructions(result, Texts.TOC_COMPILER_INSTRUCTION_TYPE_PSEUDO_OPCODES_LABEL, pseudoOpcodes);
		getCompilerInstructions(result, Texts.TOC_COMPILER_INSTRUCTION_TYPE_ILLEGAL_OPCODES_LABEL, illegalOpcodes);
		getCompilerInstructions(result, Texts.TOC_COMPILER_INSTRUCTION_TYPE_W65816_OPCODES_LABEL, w65816Opcodes);

		return result;
	}

	private void getCompilerInstructions(HTMLWriter writer, String title, List<Instruction> instructions) {
		if (writer == null) {
			throw new IllegalArgumentException("Parameter 'writer' must not be null.");
		}
		if (title == null) {
			throw new IllegalArgumentException("Parameter 'title' must not be null.");
		}
		if (instructions == null) {
			throw new IllegalArgumentException("Parameter 'instructions' must not be null.");
		}
		if (instructions.isEmpty()) {
			return;
		}

		Collections.sort(instructions);

		writer.begin("h3", null);
		writer.writeText(title);
		writer.end();

		writer.beginTable();
		writer.beginTableRow();
		writer.writeTableHeader(Texts.TOC_COMPILER_INSTRUCTION_TYPE_LABEL);
		writer.writeTableHeader(Texts.TOC_COMPILER_INSTRUCTION_NAME_LABEL);
		writer.writeTableHeader(Texts.TOC_COMPILER_INSTRUCTION_DESCRIPTION_LABEL);

		writer.end();

		for (Instruction instruction : instructions) {
			String typeImagePath = ICONS_PATH + CompilerSyntaxUtility.getTypeImagePath(instruction);
			String typeText = CompilerSyntaxUtility.getTypeText(instruction);
			StringBuilder styledTitle = new StringBuilder(instruction.getStyledTitle());
			int[] offsets = instruction.getStyledTitleOffsets();

			for (int j = offsets.length - 1; j >= 0; j--) {
				styledTitle.insert(offsets[j] + 1, "</u>");
				styledTitle.insert(offsets[j], "<u>");
			}

			writer.beginTableRow();
			writer.writeTableCell(HTMLWriter.getImage(typeImagePath, typeText, ""));
			writer.writeTableCell(instruction.getName());
			writer.writeTableCell(styledTitle.toString());
			writer.end();

		}
		writer.end();
	}

	private String getHardwareIconImage(Hardware hardware) {
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		return HTMLWriter.getImage(HARDWARE_ICONS_PATH + HardwareUtility.getImagePath(hardware), hardware.name(),
				hardware.name());
	}

	private InputStream getHardwareInputStream(String href) {
		if (href == null) {
			throw new IllegalArgumentException("Parameter 'href' must not be null.");
		}
		String path = getPath(SCHEMA_HARDWARE, href);
		if (path == null) {
			return null;
		}
		Hardware hardware = Hardware.valueOf(path.toUpperCase());
		LanguagePlugin languagePlugin = LanguagePlugin.getInstance();
		RunnerRegistry runnerRegistry = languagePlugin.getRunnerRegistry();

		HTMLWriter writer = createHeader();

		writer.beginTable();
		writer.writeTableRow(Texts.TOC_HARDWARE_NAME_LABEL, EnumUtility.getText(hardware));
		writer.writeTableRow(Texts.TOC_HARDWARE_ID_LABEL, hardware.name());
		writer.writeTableRow(Texts.TOC_HARDWARE_ICON_LABEL, getHardwareIconImage(hardware));

		writer.writeTableRow(Texts.TOC_HARDWARE_DEFAULT_FILE_EXTENSION_LABEL,
				HardwareUtility.getDefaultFileExtension(hardware));
		writer.end();

		writer.begin("br", null);
		writer.end();

		writer.beginTable();
		writer.beginTableRow();
		writer.writeTableHeader(Texts.TOC_HARDWARE_EMULATOR_LABEL);
		writer.writeTableHeader(Texts.TOC_HARDWARE_HOME_PAGE_LABEL);
		writer.writeTableHeader(Texts.TOC_HARDWARE_DEFAULT_PARAMETERS_LABEL);
		writer.end();

		List<RunnerDefinition> runnerDefinitions = runnerRegistry.getDefinitions(hardware);
		for (RunnerDefinition runnerDefinition : runnerDefinitions) {

			String runnerId = runnerDefinition.getId();
			if (runnerId.equals(RunnerId.DEFAULT_APPLICATION) || runnerId.equals(RunnerId.USER_DEFINED_APPLICATION)) {
				continue;
			}
			writer.beginTableRow();
			writer.writeTableCell(runnerDefinition.getName());
			writer.writeTableCell(
					HTMLWriter.getLink(runnerDefinition.getHomePageURL(), runnerDefinition.getHomePageURL()));
			writer.writeTableCell(runnerDefinition.getDefaultCommandLine());

			writer.end();

		}
		writer.end();

		return getInputStream(writer);
	}

	private InputStream getTargetInputStream(String href) {

		if (href == null) {
			throw new IllegalArgumentException("Parameter 'href' must not be null.");
		}
		String path = getPath(SCHEMA_TARGET, href);
		if (path == null) {
			return null;
		}

		Target target = Target.valueOf(path.toUpperCase());
		LanguagePlugin languagePlugin = LanguagePlugin.getInstance();
		CompilerRegistry compilerRegistry = languagePlugin.getCompilerRegistry();

		HTMLWriter writer = createHeader();

		writer.beginTable();
		writer.writeTableRow(Texts.TOC_TARGET_NAME_LABEL, EnumUtility.getText(target));
		Language language = TargetUtility.getLanguage(target);
		writer.writeTableRow(Texts.TOC_TARGET_LANGUAGE_LABEL, LanguageUtility.getText(language));
		writer.end();

		writer.begin("br", null);
		writer.end();

		writer.beginTable();
		writer.beginTableRow();

		writer.writeTableHeader(Texts.TOC_TARGET_OPCODE_LABEL);
		writer.writeTableHeader(Texts.TOC_COMPILER_INSTRUCTION_DESCRIPTION_LABEL);

		List<CompilerDefinition> compilerDefinitions = compilerRegistry.getCompilerDefinitions(language);
		List<InstructionSet> instructionSets = new ArrayList<InstructionSet>();
		for (CompilerDefinition compilerDefinition : compilerDefinitions) {
			if (compilerDefinition.getSupportedTargets().contains(target)) {
				String compilerHref = "../"
						+ LanguageHelpContentProducer.getComplierHref(compilerDefinition, SECTION_GENERAL, null);

				writer.writeTableHeader(HTMLWriter.getLink(compilerHref, compilerDefinition.getName()));

				instructionSets.add(compilerDefinition.getSyntax().getInstructionSet(target));
			}

		}

		writer.end();

		List<String> cellContents = new ArrayList<String>(instructionSets.size());

		for (int opcode = 0; opcode < Opcode.MAX_OPCODES; opcode++) {
			String opcodeText = null;
			cellContents.clear();

			for (InstructionSet instructionSet : instructionSets) {
				List<OpcodeAddressingMode> opcodeAddressingModes = instructionSet.getOpcodeAddressingModes(opcode);
				StringBuffer cellBuffer = new StringBuffer();
				for (int m = 0; m < opcodeAddressingModes.size(); m++) {
					// There should only be one, but be robust here.
					if (m > 0 && m < opcodeAddressingModes.size()) {
						cellBuffer.append("<br/>");
					}
					OpcodeAddressingMode opcodeAddressingMode = opcodeAddressingModes.get(m);
					if (opcodeText == null) {
						opcodeText = opcodeAddressingMode.getOpcode().getStyledTitle();
					}
					cellBuffer.append(opcodeAddressingMode.getFormattedText());
				}
				cellContents.add(cellBuffer.toString());

			}

			if (opcodeText != null) {
				writer.beginTableRow();
				writer.writeTableCell(HexUtility.getByteValueHexString(opcode));
				writer.writeTableCell(opcodeText);

				for (int c = 0; c < instructionSets.size(); c++) {

					writer.writeTableCell(cellContents.get(c));

				}
				writer.end();
			}
		}

		writer.end();

		return getInputStream(writer);
	}

}
