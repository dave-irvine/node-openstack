BaseModel = require '../../BaseModel'
_ = require 'underscore'

class Projects extends BaseModel
    Project = null

    constructor: (@client) ->
        super client
        Project = require('./Project') @client

    init: =>
        @type = "identity"

    all: (params={}, fn=null) =>
        @debug "all()"
        if typeof params is 'function'
            fn = params
            params = {}

        @get "projects", (data) =>
            projects = []
            _.each data.projects ? [], (project) =>
                _project = Project(project)
                projects.push _project

            fn projects if fn

    show: (params={}, fn=null) =>
        @debug "show()"
        if typeof params is 'function'
            fn = params
            params = {}

        unless params.project_id
            throw "`project_id` is mandatory"

        @get "projects/#{params.project_id}", (data) =>
            if data.project
                fn Project(data.project) if fn
            else
                fn {} if fn

module.exports = (client) -> new Projects client
