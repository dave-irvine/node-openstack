// Generated by CoffeeScript 1.8.0
(function() {
  var BaseModel, Domains,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseModel = require('../../BaseModel');

  Domains = (function(_super) {
    __extends(Domains, _super);

    function Domains() {
      this.show = __bind(this.show, this);
      this.all = __bind(this.all, this);
      this.init = __bind(this.init, this);
      return Domains.__super__.constructor.apply(this, arguments);
    }

    Domains.prototype.init = function() {
      return this.type = "identity";
    };

    Domains.prototype.all = function(params, fn) {
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
      return this.get("domains", (function(_this) {
        return function(data) {
          if (fn) {
            return fn(data);
          }
        };
      })(this));
    };

    Domains.prototype.show = function(params, fn) {
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
      return this.get("domains/" + params.domain_id, (function(_this) {
        return function(data) {
          if (fn) {
            return fn(data);
          }
        };
      })(this));
    };

    return Domains;

  })(BaseModel);

  module.exports = function(client) {
    return new Domains(client);
  };

}).call(this);
