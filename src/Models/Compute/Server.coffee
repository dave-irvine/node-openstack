BaseModel = require '../../BaseModel'
_ = require 'underscore'
minimatch = require 'minimatch'
debug = require('debug') "OpenStack:Models:Server"

class Server extends BaseModel
    constructor: (client, server) ->
        super client
        @id = server.uuid ? server.id
        @name = server.name ? ""
        @tenant_id = client.auth_token.context

    init: =>
        @type = "compute"

    populate: (full=false, fn=null) =>
        debug "populate()"
        if typeof full is 'function'
            fn = full
            full = false

        query =
            context: @tenant_id

        @get "#{@tenant_id}/servers/#{@id}", query, (data) =>
            @status = data.server.status
            @addresses = data.server.addresses
            @name = data.server.name
            @hypervisor_hostname = data.server['OS-EXT-SRV-ATTR:hypervisor_hostname']
            @tenant_id = data.server.tenant_id
            if full
                @client.hypervisors.show { hypervisor_hostname: @hypervisor_hostname }, (hypervisor) =>
                    @hypervisor = hypervisor
                    fn @ if fn
            else
                fn @ if fn

    confirmResize: (fn=null) =>
        params =
            confirmResize: null

        @post "#{@tenant_id}/servers/#{@id}/action", params, (data) =>
            fn @ if fn

    confirmMigrate: (fn=null) =>
        @confirmResize fn

    migrate: (params={}, fn=null) =>
        debug "migrate()"
        if typeof params is 'function'
            fn = params
            params = {}

        unless params.migrate_to
            throw "`migrate_to` is mandatory"

        target_hypervisor = null
        target_compute_service = null
        compute_services = []

        # Using Hypervisors.find fetches all Hypervisors and filters in the client,
        # we need the full list of Hypervisors anyway, so we might as well fetch all
        # and then filter ourselves.
        @client.hypervisors.all (hypervisors) =>
            unless hypervisors.length > 1
                throw "Couldn't find hypervisor: #{params.migrate_to}"

            _.each hypervisors, (hypervisor) =>
                if minimatch(hypervisor.hostname, params.migrate_to)
                    target_hypervisor = hypervisor

            unless target_hypervisor
                throw "Couldn't find hypervisor: #{params.migrate_to}"

            #Locate every compute service
            find_compute_services =>
                unless target_compute_service
                    throw "Couldn't find a compute service for target hypervisor: #{params.migrate_to}"
                else
                    #Disable all the compute services
                    disable_compute_services =>
                        #Enabled the compute service we are targeting
                        target_compute_service.enable =>
                            issue_migration =>
                                #Enable all the compute services
                                enable_compute_services =>
                                    monitor_migration_status =>
                                        fn @ if fn

        monitor_migration_status = (fn) =>
            @debug "Checking migration status"
            @populate =>
                @debug "Server status is: #{@status}"
                if @status == 'RESIZE'
                    monitor = () =>
                        monitor_migration_status fn
                    setTimeout monitor, 1000
                else if @status == 'VERIFY_RESIZE'
                    @debug "Migration complete. Requires verify."
                    do fn
                else
                    throw "Server in unexpected state: #{@state}"

        issue_migration = (fn) =>
            @debug "Begin migration action"
            params.migrate = null
            delete params.migrate_to
            #Begin the migration
            @post "#{@tenant_id}/servers/#{@id}/action", params, (data) =>
                @debug "Migration action started"
                @debug data
                do fn

        find_compute_services = (fn) =>
            @client.os_services.all (services) =>
                compute_services = _.filter services, (service) =>
                    #Hijack our filter loop to find the target compute service.
                    if minimatch(service.host, params.migrate_to)
                        target_compute_service = service
                    service.binary == 'nova-compute'
                do fn

        disable_compute_services = (fn) =>
                #Disable every compute service
                compute_services_disabled = 0
                _.each compute_services, (service) =>
                    service.disable =>
                        @debug "Compute service disabled"
                        do compute_service_disabled

                compute_service_disabled = =>
                    compute_services_disabled++
                    if compute_services_disabled == compute_services.length
                        do fn
                    else
                        @debug "Disabled #{compute_services_disabled} / #{compute_services.length}"

        enable_compute_services = (fn) =>
            #Enable every compute service
            compute_services_enabled = 0
            _.each compute_services, (service) =>
                service.enable =>
                    @debug "Compute service enabled"
                    do compute_service_enabled

            compute_service_enabled = =>
                compute_services_enabled++
                if compute_services_enabled == compute_services.length
                    do fn
                else
                    @debug "Enabled #{compute_services_enabled} / #{compute_services.length}"

module.exports = (client) ->
    (server) ->
        _server = new Server client, server
