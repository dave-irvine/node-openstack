BaseModel = require '../../BaseModel'

class Endpoints extends BaseModel
    init: =>
        @type = "identity"

    all: (params={}, fn=null) =>
        @debug "all()"
        if typeof params is 'function'
            fn = params
            params = {}

        @get "endpoints", (data) => fn data if fn

    show: (params={}, fn=null) =>
        @debug "show()"
        if typeof params is 'function'
            fn = params
            params = {}

        @get "endpoints/#{params.endpoint_id}", (data) => fn data if fn

module.exports = (client) -> new Endpoints client
