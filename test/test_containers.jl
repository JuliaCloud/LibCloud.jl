module TestContainers

using LibCloud.Containers
using Base.Test
using PyCall

function ecs(key, secret)
    cp = ContainerDriver(ContainerProvider.ECS, key, secret, "us-east-1")
    println("Regions:\n", list_regions(cp))
    println("Images:\n", list_images(cp, "ecs-test"))
    println("Containers:\n", list_containers(cp))
    println("Clusters:\n", list_clusters(cp))
end

function docker(host, port)
    cp = ContainerDriver(ContainerProvider.DOCKER, host, port)
    println("Regions:\n", list_regions(cp))
    println("Images:\n", list_images(cp))
    println("Containers:\n", list_containers(cp))
    println("Locations:\n", list_locations(cp))
    println("Clusters:\n", list_clusters(cp))
end

function dummy()
    cp = ContainerDriver(ContainerProvider.DUMMY, "key", "secret")
    println("Regions:\n", list_regions(cp))
end

end # module TestContainers
