module Backup

include("module_common.jl")

const _libcloud_backup_types = PyCall.PyNULL()
const _libcloud_backup_providers = PyCall.PyNULL()
const _libcloud_backup_base = PyCall.PyNULL()

immutable BackupDriver
    o::PyObject

    function BackupDriver(provider::Compat.String, args...; kwargs...)
        cls = _libcloud_backup_providers[:get_driver](provider)
        BackupDriver(cls(args...; kwargs...))
    end
    BackupDriver(driver::PyObject) = new(driver)
end
show(io::IO, c::BackupDriver) = print(io, c.o[:__str__]())

immutable BackupTarget
    o::PyObject

    id::Nullable{Compat.String}
    name::Compat.String
    address::Compat.String
    typ::Compat.String
    extra::Dict
    driver::BackupDriver

    function BackupTarget(o::PyObject)
        new(o, o[:id], o[:name], o[:address], o[:type], o[:extra], BackupDriver(o[:driver]))
    end
end
PyObject(o::BackupTarget) = o.o
convert(::Type{BackupTarget}, o::PyObject) =  BackupTarget(o)
show(io::IO, o::BackupTarget) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_backup_base, "BackupTarget") BackupTarget

immutable BackupTargetJob
    o::PyObject

    id::Nullable{Compat.String}
    status::Compat.String
    progress::Int
    target::BackupTarget
    extra::Dict
    driver::BackupDriver

    function BackupTargetJob(o::PyObject)
        new(o, o[:id], o[:status], o[:progress], BackupTarget(o[:target]), o[:extra], BackupDriver(o[:driver]))
    end
end
PyObject(o::BackupTargetJob) = o.o
convert(::Type{BackupTargetJob}, o::PyObject) =  BackupTargetJob(o)
show(io::IO, o::BackupTargetJob) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_backup_base, "BackupTargetJob") BackupTargetJob

immutable BackupTargetRecoveryPoint
    o::PyObject

    id::Nullable{Compat.String}
    date::DateTime
    target::BackupTarget
    extra::Dict
    driver::BackupDriver

    function BackupTargetRecoveryPoint(o::PyObject)
        new(o, o[:id], o[:date], BackupTarget(o[:target]), o[:extra], BackupDriver(o[:driver]))
    end
end
PyObject(o::BackupTargetRecoveryPoint) = o.o
convert(::Type{BackupTargetRecoveryPoint}, o::PyObject) =  BackupTargetRecoveryPoint(o)
show(io::IO, o::BackupTargetRecoveryPoint) = print(io, o.o[:__str__]())
@doc LazyHelp(_libcloud_backup_base, "BackupTargetRecoveryPoint") BackupTargetRecoveryPoint

const _backupdriver_fns = [
    :get_supported_target_types, :list_targets,
    :create_target, :create_target_from_node, :create_target_from_storage_container,
    :update_target, :delete_target,
    :list_recovery_points, :recover_target, :recover_target_out_of_place,
    :get_target_job, :list_target_jobs, :create_target_job, :resume_target_job, :suspend_target_job, :cancel_target_job
]

const _backup_target_fns = [ :update, :delete ]
const _backup_target_job_fns = [ :cancel, :suspend, :resume ]
const _backup_target_recovery_point_fns = [ :recover, :recover_to ]

for f in union(Set(_backupdriver_fns), Set(_base_driver_fns))
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_backup_base, "BackupDriver", $sf) $(f)(b::BackupDriver, args...; kwargs...) = b.o[$(sf)](args..., kwargs...)
end

for f in _backup_target_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_backup_base, "BackupTarget", $sf) $(f)(b::BackupTarget, args...; kwargs...) = b.o[$(sf)](args..., kwargs...)
end

for f in _backup_target_job_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_backup_base, "BackupTargetJob", $sf) $(f)(b::BackupTargetJob, args...; kwargs...) = b.o[$(sf)](args..., kwargs...)
end

for f in _backup_target_recovery_point_fns
    sf = string(f)
    @eval @doc LazyHelp(_libcloud_backup_base, "BackupTargetRecoveryPoint", $sf) $(f)(b::BackupTargetRecoveryPoint, args...; kwargs...) = b.o[$(sf)](args..., kwargs...)
end

# Initialize cloud backup
function __init__()
    copy!(_libcloud_backup_types, pyimport("libcloud.backup.types"))
    copy!(_libcloud_backup_providers, pyimport("libcloud.backup.providers"))
    copy!(_libcloud_backup_base, pyimport("libcloud.backup.base"))

    global const BackupProvider = pywrap(_libcloud_backup_types[:Provider])
    global const BackupTargetType = pywrap(_libcloud_backup_types[:BackupTargetType])
    global const BackupTargetJobStatusType = pywrap(_libcloud_backup_types[:BackupTargetJobStatusType])

    _map_types(_libcloud_backup_base, (BackupTarget, BackupTargetJob, BackupTargetRecoveryPoint))
end

# types
export BackupProvider, BackupDriver, BackupTargetType, BackupTarget, BackupTargetJob, BackupTargetRecoveryPoint
# backup driver functions
export get_supported_target_types, list_targets,
       create_target, create_target_from_node, create_target_from_storage_container,
       update_target, delete_target,
       list_recovery_points, recover_target, recover_target_out_of_place,
       get_target_job, list_target_jobs, create_target_job, resume_target_job, suspend_target_job, cancel_target_job
# backup target functions
export update, delete
# backup target job functions
export cancel, suspend, resume
# backup target recovery point functions
export recover, recover_to

end # module Backup
