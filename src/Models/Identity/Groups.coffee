BaseModel = require '../../BaseModel'

class Groups extends BaseModel
    init: =>
        @type = "identity"

    all: (params={}, fn=null) =>
        @debug "all()"
        if typeof params is 'function'
            fn = params
            params = {}

        @get "groups", (data) => fn data if fn

    show: (params={}, fn=null) =>
        @debug "show()"
        if typeof params is 'function'
            fn = params
            params = {}

        @get "groups/#{params.group_id}", (data) => fn data if fn

module.exports = (client) -> new Groups client
