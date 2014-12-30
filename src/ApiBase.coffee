debug = require('debug') 'OpenStack:ApiBase'
{ApiBase} = require './ApiBase'
urljoin = require 'url-join'
querystring = require 'querystring'
request = require 'request'

class module.exports.ApiBase
    constructor: (@options) ->
        debug "constructor()"
        unless @options
            throw "`options` is mandatory"

        do @handleOptions
        do @init

    handleOptions: =>
        debug "handleOptions()"
        unless @options.identity_url
            throw "`identity_url` is mandatory"

        unless @options.compute_url
            throw "`compute_url` is mandatory"

        unless @options.username
            throw "`username` is mandatory"

        unless @options.password
            throw "`password` is mandatory"

        @options.default_headers = {
            "Content-Type": "application/json",
            "Accept": "application/json"
        }

        @options.endpoints =
            identity: urljoin(@options.identity_url, "v3/")
            compute: urljoin(@options.compute_url, "v2/")

    init: =>
        debug "init()"
        @client = @

        @base_post = (path, data={}, fn=null) =>
            debug "base_post() : #{path}"
            opts = @prepareOpts path, data, "POST"
            debug opts
            request opts, (err, response, body) =>
                debug "post request return"
                if body == ""
                    body = "{}"

                unless err
                    fn JSON.parse(body), response.headers if fn
                else throw "error from API: " + err

        @base_put = (path, data={}, fn=null) =>
            debug "base_put() : #{path}"
            opts = @prepareOpts path, data, "PUT"
            debug opts
            request opts, (err, response, body) =>
                debug "put request return"
                if body == ""
                    body = "{}"
                unless err
                    fn JSON.parse(body), response.headers if fn
                else throw "error from API: " + err

        @base_get = (path, query={}, fn=null) =>
            debug "base_get() : #{path} #{querystring.stringify(query)}"
            if typeof query is 'function'
                fn = query
                query = {}

            opts = @prepareOpts path, query, "GET"
            debug opts
            request opts, (err, response, body) =>
                debug "get request return"
                if body == ""
                    body = "{}"
                unless err
                    fn JSON.parse(body), response.headers if fn
                else throw "error from API: " + err

    fixPath: (path) =>
        debug "fixPath()"
        path.replace(/\/$/, '')

    prepareOpts: (path, opts, method) =>
        debug "prepareOpts()"
        finalopts =
            uri: path
            method: method
            headers: @options.request_headers ? @options.default_headers
        switch method
            when "POST" then finalopts.body = JSON.stringify(opts)
            when "PUT" then finalopts.body = JSON.stringify(opts)
            when "GET" then finalopts.uri = urljoin(path, "?#{querystring.stringify(opts)}")

        finalopts.uri = finalopts.uri.replace(/\?$/,'')
        return finalopts

    get: (path, query={}, fn=null) =>
        @base_get path, query, fn

    post: (path, data={}, fn=null) =>
        @base_post path, data, fn

    put: (path, data={}, fn=null) =>
        @base_put path, data, fn