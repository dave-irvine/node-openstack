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

    init: =>
        @type = "compute"

    servers: (params={}, fn=null) =>
        @debug "servers()"

        if typeof params is 'function'
            fn = params
            params = {}

        query = {}

        if params.tenant_id
            query.context = params.tenant_id
        else
            query.all_tenants = 1
            query.context = "%context%"

        @get "%context%/os-hypervisors/#{@hostname}/servers", query, (data) =>
            servers = []
            _.each data.hypervisors[0].servers ? [], (server) =>
                _server = Server(server)
                servers.push _server
            
            fn servers if fn

module.exports = (client) ->
    (hypervisor) ->
        _hypervisor = new Hypervisor client, hypervisor
