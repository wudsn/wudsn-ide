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

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

import org.eclipse.core.expressions.IEvaluationContext;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.help.AbstractTocProvider;
import org.eclipse.help.IToc;
import org.eclipse.help.ITocContribution;
import org.eclipse.help.ITopic;
import org.eclipse.help.ITopic2;
import org.eclipse.help.IUAElement;

import com.wudsn.ide.base.common.EnumUtility;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.LanguageUtility;
import com.wudsn.ide.lng.Target;
import com.wudsn.ide.lng.Texts;
import com.wudsn.ide.lng.compiler.CompilerDefinition;

/**
 * Dynamic help content provider. Uses static pages and the meta data from the
 * compiler definitions to build a comprehensive help.
 * 
 * @author Peter Dell
 * 
 * @since 1.6.1
 */
public final class LanguageTocProvider extends AbstractTocProvider {

	private static final class Toc implements IToc {
		private ITopic[] topics;

		public Toc() {

			topics = createTopics();
		}

		@Override
		public boolean isEnabled(IEvaluationContext context) {
			return true;
		}

		@Override
		public IUAElement[] getChildren() {
			return topics;
		}

		@Override
		public String getHref() {
			return "";
		}

		@Override
		public String getLabel() {
			return Texts.TOC_WUDSN_IDE_LABEL;
		}

		@Override
		public ITopic[] getTopics() {
			return topics;
		}

		@Override
		public ITopic getTopic(String href) {
			return topics[0];
		}
	}

	private static final class TocContribution implements ITocContribution {

		public TocContribution() {
		}

		@Override
		public String getCategoryId() {
			return "CategoryID";
		}

		@Override
		public String getContributorId() {
			return LanguagePlugin.ID;
		}

		@Override
		public String[] getExtraDocuments() {
			return new String[0];
		}

		@Override
		public String getId() {
			return "ID";
		}

		@Override
		public String getLocale() {
			return "";
		}

		@Override
		public String getLinkTo() {
			return "";
		}

		@Override
		public IToc getToc() {
			return new Toc();
		}

		@Override
		public boolean isPrimary() {
			return true;
		}

	}

	public LanguageTocProvider() {
	}

	@Override
	public ITocContribution[] getTocContributions(String locale) {
		return new ITocContribution[] { new TocContribution() };
	}

	private static ITopic createTopic(String href) {
		if (href == null) {
			throw new IllegalArgumentException("Parameter 'href' must not be null.");
		}

		String label;
		String key = href;
		try {
			var clazz = LanguageTocProvider.class;
			var resourceBundle = ResourceBundle.getBundle(clazz.getName().replace('.', '/'), Locale.getDefault(),
					clazz.getClassLoader());
			label = resourceBundle.getString(key);
		} catch (MissingResourceException ex) {
			label = href + " - Text missing";
			LanguagePlugin.getInstance().logError("Resource for enum value {0} is missing.", new Object[] { key }, ex);
		}
		return createTopic("", label, href, null);
	}

	// See[Bug 382599] Help: Icons not taken from IToc2/ITopic2 Implementations
	// https://bugs.eclipse.org/bugs/show_bug.cgi?id=382599
	@SuppressWarnings("restriction")
	private static ITopic createTopic(String icon, String label, String href, ITopic[] subtopics) {
		var result = new org.eclipse.help.internal.Topic();
		result.setAttribute(org.eclipse.help.internal.Topic.ATTRIBUTE_ICON, icon);
		result.setLabel(label);
		result.setHref(href);
		if (subtopics == null) {
			subtopics = new ITopic2[0];
		}
		result.appendChildren(subtopics);
		return result;
	}

	private static ITopic[] createTopicsArray(List<ITopic> topics) {
		if (topics == null) {
			throw new IllegalArgumentException("Parameter 'topics' must not be null.");
		}
		var topicsArray = new ITopic[topics.size()];
		topics.toArray(topicsArray);
		return topicsArray;
	}

