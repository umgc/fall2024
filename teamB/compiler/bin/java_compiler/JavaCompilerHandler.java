import java.io.*;
import java.nio.file.*;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class JavaCompilerHandler {

    private static final String UPLOAD_DIR = "uploads_java";

    // Method to handle multiple student files and one test file (test file must have '_main.java' in its name)
    public String processMultipleStudentFiles(List<MultipartFile> studentFiles, MultipartFile testFile) throws IOException, InterruptedException {
        // Create upload directory
        Path uploadDir = Paths.get(UPLOAD_DIR);
        if (Files.exists(uploadDir)) {
            deleteDirectory(uploadDir.toFile());
        }
        Files.createDirectories(uploadDir);

        // Save all student files
        for (MultipartFile studentFile : studentFiles) {
            saveFile(studentFile, uploadDir.toString());
        }

        // Save the test file, which must include '_main.java' in its name
        if (testFile != null && testFile.getOriginalFilename().contains("_main.java")) {
            String testFilePath = saveFile(testFile, uploadDir.toString());
            return compileAndRun(uploadDir.toString(), testFilePath);
        }

        return "Error: No valid test file (_main.java) found.";
    }

    // Method to handle zip file submissions (test file must have '_main.java' in its name)
    public String processZipSubmission(MultipartFile submissionZip) throws IOException, InterruptedException {
        Path uploadDir = Paths.get(UPLOAD_DIR);
        if (Files.exists(uploadDir)) {
            deleteDirectory(uploadDir.toFile());
        }
        Files.createDirectories(uploadDir);

        // Extract the zip file
        unzipFile(submissionZip, uploadDir.toString());

        // Identify the test file with '_main.java'
        File folder = new File(uploadDir.toString());
        File[] javaFiles = folder.listFiles((dir, name) -> name.endsWith(".java"));

        if (javaFiles != null) {
            for (File file : javaFiles) {
                if (file.getName().contains("_main.java")) {
                    // Compile and run the test file
                    return compileAndRun(uploadDir.toString(), file.getAbsolutePath());
                }
            }
        }

        return "Error: No valid test file (_main.java) found in the zip.";
    }

    // Helper method to save files to the filesystem
    private String saveFile(MultipartFile file, String uploadDir) throws IOException {
        Path filePath = Paths.get(uploadDir, file.getOriginalFilename());
        try (OutputStream os = Files.newOutputStream(filePath)) {
            os.write(file.getBytes());
        }
        return filePath.toString();
    }

    // Helper method to unzip a submission file
    private void unzipFile(MultipartFile zipFile, String destDir) throws IOException {
        try (ZipInputStream zis = new ZipInputStream(zipFile.getInputStream())) {
            ZipEntry zipEntry = zis.getNextEntry();
            while (zipEntry != null) {
                File newFile = new File(destDir, zipEntry.getName());
                if (zipEntry.isDirectory()) {
                    if (!newFile.isDirectory() && !newFile.mkdirs()) {
                        throw new IOException("Failed to create directory " + newFile);
                    }
                } else {
                    File parent = newFile.getParentFile();
                    if (!parent.isDirectory() && !parent.mkdirs()) {
                        throw new IOException("Failed to create directory " + parent);
                    }
                    try (FileOutputStream fos = new FileOutputStream(newFile)) {
                        byte[] buffer = new byte[1024];
                        int len;
                        while ((len = zis.read(buffer)) > 0) {
                            fos.write(buffer, 0, len);
                        }
                    }
                }
                zipEntry = zis.getNextEntry();
            }
            zis.closeEntry();
        }
    }

    // Helper method to compile and run Java files
    private String compileAndRun(String projectDir, String testFilePath) throws IOException, InterruptedException {
        // Compile all Java files in the projectDir
        String compileCommand = "javac " + projectDir + "/*.java";
        Process compileProcess = Runtime.getRuntime().exec(compileCommand);
        compileProcess.waitFor();

        if (compileProcess.exitValue() != 0) {
            return "Compilation failed!";
        }

        // Extract the name of the test file without the extension (to run it with 'java' command)
        String testFileName = new File(testFilePath).getName().replace(".java", "");

        // Run the test file (the one containing '_main.java')
        String runCommand = "java -cp " + projectDir + " " + testFileName;
        Process runProcess = Runtime.getRuntime().exec(runCommand);
        InputStream resultStream = runProcess.getInputStream();
        String result = new BufferedReader(new InputStreamReader(resultStream)).lines().reduce("", (acc, line) -> acc + line + "\n");

        if (runProcess.exitValue() != 0) {
            return "Execution failed!";
        }

        return result;
    }

    // Helper method to delete a directory
    private void deleteDirectory(File directory) throws IOException {
        Files.walk(directory.toPath())
                .map(Path::toFile)
                .forEach(File::delete);
    }
}