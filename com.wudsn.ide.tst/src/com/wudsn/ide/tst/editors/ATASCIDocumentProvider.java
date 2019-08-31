package com.wudsn.ide.tst.editors;

//import static org.eclipse.ui.editors.text.FileDocumentProvider.CHARSET_UTF_16;
//import static org.eclipse.ui.editors.text.FileDocumentProvider.CHARSET_UTF_16LE;
//import static org.eclipse.ui.editors.text.FileDocumentProvider.CHARSET_UTF_8;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;

import org.eclipse.core.filebuffers.manipulation.ContainerCreator;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.SubMonitor;
import org.eclipse.jface.text.IDocument;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.editors.text.FileDocumentProvider;
//import org.eclipse.ui.internal.editors.text.NLSUtility;
import org.eclipse.ui.texteditor.ResourceMarkerAnnotationModel;

// TODO Implement correctly
public class ATASCIDocumentProvider extends FileDocumentProvider {

    private static final String ENCODING = "US-ASCII";
    private static final char EOL = 0x9b;
    private static final char NL = 0x0a;

    @Override
    protected IDocument createDocument(Object element) throws CoreException {
	IDocument document = super.createDocument(element);
	if (document != null) {
	    System.out.println(element);
	    System.out.println(document);
	}
	return document;
    }

    /**
     * Initializes the given document with the given stream using the given
     * encoding.
     * 
     * @param document
     *            the document to be initialized
     * @param contentStream
     *            the stream which delivers the document content
     * @param encoding
     *            the character encoding for reading the given stream
     * @throws CoreException
     *             if the given stream can not be read
     * @since 2.0
     */
    @Override
    protected void setDocumentContent(IDocument document, InputStream contentStream, String encoding)
	    throws CoreException {

	InputStream in = null;

	try {

	    // if (encoding == null) {
	    // encoding = getDefaultEncoding();
	    // }
	    encoding = ENCODING;
	    in = contentStream;
	    StringBuilder builder = new StringBuilder(DEFAULT_FILE_SIZE);
	    byte[] readBuffer = new byte[2048];
	    int n = in.read(readBuffer);
	    while (n > 0) {
		for (int i = 0; i < n; i++) {
		    int c = readBuffer[i] & 0xff;
		    if (c == EOL) {
			c = NL;
		    }
		    c = c & 0x7f; // Currently the real charset is not there, so
				  // mask out the inverse bit
		    builder.append((char) c);
		}
		n = in.read(readBuffer);
	    }
	    String text = builder.toString();
	    document.set(text);

	} catch (IOException x) {
	    String message = (x.getMessage() != null ? x.getMessage() : ""); //$NON-NLS-1$
	    IStatus s = new Status(IStatus.ERROR, PlatformUI.PLUGIN_ID, IStatus.OK, message, x);
	    throw new CoreException(s);
	} finally {
	    try {
		if (in != null)
		    in.close();
		else
		    contentStream.close();
	    } catch (IOException x) {
	    }
	}
    }

    @Override
    protected void doSaveDocument(IProgressMonitor monitor, Object element, IDocument document, boolean overwrite)
	    throws CoreException {
	if (element instanceof IFileEditorInput) {

	    IFileEditorInput input = (IFileEditorInput) element;
	    FileInfo info = (FileInfo) getElementInfo(element);
	    IFile file = input.getFile();

	    byte[] bytes = null;
	    try {
		bytes = document.get().getBytes(ENCODING);

	    } catch (UnsupportedEncodingException ex) {
		throw new CoreException(new Status(IStatus.ERROR, "com.wudsn.ide.tst", ex.getMessage()));
	    }
	    for (int i = 0; i < bytes.length; i++) {
		if (bytes[i] == NL) {
		    bytes[i] = (byte) EOL;
		}
	    }
	    InputStream stream = new ByteArrayInputStream(bytes);
	    if (file.exists()) {

		if (info != null && !overwrite) {
		    checkSynchronizationState(info.fModificationStamp, file);
		}
		// inform about the upcoming content change
		fireElementStateChanging(element);
		try {
		    file.setContents(stream, overwrite, true, monitor);
		} catch (CoreException x) {
		    // inform about failure
		    fireElementStateChangeFailed(element);
		    throw x;
		} catch (RuntimeException x) {
		    // inform about failure
		    fireElementStateChangeFailed(element);
		    throw x;
		}

		// If here, the editor state will be flipped to "not dirty".
		// Thus, the state changing flag will be reset.

		if (info != null) {

		    ResourceMarkerAnnotationModel model = (ResourceMarkerAnnotationModel) info.fModel;
		    if (model != null)
			model.updateMarkers(info.fDocument);

		    info.fModificationStamp = computeModificationStamp(file);
		}

	    } else {
		try {
		    monitor.beginTask("Saving...", 2000);
		    ContainerCreator creator = new ContainerCreator(file.getWorkspace(),
			    file.getParent().getFullPath());
		    creator.createContainer(SubMonitor.convert(monitor, 1000));
		    file.create(stream, false, SubMonitor.convert(monitor, 1000));
		} finally {
		    monitor.done();
		}
	    }

	} else {
	    super.doSaveDocument(monitor, element, document, overwrite);
	}
    }
}