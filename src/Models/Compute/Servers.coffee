BaseModel = require '../../BaseModel'

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

    show: (params={}, fn=null) =>
        @debug "show()"
        if typeof params is 'function'
            fn = params
            params = {}

        @get "servers/#{params.endpoint_id}", (data) => fn data if fn

module.exports = (client) -> new Servers client
