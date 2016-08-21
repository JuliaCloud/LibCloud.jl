const _libcloud_dns_types = PyCall.PyNULL()
const _libcloud_dns_providers = PyCall.PyNULL()
const _libcloud_dns_base = PyCall.PyNULL()

type DNS
    driver::Module

    function DNS(provider, args...; kwargs...)
        cls = _libcloud_dns_providers[:get_driver](provider)
        driver = cls(args...; kwargs...)
        new(pywrap(driver))
    end
end
function show(io::IO, c::DNS)
    print(io, "DNS: ", c.driver.name)
end

type Zone
    o::PyObject
end
PyObject(o::Zone) = o.o
convert(::Type{Zone}, o::PyObject) =  Zone(o)
function show(io::IO, o::Zone)
    print(io, "Zone: ", o.o[:id], ", domain=", o.o[:domain], ", type=", o.o[:type], ", provider=", o.o[:driver][:name])
end
@doc LazyHelp(_libcloud_dns_base, "Zone") Zone

type Record
    o::PyObject
end
PyObject(o::Record) = o.o
convert(::Type{Record}, o::PyObject) =  Record(o)
function show(io::IO, o::Record)
    print(io, "Record: ", o.o[:id], ", name=", o.o[:name], ", type=", o.o[:type], ", data=", o.o[:data], "bytes")
end
@doc LazyHelp(_libcloud_dns_base, "Record") Record

const _dns_fns = [:list_record_types, :iterate_zones, :list_zones, :iterate_records, :list_records,
                  :get_zone, :get_record, :create_zone, :update_zone, :create_record, :update_record,
                  :delete_zone, :delete_record, :export_zone_to_bind_format, :export_zone_to_bind_zone_file]

const _zone_fns = [:list_records, :create_record, :update, :delete, :export_to_bind_format, :export_to_bind_zone_file]

const _record_fns = [:update, :delete]

for f in _dns_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_dns_base, "DNSDriver", $sf) $(f)(dns::DNS, args...; kwargs...) = dns.driver.$(f)(args..., kwargs...)
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
function __init_dns()
    copy!(_libcloud_dns_types, pyimport("libcloud.dns.types"))
    copy!(_libcloud_dns_providers, pyimport("libcloud.dns.providers"))
    copy!(_libcloud_dns_base, pyimport("libcloud.dns.base"))

    global const DNSProvider = pywrap(_libcloud_dns_types[:Provider])
    global const DNSRecordType = pywrap(_libcloud_dns_types[:RecordType])

    pytype_mapping(_libcloud_dns_base["Zone"], Zone)
    pytype_mapping(_libcloud_dns_base["Record"], Record)
end

export DNSProvider, DNS, Zone, Record
export list_record_types, iterate_zones, list_zones, iterate_records, list_records,
       get_zone, get_record, create_zone, update_zone, create_record, update_record,
       delete_zone, delete_record, export_zone_to_bind_format, export_zone_to_bind_zone_file
export list_records, create_record, update, delete, export_to_bind_format, export_to_bind_zone_file
export update, delete
