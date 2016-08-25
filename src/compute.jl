module Compute

include("module_common.jl")

const _libcloud_compute_types = PyCall.PyNULL()
const _libcloud_compute_providers = PyCall.PyNULL()
const _libcloud_compute_base = PyCall.PyNULL()

immutable NodeDriver
    o::PyObject

    function NodeDriver(provider::String, args...; kwargs...)
        cls = _libcloud_compute_providers[:get_driver](provider)
        NodeDriver(cls(args...; kwargs...))
    end
    NodeDriver(driver::PyObject) = new(driver)
end
show(io::IO, c::NodeDriver) = print(io, c.o[:__str__]())

immutable NodeSize
    o::PyObject

    id::String
    name::String
    ram::Nullable{Int}
    disk::Nullable{Int}
    bandwidth::Nullable{Int}
    price::Nullable{Float64}
    extra::Dict
    driver::NodeDriver

    function NodeSize(o::PyObject)
        new(o, o[:id], o[:name], o[:ram], o[:disk], o[:bandwidth], o[:price], o[:extra], NodeDriver(o[:driver]))
    end
end
PyObject(o::NodeSize) = o.o
convert(::Type{NodeSize}, o::PyObject) = NodeSize(o)
show(io::IO, o::NodeSize) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_compute_base, "NodeSize") NodeSize

immutable NodeImage
    o::PyObject

    id::String
    name::String
    extra::Dict
    driver::NodeDriver
    
    function NodeImage(o::PyObject)
        new(o, o[:id], o[:name], o[:extra], NodeDriver(o[:driver]))
    end
end
PyObject(o::NodeImage) = o.o
convert(::Type{NodeImage}, o::PyObject) = NodeImage(o)
show(io::IO, o::NodeImage) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_compute_base, "NodeImage") NodeImage

immutable Node
    o::PyObject

    id::String
    name::String
    state::String
    public_ips::Vector
    private_ips::Vector
    size::NodeSize
    image::NodeImage
    created_at::DateTime
    extra::Dict
    driver::NodeDriver

    function Node(o::PyObject)
        created_at = o[:created_at]
        new(o, o[:id], o[:name], o[:state], o[:public_ips], o[:private_ips], NodeSize(o[:size]), NodeImage(o[:image]), created_at, o[:extra], NodeDriver(o[:driver]))
    end
end
PyObject(o::Node) = o.o
convert(::Type{Node}, o::PyObject) = Node(o)
show(io::IO, o::Node) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_compute_base, "Node") Node

immutable NodeLocation
    o::PyObject

    id::String
    name::String
    country::String
    driver::NodeDriver

    function NodeLocation(o::PyObject)
        new(o, o[:id], o[:name], o[:country], NodeDriver(o[:driver]))
    end
end
PyObject(o::NodeLocation) = o.o
convert(::Type{NodeLocation}, o::PyObject) = NodeLocation(o)
show(io::IO, o::NodeLocation) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_compute_base, "NodeLocation") NodeLocation

immutable NodeAuthSSHKey
    o::PyObject

    pubkey::String

    function NodeAuthSSHKey(o::PyObject)
        new(o, o[:pubkey])
    end
end
PyObject(o::NodeAuthSSHKey) = o.o
convert(::Type{NodeAuthSSHKey}, o::PyObject) = NodeAuthSSHKey(o)
show(io::IO, o::NodeAuthSSHKey) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_compute_base, "NodeAuthSSHKey") NodeAuthSSHKey

immutable NodeAuthPassword
    o::PyObject

    password::String
    generated::Bool

    function NodeAuthPassword(o::PyObject)
        new(o, o[:password], o[:generated])
    end
end
PyObject(o::NodeAuthPassword) = o.o
convert(::Type{NodeAuthPassword}, o::PyObject) = NodeAuthPassword(o)
show(io::IO, o::NodeAuthPassword) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_compute_base, "NodeAuthPassword") NodeAuthPassword

immutable StorageVolume
    o::PyObject

    id::String
    name::String
    size::Int
    state::String
    extra::Dict
    driver::NodeDriver

    function StorageVolume(o::PyObject)
        new(o, o[:id], o[:name], o[:size], o[:state], o[:extra], NodeDriver(o[:driver]))
    end
end
PyObject(o::StorageVolume) = o.o
convert(::Type{StorageVolume}, o::PyObject) = StorageVolume(o)
show(io::IO, o::StorageVolume) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_compute_base, "StorageVolume") StorageVolume

immutable VolumeSnapshot
    o::PyObject

    id::String
    size::Int
    created::DateTime
    state::String
    extra::Dict
    driver::NodeDriver

    function VolumeSnapshot(o::PyObject)
        created = o[:created]
        new(o, o[:id], o[:size], created, o[:state], o[:extra], NodeDriver(o[:driver]))
    end
end
PyObject(o::VolumeSnapshot) = o.o
convert(::Type{VolumeSnapshot}, o::PyObject) = VolumeSnapshot(o)
show(io::IO, o::VolumeSnapshot) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_compute_base, "VolumeSnapshot") VolumeSnapshot

immutable KeyPair
    o::PyObject

    name::String
    fingerprint::String
    public_key::Nullable{String}
    private_key::Nullable{String}
    extra::Dict
    driver::NodeDriver

    function KeyPair(o::PyObject)
        new(o, o[:name], o[:fingerprint], o[:public_key], o[:private_key], o[:extra], NodeDriver(o[:driver]))
    end