	static ITopic[] createTopics() {
		List<ITopic> topics = new ArrayList<ITopic>();

		var languagePlugin = LanguagePlugin.getInstance();

		var ideTopics = createIDETopics();
		topics.add(createTopic("", Texts.TOC_IDE_TOPIC_LABEL, "", createTopicsArray(ideTopics)));

		var languagesTopics = createLanguagesTopics(languagePlugin);
		topics.add(createTopic("", Texts.TOC_LANGUAGES_TOPIC_LABEL, "", createTopicsArray(languagesTopics)));

		var hardwareTopics = createHardwareTopics();
		topics.add(createTopic("", Texts.TOC_HARDWARES_TOPIC_LABEL, "", createTopicsArray(hardwareTopics)));

		var cpuTopics = createTargetTopics();
		topics.add(createTopic("", Texts.TOC_TARGETS_TOPIC_LABEL, "", createTopicsArray(cpuTopics)));

		return createTopicsArray(topics);
	}

	private static List<ITopic> createLanguagesTopics(LanguagePlugin languagePlugin) {
		var compilerRegistry = languagePlugin.getCompilerRegistry();
		List<ITopic> topics = new ArrayList<ITopic>();
		for (var language : languagePlugin.getLanguages()) {

			var compilerDefinitions = compilerRegistry.getCompilerDefinitions(language);

			var compilerTopics = createCompilersTopics(compilerDefinitions);
			topics.add(createTopic("",
					TextUtility.format(Texts.TOC_COMPILERS_TOPIC_LABEL, LanguageUtility.getText(language)), "",
					createTopicsArray(compilerTopics)));
		}
		return topics;
	}

	private static List<ITopic> createIDETopics() {
		List<ITopic> topics = new ArrayList<ITopic>();

		topics.add(createTopic("help/ide-tutorials.section.html"));
		topics.add(createTopic("help/ide-features.section.html"));
		topics.add(createTopic("help/ide-installation.section.html"));
		topics.add(createTopic("help/ide-releases.section.html"));
		topics.add(createTopic("help/ide-faq.section.html"));
		topics.add(createTopic("help/ide-credits.section.html"));
		return topics;
	}

	private static List<ITopic> createCompilersTopics(List<CompilerDefinition> compilerDefinitions) {

		if (compilerDefinitions == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinitions' must not be null.");
		}
		var size = compilerDefinitions.size();
		var compilerTopics = new ArrayList<ITopic>(size);

		for (int i = 0; i < size; i++) {
			var compilerDefinition = compilerDefinitions.get(i);

			var href = LanguageHelpContentProducer.getComplierHref(compilerDefinition,
					LanguageHelpContentProducer.SECTION_GENERAL, null);

			var generalTopic = createTopic("", Texts.TOC_COMPILER_GENERAL_TOPIC_LABEL, href, null);

			href = LanguageHelpContentProducer.getComplierHref(compilerDefinition,
					LanguageHelpContentProducer.SECTION_INSTRUCTIONS, null);
			var opcodesTopic = createTopic("", Texts.TOC_COMPILER_INSTRUCTIONS_TOPIC_LABEL, href, null);

			var languagePreferences = LanguagePlugin.getInstance()
					.getLanguagePreferences(compilerDefinition.getLanguage());
			var compilerExecutablePath = languagePreferences.getCompilerExecutablePathOrDefault(compilerDefinition);

			var icon = "";
			var manualTopics = new ArrayList<ITopic>();
			try {
				var helpDocument = compilerDefinition.getInstalledHelpForCurrentLocale(compilerExecutablePath);
				if (helpDocument.file != null) {
					File file = helpDocument.file;

					// Appending the help file path with the correct file
					// extension allows in-place display for example for ".html"
					// files.
					var extension = file.getPath();
					int index = extension.lastIndexOf('.');
					if (index > 0) {
						extension = extension.substring(index);
						if (extension.equalsIgnoreCase(".pdf")) {
							icon = "pdf";
						}
					} else {
						extension = ".html";
					}

					href = LanguageHelpContentProducer.getComplierHref(compilerDefinition,
							LanguageHelpContentProducer.SECTION_MANUAL, extension);

					if (file.isDirectory()) {
						var files = file.listFiles();
						if (files != null) {
							for (var file2 : files) {
								String encodedPath;
								try {
									encodedPath = URLEncoder.encode(file2.getName(), "UTF-8");
								} catch (UnsupportedEncodingException ex) {
									throw new IllegalArgumentException(
											"Cannot encode file name '" + file2.getName() + "'");
								}

								manualTopics.add(createTopic(
										"", file2.getName(), href + "?"
												+ LanguageHelpContentProducer.SECTION_MANUAL_FILE + "=" + encodedPath,
										null));
							}
						}
						// if the file is folder, the manual does not have own
						// content but only sub-topics
						href = "";
					}
				} else {
					href = helpDocument.uri.toString(); // TODO Check if this works
				}
			} catch (CoreException ex) {

				href = LanguageHelpContentProducer.getComplierHref(compilerDefinition,
						LanguageHelpContentProducer.SECTION_MANUAL, null);
			}

			var manualTopic = createTopic(icon, Texts.TOC_COMPILER_MANUAL_TOPIC_LABEL, href,
					createTopicsArray(manualTopics));

			compilerTopics.add(createTopic("", compilerDefinition.getName(), "",
					new ITopic[] { generalTopic, opcodesTopic, manualTopic }));
		}
		return compilerTopics;
	}

