module TestStorage

using LibCloud.Storage
using Base.Test
using PyCall

const TEST_BKT_NAME = "julia-libcloud-test"

function s3_like(storage, do_download=true)
    println("Regions:\n", list_regions(storage))

    println("Creating test container ($TEST_BKT_NAME)...")
	cont = create_container(storage, TEST_BKT_NAME)
    @test isa(cont, Container)
    @test cont.name == TEST_BKT_NAME

    println("Creating temp file...")
    fname, io = mktemp()
    for x in 1:10
        println(io, "hello world")
    end
    close(io)

    println("Uploading test files...")
    for idx in 1:5
        meta_data = Dict{Any,Any}("idx" => idx)
        extra = Dict{Any,Any}("meta_data" => meta_data)
        println("    - ", meta_data["idx"])
        oname = "storage_test_$idx"
        obj = upload_object(cont, fname, oname, extra)
        @test isa(obj, Object)
        @test obj.name == oname
    end

    if do_download
        println("Downloading test files...")
        for idx in 1:5
            obj = get_object(cont, "storage_test_$idx")
            @test isa(obj, Object)
            println("    - ", obj.meta_data["idx"])
            @test download_object(cont, obj, fname, overwrite_existing=true)
        end
    end

    println("Listing files...")
    for container in iterate_containers(storage)
        @test isa(container, Container)
        println(container)
        try
            objcount = 0
            for obj in iterate_container_objects(storage, container)
                @test isa(obj, Object)
                println("    - ", obj)
                objcount += 1
                if objcount > 20
                    break
                end
            end
        end
    end

    println("Deleting test files...")
    for idx in 1:5
        obj = get_object(cont, "storage_test_$idx")
        @test isa(obj, Object)
        println("    - ", obj.meta_data["idx"])
        @test delete_object(cont, obj)
    end

    println("Deleting test container ($TEST_BKT_NAME)...")
	@test delete_container(storage, cont)

    println("Deleting temp file ($fname)...")
    rm(fname)

    println("Done.")
end

function s3(key, secret)
    storage = StorageDriver(StorageProvider.S3, key, secret)
    s3_like(storage)
end

function gce(service_account_id, key, project)
	storage = StorageDriver(StorageProvider.GOOGLE_STORAGE, service_account_id, key, project=project)
    s3_like(storage)
end

function dummy()
	storage = StorageDriver(StorageProvider.DUMMY, "key", "secret")
    s3_like(storage, false)
end

end # module TestStorage
