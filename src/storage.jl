const _libcloud_storage_types = PyCall.PyNULL()
const _libcloud_storage_providers = PyCall.PyNULL()
const _libcloud_storage_base = PyCall.PyNULL()

type Storage
    driver::Module

    function Storage(provider, args...; kwargs...)
        cls = _libcloud_storage_providers[:get_driver](provider)
        driver = cls(args...; kwargs...)
        new(pywrap(driver))
    end
end
function show(io::IO, c::Storage)
    print(io, "Storage: ", c.driver.name)
end

type Container
    o::PyObject
end
PyObject(c::Container) = c.o
convert(::Type{Container}, o::PyObject) =  Container(o)
function show(io::IO, c::Container)
    print(io, "Container: ", c.o[:name], ", provider=", c.o[:driver][:name])
end
@doc LazyHelp(_libcloud_storage_base, "Container") Container

type Object
    o::PyObject
end
PyObject(o::Object) = o.o
convert(::Type{Object}, o::PyObject) =  Object(o)
function show(io::IO, o::Object)
    print(io, "Object: ", o.o[:name], ", size=", o.o[:size], "bytes")
end
@doc LazyHelp(_libcloud_storage_base, "Object") Object

const _storage_fns = [:create_container, :delete_container, :delete_object, :download_object, :download_object_as_stream,
                      :enable_container_cdn, :enable_object_cdn, :get_container, :get_container_cdn_url, :get_object,
                      :get_object_cdn_url, :iterate_container_objects, :iterate_containers, :list_container_objects,
                      :list_containers, :upload_object, :upload_object_via_stream]

const _container_fns = [:iterate_objects, :list_objects, :get_cdn_url, :enable_cdn, :get_object, :upload_object,
                        :upload_object_via_stream, :download_object, :download_object_as_stream, :delete_object, :delete]

const _object_fns = [:get_cdn_url, :enable_cdn, :download, :as_stream, :delete]

for f in _storage_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_storage_base, "StorageDriver", $sf) $(f)(storage::Storage, args...; kwargs...) = storage.driver.$(f)(args..., kwargs...)
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
function __init_storage()
    copy!(_libcloud_storage_types, pyimport("libcloud.storage.types"))
    copy!(_libcloud_storage_providers, pyimport("libcloud.storage.providers"))
    copy!(_libcloud_storage_base, pyimport("libcloud.storage.base"))

    global const StorageProvider = pywrap(_libcloud_storage_types[:Provider])

    pytype_mapping(_libcloud_storage_base["Container"], Container)
    pytype_mapping(_libcloud_storage_base["Object"], Object)
end

export StorageProvider, Storage, Container, Object
export create_container, delete_container, delete_object, download_object, download_object_as_stream,
       enable_container_cdn, enable_object_cdn, get_container, get_container_cdn_url, get_object,
       get_object_cdn_url, iterate_container_objects, iterate_containers, list_container_objects,
       list_containers, upload_object, upload_object_via_stream
export iterate_objects, list_objects, get_cdn_url, enable_cdn, get_object, upload_object,
       upload_object_via_stream, download_object, download_object_as_stream, delete_object, delete
export get_cdn_url, enable_cdn, download, as_stream, delete