	private static List<ITopic> createHardwareTopics() {
		// Build hardware topics
		List<ITopic> hardwareTopics = new ArrayList<ITopic>(Hardware.values().length - 1);
		for (var hardware : Hardware.values()) {
			if (hardware.equals(Hardware.GENERIC)) {
				continue;
			}
			List<ITopic> chipTopics = new ArrayList<ITopic>();
			switch (hardware) {

			case ATARI2600:
				chipTopics.add(createTopic("help/www.qotile.net/minidig/docs/sizes.txt"));
				chipTopics.add(createTopic("help/www.qotile.net/minidig/docs/2600_mem_map.txt"));
				chipTopics.add(createTopic("help/www.qotile.net/minidig/docs/stella.pdf"));
				chipTopics.add(createTopic("help/www.qotile.net/minidig/docs/2600_advanced_prog_guide.txt"));
				chipTopics.add(createTopic("help/www.qotile.net/minidig/docs/tia_color.html"));
				chipTopics.add(createTopic("help/www.qotile.net/minidig/docs/2600_tia_map.txt"));
				chipTopics.add(createTopic("help/www.qotile.net/minidig/docs/2600_riot_map.txt"));
				break;

			case ATARI8BIT:
				chipTopics.add(createTopic("help/www.oxyron.de/html/registers_antic.html"));
				chipTopics.add(createTopic("help/www.oxyron.de/html/registers_gtia.html"));
				chipTopics.add(createTopic("help/www.oxyron.de/html/registers_pokey.html"));
				break;

			case ATARI7800:
				chipTopics.add(createTopic("help/7800.8bitdev.org/index.html"));
				break;

			case C64:
				chipTopics.add(createTopic("help/www.oxyron.de/html/registers_rec.html"));
				chipTopics.add(createTopic("help/www.oxyron.de/html/registers_sid.html"));
				chipTopics.add(createTopic("help/www.oxyron.de/html/registers_vic2.html"));
				break;
			default:
				// Nothing available.

			}
			var href = LanguageHelpContentProducer.SCHEMA_HARDWARE + hardware.name().toLowerCase()
					+ LanguageHelpContentProducer.EXTENSION;
			hardwareTopics.add(createTopic("", EnumUtility.getText(hardware), href, createTopicsArray(chipTopics)));
		}
		return hardwareTopics;
	}

	private static List<ITopic> createTargetTopics() {
		List<ITopic> cpuTopics = new ArrayList<ITopic>(Target.values().length - 1);
		for (var target : Target.values()) {
			var href = LanguageHelpContentProducer.SCHEMA_TARGET + target.name().toLowerCase()
					+ LanguageHelpContentProducer.EXTENSION;
			cpuTopics.add(createTopic("", EnumUtility.getText(target), href, null));
		}
		return cpuTopics;
	}

}
