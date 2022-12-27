package com.wudsn.ide.gfx;

import static com.wudsn.ide.base.common.Assertions.assertFalse;
import static com.wudsn.ide.base.common.Assertions.fail;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;

import com.wudsn.ide.base.common.MessageQueue;
import com.wudsn.ide.base.common.MessageQueue.Entry;
import com.wudsn.ide.base.common.TestMethod;
import com.wudsn.ide.gfx.converter.ConverterData;
import com.wudsn.ide.gfx.converter.ConverterDataLogic;
import com.wudsn.ide.gfx.model.ConverterMode;

// TODO Implement unit tests / hwo to run run as plugin test?
class GraphicsPluginTest {
	private static void assertContainsNoErrorMessage(MessageQueue messageQueue) {
		if (messageQueue.containsError()) {
			StringBuilder builder = new StringBuilder();
			for (Entry entry : messageQueue.getEntries()) {
				builder.append(entry.toString());
				builder.append(",");
			}
			fail(builder.toString());
		}

	};

	@TestMethod
	void test() {

		MessageQueue messageQueue = new MessageQueue();
		ConverterDataLogic converterDataLogic = new ConverterDataLogic(messageQueue);
		ConverterData converterData = converterDataLogic.createData();
		IPath path = new Path("Atari800/Graphics/GraphicsPluginTest.cnv"); // TODO Does not work
		IWorkspace workspace = ResourcesPlugin.getWorkspace();
		IFile file = workspace.getRoot().getFile(path);
		converterData.setFile(file);
		converterData.setConverterMode(ConverterMode.NONE);
		converterDataLogic.saveConversion(converterData, null);
		assertContainsNoErrorMessage(messageQueue);
		assertFalse(converterData.isChanged());

		converterData.clear();

		converterDataLogic.load(converterData);
		if (messageQueue.containsError()) {
			fail(messageQueue.getEntries().toString());
		}
		try {
			converterData.getParameters().read(file);
		} catch (CoreException ex) {
			fail(ex);
		}
		fail("Not yet implemented");
	}

}
