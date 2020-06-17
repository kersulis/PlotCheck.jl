module PlotCheck

using Plots, Markdown

include("access_features.jl")
include("basic_checks.jl")

include("filesystem_utils.jl")
include("generate_reference.jl")
include("comparative_checks.jl")
include("reports.jl")

end # module
