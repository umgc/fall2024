const http = require('http');
const url = require('url');

const PORT = 3000;
const processRequest = require('./javascriptCompiler');

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
    case '/compile':
      // payload will be a list of filess
      if (req.method === 'POST' && req.headers['content-type'].includes('multipart/form-data')) {
        processRequest(req, res);
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

