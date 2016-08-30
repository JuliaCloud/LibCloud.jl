using LibCloud
using Base.Test

include("test_compute.jl")
include("test_storage.jl")
include("test_dns.jl")

using TestCompute
using TestStorage
using TestDNS

println("\nCOMPUTE\n===================")
TestCompute.dummy()
println("\nSTORAGE\n===================")
TestStorage.dummy()
println("\nDNS\n===================")
TestDNS.dummy()
