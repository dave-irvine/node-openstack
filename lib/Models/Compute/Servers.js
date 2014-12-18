// Generated by CoffeeScript 1.8.0
(function() {
  var BaseModel, Servers,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseModel = require('../../BaseModel');

  Servers = (function(_super) {
    __extends(Servers, _super);

    function Servers() {
      this.show = __bind(this.show, this);
      this.all = __bind(this.all, this);
      this.init = __bind(this.init, this);
      return Servers.__super__.constructor.apply(this, arguments);
    }

    Servers.prototype.init = function() {
      return this.type = "compute";
    };

    Servers.prototype.all = function(params, fn) {
      var detail, query;
      if (params == null) {
        params = {};
      }
      if (fn == null) {
        fn = null;
      }
      this.debug("all()");
      if (typeof params === 'function') {
        fn = params;
        params = {};
      }
      query = {};
      if (params.tenant_id) {
        query.context = params.tenant_id;
      } else {
        query.all_tenants = 1;
        query.context = "%context%";
      }
      if (params.detail) {
        detail = "/detail";
      } else {
        detail = "";
      }
      return this.get("%context%/servers" + detail, query, (function(_this) {
        return function(data) {
          if (fn) {
            return fn(data);
          }
        };
      })(this));
    };

    Servers.prototype.show = function(params, fn) {
      if (params == null) {
        params = {};
      }
      if (fn == null) {
        fn = null;
      }
      this.debug("show()");
      if (typeof params === 'function') {
        fn = params;
        params = {};
      }
      return this.get("servers/" + params.endpoint_id, (function(_this) {
        return function(data) {
          if (fn) {
            return fn(data);
          }
        };
      })(this));
    };

    return Servers;

  })(BaseModel);

  module.exports = function(client) {
    return new Servers(client);
  };

}).call(this);