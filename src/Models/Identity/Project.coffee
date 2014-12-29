BaseModel = require '../../BaseModel'
_ = require 'underscore'
minimatch = require 'minimatch'
debug = require('debug') "OpenStack:Models:Project"

class Project extends BaseModel
    constructor: (client, project) ->
        super client
        @description = project.description
        @name = project.name
        @id = project.id
        @enabled = project.enabled
        @tenant_id = client.auth_token.context

    init: =>
        @type = "identity"

    servers: (detail=false, fn=null) =>
        if typeof detail == 'function'
            fn = detail
            detail = false

        params =
            tenant_id: @id
            detail: detail

        @client.servers.all params, (servers) =>
            fn servers if fn

module.exports = (client) ->
    (project) ->
        _project = new Project client, project
