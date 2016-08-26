using Compat
using PyCall
import PyCall: PyObject, pygui, pycall, pyexists
import Base: convert, show, download, detach

const _libcloud = PyCall.PyNULL()
const _base_driver_fns = [:list_regions]
global list_regions

function _map_types(pymod, types)
    for t in types
        n = rsplit(string(t), '.', limit=2)[end]
        pytype_mapping(pymod[n], t)
    end
end

function __init__()
    copy!(_libcloud, pyimport_conda("libcloud", "apache-libcloud"))

    global const version = try
        convert(VersionNumber, _libcloud[:__version__])
    catch
        v"0.0" # fallback
    end
end
