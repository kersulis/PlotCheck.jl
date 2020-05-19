get_subplots(plot::Plots.Plot) = plot.subplots

"For a plot with only one subplot, return that subplot."
function get_subplot(plot::Plots.Plot)
    subplots = get_subplots(plot)
    @assert length(subplots) == 1 "Plot has multiple subplots."
    return subplots |> first
end

# retrieve subplot features
get_title(subplot::Plots.Subplot) = subplot.attr[:title]
get_xaxis(subplot::Plots.Subplot) = Plots.get_axis(subplot, :x)
get_yaxis(subplot::Plots.Subplot) = Plots.get_axis(subplot, :y)
get_xlim(subplot::Plots.Subplot) = Plots.axis_limits(subplot, :x)
get_ylim(subplot::Plots.Subplot) = Plots.axis_limits(subplot, :y)
get_xlabel(subplot::Plots.Subplot) = get_xaxis(subplot).plotattributes[:guide]
get_ylabel(subplot::Plots.Subplot) = get_yaxis(subplot).plotattributes[:guide]
get_xscale(subplot::Plots.Subplot) = get_xaxis(subplot)[:scale]
get_yscale(subplot::Plots.Subplot) = get_yaxis(subplot)[:scale]
get_series_list(subplot::Plots.Subplot) = subplot.series_list
get_series_list(plot::Plots.Plot) = plot |> get_subplot |> get_series_list

"For a suplot with only one series, return that series."
function get_series(subplot::Plots.Subplot)
    series = get_series_list(subplot)
    @assert length(series) == 1 "Subplot has multiple series."
    return series |> first
end

"For a plot with only one subplot having only one series, return that series."
get_series(plot::Plots.Plot) = plot |> get_subplot |> get_series

# retrieve series features
get_label(series::Plots.Series) = series.plotattributes[:label]
get_xdata(series::Plots.Series) = series.plotattributes[:x]
get_ydata(series::Plots.Series) = series.plotattributes[:y]
get_zdata(series::Plots.Series) = series.plotattributes[:z]
get_markershape(series::Plots.Series) = series.plotattributes[:markershape]
get_markercolor(series::Plots.Series) = series.plotattributes[:markercolor]
get_markersize(series::Plots.Series) = series.plotattributes[:markersize]
get_linewidth(series::Plots.Series) = series.plotattributes[:linewidth]
get_linecolor(series::Plots.Series) = series.plotattributes[:linecolor]
