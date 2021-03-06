// Generated by CoffeeScript 1.8.0
(function() {
  var BaseModel, Server, debug, minimatch, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseModel = require('../../BaseModel');

  _ = require('underscore');

  minimatch = require('minimatch');

  debug = require('debug')("OpenStack:Models:Server");

  Server = (function(_super) {
    __extends(Server, _super);

    function Server(client, server) {
      this.migrate = __bind(this.migrate, this);
      this.confirmMigrate = __bind(this.confirmMigrate, this);
      this.confirmResize = __bind(this.confirmResize, this);
      this.populate = __bind(this.populate, this);
      this.init = __bind(this.init, this);
      var _ref, _ref1;
      Server.__super__.constructor.call(this, client);
      this.id = (_ref = server.uuid) != null ? _ref : server.id;
      this.name = (_ref1 = server.name) != null ? _ref1 : "";
      this.tenant_id = client.auth_token.context;
    }

    Server.prototype.init = function() {
      return this.type = "compute";
    };

    Server.prototype.populate = function(full, fn) {
      var query;
      if (full == null) {
        full = false;
      }
      if (fn == null) {
        fn = null;
      }
      debug("populate()");
      if (typeof full === 'function') {
        fn = full;
        full = false;
      }
      query = {
        context: this.tenant_id
      };
      return this.get("" + this.tenant_id + "/servers/" + this.id, query, (function(_this) {
        return function(data) {
          _this.status = data.server.status;
          _this.addresses = data.server.addresses;
          _this.name = data.server.name;
          _this.hypervisor_hostname = data.server['OS-EXT-SRV-ATTR:hypervisor_hostname'];
          _this.tenant_id = data.server.tenant_id;
          if (full) {
            return _this.client.hypervisors.show({
              hypervisor_hostname: _this.hypervisor_hostname
            }, function(hypervisor) {
              _this.hypervisor = hypervisor;
              if (fn) {
                return fn(_this);
              }
            });
          } else {
            if (fn) {
              return fn(_this);
            }
          }
        };
      })(this));
    };

    Server.prototype.confirmResize = function(fn) {
      var params;
      if (fn == null) {
        fn = null;
      }
      params = {
        confirmResize: null
      };
      return this.post("" + this.tenant_id + "/servers/" + this.id + "/action", params, (function(_this) {
        return function(data) {
          if (fn) {
            return fn(_this);
          }
        };
      })(this));
    };

    Server.prototype.confirmMigrate = function(fn) {
      if (fn == null) {
        fn = null;
      }
      return this.confirmResize(fn);
    };

    Server.prototype.migrate = function(params, fn) {
      var compute_services, disable_compute_services, enable_compute_services, find_compute_services, issue_migration, monitor_migration_status, target_compute_service, target_hypervisor;
      if (params == null) {
        params = {};
      }
      if (fn == null) {
        fn = null;
      }
      debug("migrate()");
      if (typeof params === 'function') {
        fn = params;
        params = {};
      }
      if (!params.migrate_to) {
        throw "`migrate_to` is mandatory";
      }
      target_hypervisor = null;
      target_compute_service = null;
      compute_services = [];
      this.client.hypervisors.all((function(_this) {
        return function(hypervisors) {
          if (!(hypervisors.length > 0)) {
            throw "Couldn't find hypervisor: " + params.migrate_to;
          }
          _.each(hypervisors, function(hypervisor) {
            if (minimatch(hypervisor.hostname, params.migrate_to)) {
              return target_hypervisor = hypervisor;
            }
          });
          if (!target_hypervisor) {
            throw "Couldn't find hypervisor: " + params.migrate_to;
          }
          return find_compute_services(function() {
            if (!target_compute_service) {
              throw "Couldn't find a compute service for target hypervisor: " + params.migrate_to;
            } else {
              return disable_compute_services(function() {
                return target_compute_service.enable(function() {
                  return issue_migration(function() {
                    return enable_compute_services(function() {
                      return monitor_migration_status(function() {
                        if (fn) {
                          return fn(_this);
                        }
                      });
                    });
                  });
                });
              });
            }
          });
        };
      })(this));
      monitor_migration_status = (function(_this) {
        return function(fn) {
          _this.debug("Checking migration status");
          return _this.populate(function() {
            var monitor;
            _this.debug("Server status is: " + _this.status);
            if (_this.status === 'RESIZE') {
              monitor = function() {
                return monitor_migration_status(fn);
              };
              return setTimeout(monitor, 1000);
            } else if (_this.status === 'VERIFY_RESIZE') {
              _this.debug("Migration complete. Requires verify.");
              return fn();
            } else {
              throw "Server " + _this.name + "in unexpected state: " + _this.status;
            }
          });
        };
      })(this);
      issue_migration = (function(_this) {
        return function(fn) {
          _this.debug("Begin migration action");
          params.migrate = null;
          delete params.migrate_to;
          _this.debug("Context switch");
          return _this.client.switchContext(_this.tenant_id, function() {
            _this.debug("Context switch complete");
            return _this.post("" + _this.tenant_id + "/servers/" + _this.id + "/action", params, function(data) {
              _this.debug("Migration action started");
              _this.debug(data);
              return fn();
            });
          });
        };
      })(this);
      find_compute_services = (function(_this) {
        return function(fn) {
          return _this.client.os_services.all(function(services) {
            compute_services = _.filter(services, function(service) {
              if (minimatch(service.host, params.migrate_to)) {
                target_compute_service = service;
              }
              return service.binary === 'nova-compute';
            });
            return fn();
          });
        };
      })(this);
      disable_compute_services = (function(_this) {
        return function(fn) {
          var compute_service_disabled, compute_services_disabled;
          compute_services_disabled = 0;
          _.each(compute_services, function(service) {
            return service.disable(function() {
              _this.debug("Compute service disabled");
              return compute_service_disabled();
            });
          });
          return compute_service_disabled = function() {
            compute_services_disabled++;
            if (compute_services_disabled === compute_services.length) {
              return fn();
            } else {
              return _this.debug("Disabled " + compute_services_disabled + " / " + compute_services.length);
            }
          };
        };
      })(this);
      return enable_compute_services = (function(_this) {
        return function(fn) {
          var compute_service_enabled, compute_services_enabled;
          compute_services_enabled = 0;
          _.each(compute_services, function(service) {
            return service.enable(function() {
              _this.debug("Compute service enabled");
              return compute_service_enabled();
            });
          });
          return compute_service_enabled = function() {
            compute_services_enabled++;
            if (compute_services_enabled === compute_services.length) {
              return fn();
            } else {
              return _this.debug("Enabled " + compute_services_enabled + " / " + compute_services.length);
            }
          };
        };
      })(this);
    };

    return Server;

  })(BaseModel);

  module.exports = function(client) {
    return function(server) {
      var _server;
      return _server = new Server(client, server);
    };
  };

}).call(this);
