module.exports = {
  build: {
    "index.html": "index.html",
    "app.css": "app.css",
    "app.js": "app.js",
    "img/": "img/",
    "js/": "js/",
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
      network_id: 180666,        // Custom ethereum template
      host: "hackminingnode0.northeurope.cloudapp.azure.com", // domain of ethereum client pointing to live network
      port: 8545
    },
    "development": {
      network_id: "default"
    },
    "consortium": {
      network_id: 8041971,        // Consortium ethereum template
      host: "bdfrlejdd.northeurope.cloudapp.azure.com:8545"
    }
  }
};
