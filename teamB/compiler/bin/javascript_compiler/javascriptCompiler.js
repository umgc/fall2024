const busboy = require('busboy');
const fs = require('fs');
const { exec } = require('child_process');

function processRequst(req, res) {
    const bb = busboy({ headers: req.headers });

    console.log(bb);

    // Unit Test files => _test.js
    // Student Submissions files => anything else .js
    // No limit on the amount of files given to the API 

    bb.on('file', (name, file, info) => {
      const { filename, encoding, mimeType } = info;
      console.log(`File [${name}]: Filename: ${filename}, Encoding: ${encoding}, MimeType: ${mimeType}`);

      const savePath = `${__dirname}/uploads/${filename}`;
      file.pipe(fs.createWriteStream(savePath));
    });

    bb.on('field', (name, value, info) => {
      console.log(`Field [${name}]: Value: ${value}`);
    });

    bb.on('close', () => {
      console.log('Done parsing form!');
      res.writeHead(200, { 'Connection': 'close' });
      res.end('Success!');
    });

    req.pipe(bb);
}

// Using files given from the API request, we can create the submission files locally in the folder
// We can then use exec() to run the Unit Test file which will use the logic provided by each of the submissions
function compileJavaScript(files) {
    // Implement JavaScript compilation logic here
    console.log('Compiling JavaScript files:', files);
}

module.exports = processRequst;
