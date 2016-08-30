module TestBackup

using LibCloud.Backup
using Base.Test
using PyCall

function dummy()
    cp = BackupDriver(BackupProvider.DUMMY, "key", "secret")
    println("Regions:\n", list_regions(cp))
end

end # module TestBackup
