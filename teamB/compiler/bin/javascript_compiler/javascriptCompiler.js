const busboy = require('busboy');
const fs = require('fs');
const fsPromises = require('fs').promises;
const path = require('path');
const util = require('util');
const exec = util.promisify(require('child_process').exec);

const currentDir = __dirname;
const uploadDir = path.join(currentDir, 'uploads_js');

async function processRequest(req, res) {
    const bb = busboy({ headers: req.headers });
    const unitTestFile = {};
    const filePromises = [];
    const uploadedFiles = [];
    let hasInvalidFile = false;

    // Ensure the upload directory exists
    await fsPromises.mkdir(uploadDir, { recursive: true });

    bb.on('file', (name, file, info) => {
        const { filename, encoding, mimeType } = info;
        console.log(`File [${name}]: Filename: ${filename}, Encoding: ${encoding}, MimeType: ${mimeType}`);

        if (mimeType !== 'application/javascript') {
            hasInvalidFile = true;
            file.resume(); // Discard this file
            return;
        }

        const savePath = path.join(uploadDir, filename);
        const writeStream = fs.createWriteStream(savePath);

        if (filename.endsWith('_test.js')) {
          unitTestFile.filename = filename;
          unitTestFile.path = savePath;
        }

        const filePromise = new Promise((resolve, reject) => {
            file.pipe(writeStream);
            writeStream.on('finish', () => {
                console.log(`File saved: ${savePath}`);
                uploadedFiles.push({ filename, path: savePath });
                resolve();
            });
            writeStream.on('error', reject);
        });

        filePromises.push(filePromise);
    });

    bb.on('close', async () => {
        if (hasInvalidFile) {
            // Clean up any files that were uploaded before the invalid one was detected
            for (const file of uploadedFiles) {
                await fsPromises.unlink(file.path).catch(console.error);
            }
            res.statusCode = 400;
            res.end('Invalid files found. Please only submit JavaScript files to this request.');
            return;
        }

        try {
            await Promise.all(filePromises);
            console.log('All files processed');

            // Process the uploaded files
            const finalResponse = await processUploadedFiles(uploadedFiles, unitTestFile);

            res.writeHead(200, { 'Connection': 'close' });
            res.end(finalResponse);
        } catch (error) {
            console.error('Error processing files:', error);
            res.writeHead(500, { 'Connection': 'close' });
            res.end('Error processing files');
        }
    });

    req.pipe(bb);
}

async function processUploadedFiles(files, unitTestFile) {
  console.log('Processing uploaded files:', files);
  // Implement your file processing logic here
  // For example, you might want to compile JavaScript files or run tests
  let finalResponse = "";

  for (const file of files) {
      if (file.filename.endsWith('_test.js')) {
          console.log(`Skipping Unit Case File: ${file.filename}`);
      } else {
          console.log(`Processing submission: ${file.filename}`);
          // Process student submission
          const runRes = await runTest(file.filename, unitTestFile.path);
          finalResponse += runRes;
      }
  }
  return finalResponse;
}

async function runTest(testFile, unitTestPath) {
  // Implement test running logic
  console.log(`Running test: node ${unitTestPath} ${testFile} `);
  //const res = await executeCommand(`node ${testFilePath} ${unitTestPath}`);
  const { stdout } = await exec(`node ${unitTestPath} ${testFile}`);

  return stdout;
}

// Function to execute a command
function executeCommand(command) {
  return new Promise((resolve, reject) => {
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error executing command: ${error.message}`);
        reject(error);
        return;
      }
      if (stderr) {
        console.error(`Command stderr: ${stderr}`);
      }
      console.log(`Command stdout: ${stdout}`);
      resolve(stdout);
    });
  });
}

module.exports = processRequest;

