BaseModel = require '../../BaseModel'

class Projects extends BaseModel
    init: =>
        @type = "identity"

    all: (params={}, fn=null) =>
        @debug "all()"
        if typeof params is 'function'
            fn = params
            params = {}

        @get "projects", (data) => fn data if fn

    show: (params={}, fn=null) =>
        @debug "show()"
        if typeof params is 'function'
            fn = params
            params = {}

        @get "projects/#{params.project_id}", (data) => fn data if fn

module.exports = (client) -> new Projects client