end
PyObject(o::KeyPair) = o.o
convert(::Type{KeyPair}, o::PyObject) = KeyPair(o)
show(io::IO, o::KeyPair) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_compute_base, "KeyPair") KeyPair

const _nodedriver_fns = [
    # Node management methods
    :list_nodes, :list_sizes, :list_locations, :create_node, :deploy_node, :reboot_node, :destroy_node, :wait_until_running,
    # Volume and snapshot management methods
    :list_volumes, :list_volume_snapshots, :create_volume, :create_volume_snapshot, :attach_volume, :detach_volume, :destroy_volume, :destroy_volume_snapshot,
    # Image management methods
    :list_images, :create_image, :delete_image, :get_image, :copy_image,
    # SSH key pair management methods
    :list_key_pairs, :get_key_pair, :create_key_pair, :import_key_pair_from_string, :import_key_pair_from_file, :delete_key_pair
]

const _uuid_fns = [ :get_uuid ]
const _node_fns = [ :reboot, :destroy ]
const _storage_volume_fns = [ :list_snapshots, :attach, :detach, :snapshot, :destroy ]
const _volume_snapshot_fns = [ :destroy ]

for f in _uuid_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_compute_base, "UuidMixin", $sf) $(f)(n::Node, args...; kwargs...) = n.o[$(sf)](args..., kwargs...)
    @eval @doc LazyHelp(_libcloud_compute_base, "UuidMixin", $sf) $(f)(n::NodeSize, args...; kwargs...) = n.o[$(sf)](args..., kwargs...)
    @eval @doc LazyHelp(_libcloud_compute_base, "UuidMixin", $sf) $(f)(n::NodeImage, args...; kwargs...) = n.o[$(sf)](args..., kwargs...)
    @eval @doc LazyHelp(_libcloud_compute_base, "UuidMixin", $sf) $(f)(n::StorageVolume, args...; kwargs...) = n.o[$(sf)](args..., kwargs...)
end

for f in union(Set(_nodedriver_fns), Set(_base_driver_fns))
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_compute_base, "NodeDriver", $sf) $(f)(driver::NodeDriver, args...; kwargs...) = driver.o[$(sf)](args..., kwargs...)
end

for f in _node_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_compute_base, "Node", $sf) $(f)(node::Node, args...; kwargs...) = node.o[$(sf)](args..., kwargs...)
end

for f in _storage_volume_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_compute_base, "StorageVolume", $sf) $(f)(vol::StorageVolume, args...; kwargs...) = vol.o[$(sf)](args..., kwargs...)
end

for f in _volume_snapshot_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_compute_base, "VolumeSnapshot", $sf) $(f)(vol::VolumeSnapshot, args...; kwargs...) = vol.o[$(sf)](args..., kwargs...)
end

# Initialize cloud dns
function __init__()
    copy!(_libcloud_compute_types, pyimport("libcloud.compute.types"))
    copy!(_libcloud_compute_providers, pyimport("libcloud.compute.providers"))
    copy!(_libcloud_compute_base, pyimport("libcloud.compute.base"))

    global const ComputeProvider = pywrap(_libcloud_compute_types[:Provider])
    global const NodeState = pywrap(_libcloud_compute_types[:NodeState])
    global const Architecture = pywrap(_libcloud_compute_types[:Architecture])
    global const StorageVolumeState = pywrap(_libcloud_compute_types[:StorageVolumeState])
    global const VolumeSnapshotState = pywrap(_libcloud_compute_types[:VolumeSnapshotState])

    pytype_mapping(_libcloud_compute_base["Node"], Node)
    pytype_mapping(_libcloud_compute_base["NodeSize"], NodeSize)
    pytype_mapping(_libcloud_compute_base["NodeImage"], NodeImage)
    pytype_mapping(_libcloud_compute_base["NodeLocation"], NodeLocation)
    pytype_mapping(_libcloud_compute_base["NodeAuthSSHKey"], NodeAuthSSHKey)
    pytype_mapping(_libcloud_compute_base["NodeAuthPassword"], NodeAuthPassword)
    pytype_mapping(_libcloud_compute_base["StorageVolume"], StorageVolume)
    pytype_mapping(_libcloud_compute_base["VolumeSnapshot"], VolumeSnapshot)
    pytype_mapping(_libcloud_compute_base["KeyPair"], KeyPair)
end

# types
export ComputeProvider, NodeDriver, NodeSize, NodeImage, Node, NodeLocation, NodeAuthSSHKey, NodeAuthPassword, StorageVolume, VolumeSnapshot, KeyPair
# Node management methods
export list_nodes, list_sizes, list_locations, create_node, deploy_node, reboot_node, destroy_node, wait_until_running
# Volume and snapshot management methods
export list_volumes, list_volume_snapshots, create_volume, create_volume_snapshot, attach_volume, detach_volume, destroy_volume, destroy_volume_snapshot
# Image management methods
export list_images, create_image, delete_image, get_image, copy_image
# SSH key pair management methods
export list_key_pairs, get_key_pair, create_key_pair, import_key_pair_from_string, import_key_pair_from_file, delete_key_pair

export get_uuid
export reboot, destroy
export list_snapshots, attach, detach, snapshot, destroy
export destroy

end # module Compute
