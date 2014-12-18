BaseModel = require '../../BaseModel'

class Users extends BaseModel
    init: =>
        @type = "identity"

    all: (params={}, fn=null) =>
        @debug "all()"
        if typeof params is 'function'
            fn = params
            params = {}

        @get "users", (data) => fn data if fn

    show: (params={}, fn=null) =>
        @debug "show()"
        if typeof params is 'function'
            fn = params
            params = {}

        @get "users/#{params.user_id}", (data) => fn data if fn

module.exports = (client) -> new Users client
