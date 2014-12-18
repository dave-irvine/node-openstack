// Generated by CoffeeScript 1.8.0
(function() {
  var debug, urljoin,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  debug = require('debug')('OpenStack:BaseModel');

  urljoin = require('url-join');

  module.exports = (function() {
    function exports(client) {
      this.client = client;
      this._init = __bind(this._init, this);
      this.load = __bind(this.load, this);
      this._init();
    }

    exports.prototype.load = function(model) {
      return require("./Models/" + model)(this.client);
    };

    exports.prototype._init = function() {
      this.debug = require('debug')("OpenStack:Models:" + this.constructor.name);
      this.get = function(path, query, fn) {
        debug("get()");
        switch (this.type) {
          case "compute":
            path = urljoin(this.client.options.endpoints.compute, path);
            break;
          case "identity":
            path = urljoin(this.client.options.endpoints.identity, path);
        }
        return this.client.get(path, query, fn);
      };
      this.post = this.client.post;
      this.put = this.client.put;
      this["delete"] = this.client["delete"];
      if (this.init) {
        return this.init();
      }
    };

    return exports;

  })();

}).call(this);