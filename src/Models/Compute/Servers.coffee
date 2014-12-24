BaseModel = require '../../BaseModel'
_ = require 'underscore'
minimatch = require 'minimatch'

class Servers extends BaseModel
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

        @get "%context%/servers#{detail}", query, (data) => fn data if fn

    find: (params={}, fn=null) =>
        @debug "find()"
        if typeof params is 'function'
            fn = params
            params = {}

        if params.ip
            params.detail = true
            check = "ip"
        else if params.server_name
            check = "name"
        else
            throw "Matching query is mandatory"

        @all params, (body) =>
            matches = [];

            _.each body.servers, (server) =>
                @debug server
                switch check
                    when "name"
                        if minimatch(server.name, params.server_name)
                            matches.push server
                    when "ip"
                        _.each server.addresses, (nic) =>
                            _.each nic, (address) =>
                                if minimatch(address.addr, params.ip)
                                    matches.push server

            fn matches if fn

    show: (params={}, fn=null) =>
        @debug "show()"
        if typeof params is 'function'
            fn = params
            params = {}

        @get "servers/#{params.endpoint_id}", (data) => fn data if fn

module.exports = (client) -> new Servers client
