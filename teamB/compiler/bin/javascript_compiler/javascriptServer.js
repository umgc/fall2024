const http = require('http');
const url = require('url');

const PORT = 3000;

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
      // payload will be a list of files
      let body = '';
      req.on('data', (chunk) => {
        body += chunk.toString();
      });
      req.on('end', () => {
        console.log('Received data:', body);
        res.end(`You sent: ${body}\n`);
      });
      break;
    default:
      res.statusCode = 404;
      res.end('404 Not Found\n');
  }
});

server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}/`);
});

