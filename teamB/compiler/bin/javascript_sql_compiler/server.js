const http = require('http');
const url = require('url');

const PORT = 3000;
const processJSRequest = require('./javascriptCompiler');
const processSQLRequest = require('./sqlCompiler');
const processPyRequest = require('./pythonCompiler');

const server = http.createServer((req, res) => {
  console.log('Server has been created');
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;

  // Set response headers
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');

  // Handle different routes
  switch (path) {
    case '/':
      res.end('JavaScript Server is accessible!\n');
      break;
    case '/compile/js':
      console.log(req.headers);
      if (req.method === 'POST' && req.headers['content-type']?.includes('multipart/form-data')) {
        processJSRequest(req, res);
      } else {
        res.statusCode = 400;
        res.end('400 Bad Request\n');
      }
      break;
    case '/compile/sql':
       if (req.method === 'POST' && req.headers['content-type'].includes('multipart/form-data')) {
        processSQLRequest(req, res);
      } else {
        res.statusCode = 400;
        res.end('400 Bad Request\n');
      }
      break;
    case '/compile/python':
        if (req.method === 'POST' && req.headers['content-type'].includes('multipart/form-data')) {
         processPyRequest(req, res);
       } else {
         res.statusCode = 400;
         res.end('400 Bad Request\n');
       }
       break;
    default:
      res.statusCode = 404;
      res.end('404 Not Found\n');
  }
});

server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}/`);
});

