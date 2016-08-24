using LibCloud.Compute

function test_compute(key, secret)
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
