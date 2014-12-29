BaseModel = require '../../BaseModel'
_ = require 'underscore'
minimatch = require 'minimatch'
debug = require('debug') "OpenStack:Models:Server"

class Server extends BaseModel
    constructor: (client, server) ->
        super client
        @id = server.uuid ? server.id
        @name = server.name ? ""
        @tenant_id = client.auth_token.context

    init: =>
        @type = "compute"

    populate: (full=false, fn=null) =>
        debug "populate()"
        if typeof full is 'function'
            fn = full
            full = false

        @client.servers.show { id: @id }, (data) =>
            @debug data.server
            @status = data.server.status
            @addresses = data.server.addresses
            @name = data.server.name
            @hypervisor_hostname = data.server['OS-EXT-SRV-ATTR:hypervisor_hostname']
            @tenant_id = data.server.tenant_id
            if full
                @client.hypervisors.show { hypervisor_hostname: @hypervisor_hostname }, (hypervisor) =>
                    @hypervisor = hypervisor
                    fn @ if fn
            else
                fn @ if fn

module.exports = (client) ->
    (server) ->
        _server = new Server client, server
