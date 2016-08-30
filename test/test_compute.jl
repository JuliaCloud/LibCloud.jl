module TestCompute

using LibCloud.Compute
using Base.Test
using PyCall

function ec2(key, secret)
    nd = NodeDriver(ComputeProvider.EC2, key, secret)
    println("Regions:")
    for reg in list_regions(nd)
        println("    - ", reg)
    end

    println("Sizes:")
    for sz in list_sizes(nd)
        println("    - ", sz)
    end

    println("Locations:")
    for loc in list_locations(nd)
        println("    - ", loc)
    end
   
    println("Volumes:") 
    for vol in list_volumes(nd)
        println(vol)
        for snapshot in list_volume_snapshots(nd, vol)
            println("    - ", snapshot)
        end
    end
end

function dummy()
    driver = NodeDriver(ComputeProvider.DUMMY, 0)

    driver_features = features(driver)
    @test "create_node" in keys(driver_features)
    @test isempty(driver_features["create_node"])

    println("Creating a node...")
    node = Node(create_node(driver))
    @test !isempty(get_uuid(node))
    @test state(node) == NodeState.RUNNING

    println("Listing nodes...")
    nodes = list_nodes(driver)
    @test !isempty(nodes)
    for n in nodes
        @test isa(n, Node)
    end

    println("Listing sizes...")
    sizes = list_sizes(driver)
    @test !isempty(sizes)
    for s in sizes
        @test isa(s, NodeSize)
    end

    println("Listing images...")
    images = list_images(driver)
    @test !isempty(images)
    for i in images
        @test isa(i, NodeImage)
    end

    println("Listing locations...")
    locs = list_locations(driver)
    @test !isempty(locs)
    for l in locs
        @test isa(l, NodeLocation)
    end

    println("Rebooting node...")
    @test reboot(node) == true
    @test state(node) == NodeState.REBOOTING
    println("Destroying node...")
    @test destroy(node) == true
    @test state(node) == NodeState.TERMINATED

    println("Creating key...")
    k = NodeAuthSSHKey("my pub key")
    @test k.o[:pubkey] == "my pub key"
end

function gce(service_account_id, key, project)
    driver = NodeDriver(ComputeProvider.GCE, service_account_id, key, project=project)

    driver_features = features(driver)
    @test "create_node" in keys(driver_features)
    @test isempty(driver_features["create_node"])

    println("Listing nodes...")
    nodes = list_nodes(driver)
    @test !isempty(nodes)
    for n in nodes
        @test isa(n, Node)
    end

    println("Listing sizes...")
    sizes = list_sizes(driver)
    @test !isempty(sizes)
    for s in sizes
        @test isa(s, NodeSize)
    end     

    println("Listing images...")
    images = list_images(driver)
    @test !isempty(images)
    for i in images
        @test isa(i, NodeImage)
    end

    println("Listing locations...")
    locs = list_locations(driver)
    @test !isempty(locs)
    for l in locs
        @test isa(l, NodeLocation)
    end
end

end # module TestCompute
