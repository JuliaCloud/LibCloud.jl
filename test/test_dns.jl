using LibCloud.DNS

function test_route53(key, secret)
    dns = DNSDriver(DNSProvider.ROUTE53, key, secret)
    println("Regions:\n", list_regions(dns))
    for zone in iterate_zones(dns)
        println(zone)
        for record in list_records(zone)
            println("    - ", record)
        end
    end
end
