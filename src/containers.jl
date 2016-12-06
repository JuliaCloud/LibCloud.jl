module Containers

include("module_common.jl")

const _libcloud_container_types = PyCall.PyNULL()
const _libcloud_container_providers = PyCall.PyNULL()
const _libcloud_container_base = PyCall.PyNULL()

immutable ContainerDriver
    o::PyObject

    function ContainerDriver(provider::Compat.String, args...; kwargs...)
        cls = _libcloud_container_providers[:get_driver](provider)
        ContainerDriver(cls(args...; kwargs...))
    end
    ContainerDriver(driver::PyObject) = new(driver)
end
show(io::IO, c::ContainerDriver) = print(io, c.o[:__str__]())

immutable ContainerImage
    o::PyObject

    id::Nullable{Compat.String}
    name::Compat.String
    path::Compat.String
    version::Compat.String
    extra::Dict
    driver::ContainerDriver

    function ContainerImage(o::PyObject)
        new(o, o[:id], o[:name], o[:path], o[:version], o[:extra], ContainerDriver(o[:driver]))
    end
end
PyObject(o::ContainerImage) = o.o
convert(::Type{ContainerImage}, o::PyObject) =  ContainerImage(o)
show(io::IO, o::ContainerImage) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_container_base, "ContainerImage") ContainerImage

immutable ContainerCluster
    o::PyObject

    id::Nullable{Compat.String}
    name::Compat.String
    extra::Dict
    driver::ContainerDriver

    function ContainerCluster(o::PyObject)
        new(o, o[:id], o[:name], o[:extra], ContainerDriver(o[:driver]))
    end
end
PyObject(o::ContainerCluster) = o.o
convert(::Type{ContainerCluster}, o::PyObject) =  ContainerCluster(o)
show(io::IO, o::ContainerCluster) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_container_base, "ContainerCluster") ContainerCluster

immutable ClusterLocation
    o::PyObject

    id::Compat.String
    name::Compat.String
    country::Compat.String
    driver::ContainerDriver

    function ClusterLocation(o::PyObject)
        new(o, o[:id], o[:name], o[:country], ContainerDriver(o[:driver]))
    end
end
PyObject(o::ClusterLocation) = o.o
convert(::Type{ClusterLocation}, o::PyObject) =  ClusterLocation(o)
show(io::IO, o::ClusterLocation) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_container_base, "ClusterLocation") ClusterLocation

immutable Container
    o::PyObject

    id::Nullable{Compat.String}
    name::Compat.String
    image::ContainerImage
    state::Compat.String
    ip_addresses::Array
    extra::Dict
    driver::ContainerDriver

    function Container(o::PyObject)
        new(o, o[:id], o[:name], o[:image], o[:state], o[:ip_addresses], o[:extra], ContainerDriver(o[:driver]))
    end
end
PyObject(o::Container) = o.o
convert(::Type{Container}, o::PyObject) =  Container(o)
show(io::IO, o::Container) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_container_base, "Container") Container

const _containerdriver_fns = [
    :install_image, :list_images, :list_containers, :deploy_container, :get_container,
    :start_container, :stop_container, :restart_container, :destroy_container,
    :list_locations, :create_cluster, :destroy_cluster, :list_clusters, :get_cluster
]

const _container_cluster_fns = [ :list_containers, :destroy ]
const _container_image_fns = [ :deploy ]
const _container_fns = [ :start, :stop, :restart, :destroy ]

for f in union(Set(_containerdriver_fns), Set(_base_driver_fns))
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_container_base, "ContainerDriver", $sf) $(f)(d::ContainerDriver, args...; kwargs...) = d.o[$(sf)](args...; kwargs...)
end

for f in _container_cluster_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_container_base, "ContainerCluster", $sf) $(f)(c::ContainerCluster, args...; kwargs...) = c.o[$(sf)](args...; kwargs...)
end

for f in _container_image_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_container_base, "ContainerImage", $sf) $(f)(c::ContainerImage, args...; kwargs...) = c.o[$(sf)](args...; kwargs...)
end

for f in _container_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_container_base, "Container", $sf) $(f)(c::Container, args...; kwargs...) = c.o[$(sf)](args...; kwargs...)
end

# Initialize container service
function __init__()
    copy!(_libcloud_container_types, pyimport("libcloud.container.types"))
    copy!(_libcloud_container_providers, pyimport("libcloud.container.providers"))
    copy!(_libcloud_container_base, pyimport("libcloud.container.base"))

    global const ContainerProvider = pywrap(_libcloud_container_types[:Provider])
    global const ContainerState = pywrap(_libcloud_container_types[:ContainerState])

    _map_types(_libcloud_container_base, (ContainerImage, ContainerCluster, ClusterLocation, Container))
end

# types
export ContainerProvider, ContainerDriver, ContainerState, ContainerImage, ContainerCluster, ClusterLocation, Container
# container driver functions
export install_image, list_images, list_containers, deploy_container, get_container,
       start_container, stop_container, restart_container, destroy_container,
       list_locations, create_cluster, destroy_cluster, list_clusters, get_cluster
# container cluster functions
export list_containers, destroy
# container image functions
export deploy
# container functions
export start, stop, restart, destroy

end # module Containers
