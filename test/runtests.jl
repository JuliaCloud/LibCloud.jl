using LibCloud
using Base.Test

include("test_compute.jl")
include("test_storage.jl")

using TestCompute
using TestStorage

println("\nCOMPUTE\n===================")
TestCompute.dummy()
println("\nSTORAGE\n===================")
TestStorage.dummy()
