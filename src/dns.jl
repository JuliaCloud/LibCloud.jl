module DNS

include("module_common.jl")

const _libcloud_dns_types = PyCall.PyNULL()
const _libcloud_dns_providers = PyCall.PyNULL()
const _libcloud_dns_base = PyCall.PyNULL()

immutable DNSDriver
    o::PyObject

    function DNSDriver(provider::String, args...; kwargs...)
        cls = _libcloud_dns_providers[:get_driver](provider)
        DNSDriver(cls(args...; kwargs...))
    end
    DNSDriver(driver::PyObject) = new(driver)
end
show(io::IO, c::DNSDriver) = print(io, c.o[:__str__]())

immutable Zone
    o::PyObject

    id::Nullable{String}
    domain::String
    typ::String
    ttl::Nullable{Int}
    driver::DNSDriver
    extra::Dict

    function Zone(o::PyObject)
        new(o, o[:id], o[:domain], o[:type], o[:ttl], DNSDriver(o[:driver]), o[:extra])
    end
end
PyObject(o::Zone) = o.o
convert(::Type{Zone}, o::PyObject) =  Zone(o)
show(io::IO, o::Zone) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_dns_base, "Zone") Zone

immutable Record
    o::PyObject

    id::Nullable{String}
    name::String
    typ::String
    data::String
    zone::Zone
    driver::DNSDriver
    ttl::Int
    extra::Dict

    function Record(o::PyObject)
        new(o, o[:id], o[:name], o[:type], o[:data], Zone(o[:zone]), DNSDriver(o[:driver]), o[:ttl], o[:extra])
    end
end
PyObject(o::Record) = o.o
convert(::Type{Record}, o::PyObject) =  Record(o)
show(io::IO, o::Record) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_dns_base, "Record") Record

const _dnsdriver_fns = [
    :list_record_types, :iterate_zones, :list_zones, :iterate_records, :list_records,
    :get_zone, :get_record, :create_zone, :update_zone, :create_record, :update_record,
    :delete_zone, :delete_record, :export_zone_to_bind_format, :export_zone_to_bind_zone_file
]

const _zone_fns = [
    :list_records, :create_record, :update, :delete, :export_to_bind_format, :export_to_bind_zone_file
]

const _record_fns = [
    :update, :delete
]

for f in union(Set(_dnsdriver_fns), Set(_base_driver_fns))
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_dns_base, "DNSDriver", $sf) $(f)(dns::DNSDriver, args...; kwargs...) = dns.o[$(sf)](args..., kwargs...)
end

for f in _zone_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_dns_base, "Zone", $sf) $(f)(zone::Zone, args...; kwargs...) = zone.o[$(sf)](args..., kwargs...)
end

for f in _record_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_dns_base, "Record", $sf) $(f)(rec::Record, args...; kwargs...) = rec.o[$(sf)](args..., kwargs...)
end

# Initialize cloud dns
function __init__()
    copy!(_libcloud_dns_types, pyimport("libcloud.dns.types"))
    copy!(_libcloud_dns_providers, pyimport("libcloud.dns.providers"))
    copy!(_libcloud_dns_base, pyimport("libcloud.dns.base"))

    global const DNSProvider = pywrap(_libcloud_dns_types[:Provider])
    global const RecordType = pywrap(_libcloud_dns_types[:RecordType])

    pytype_mapping(_libcloud_dns_base["Zone"], Zone)
    pytype_mapping(_libcloud_dns_base["Record"], Record)
end

# types
export DNSProvider, DNSDriver, RecordType, Zone, Record
# dns driver functions
export list_record_types, iterate_zones, list_zones, iterate_records, list_records,
       get_zone, get_record, create_zone, update_zone, create_record, update_record,
       delete_zone, delete_record, export_zone_to_bind_format, export_zone_to_bind_zone_file
# zone functions
export list_records, create_record, update, delete, export_to_bind_format, export_to_bind_zone_file
# record functions
export update, delete

end # module DNS
