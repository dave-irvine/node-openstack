BaseModel = require '../../BaseModel'
_ = require 'underscore'
minimatch = require 'minimatch'

class Services extends BaseModel
    Service = null

    constructor: (@client) ->
        super client
        Service = require('./Service') @client

    init: =>
        @debug "init()"
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

        @get "%context%/os-services#{detail}", query, (data) =>
            services = []
            _.each data.services, (service) =>
                _service = Service(service)
                services.push _service

            fn services if fn

module.exports = (client) -> new Services client
