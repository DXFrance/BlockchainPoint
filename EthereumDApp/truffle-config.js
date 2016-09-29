module.exports = {
  build: {
    "index.html": "index.html",
    "app.css": "app.css",
    "img/": "img/",
    "QR/": "QR/",
    "app.js": "app.js",
    "bower_components/": "bower_components"
  },
  rpc: {
    host: "localhost",
    port: 8545
   },
  networks: {
    "public": {
      network_id: 1, // Ethereum public network
      // optional config values
      // host - defaults to "localhost"
      // port - defaults to 8545
      // gas
      // gasPrice
      // from - default address to use for any transaction Truffle makes during migrations
    },
    "production": {
      network_id: 180666,        // Official Ethereum test network
      host: "hackminingnode0.northeurope.cloudapp.azure.com", // domain of ethereum client pointing to live network
      port: 8545
    },
    "development": {
      network_id: "default"
    },
    "bletchley": {
      network_id: 112358,
      host: "tconte4kv.northeurope.cloudapp.azure.com"
    }
  }
};
