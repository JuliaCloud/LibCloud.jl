module Storage

include("module_common.jl")

const _libcloud_storage_types = PyCall.PyNULL()
const _libcloud_storage_providers = PyCall.PyNULL()
const _libcloud_storage_base = PyCall.PyNULL()

immutable StorageDriver
    o::PyObject

    function StorageDriver(provider::Compat.String, args...; kwargs...)
        cls = _libcloud_storage_providers[:get_driver](provider)
        StorageDriver(cls(args...; kwargs...))
    end
    StorageDriver(driver::PyObject) = new(driver)
end
show(io::IO, c::StorageDriver) = print(io, c.o[:__str__]())

immutable Container
    o::PyObject

    name::Compat.String
    extra::Dict
    driver::StorageDriver

    function Container(o::PyObject)
        new(o, o[:name], o[:extra], StorageDriver(o[:driver]))
    end
end
PyObject(c::Container) = c.o
convert(::Type{Container}, o::PyObject) =  Container(o)
show(io::IO, o::Container) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_storage_base, "Container") Container

immutable Object
    o::PyObject

    name::Compat.String
    size::Int
    hash::Compat.String
    container::Container
    extra::Dict
    meta_data::Dict
    driver::StorageDriver

    function Object(o::PyObject)
        new(o, o[:name], o[:size], o[:hash], Container(o[:container]), o[:extra], o[:meta_data] , StorageDriver(o[:driver]))
    end
end
PyObject(o::Object) = o.o
convert(::Type{Object}, o::PyObject) =  Object(o)
show(io::IO, o::Object) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_storage_base, "Object") Object

const _storagedriver_fns = [
    :create_container, :delete_container, :delete_object, :download_object, :download_object_as_stream,
    :enable_container_cdn, :enable_object_cdn, :get_container, :get_container_cdn_url, :get_object,
    :get_object_cdn_url, :iterate_container_objects, :iterate_containers, :list_container_objects,
    :list_containers, :upload_object, :upload_object_via_stream
]

const _container_fns = [
    :iterate_objects, :list_objects, :get_cdn_url, :enable_cdn, :get_object, :upload_object,
    :upload_object_via_stream, :download_object, :download_object_as_stream, :delete_object, :delete
]

const _object_fns = [
    :get_cdn_url, :enable_cdn, :download, :as_stream, :delete
]

for f in union(Set(_storagedriver_fns), Set(_base_driver_fns))
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_storage_base, "StorageDriver", $sf) $(f)(storage::StorageDriver, args...; kwargs...) = storage.o[$(sf)](args..., kwargs...)
end

for f in _container_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_storage_base, "Container", $sf) $(f)(cont::Container, args...; kwargs...) = cont.o[$(sf)](args..., kwargs...)
end

for f in _object_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_storage_base, "Object", $sf) $(f)(obj::Object, args...; kwargs...) = obj.o[$(sf)](args..., kwargs...)
end

# Initialize cloud storage
function __init__()
    copy!(_libcloud_storage_types, pyimport("libcloud.storage.types"))
    copy!(_libcloud_storage_providers, pyimport("libcloud.storage.providers"))
    copy!(_libcloud_storage_base, pyimport("libcloud.storage.base"))

    global const StorageProvider = pywrap(_libcloud_storage_types[:Provider])

    _map_types(_libcloud_storage_base, (Container, Object))
end

# types
export StorageProvider, StorageDriver, Container, Object
# storage driver functions
export create_container, delete_container, delete_object, download_object, download_object_as_stream,
       enable_container_cdn, enable_object_cdn, get_container, get_container_cdn_url, get_object,
       get_object_cdn_url, iterate_container_objects, iterate_containers, list_container_objects,
       list_containers, upload_object, upload_object_via_stream
# container functions
export iterate_objects, list_objects, get_cdn_url, enable_cdn, get_object, upload_object,
       upload_object_via_stream, download_object, download_object_as_stream, delete_object, delete
# object functions
export get_cdn_url, enable_cdn, download, as_stream, delete

end # module Storage
