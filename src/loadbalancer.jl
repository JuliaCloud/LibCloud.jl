const _libcloud_lb_types = PyCall.PyNULL()
const _libcloud_lb_providers = PyCall.PyNULL()
const _libcloud_lb_base = PyCall.PyNULL()

type LBDriver
    driver::Module

    function LBDriver(provider, args...; kwargs...)
        cls = _libcloud_lb_providers[:get_driver](provider)
        driver = cls(args...; kwargs...)
        new(pywrap(driver))
    end
end
function show(io::IO, c::LBDriver)
    print(io, "LB Driver: ", c.driver.name)
end

type Member
    o::PyObject
end
PyObject(o::Member) = o.o
convert(::Type{Member}, o::PyObject) =  Member(o)
function show(io::IO, o::Member)
    print(io, "Member: ", o.o[:id], ", ip=", o.o[:ip], ", port=", o.o[:port])
end
@doc LazyHelp(_libcloud_lb_base, "Member") Member

type LoadBalancer
    o::PyObject
end
PyObject(o::LoadBalancer) = o.o
convert(::Type{LoadBalancer}, o::PyObject) =  LoadBalancer(o)
function show(io::IO, o::LoadBalancer)
    print(io, "LoadBalancer: ", o.o[:id], ", name=", o.o[:name], ", state=", o.o[:state], ", ip=", o.o[:ip], ", port=", o.o[:port])
end
@doc LazyHelp(_libcloud_lb_base, "LoadBalancer") LoadBalancer

const _lbdriver_fns = [
    :list_protocols, :list_balancers, :create_balancer, :destroy_balancer,
    :get_balancer, :update_balancer, :balancer_attach_compute_node, :balancer_attach_member,
    :balancer_detach_member, :balancer_list_members, :list_supported_algorithms
]

const _lb_fns = [
    :attach_compute_node, :attach_member, :detach_member, :list_members, :destroy
]

for f in _lbdriver_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_lb_base, "Driver", $sf) $(f)(lb::LBDriver, args...; kwargs...) = lb.driver.$(f)(args..., kwargs...)
end

for f in _lb_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_lb_base, "LoadBalancer", $sf) $(f)(lb::LoadBalancer, args...; kwargs...) = lb.o[$(sf)](args..., kwargs...)
end

# Initialize load balancer
function __init_loadbalancer()
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

export LBProvider, LBDriver, State, MemberCondition, Algorithm, DefaultAlgorithm, LoadBalancer, Member
export list_protocols, list_balancers, create_balancer, destroy_balancer,
       get_balancer, update_balancer, balancer_attach_compute_node, balancer_attach_member,
       balancer_detach_member, balancer_list_members, list_supported_algorithms
export attach_compute_node, attach_member, detach_member, list_members, destroy
