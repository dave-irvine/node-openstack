// Generated by CoffeeScript 1.8.0
(function() {
  var ApiBase, debug, urljoin, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  debug = require('debug')('OpenStack');

  ApiBase = require('./ApiBase').ApiBase;

  urljoin = require('url-join');

  _ = require('underscore');

  module.exports.OpenStack = (function(_super) {
    __extends(OpenStack, _super);

    function OpenStack(options) {
      this.options = options;
      this.put = __bind(this.put, this);
      this.post = __bind(this.post, this);
      this.get = __bind(this.get, this);
      this.replaceTokens = __bind(this.replaceTokens, this);
      this.checkAuth = __bind(this.checkAuth, this);
      this.refreshToken = __bind(this.refreshToken, this);
      this.switchContext = __bind(this.switchContext, this);
      this.auth = __bind(this.auth, this);
      this.handleOptions = __bind(this.handleOptions, this);
      this.init = __bind(this.init, this);
      debug("constructor()");
      OpenStack.__super__.constructor.apply(this, arguments);
    }

    OpenStack.prototype.init = function() {
      debug("init()");
      OpenStack.__super__.init.apply(this, arguments);
      this.auth_token = null;
      if (this.options.auth_token) {
        this.auth_token = this.options.auth_token;
      }
      this.hypervisors = require('./Models/Compute/Hypervisors')(this.client);
      this.servers = require('./Models/Compute/Servers')(this.client);
      this.os_services = require('./Models/Compute/Services')(this.client);
      this.credentials = require('./Models/Identity/Credentials')(this.client);
      this.domains = require('./Models/Identity/Domains')(this.client);
      this.endpoints = require('./Models/Identity/Endpoints')(this.client);
      this.groups = require('./Models/Identity/Groups')(this.client);
      this.policies = require('./Models/Identity/Policies')(this.client);
      this.projects = require('./Models/Identity/Projects')(this.client);
      this.roles = require('./Models/Identity/Roles')(this.client);
      this.services = require('./Models/Identity/Services')(this.client);
      return this.users = require('./Models/Identity/Users')(this.client);
    };

    OpenStack.prototype.handleOptions = function() {
      debug("handleOptions()");
      return OpenStack.__super__.handleOptions.apply(this, arguments);
    };

    OpenStack.prototype.auth = function(fn) {
      var authOpts, _ref;
      debug("auth()");
      authOpts = {
        auth: {
          identity: {
            methods: ["password"],
            password: {
              user: {
                name: this.options.username,
                domain: {
                  id: (_ref = this.options.domain) != null ? _ref : "default"
                },
                password: this.options.password
              }
            }
          }
        }
      };
      return this.base_post(urljoin(this.options.endpoints.identity, "/auth/tokens"), authOpts, (function(_this) {
        return function(body, headers) {
          debug("auth complete");
          _this.auth_token = {
            id: headers['x-subject-token'],
            expires: body.token.expires_at,
            context: body.token.project.id
          };
          debug(_this.auth_token);
          if (fn) {
            return fn();
          }
        };
      })(this));
    };

    OpenStack.prototype.switchContext = function(context, fn) {
      var authOpts;
      debug("switchContext()");
      authOpts = {
        auth: {
          identity: {
            methods: ["token"],
            token: {
              id: this.auth_token.id
            }
          },
          scope: {
            project: {
              id: context
            }
          }
        }
      };
      return this.post(urljoin(this.options.endpoints.identity, "/auth/tokens"), authOpts, (function(_this) {
        return function(body, headers) {
          debug("context switch complete");
          _this.auth_token = {
            id: headers['x-subject-token'],
            expires: body.token.expires_at,
            context: body.token.project.id
          };
          debug(_this.auth_token);
          if (fn) {
            return fn();
          }
        };
      })(this));
    };

    OpenStack.prototype.refreshToken = function(fn) {
      var authOpts;
      debug("refreshToken()");
      authOpts = {
        auth: {
          identity: {
            methods: ["token"],
            token: {
              id: this.auth_token.id
            }
          }
        }
      };
      return this.post(urljoin(this.options.endpoints.identity, "/auth/tokens"), authOpts, (function(_this) {
        return function(body, headers) {
          debug("refreshToken complete");
          _this.auth_token = {
            id: headers['x-subject-token'],
            expires: body.token.expires_at,
            context: _this.auth_token.context
          };
          debug(_this.auth_token);
          if (fn) {
            return fn();
          }
        };
      })(this));
    };

    OpenStack.prototype.checkAuth = function(fn) {
      debug("checkAuth()");
      if (!this.auth_token) {
        return this.auth(fn);
      } else {
        debug("skipping authentication");
        if (fn) {
          return fn();
        }
      }
    };

    OpenStack.prototype.replaceTokens = function(path, query) {
      var context_replacement;
      if (query.context === "%context%") {
        context_replacement = this.auth_token.context;
      } else {
        context_replacement = query.context;
      }
      return path.replace(/%context%/, context_replacement);
    };

    OpenStack.prototype.get = function(path, query, fn) {
      if (query == null) {
        query = {};
      }
      if (fn == null) {
        fn = null;
      }
      debug("get()");
      return this.checkAuth((function(_this) {
        return function() {
          var _get;
          _get = function() {
            _this.options.request_headers = _.extend({
              "X-Auth-Token": _this.auth_token.id
            }, _this.options.default_headers);
            path = _this.fixPath(path);
            path = _this.replaceTokens(path, query);
            delete query.context;
            return OpenStack.__super__.get.call(_this, path, query, fn);
          };
          if (query.context && query.context !== "%context%" && query.context !== _this.auth_token.context) {
            debug("switch context to " + query.context);
            return _this.switchContext(query.context, _get);
          } else {
            return _get();
          }
        };
      })(this));
    };

    OpenStack.prototype.post = function(path, query, fn) {
      if (query == null) {
        query = {};
      }
      if (fn == null) {
        fn = null;
      }
      debug("post()");
      return this.checkAuth((function(_this) {
        return function() {
          var _post;
          _post = function() {
            _this.options.request_headers = _.extend({
              "X-Auth-Token": _this.auth_token.id
            }, _this.options.default_headers);
            path = _this.fixPath(path);
            path = _this.replaceTokens(path, query);
            delete query.context;
            return OpenStack.__super__.post.call(_this, path, query, fn);
          };
          if (query.context && query.context !== "%context%" && query.context !== _this.auth_token.context) {
            debug("switch context to " + query.context);
            return _this.switchContext(query.context, _post);
          } else {
            return _post();
          }
        };
      })(this));
    };

    OpenStack.prototype.put = function(path, query, fn) {
      if (query == null) {
        query = {};
      }
      if (fn == null) {
        fn = null;
      }
      debug("put()");
      return this.checkAuth((function(_this) {
        return function() {
          var _put;
          _put = function() {
            _this.options.request_headers = _.extend({
              "X-Auth-Token": _this.auth_token.id
            }, _this.options.default_headers);
            path = _this.fixPath(path);
            path = _this.replaceTokens(path, query);
            delete query.context;
            return OpenStack.__super__.put.call(_this, path, query, fn);
          };
          if (query.context && query.context !== "%context%" && query.context !== _this.auth_token.context) {
            debug("switch context to " + query.context);
            return _this.switchContext(query.context, _put);
          } else {
            return _put();
          }
        };
      })(this));
    };

    return OpenStack;

  })(ApiBase);

}).call(this);
