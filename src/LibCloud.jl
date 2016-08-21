#__precompile__()

module LibCloud

using Compat
using PyCall
import PyCall: PyObject, pygui, pycall, pyexists
import Base: convert, show

const _libcloud = PyCall.PyNULL()

include("lazyhelp.jl")
include("storage.jl")
include("dns.jl")

function __init__()
    copy!(_libcloud, pyimport_conda("libcloud", "apache-libcloud"))

    global const version = try
        convert(VersionNumber, _libcloud[:__version__])
    catch
        v"0.0" # fallback
    end

    __init_storage()
    __init_dns()
end

end # module
