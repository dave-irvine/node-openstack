BaseModel = require '../../BaseModel'
_ = require 'underscore'
minimatch = require 'minimatch'

class Hypervisor extends BaseModel
    constructor: (client, hypervisor) ->
        super client
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

        @find params, (matches) =>
            if matches.length < 1
                throw "No results for #{params.hypervisor_hostname}"
            else if matches.length > 1
                throw "#{params.hypervisor_hostname} returned multiple results"
            else
                @get "%context%/os-hypervisors/#{matches[0].hypervisor_hostname}/servers", query, (data) => fn data.hypervisors[0].servers if fn

module.exports = (client) ->
    (hypervisor) ->
        _hypervisor = new Hypervisor client, hypervisor
