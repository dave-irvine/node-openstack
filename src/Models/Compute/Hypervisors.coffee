BaseModel = require '../../BaseModel'
_ = require 'underscore'
minimatch = require 'minimatch'

class Hypervisors extends BaseModel
    Hypervisor = null

    constructor: (@client) ->
        super client
        Hypervisor = require('./Hypervisor') @client

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

        @get "%context%/os-hypervisors#{detail}", query, (data) =>
            hypervisors = []
            _.each data.hypervisors, (hypervisor) =>
                hypervisors.push Hypervisor(hypervisor)

            fn hypervisors if fn

    find: (params={}, fn=null) =>
        @debug "find()"
        if typeof params is 'function'
            fn = params
            params = {}

        unless params.hypervisor_hostname
            throw "`hypervisor_hostname` is mandatory"

        @debug params
        @all params, (hypervisors) =>
            matches = [];

            _.each hypervisors, (hypervisor) =>
                @debug hypervisor
                if minimatch(hypervisor.hostname, params.hypervisor_hostname)
                    matches.push hypervisor

            fn matches if fn

    show: (params={}, fn=null) =>
        @debug "show()"
        if typeof params is 'function'
            fn = params
            params = {}

        unless params.hypervisor_hostname
            throw "`hypervisor_hostname` is mandatory"

        @find params, (matches) ->
            if matches.length < 1
                throw "No results for #{params.hypervisor_hostname}"
            else if matches.length > 1
                throw "#{params.hypervisor_hostname} returned multiple results"
            else
                fn matches[0] if fn

module.exports = (client) -> new Hypervisors client
