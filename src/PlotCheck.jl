module PlotCheck

using Plots, Markdown

using Plots: Plot, Subplot, Series


struct SeriesDict
    kwargs::Dict
end


struct SubplotDict
    kwargs::Dict
    series_list::Vector{SeriesDict}
end


struct PlotDict
    subplots::Vector{SubplotDict}
end

SeriesData = Union{Plots.Series, SeriesDict}

SubplotData = Union{Plots.Subplot, SubplotDict}

PlotData = Union{Plots.Plot, PlotDict}

include("filesystem_utils.jl")
include("io.jl")

include("access_features.jl")
include("basic_checks.jl")

include("comparative_checks.jl")
include("reports.jl")

end # module
