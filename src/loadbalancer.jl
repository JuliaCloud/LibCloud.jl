module LB

using Compat
using PyCall
import PyCall: PyObject, pycall, pyexists
import Base: convert, show, download
using ..LazyHelp
using .._base_driver_fns

const _libcloud_lb_types = PyCall.PyNULL()
const _libcloud_lb_providers = PyCall.PyNULL()
const _libcloud_lb_base = PyCall.PyNULL()

immutable LBDriver
    o::PyObject

    function LBDriver(provider::String, args...; kwargs...)
        cls = _libcloud_lb_providers[:get_driver](provider)
        LBDriver(cls(args...; kwargs...))
    end
    LBDriver(driver::PyObject) = new(driver)
end
show(io::IO, c::LBDriver) = print(io, c.o[:__str__]())

immutable LoadBalancer
    o::PyObject

    id::Nullable{String}
    name::String
    state::Int
    ip::String
    port::Nullable{Int}
    driver::LBDriver
    extra::Dict

    function LoadBalancer(o::PyObject)
        new(o, o[:id], o[:name], o[:state], o[:ip], o[:port], LBDriver(o[:driver]), o[:extra])
    end
end
PyObject(o::LoadBalancer) = o.o
convert(::Type{LoadBalancer}, o::PyObject) =  LoadBalancer(o)
show(io::IO, o::LoadBalancer) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_lb_base, "LoadBalancer") LoadBalancer

immutable Member
    o::PyObject

    id::Nullable{String}
    ip::Nullable{String}
    port::Nullable{String}
    balancer::Nullable{LoadBalancer}
    extra::Dict

    function Member(o::PyObject)
        balancer = (o[:balancer] == nothing) ? Nullable{LoadBalancer}() : Nullable(LoadBalancer(o[:balancer]))
        new(o, o[:id], o[:ip], o[:port], balancer, o[:extra])
    end
end
PyObject(o::Member) = o.o
convert(::Type{Member}, o::PyObject) =  Member(o)
show(io::IO, o::Member) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_lb_base, "Member") Member

const _lbdriver_fns = [
    :list_protocols, :list_balancers, :create_balancer, :destroy_balancer,
    :get_balancer, :update_balancer, :balancer_attach_compute_node, :balancer_attach_member,
    :balancer_detach_member, :balancer_list_members, :list_supported_algorithms
]

const _lb_fns = [
    :attach_compute_node, :attach_member, :detach_member, :list_members, :destroy
]

for f in union(Set(_lbdriver_fns), Set(_base_driver_fns))
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_lb_base, "Driver", $sf) $(f)(lb::LBDriver, args...; kwargs...) = lb.o[$(sf)](args..., kwargs...)
end

for f in _lb_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_lb_base, "LoadBalancer", $sf) $(f)(lb::LoadBalancer, args...; kwargs...) = lb.o[$(sf)](args..., kwargs...)
end

# Initialize load balancer
function __init__()
    copy!(_libcloud_lb_types, pyimport("libcloud.loadbalancer.types"))
    copy!(_libcloud_lb_providers, pyimport("libcloud.loadbalancer.providers"))
    copy!(_libcloud_lb_base, pyimport("libcloud.loadbalancer.base"))

    global const LBProvider = pywrap(_libcloud_lb_types[:Provider])
    global const State = pywrap(_libcloud_lb_types[:State])
    global const MemberCondition = pywrap(_libcloud_lb_types[:MemberCondition])
    global const Algorithm = pywrap(_libcloud_lb_base[:Algorithm])
    global const DefaultAlgorithm = Algorithm.ROUND_ROBIN

    pytype_mapping(_libcloud_lb_base["Driver"], LBDriver)
    pytype_mapping(_libcloud_lb_base["Member"], Member)
    pytype_mapping(_libcloud_lb_base["LoadBalancer"], LoadBalancer)
end

# types
export LBProvider, LBDriver, State, MemberCondition, Algorithm, DefaultAlgorithm, LoadBalancer, Member
# base driver functions
export list_regions
# lb driver functions
export list_protocols, list_balancers, create_balancer, destroy_balancer,
       get_balancer, update_balancer, balancer_attach_compute_node, balancer_attach_member,
       balancer_detach_member, balancer_list_members, list_supported_algorithms
# lb functons
export attach_compute_node, attach_member, detach_member, list_members, destroy

end # module LoadBalancer
