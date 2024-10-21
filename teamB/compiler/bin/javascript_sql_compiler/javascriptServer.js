const http = require('http');
const url = require('url');

const PORT = 3000;
const processJSRequest = require('./javascriptCompiler');
const processSQLRequest = require('./sqlCompiler');
const processPythonRequest = require('./pythonCompiler');

function checkAuth(req) {
  const apiKey = req.headers['x-api-key'];
  return apiKey === process.env.COMPILER_KEY;
}

const server = http.createServer((req, res) => {
  console.log('Server has been created');
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;

  // Handle preflight OPTIONS request
  if (req.method === 'OPTIONS') {
    res.statusCode = 200;
    res.setHeader('Access-Control-Allow-Origin', '*'); // Allow all origins, adjust this as necessary
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS'); // Allow required methods
    res.setHeader('Access-Control-Allow-Headers', 'x-api-key, Content-Type'); // Allow custom headers
    res.setHeader('Access-Control-Max-Age', '86400'); // Cache preflight response for 1 day
    res.end(); // End the response here for preflight
    return;
  }

  // Check authorization
  if (!checkAuth(req)) {
    res.statusCode = 401;
    res.setHeader('Content-Type', 'text/plain');
    res.end('401 Unauthorized\n');
    return;
  }

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
         processPythonRequest(req, res);
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

