using LibCloud.LB

function test_lb(key, secret)
    lb = LBDriver(LBProvider.ELB, key, secret, "us-east-1")
    println("Regions:\n", list_regions(lb))
    println("Algorithms:\n", list_supported_algorithms(lb))
    println("Protocols:\n", list_protocols(lb))

    for balancer in list_balancers(lb)
        println(balancer)
        try
            for member in list_members(balancer)
                println("    - ", member)
            end
        end
    end
end
