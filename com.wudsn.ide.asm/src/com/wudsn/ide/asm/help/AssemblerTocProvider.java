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

package com.wudsn.ide.asm.help;

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

import com.wudsn.ide.asm.AssemblerPlugin;
import com.wudsn.ide.asm.CPU;
import com.wudsn.ide.asm.Texts;
import com.wudsn.ide.asm.compiler.CompilerDefinition;
import com.wudsn.ide.asm.compiler.CompilerRegistry;
import com.wudsn.ide.asm.preferences.AssemblerPreferences;
import com.wudsn.ide.base.common.EnumUtility;
import com.wudsn.ide.base.hardware.Hardware;

/**
 * Dynamic help content provider. Uses static pages and the meta data from the
 * compiler definitions to build a comprehensive help.
 * 
 * @author Peter Dell
 * 
 * @since 1.6.1
 */
public final class AssemblerTocProvider extends AbstractTocProvider {

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
			return AssemblerPlugin.ID;
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

	public AssemblerTocProvider() {
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
			ResourceBundle resourceBundle;
			resourceBundle = ResourceBundle.getBundle("com/wudsn/ide/asm/help/AssemblerTocProvider",
					Locale.getDefault(), AssemblerTocProvider.class.getClassLoader());
			label = resourceBundle.getString(key);
		} catch (MissingResourceException ex) {
			label = href + " - Text missing";
			AssemblerPlugin.getInstance().logError("Resource for enum value {0} is missing.", new Object[] { key }, ex);
		}
		return createTopic("", label, href, null);
	}

	// See[Bug 382599] Help: Icons not taken from IToc2/ITopic2 Implementations
	// https://bugs.eclipse.org/bugs/show_bug.cgi?id=382599
	@SuppressWarnings("restriction")
	private static ITopic createTopic(String icon, String label, String href, ITopic[] subtopics) {
		org.eclipse.help.internal.Topic result = new org.eclipse.help.internal.Topic();
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
		ITopic[] topicsArray;
		topicsArray = new ITopic[topics.size()];
		topics.toArray(topicsArray);
		return topicsArray;
	}

	static ITopic[] createTopics() {
		AssemblerPlugin assemblerPlugin = AssemblerPlugin.getInstance();
		CompilerRegistry compilerRegistry = assemblerPlugin.getCompilerRegistry();
		List<CompilerDefinition> compilerDefinitions = compilerRegistry.getCompilerDefinitions();

		List<ITopic> ideTopics = createIDETopics();
		List<ITopic> assemblerTopics = createAssemblerTopics(compilerDefinitions);
		List<ITopic> hardwareTopics = createHardwareTopics();
		List<ITopic> cpuTopics = createCPUTopics();

		List<ITopic> topics = new ArrayList<ITopic>();

		topics.add(createTopic("", Texts.TOC_IDE_TOPIC_LABEL, "", createTopicsArray(ideTopics)));
		topics.add(createTopic("", Texts.TOC_ASSEMBLERS_TOPIC_LABEL, "", createTopicsArray(assemblerTopics)));
		topics.add(createTopic("", Texts.TOC_HARDWARES_TOPIC_LABEL, "", createTopicsArray(hardwareTopics)));
		topics.add(createTopic("", Texts.TOC_CPUS_TOPIC_LABEL, "", createTopicsArray(cpuTopics)));

		return createTopicsArray(topics);
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

	private static List<ITopic> createAssemblerTopics(List<CompilerDefinition> compilerDefinitions) {
		if (compilerDefinitions == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinitions' must not be null.");
		}
		int size = compilerDefinitions.size();
		List<ITopic> assemblerTopics = new ArrayList<ITopic>(size);

		for (int i = 0; i < size; i++) {
			CompilerDefinition compilerDefinition = compilerDefinitions.get(i);

			String href = AssemblerHelpContentProducer.SCHEMA_COMPILER + compilerDefinition.getId() + "/"
					+ AssemblerHelpContentProducer.SECTION_GENERAL + AssemblerHelpContentProducer.EXTENSION;

			ITopic generalTopic = createTopic("", Texts.TOC_ASSEMBLER_GENERAL_TOPIC_LABEL, href, null);

			href = AssemblerHelpContentProducer.SCHEMA_COMPILER + compilerDefinition.getId() + "/"
					+ AssemblerHelpContentProducer.SECTION_INSTRUCTIONS + AssemblerHelpContentProducer.EXTENSION;
			ITopic opcodesTopic = createTopic("", Texts.TOC_ASSEMBLER_INSTRUCTIONS_TOPIC_LABEL, href, null);

			AssemblerPreferences assemblerPreferences = AssemblerPlugin.getInstance().getPreferences();
			String compilerExecutablePath = assemblerPreferences.getCompilerExecutablePath(compilerDefinition.getId());

			String icon = "";
			List<ITopic> manualTopics = new ArrayList<ITopic>();
			try {
				File file = compilerDefinition.getHelpFile(compilerExecutablePath);

				// Appending the help file path with the correct file
				// extension allows in-place display for example for ".html"
				// files.
				String extension = file.getPath();
				int index = extension.lastIndexOf('.');
				if (index > 0) {
					extension = extension.substring(index);
					if (extension.equalsIgnoreCase(".pdf")) {
						icon = "pdf";
					}
				} else {
					extension = ".html";
				}

				href = AssemblerHelpContentProducer.SCHEMA_COMPILER + compilerDefinition.getId() + "/"
						+ AssemblerHelpContentProducer.SECTION_MANUAL + extension;

				if (file.isDirectory()) {
					File[] files = file.listFiles();
					if (files != null) {
						for (File file2 : files) {
							String encodedPath;
							try {
								encodedPath = URLEncoder.encode(file2.getName(), "UTF-8");
							} catch (UnsupportedEncodingException ex) {
								throw new IllegalArgumentException("Cannot encode file name '" + file2.getName() + "'");
							}

							manualTopics.add(createTopic("", file2.getName(),
									href + "?" + AssemblerHelpContentProducer.SECTION_MANUAL_FILE + "=" + encodedPath,
									null));
						}
					}
					// if the file is folder, the manual does not have own
					// content but only sub-topics
					href = "";
				}
			} catch (CoreException ex) {
				href = AssemblerHelpContentProducer.SCHEMA_COMPILER + compilerDefinition.getId() + "/"
						+ AssemblerHelpContentProducer.SECTION_MANUAL + ".html";
			}

			ITopic manualTopic = createTopic(icon, Texts.TOC_ASSEMBLER_MANUAL_TOPIC_LABEL, href,
					createTopicsArray(manualTopics));

			assemblerTopics.add(createTopic("", compilerDefinition.getName(), "",
					new ITopic[] { generalTopic, opcodesTopic, manualTopic }));
		}
		return assemblerTopics;
	}

	private static List<ITopic> createHardwareTopics() {
		// Build hardware topics
		List<ITopic> hardwareTopics = new ArrayList<ITopic>(Hardware.values().length - 1);
		for (Hardware hardware : Hardware.values()) {
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
			case C64:
				chipTopics.add(createTopic("help/www.oxyron.de/html/registers_rec.html"));
				chipTopics.add(createTopic("help/www.oxyron.de/html/registers_sid.html"));
				chipTopics.add(createTopic("help/www.oxyron.de/html/registers_vic2.html"));
				break;
			default:
				// Nothing available.

			}
			String href = AssemblerHelpContentProducer.SCHEMA_HARDWARE + hardware.name().toLowerCase()
					+ AssemblerHelpContentProducer.EXTENSION;
			hardwareTopics.add(createTopic("", EnumUtility.getText(hardware), href, createTopicsArray(chipTopics)));
		}
		return hardwareTopics;
	}

	private static List<ITopic> createCPUTopics() {
		List<ITopic> cpuTopics = new ArrayList<ITopic>(CPU.values().length - 1);
		for (CPU cpu : CPU.values()) {
			String href = AssemblerHelpContentProducer.SCHEMA_CPU + cpu.name().toLowerCase()
					+ AssemblerHelpContentProducer.EXTENSION;
			cpuTopics.add(createTopic("", EnumUtility.getText(cpu), href, null));
		}
		return cpuTopics;
	}

}
