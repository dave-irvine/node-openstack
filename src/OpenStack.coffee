debug = require('debug') 'OpenStack'
{ApiBase} = require './ApiBase'
urljoin = require 'url-join'
_ = require 'underscore'

class module.exports.OpenStack extends ApiBase
    constructor: (@options) ->
        debug "constructor()"
        super

    init: =>
        debug "init()"
        super
        @auth_token = null
        # Compute
        @servers            = require('./Models/Compute/Servers')        @client
        # Identity
        @credentials        = require('./Models/Identity/Credentials')   @client
        @domains            = require('./Models/Identity/Domains')       @client
        @endpoints          = require('./Models/Identity/Endpoints')     @client
        @groups             = require('./Models/Identity/Groups')        @client
        @policies           = require('./Models/Identity/Policies')      @client
        @projects           = require('./Models/Identity/Projects')      @client
        @roles              = require('./Models/Identity/Roles')         @client
        @services           = require('./Models/Identity/Services')      @client
        @users              = require('./Models/Identity/Users')         @client

    handleOptions: =>
        debug "handleOptions()"
        super

    auth: (fn) =>
        debug "auth()"
        authOpts =
            auth:
                identity:
                    methods: ["password"]
                    password:
                        user:
                            name: @options.username
                            domain:
                                id: @options.domain ? "default"
                            password: @options.password

        @post urljoin(@options.endpoints.identity, "/auth/tokens"), authOpts, ((body, headers) ->
            debug "auth complete"
            @auth_token =
                id: headers['x-subject-token']
                expires: body.token.expires_at
                context: body.token.project.id

            debug @auth_token
            do fn if fn
        ).bind(@)

    switchContext: (context, fn) =>
        debug "switchContext()"
        authOpts =
            auth:
                identity:
                    methods: ["token"]
                    token:
                        id: @auth_token.id
                scope:
                    project:
                        id: context

        @post urljoin(@options.endpoints.identity, "/auth/tokens"), authOpts, ((body, headers) ->
            debug "context switch complete"
            @auth_token =
                id: headers['x-subject-token']
                expires: body.token.expires_at
                context: body.token.project.id

            debug @auth_token
            do fn if fn
        ).bind(@)

    checkAuth: (fn) =>
        debug "checkAuth()"
        unless @auth_token
            @auth fn
        else
            debug "skipping authentication"
            do fn if fn

    replaceTokens: (path, query) =>
        if query.context == "%context%"
            context_replacement = @auth_token.context
        else
            context_replacement = query.context

        path.replace(/%context%/, context_replacement)

    get: (path, query={}, fn=null) =>
        debug "get()"
        @checkAuth (->
            _get = (->
                @options.request_headers = _.extend { "X-Auth-Token": @auth_token.id }, @options.default_headers
                path = @fixPath path
                path = @replaceTokens path, query
                super path, query, fn
            ).bind(@)

            if query.context && query.context != "%context%" && query.context != @auth_token.context
                debug "switch context to #{query.context}"
                @switchContext query.context, _get
            else
                do _get
        ).bind(@)
