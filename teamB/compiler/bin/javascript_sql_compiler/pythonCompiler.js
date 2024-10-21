const busboy = require('busboy');
const fs = require('fs');
const fsPromises = require('fs').promises;
const path = require('path');
const util = require('util');
const exec = util.promisify(require('child_process').exec);

const currentDir = __dirname;
const uploadDir = path.join(currentDir, 'uploads_py');

async function processPythonRequest(req, res) {
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

        const savePath = path.join(uploadDir, filename);
        const writeStream = fs.createWriteStream(savePath);

        if (filename.endsWith('_test.py')) {
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

  let finalResponse = "";

  for (const file of files) {
      if (file.filename.endsWith('_test.py')) {
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
  const { stdout } = await exec(`python3 ${unitTestPath} ${testFile}`);
  return stdout;
}

module.exports = processPythonRequest;