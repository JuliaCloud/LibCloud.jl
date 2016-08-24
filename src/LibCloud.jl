#__precompile__()

module LibCloud

using Compat
using PyCall
import PyCall: PyObject, pygui, pycall, pyexists
import Base: convert, show, download

const _libcloud = PyCall.PyNULL()

include("lazyhelp.jl")
include("common.jl")
include("storage.jl")
include("dns.jl")
include("loadbalancer.jl")
include("compute.jl")
include("containers.jl")

function __init__()
    copy!(_libcloud, pyimport_conda("libcloud", "apache-libcloud"))

    global const version = try
        convert(VersionNumber, _libcloud[:__version__])
    catch
        v"0.0" # fallback
    end
end

end # module
