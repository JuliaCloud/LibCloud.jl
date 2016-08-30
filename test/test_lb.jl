module TestLB

using LibCloud.LB
using Base.Test
using PyCall

function common(lb)
    println("Regions:\n", list_regions(lb))
    println("Algorithms:\n", list_supported_algorithms(lb))
    println("Protocols:\n", list_protocols(lb))

    for balancer in list_balancers(lb)
        @test isa(balancer, LoadBalancer)
        println(balancer)
        try
            for member in list_members(balancer)
                @test isa(member, Member)
                println("    - ", member)
            end
        end
    end
end

function elb(key, secret, region="us-east-1")
    lb = LBDriver(LBProvider.ELB, key, secret, region)
    common(lb)
end

function gce(service_account_id, key, project)
	lb = LBDriver(LBProvider.GCE, service_account_id, key, project=project)
    common(lb)
end

end # module TestLB
