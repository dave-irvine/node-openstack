BaseModel = require '../../BaseModel'
_ = require 'underscore'
minimatch = require 'minimatch'

class Hypervisors extends BaseModel
    init: =>
        @type = "compute"

    all: (params={}, fn=null) =>
        @debug "all()"
        if typeof params is 'function'
            fn = params
            params = {}

        query = {}

        if params.tenant_id
            query.context = params.tenant_id
        else
            query.all_tenants = 1
            query.context = "%context%"

        if params.detail
            detail = "/detail"
        else
            detail = ""

        @get "%context%/os-hypervisors#{detail}", query, (data) => fn data if fn

    find: (params={}, fn=null) =>
        @debug "find()"
        if typeof params is 'function'
            fn = params
            params = {}

        unless params.hypervisor_hostname
            throw "`hypervisor_hostname` is mandatory"

        @all(params, ((body) ->
                matches = [];

                _.each(body.hypervisors, ((hypervisor) ->
                        @debug hypervisor
                        if minimatch(hypervisor.hypervisor_hostname, params.hypervisor_hostname)
                            matches.push hypervisor
                    ).bind(@)
                )

                fn matches if fn
            ).bind(@)
        )

    show: (params={}, fn=null) =>
        @debug "show()"
        if typeof params is 'function'
            fn = params
            params = {}

        unless params.hypervisor_hostname
            throw "`hypervisor_hostname` is mandatory"

        _self = @

        @find(params, (matches) ->
            if matches.length < 1
                throw "No results for #{params.hypervisor_hostname}"
            else if matches.length > 1
                throw "#{params.hypervisor_hostname} returned multiple results"
            else
                fn matches[0] if fn
        )

    servers: (params={}, fn=null) =>
        @debug "servers()"

        if typeof params is 'function'
            fn = params
            params = {}

        query = {}

        unless params.hypervisor_hostname
            throw "`hypervisor_hostname` is mandatory"

        if params.tenant_id
            query.context = params.tenant_id
        else
            query.all_tenants = 1
            query.context = "%context%"

        @find(params, ((matches) ->
            if matches.length < 1
                throw "No results for #{params.hypervisor_hostname}"
            else if matches.length > 1
                throw "#{params.hypervisor_hostname} returned multiple results"
            else
                @get "%context%/os-hypervisors/#{matches[0].hypervisor_hostname}/servers", query, (data) => fn data.hypervisors[0].servers if fn
            ).bind(@)
        )

module.exports = (client) -> new Hypervisors client
