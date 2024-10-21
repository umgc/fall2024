import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@SpringBootApplication
public class JavaServerApp {

    public static void main(String[] args) {
        SpringApplication.run(JavaServerApp.class, args);
    }
}

@RestController
@RequestMapping("/compile/java")
class JavaCompilerController {

    private final JavaCompilerHandler compilerHandler = new JavaCompilerHandler();

    @PostMapping
    public String handleJavaSubmission(@RequestParam("studentFiles") List<MultipartFile> studentFiles,
                                       @RequestParam("testFile") MultipartFile testFile,
                                       @RequestParam(value = "submissionZip", required = false) MultipartFile submissionZip) {
        try {
            System.out.println("Received POST request at /compile/java");

            // If a zip file is provided, process it accordingly
            if (submissionZip != null) {
                return compilerHandler.processZipSubmission(submissionZip);
            }

            // Process multiple student files and a single test file (test file must have '_main.java')
            return compilerHandler.processMultipleStudentFiles(studentFiles, testFile);

        } catch (Exception e) {
            System.err.println("Error processing request: " + e.getMessage());
            return "Internal server error: " + e.getMessage();
        }
    }
}