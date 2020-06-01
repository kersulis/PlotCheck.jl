module PlotCheck

using Plots

# const _LOGGER = Memento.getlogger(@__MODULE__)

# const _LOGGER = logger = Memento.config!("debug"; fmt="[{level} | {name}]: {msg}")
# __init__() = Memento.register(_LOGGER)

# Memento.config!(Memento.getlogger("PlotCheck"), "info"; fmt="PlotCheck {level}: {msg}")

include("access_features.jl")
include("check_features.jl")
include("compare_plots.jl")
include("generate_reference.jl")
include("logger.jl")

end # module
