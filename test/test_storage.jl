using LibCloud.Storage

function test_s3(key, secret)
    storage = StorageDriver(StorageProvider.S3, key, secret)
    println("Regions:\n", list_regions(storage))

    for container in iterate_containers(storage)
        println(container)
        try
            objcount = 0
            for obj in iterate_container_objects(storage, container)
                println("    - ", obj)
                objcount += 1
                if objcount > 20
                    break
                end
            end
        end
    end
end
