module PlotCheck

using Plots, Memento

# for some reason, any use of Memento.config! causes a segfault
# (on Windows and Linux)
# const _LOGGER = Memento.config!("info"; fmt="{name} {level}: {msg}")

const _LOGGER = Memento.getlogger(@__MODULE__)
__init__() = Memento.register(_LOGGER)

include("access_features.jl")
include("check_features.jl")

include("filesystem_utils.jl")
include("generate_reference.jl")
include("compare_plots.jl")

end # module
