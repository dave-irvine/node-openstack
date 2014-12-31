# node-openstack

Node.js bindings for the OpenStack API.

## Should I be using this?

Probably not. See [pkgcloud](https://github.com/pkgcloud/pkgcloud) for something a little more provider agnostic.

## What is this for then?

I couldn't get pkgcloud to work the way I wanted and I had a deadline with no time to understand pkgcloud's code layout to submit pull requests.

#Usage

Figuring out the endpoints for your OpenStack configuration is the first step.

If you have Horizon, you can adjust the following URL to fetch your RC file:

[https://your-openstack-install/project/access_and_security/api_access/openrc/](https://your-openstack-install/project/access_and_security/api_access/openrc/)

This will fetch a .sh file, inside which you will find an export definition that looks like:

```
export OS_AUTH_URL=http://your-openstack-install:5000/v2.0
```
Pull that URL and remove any API versioning. Now you've got your `identity_url`!

```
var openstack = require("openstack")({
	identity_url: "http://your-openstack-install:5000/",
	compute_url: "http://your-openstack-install:8774/",
	username: "",
	password: ""
});
```

##API
We mirror the latest APIs for each resource type as closely as possible.

Top-level API members are available as properties on the `openstack` instance.

- `~` parameters are optional
- `?` parameters are expected to be Booleans
- `""` parameters are espected to be Strings
- `{}` parameters are expected to be Objects
- `()` parameters are expected to be functions
	- Whose function signature should match the provided detail.
	
So an API function like:

`all => ~params={}, ~callback=(error="", [Things={}])`

Takes an option parameters Object, and an optional callback function. The callback should expect a String as its first parameter, and an Array of Thing Objects as its second parameter.

###Compute
Top-level API members are: `Servers`, `Hypervisors`, `Services`.
Sub-level API members are: `Server`, `Hypervisor`, `Service`.

####Servers
#####all => ~params={}, ~callback=(error="", [Server={}])
Find all Servers.

By default, this will fetch all Servers across all tenants, with minimum detail.

`params` can contain the following:

- ~ `tenant_id` (String) : Filter for Servers belonging to this tenant (Project).
- ~ `detail` (Boolean) : Fetch additional detail for each Server.

######Example
```
openstack.servers.all(function (servers) {
	console.log(servers);
});
```

#####find => params={}, ~callback=(error="", [Server={}])
Find Servers that match our search terms.

`params` must contain at least one of the following:

- ~ `ip` (String) : Search for Servers with this IP address (checks local and floating IPs)
- ~ `server_name` (String) : Search for Servers with this name (uses glob matching)

######Example
```
openstack.servers.find({
	ip: "10.241.0.1"
}, function (servers) {
	console.log(servers);
});
```


#####show => params={}, ~callback=(error="", Server={})
Fetch a Server that has a matching ID.

`params` must contain the following:

- `id` (String) : The Server ID to fetch

######Example
```
openstack.servers.show({
	id: "abcdef-12345-ghijkl-67890"
}, function (server) {
	console.log(server);
});
```

####Server
This object is only accessible from a function on another object.

#####confirmMigrate => ~callback=(error="", Server={})
Synonym of `confirmResize()`

#####confirmResize => ~callback=(error="", Server={})
Confirm that a resize/migrate/rebuild has been successful.

#####migrate => params={}, ~callback=(error="", Server={})
Migrate this server from one Hypervisor to another.

This function will automatically poll OpenStack until the state of the Server becomes VERIFY_RESIZE, at which point the provided `callback` will be called. You must then call `confirmMigrate()` once you are satisfied the migration has been successful.

Because you cannot directly target a Hypervisor to migrate a Server to, this function disables the Compute service on all Hypervisors, enables the Compute service on the target Hypervisor, begins the migration, and then re-enables the Compute service on all Hypervisors. This action is not respectful of the state of the Compute services before the function is called; all Compute services will be enabled as part of this action.

`params` must contain the following:

- `migrate_to` (String) : The Hostname of a Hypervisor to migrate to.

#####populate => ~full=?, ~callback=(error="", Server={})
Fetch additional details for a sparsely populated Server object (like you get from Servers.all with detail set to false)

If `full` is set to true, the `hypervisor` property of the Server is also set, which will contain a Hypervisor object.

####Hypervisors
#####all => ~params={}, ~callback=(error="", [Hypervisor={}])
Find all Hypervisors.

By default, this will fetch all Hypervisors across all tenants, with minimum detail.

`params` can contain the following:

- ~ `tenant_id` (String) : Filter for Hypervisors belonging to this Tenant.
- ~ `detail` (Boolean) : Fetch additional detail for each Hypervisor.

#####find => params={}, ~callback=(error="", [Hypervisor={}])
Find Hypervisors that match our search terms.

`params` must contain at least one of the following:

- ~ `hypervisor_hostname` (String) : Search for Hypervisors with this hostname (uses glob matching)
#####show => params={}, ~callback=(error="", Hypervisor={})
Fetch a Hypervisor that has a matching hostname. Will error if more than one result is found, so be specific.

`params` must contain the following:

- `hypervisor_hostname` (String) : The hostname of the Hypervisor to fetch

####Hypervisor
This object is only accessible from a function on another object.

#####servers => ~params={}, ~callback=(error="", [Server={}])
Find all Servers being hosted by this Hypervisor.

######Example
```
openstack.hypervisors.show({
	hypervisor_hostname: "hyp01"
}, function (hypervisor) {
	hypervisor.servers(function (servers) {
		console.log(servers);
	});
});
```

####Services
#####all => ~params={}, ~callback=(error="", [Hypervisor={}])
Find all Services.

By default, this will fetch all Services across all tenants, with minimum detail.

`params` can contain the following:

- ~ `tenant_id` (String) : Filter for Services belonging to this Tenant.
- ~ `detail` (Boolean) : Fetch additional detail for each Service.

####Service
This object is only accessible from a function on another object.

#####enable => ~callback=(error="", {})
Enable this Service.

#####disable => ~callback=(error="", {})
Disable this Service.

#####enabled => : ?
Test if this Service is enabled.

#####disabled => : ?
Test if this Service is disabled.
