export check_plot_basics

# subplot-level checks
"Return `true` if subplot has a title."
has_title(subplot::Plots.Subplot) = get_title(subplot) != ""

"Return `true` if subplot has linear-linear scale."
is_linear_plot(subplot::Plots.Subplot) = (get_xscale(subplot) == :identity) && (get_yscale(subplot) == :identity)

"Return `true` if subplot has a log10 x-scale and linear y-scale."
is_semilogx_plot(subplot::Plots.Subplot) = (get_xscale(subplot) == :log10) && (get_yscale(subplot) == :identity)

"Return `true` if subplot has a linear x-scale and log10 y-scale"
is_semilogy_plot(subplot::Plots.Subplot) = (get_xscale(subplot) == :identity) && (get_yscale(subplot) == :log10)

"Return `true` if subplot has log-log scale."
is_loglog_plot(subplot::Plots.Subplot) = (get_xscale(subplot) == :log10) && (get_yscale(subplot) == :log10)

"Return `true` if subplot has an x-axis label."
has_xlabel(subplot::Plots.Subplot) = get_xlabel(subplot) != ""

"Return `true` if subplot has a y-axis label."
has_ylabel(subplot::Plots.Subplot) = get_ylabel(subplot) != ""

# series-level checks
"Return `true` if series is labeled."
has_label(series::Plots.Series) = get_label(series) != ""

"Return `true` if series has visible line segments between points."
function has_path(series::Plots.Series)
    return get_linewidth(series) > 0 && get_linecolor(series) != :white
end

"Return `true` if series has visible point markers."
function has_marker(series::Plots.Series)
    return all((
        get_markershape(series) != :none,
        get_markersize(series) > 0,
        get_markercolor(series) != :white
    ))
end

# retrieving sets of series from a subplot
"Return all subplot series with visible line segments connecting their points."
series_path(subplot::Plots.Subplot) = filter(s -> has_path(s), get_series_list(subplot))

"Return all subplot series with visible point markers."
series_marker(subplot::Plots.Subplot) = filter(s -> has_marker(s), get_series_list(subplot))

"Return all subplot series with both visible line segments and point markers."
series_path_marker(subplot::Plots.Subplot) = intersect(series_path(subplot), series_marker(subplot))

"Return all labeled series."
series_labeled(subplot::Plots.Subplot) = filter(s -> has_label(s), get_series_list(subplot))

"Return `true` if all subplot series are labeled."
all_series_labeled(subplot::Plots.Subplot) = all((has_label(s) for s in get_series_list(subplot)))

# testing sets of series
"Return `true` if all elements of collection `x` are unique"
all_unique(x) = length(unique(x)) == length(x)

"Return `true` if line and marker colors match for all series that have both"
function path_matches_marker(subplot::Plots.Subplot)
    return all((get_markercolor(s) == get_linecolor(s) for s in series_path_marker(subplot)))
end

"Return `true` if all line colors in a subplot are unique."
function line_colors_unique(subplot::Plots.Subplot)
    return all_unique((get_linecolor(s) for s in series_path(subplot)))
end

"Return `true` if all marker colors in a subplot are unique."
function marker_colors_unique(subplot::Plots.Subplot)
    return all_unique((get_markercolor(s) for s in series_marker(subplot)))
end

function check_axis_labels(subplot::Plots.Subplot)
    if !has_xlabel(subplot)
        warn(_LOGGER, "The horizontal axis is missing a label.")
    end
    if !has_ylabel(subplot)
        warn(_LOGGER, "The vertical axis is missing a label.")
    end
    return
end

function check_subplot_title(subplot::Plots.Subplot)
    if !has_title(subplot)
        warn(_LOGGER, "Subplot is missing a title.")
    end
    return
end

"""
Display warning messages in the following cases:
- subplot re-uses a marker color for multiple series
- subplot re-uses a line color for multiple series
- at least one series has both visible lines and markers, but their colors *do not* match
"""
function check_color_uniqueness(subplot::Plots.Subplot)
    if !path_matches_marker(subplot)
        warn(_LOGGER, "Series marker and line colors should match.")
    end
    if !line_colors_unique(subplot)
        warn(_LOGGER, "Line colors should be unique.")
    end
    if !marker_colors_unique(subplot)
        warn(_LOGGER, "Marker colors should be unique.")
    end
    return
end

"""
    check_subplot(plot)

Check the following:
- Subplot has a title
- Subplot has xlabel and ylabel
- Series colors are unique
"""
function check_subplot(subplot::Plots.Subplot)
    check_subplot_title(subplot)
    check_axis_labels(subplot)
    check_color_uniqueness(subplot)
    return
end

"""
    check_plot_basics(plot)

Check the following for each subplot in `plot`:
- Subplot has a title
- Subplot has xlabel and ylabel
- Series colors are unique
"""
function check_plot_basics(plot::Plots.Plot)
    for subplot in get_subplots(plot)
        check_subplot(subplot)
    end
    return
end
