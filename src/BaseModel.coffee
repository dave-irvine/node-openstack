debug = require('debug') 'OpenStack:BaseModel'
urljoin = require 'url-join'

class module.exports

    constructor: (@client) ->
        do @_init

    load: (model) =>
        require("./Models/#{model}") @client

    _init: =>
        debug "_init() #{@constructor.name}"
        @debug =   require('debug') "OpenStack:Models:#{@constructor.name}"

        @get = (path, query, fn) =>
            debug("get()")
            switch @type
                when "compute" then path = urljoin(@client.options.endpoints.compute, path)
                when "identity" then path = urljoin(@client.options.endpoints.identity, path)
            @client.get path, query, fn

        @post =    @client.post

        @put = (path, data, fn) =>
            debug "put()"
            switch @type
                when "compute" then path = urljoin(@client.options.endpoints.compute, path)
                when "identity" then path = urljoin(@client.options.endpoints.identity, path)
            @client.put path, data, fn

        @delete =  @client.delete

        do @init if @init
