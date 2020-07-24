using FileIO

export plotscripts2img, plotscripts2disk


"""
    reference = plotscript2img(script_path[, img_path])

Assuming `include(script_path)` returns the desired
    reference plot, change the plot's appearance
    to distinguish it from submissions (so one cannot simply
    turn in the reference plot as one's own).

If optional `img_path` (with appropriate extension) is provided,
    save an image of the reference plot at that location.
"""
function plotscript2img(script_path::String, img_path::String="")
    reference = include(script_path)
    plot!(
        reference;
         background_color_outside=:lightgray,
         background_color_inside=:lightgray,
         margin=(10.0 * Plots.mm)
     )

    if !isempty(img_path)
        savefig(reference, img_path)
        @info "$(img_path) generated from $(script_path)."
    end
    return reference
end


function plot2img(plot::Plots.Plot, img_path::String)
    plot!(
    plot;
    background_color_outside=:lightgray,
    background_color_inside=:lightgray,
    margin=(10.0 * Plots.mm)
    )

    savefig(plot, img_path)
    @info "$(img_path) saved."
    return
end


"""
    plotscript2img(dir[, script_name, img_ext])

Search through `dir` for all subdirectories that contain a file
    called `script_name`. For each of these subdirectories, the script file is run (via `include) to generate a reference plot.
    The reference plot is then saved as an image file with the indicated
    extension, and stored in the specified image directory.
"""
function plotscripts2img(
    script_dir::String,
    img_dir::String,
    script_name::String="plotscript.jl",
    img_ext::String="png"
    )
    !isdir(img_dir) && mkdir(img_dir)
    script_paths = file_search(script_dir, script_name)
    for script_path in script_paths
        img_name = dirname(script_path) |> basename
        img_path = joinpath(img_dir, img_name) * "." * img_ext
        plotscript2img(script_path, img_path)
    end
end


function series2dict(series::Plots.Series)
    return SeriesDict(
        Dict(
            :label => get_label(series),
            :x => get_xdata(series),
            :y => get_ydata(series),
            :z => get_zdata(series),
            :markershape => get_markershape(series),
            :markercolor => get_markercolor(series),
            :markersize => get_markersize(series),
            :linewidth => get_linewidth(series),
            :linecolor => get_linecolor(series),
            :seriestype => get_seriestype(series)
        )
    )
end


function subplot2dict(subplot::Plots.Subplot)
    series_list = PlotCheck.get_series_list(subplot)
    series_dict = [series2dict(series) for series in series_list]

    return SubplotDict(
        Dict(
            :title => get_title(subplot),
            :xlim => get_xlim(subplot),
            :ylim => get_ylim(subplot),
            :xlabel => get_xlabel(subplot),
            :ylabel => get_ylabel(subplot),
            :xscale => get_xscale(subplot),
            :yscale => get_yscale(subplot)
        ),
        series_dict
    )
end


function plot2dict(plot::Plots.Plot)
    subplot_list = PlotCheck.get_subplots(plot)
    subplot_dict = [subplot2dict(subplot) for subplot in subplot_list]

    return PlotDict(subplot_dict)
end


function plot2disk(plot::Plots.Plot, path::String)
    save(path, "PlotDict", plot2dict(plot))
end

disk2plotdata(path::String) = load(path)["PlotDict"]


function plotscript2disk(script_path::String, disk_path::String)
    p = include(script_path)
    plot2disk(p, disk_path)
end


function plotscripts2disk(
    script_dir::String,
    disk_dir::String,
    script_name::String="plotscript.jl",
    disk_ext::String="jld2"
    )
    !isdir(disk_dir) && mkdir(disk_dir)
    script_paths = file_search(script_dir, script_name)
    for script_path in script_paths
        disk_name = dirname(script_path) |> basename
        disk_path = joinpath(disk_dir, disk_name) * "." * disk_ext
        plotscript2disk(script_path, disk_path)
    end
end
