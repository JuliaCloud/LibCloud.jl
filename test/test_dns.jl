module TestDNS

using LibCloud.DNS
using Base.Test
using PyCall

const TEST_DOMAIN = "julialibcloudtest.com."

function common(dns, upd=false)
    println("Regions:\n", list_regions(dns))

    println("Record Types:\n", list_record_types(dns))

    println("Creating test zone ($TEST_DOMAIN)...")
    zone = create_zone(dns, TEST_DOMAIN)
    @test isa(zone, Zone)

    if upd
        println("Updating test zone ($TEST_DOMAIN)...")
        zone = update_zone(dns, zone, TEST_DOMAIN, ttl=600)
        @test isa(zone, Zone)
    end

    println("Creating test records...")

    data = Dict{Any,Any}()
    data["rrdatas"] = ["127.0.0.1"]

    rec1 = create_record(dns, "www."*TEST_DOMAIN, zone, RecordType.A, data)
    @test isa(rec1, Record)
    rec2 = create_record(dns, "ftp."*TEST_DOMAIN, zone, RecordType.A, data)
    @test isa(rec2, Record)

    println("Listing zones...")
    for z in list_zones(dns)
        @test isa(z, Zone)
        println(z)
        for r in list_records(z)
            @test isa(r, Record)
            println("    - ", r)
        end
    end

    println("Deleting test records...")
    for rec in list_records(zone)
        if rec.typ == RecordType.A
            println("    - ", rec)
            @test delete_record(dns, rec)
        end
    end

    println("Deleting test zone...")
    @test delete_zone(dns, zone)
end

function dummy()
    dns = DNSDriver(DNSProvider.DUMMY, "key", "secret")
    common(dns)
end

function route53(key, secret)
    dns = DNSDriver(DNSProvider.ROUTE53, key, secret)
    common(dns)
end

function gce(service_account_id, key, project)
	dns = DNSDriver(DNSProvider.GOOGLE, service_account_id, key, project=project)
    common(dns)
end

end # module TestDNS
