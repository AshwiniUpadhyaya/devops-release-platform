const http = require('http');
const client = require('prom-client');

const PORT = process.env.PORT || 3000;

// Collect default Node.js metrics (memory, CPU, etc.)
const register = new client.Registry();
client.collectDefaultMetrics({ register });

// A custom counter: total HTTP requests
const httpRequests = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  registers: [register],
});

const server = http.createServer(async (req, res) => {
  httpRequests.inc(); // count every request

  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'healthy' }));
    return;
  }

  if (req.url === '/metrics') {
    res.writeHead(200, { 'Content-Type': register.contentType });
    res.end(await register.metrics());
    return;
  }

  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end(`Autonomous Release Platform — version: ${process.env.VERSION || 'v1'}\n`);
});

server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
