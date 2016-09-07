# LibCloud

[![Build Status](https://travis-ci.org/JuliaCloud/LibCloud.jl.svg?branch=master)](https://travis-ci.org/JuliaCloud/LibCloud.jl)
[![Coverage Status](https://coveralls.io/repos/JuliaCloud/LibCloud.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaCloud/LibCloud.jl?branch=master)
[![codecov.io](http://codecov.io/github/JuliaCloud/LibCloud.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaCloud/LibCloud.jl?branch=master)

**LibCloud** is a Julia interface for Apache LibCloud.

[**Apache Libcloud**](http://libcloud.apache.org/) is a Python library which hides differences between different cloud provider APIs and allows you to manage different cloud resources through a unified and easy to use API.

## Installation
The `apache-libcloud` python library is needed for LibCloud to work.

If you have set up [PyCall](https://github.com/stevengj/PyCall.jl) to use [Conda.jl](https://github.com/Luthaf/Conda.jl) then LibCloud will automatically install `apache-libcloud`.

Alternatively, you can install it externally, e.g. `pip install --user apache-libcloud`.

## Usage
LibCloud has its different functionalities organized as sub-modules.
To start using any of them, type:
````julia
using LibCloud
using LibCloud.<submodule>
````

- `using LibCloud.Compute`
    - manage cloud and virtual servers
    - run deployment scripts
    - manage key pairs
    - manage block storage
- `using LibCloud.Storage`
    - manage object storage
    - simple CDN management functionality
- `using LibCloud.LB`
    - manage Load Balancers as a service
- `using LibCloud.DNS`
    - manage DNS as a service
- `using LibCloud.Container`
    - manage container based virtualization platforms
    - works with both on-premises (e.g. Docker) and cloud based (e.g. ECS)
- `using LibCloud.Backup`
    - manage backup as a service (e.g. EBS/GCE snapshots)

With each sub-module:
- examine the list of available providers by enumerating `<module>Provider`
- instantiate a driver (`<module>Driver`) configured with the appropriate provider
- call `features(driver)` to examine the feaures the driver provides
- execute appropriate actions by calling corresponding methods on the driver

The version of the underlying library is available as `LibCloud.version`.

## API Documentation
Refer to [LibCloud API Documentation](https://libcloud.readthedocs.io/en/latest/index.html).

Look at examples in the `LibCloud/test` subfolder for some common use cases.

Typing `?<type or method>` on the Julia REPL would show appropriate help.
The Julia help system is hooked to display documentation from the underlying python modules (LibCloud borrows the `LazyHelp` mechanism used in [PyPlot](https://github.com/stevengj/PyPlot.jl)).
