BaseModel = require '../../BaseModel'
_ = require 'underscore'
minimatch = require 'minimatch'
debug = require('debug') "OpenStack:Models:OS-Service"

class Service extends BaseModel
    constructor: (client, service) ->
        debug service
        super client
        @status = service.status
        @binary = service.binary
        @zone = service.zone
        @disabled_reason = service.disabled_reason
        @host = service.host
        @tenant_id = client.auth_token.context

    init: =>
        @type = "compute"

    enable: (fn=null) =>
        @debug "enable()"

        params =
            binary: @binary
            host: @host

        @put "#{@tenant_id}/os-services/enable", params, (data) =>
            @status = 'enabled'
            fn data if fn

    disable: (fn=null) =>
        @debug "disable()"

        params =
            binary: @binary
            host: @host

        @put "#{@tenant_id}/os-services/disable", params, (data) =>
            @status = 'disabled'
            fn data if fn

    disabled: =>
        @status == 'disabled'

    enabled: =>
        @status == 'enabled'

module.exports = (client) ->
    (service) ->
        _server = new Service client, service
