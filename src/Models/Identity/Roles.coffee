BaseModel = require '../../BaseModel'

class Roles extends BaseModel
    init: =>
        @type = "identity"

    all: (params={}, fn=null) =>
        @debug "all()"
        if typeof params is 'function'
            fn = params
            params = {}

        @get "roles", (data) => fn data if fn

module.exports = (client) -> new Roles client
