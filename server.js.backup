const express = require('express');
const path = require('path');
const app = express();
const port = 3000;

// Serve static files from public folder
app.use(express.static(path.join(__dirname, 'public')));

// Default route for index.html
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(port, () => {
  console.log(`🚀 Server running at http://0.0.0.0:${port}`);
});
