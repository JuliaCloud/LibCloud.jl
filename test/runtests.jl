using LibCloud
using Base.Test

include("test_compute.jl")
include("test_storage.jl")
include("test_dns.jl")
include("test_containers.jl")
include("test_backup.jl")

using TestCompute
using TestStorage
using TestDNS
using TestContainers
using TestBackup

println("\nCOMPUTE\n===================")
TestCompute.dummy()
println("\nSTORAGE\n===================")
TestStorage.dummy()
println("\nDNS\n===================")
TestDNS.dummy()
println("\nContainers\n===================")
TestContainers.dummy()
println("\nBackup\n===================")
TestBackup.dummy()
