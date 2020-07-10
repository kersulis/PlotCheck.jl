get_subplots(plot::PlotData) = plot.subplots

"For a plot with only one subplot, return that subplot."
function get_subplot(plot::PlotData)
    subplots = get_subplots(plot)
    if length(subplots) > 1
         @error "Plot has multiple subplots."
     end
    return subplots |> first
end

# retrieve subplot features from a Subplot
get_title(subplot::Subplot) = subplot.attr[:title]
get_xaxis(subplot::Subplot) = Plots.get_axis(subplot, :x)
get_yaxis(subplot::Subplot) = Plots.get_axis(subplot, :y)
get_xlim(subplot::Subplot) = Plots.axis_limits(subplot, :x)
get_ylim(subplot::Subplot) = Plots.axis_limits(subplot, :y)
get_xlabel(subplot::Subplot) = get_xaxis(subplot).plotattributes[:guide]
get_ylabel(subplot::Subplot) = get_yaxis(subplot).plotattributes[:guide]
get_xscale(subplot::Subplot) = get_xaxis(subplot)[:scale]
get_yscale(subplot::Subplot) = get_yaxis(subplot)[:scale]
get_series_list(subplot::Subplot) = subplot.series_list
get_series_list(plot::Plot) = plot |> get_subplot |> get_series_list

# retrieve subplot features from a SubplotDict
get_title(subplot::SubplotDict) = subplot.kwargs[:title]
get_xaxis(subplot::SubplotDict) = subplot.kwargs[:xaxis]
get_yaxis(subplot::SubplotDict) = subplot.kwargs[:yaxis]
get_xlim(subplot::SubplotDict) = subplot.kwargs[:xlim]
get_ylim(subplot::SubplotDict) = subplot.kwargs[:ylim]
get_xlabel(subplot::SubplotDict) = subplot.kwargs[:xlabel]
get_ylabel(subplot::SubplotDict) = subplot.kwargs[:ylabel]
get_xscale(subplot::SubplotDict) = subplot.kwargs[:xscale]
get_yscale(subplot::SubplotDict) = subplot.kwargs[:yscale]
get_series_list(subplot::SubplotDict) = subplot.series_list

"For a suplot with only one series, return that series."
function get_series(subplot::SubplotData)
    series = get_series_list(subplot)
    if length(series) > 1
        @error "Subplot has multiple series."
    end
    return series |> first
end

"For a plot with only one subplot having only one series, return that series."
get_series(plot::PlotData) = plot |> get_subplot |> get_series

# retrieve series features from a Series
get_label(series::Series) = series.plotattributes[:label]
get_xdata(series::Series) = series.plotattributes[:x]
get_ydata(series::Series) = series.plotattributes[:y]
get_zdata(series::Series) = series.plotattributes[:z]
get_markershape(series::Series) = series.plotattributes[:markershape]
get_markercolor(series::Series) = series.plotattributes[:markercolor]
get_markersize(series::Series) = series.plotattributes[:markersize]
get_linewidth(series::Series) = series.plotattributes[:linewidth]
get_linecolor(series::Series) = series.plotattributes[:linecolor]
get_seriestype(series::Series) = series.plotattributes[:seriestype]

# retrieve series features from a SeriesDict
get_label(series::SeriesDict) = series.kwargs[:label]
get_xdata(series::SeriesDict) = series.kwargs[:x]
get_ydata(series::SeriesDict) = series.kwargs[:y]
get_zdata(series::SeriesDict) = series.kwargs[:z]
get_markershape(series::SeriesDict) = series.kwargs[:markershape]
get_markercolor(series::SeriesDict) = series.kwargs[:markercolor]
get_markersize(series::SeriesDict) = series.kwargs[:markersize]
get_linewidth(series::SeriesDict) = series.kwargs[:linewidth]
get_linecolor(series::SeriesDict) = series.kwargs[:linecolor]
get_seriestype(series::SeriesDict) = series.kwargs[:seriestype]
