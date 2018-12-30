import java.io.File;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import org.apache.commons.compress.archivers.zip.*;

// Test
public class Main {

    public static void main(String[] args) throws Exception {

	String file = "C:\\Users\\D025328\\Documents\\Eclipse\\workspace.jac\\com.wudsn.site\\site\\productions\\atari800\\thecartstudio\\thecartstudio.zip";
	System.out.println(file);
	ZipFile zipFile=new ZipFile(new File(file));
	ZipEntry entry=zipFile.getEntry("TheCartStudio.jar");
	System.out.println(entry+":"+ entry.getSize());
	ZipArchiveEntry archiveEntry=new ZipArchiveEntry(entry);
	System.out.println(archiveEntry+":"+ archiveEntry.getUnixMode());
	zipFile.close();
    }

}
