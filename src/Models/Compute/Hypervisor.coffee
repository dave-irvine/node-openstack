BaseModel = require '../../BaseModel'
_ = require 'underscore'
minimatch = require 'minimatch'

class Hypervisor extends BaseModel
    Server = null

    constructor: (client, hypervisor) ->
        super client
        Server = require('./Server') @client
        @id = hypervisor.id
        @hostname = hypervisor.hypervisor_hostname
        @tenant_id = client.auth_token.context

    init: =>
        @type = "compute"

    servers: (params={}, fn=null) =>
        @debug "servers()"

        if typeof params is 'function'
            fn = params
            params = {}

        query = {}

        @get "#{@tenant_id}/os-hypervisors/#{@hostname}/servers", query, (data) =>
            servers = []
            _.each data.hypervisors[0].servers ? [], (server) =>
                _server = Server(server)
                servers.push _server
            
            fn servers if fn

module.exports = (client) ->
    (hypervisor) ->
        _hypervisor = new Hypervisor client, hypervisor
