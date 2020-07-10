export check_plot_basics


# subplot-level checks
"Return `true` if subplot has a title."
has_title(subplot::SubplotData) = get_title(subplot) != ""

"Return `true` if subplot has linear-linear scale."
is_linear_plot(subplot::SubplotData) = (get_xscale(subplot) == :identity) && (get_yscale(subplot) == :identity)

"Return `true` if subplot has a log10 x-scale and linear y-scale."
is_semilogx_plot(subplot::SubplotData) = (get_xscale(subplot) == :log10) && (get_yscale(subplot) == :identity)

"Return `true` if subplot has a linear x-scale and log10 y-scale"
is_semilogy_plot(subplot::SubplotData) = (get_xscale(subplot) == :identity) && (get_yscale(subplot) == :log10)

"Return `true` if subplot has log-log scale."
is_loglog_plot(subplot::SubplotData) = (get_xscale(subplot) == :log10) && (get_yscale(subplot) == :log10)

"Return `true` if subplot has an x-axis label."
has_xlabel(subplot::SubplotData) = get_xlabel(subplot) != ""

"Return `true` if subplot has a y-axis label."
has_ylabel(subplot::SubplotData) = get_ylabel(subplot) != ""

# series-level checks
"Return `true` if series is labeled."
has_label(series::SeriesData) = get_label(series) != ""


"Return `true` if series has visible line segments between points."
function has_path(series::SeriesData)
    return get_linewidth(series) > 0 && get_linecolor(series) != :white
end


"Return `true` if series has visible point markers."
function has_marker(series::SeriesData)
    return all((
        get_markershape(series) != :none,
        get_markersize(series) > 0,
        get_markercolor(series) != :white
    ))
end


# retrieving sets of series from a subplot
"Return all subplot series with visible line segments connecting their points."
series_path(subplot::SubplotData) = filter(s -> has_path(s), get_series_list(subplot))

"Return all subplot series with visible point markers."
series_marker(subplot::SubplotData) = filter(s -> has_marker(s), get_series_list(subplot))

"Return all subplot series with both visible line segments and point markers."
series_path_marker(subplot::SubplotData) = intersect(series_path(subplot), series_marker(subplot))

"Return all labeled series."
series_labeled(subplot::SubplotData) = filter(s -> has_label(s), get_series_list(subplot))

"Return `true` if all subplot series are labeled."
all_series_labeled(subplot::SubplotData) = all((has_label(s) for s in get_series_list(subplot)))

# testing sets of series
"Return `true` if all elements of collection `x` are unique"
all_unique(x) = length(unique(x)) == length(x)


"Return `true` if line and marker colors match for all series that have both"
function path_matches_marker(subplot::SubplotData)
    return all((get_markercolor(s) == get_linecolor(s) for s in series_path_marker(subplot)))
end


"Return `true` if all line colors in a subplot are unique."
function line_colors_unique(subplot::SubplotData)
    return all_unique((get_linecolor(s) for s in series_path(subplot)))
end


"Return `true` if all marker colors in a subplot are unique."
function marker_colors_unique(subplot::SubplotData)
    return all_unique((get_markercolor(s) for s in series_marker(subplot)))
end


function check_subplot_title(subplot::SubplotData)
    report = Dict{Symbol, String}()
    !has_title(subplot) && (report[:subplot_title] = "Subplot is missing a title.")

    return report
end


function check_axis_labels(subplot::SubplotData)
    report = Dict{Symbol, String}()
    !has_xlabel(subplot) && (report[:xlabel] = "The horizontal axis is missing a label.")
    !has_ylabel(subplot) && (report[:ylabel] = "The vertical axis is missing a label.")

    return report
end


"""
Display warning messages in the following cases:
- subplot re-uses a marker color for multiple series
- subplot re-uses a line color for multiple series
- at least one series has both visible lines and markers, but their colors *do not* match
"""
function check_color_uniqueness(subplot::SubplotData)
    report = Dict{Symbol, String}()
    !path_matches_marker(subplot) && (report[:path_matches_marker] = "Series marker and line colors should match.")
    !line_colors_unique(subplot) && (report[:line_colors_unique] = "Line colors should be unique.")
    !marker_colors_unique(subplot) && (report[:marker_colors_unique] = "Marker colors should be unique.")

    return report
end


"""
    check_subplot(plot)

Check the following:
- Subplot has a title
- Subplot has xlabel and ylabel
- Series colors are unique
"""
function check_subplot(subplot::SubplotData)
    report = Dict{Symbol, Any}()

    report[:title] = check_subplot_title(subplot)
    report[:axis_labels] = check_axis_labels(subplot)
    report[:color_uniqueness] = check_color_uniqueness(subplot)

    return report
end


"""
    check_plot_basics(plot)

Check the following for each subplot in `plot`:
- Subplot has a title
- Subplot has xlabel and ylabel
- Series colors are unique
"""
function check_plot_basics(plot::PlotData)
    reports = Vector{Dict{Symbol, Any}}()
    for (idx, subplot) in plot |> get_subplots |> enumerate
        subplot_name = "Subplot $(idx)"
        report = check_subplot(subplot)
        report[:subplot_name] = subplot_name
        push!(reports, report)
    end

    return print_reports(reports, false)
end
