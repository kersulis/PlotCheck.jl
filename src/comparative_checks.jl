export compare_plots, @check_plot


"""
    compare_plots(submission, reference)

Compare a submission plot to a reference plot, checking the following:
- Each plot has the same number of subplots (assumed to be in the same order).
- Each subplot

Additionally, generate warnings if any of the following are true:
- Subplot titles, xlabels, or ylabels do not match.
- Series line colors, marker colors, or marker shapes do not match.
- There is a mismatch in number of series values, or
- if number of values matches, there is a mismatch in x-axis values, or
- if x-axis values match, there is a mismatch in y-axis values.
"""
function compare_plots(submission::Plots.Plot, reference::Plots.Plot)
    sub_subplots = submission |> get_subplots
    ref_subplots = reference |> get_subplots
    n_sub, n_ref = length(sub_subplots), length(ref_subplots)

    # compare number of subplots
    if n_sub != n_ref
        return "Expected $(n_ref) subplots but found $(n_sub)."
    end

    # compare subplots pairwise
    reports = Vector{Dict{Symbol, Any}}()
    for (idx, (sub_subplot, ref_subplot)) in enumerate(zip(sub_subplots, ref_subplots))
        subplot_name = "Subplot $(idx)"
        report = compare_subplots(sub_subplot, ref_subplot)
        report[:subplot_name] = subplot_name
        push!(reports, report)
    end

    return print_reports(reports, true)
end


"""
    compare_plots(submission, reference_script_path)

Assuming `include(reference_script_path)` returns the desired reference plot `reference`,
compare `submission` and `reference`.
"""
function compare_plots(submission::Plots.Plot, reference_script_path::String)
    reference = include(reference_script_path)

    return compare_plots(submission, reference)
end


function compare_subplots(submission::Plots.Subplot, reference::Plots.Subplot)
    report = Dict{Symbol, Any}()

    # compare titles and axis labels
    sub_title, ref_title = get_title(submission), get_title(reference)
    if sub_title != ref_title
        report[:title] = "'$(sub_title)' does not match expected title '$(ref_title)'."
    end

    sub_xlabel, ref_xlabel = get_xlabel(submission), get_xlabel(reference)
    if sub_xlabel != ref_xlabel
        report[:xlabel] = "'$(sub_xlabel)' does not match expected xlabel '$(ref_xlabel)'."
    end

    sub_ylabel, ref_ylabel = get_ylabel(submission), get_ylabel(reference)
    if sub_ylabel != ref_ylabel
        report[:ylabel] = "'$(sub_ylabel)' does not match expected ylabel '$(ref_ylabel)'."
    end

    # compare series (by label, if multiple series)
    report[:series] = Dict{String, Any}()

    if reference |> get_series_list |> length == 1 # one series; no need to check label matching
        sub_series, ref_series = get_series(submission), get_series(reference)
        series_label = ref_series |> get_label
        report[:series][series_label] = compare_series(sub_series, ref_series)
    else
        sub_series_list = get_series_list(submission)
        sub_series_labels = [get_label(series) for series in sub_series_list]
        for ref_series in get_series_list(reference)
            ref_label = ref_series |> get_label

            if !(ref_label in sub_series_labels)
                report[:series][ref_label] = missing
                continue
            end

            sub_series_ind = findfirst(sub_series_labels .== ref_label)
            sub_series = sub_series_list[sub_series_ind]
            report[:series][ref_label] = compare_series(sub_series, ref_series)
        end
    end

    return report
end


function compare_series(submission::Plots.Series, reference::Plots.Series)
    report = Dict{Symbol, Any}()

    sub_label, ref_label = get_label(submission), get_label(reference)
    if sub_label != ref_label
        report[:label] = "'$(sub_label)' does not match expected label '$(ref_label)'."
    end

    report[:paths] = compare_paths(submission, reference)
    report[:markers] = compare_markers(submission, reference)
    report[:data] = compare_data(submission, reference)

    return report
end


"Check for presence of visible paths (connecting line segments between points)"
function compare_paths(submission::Plots.Series, reference::Plots.Series)
    report = Dict{Symbol, String}()

    sub_label = submission |> get_label
    submission_has_path, reference_has_path = has_path(submission), has_path(reference)

    if submission_has_path & !reference_has_path
        report[:path] = "Series should not have line segments connecting points."
    elseif !submission_has_path & reference_has_path
        report[:path] =  "Series should have line segments connecting points."
    end

    color_sub, color_ref = get_linecolor(submission), get_linecolor(reference)

    # do not compare all 256 colors of a gradient
    # (handles the heatmap case)
    (typeof(color_ref) <: PlotUtils.ColorGradient) && return report

    if color_sub != color_ref
        report[:color] = "Line color does not match reference."
    end

    return report
end


"Check for presence of visible point markers"
function compare_markers(submission::Plots.Series, reference::Plots.Series)
    report = Dict{Symbol, String}()

    sub_label = submission |> get_label
    submission_has_marker, reference_has_marker = has_marker(submission), has_marker(reference)

    # check for missing or extraneous markers
    if submission_has_marker && !reference_has_marker
        report[:marker] = "Series should not have markers indicating individual points."
    elseif !submission_has_marker && reference_has_marker
        report[:marker] = "Series should have markers indicating individual points."

    # if both have markers, see if colors and shapes align
    elseif submission_has_marker && reference_has_marker
        sub_markershape, ref_markershape = get_markershape(submission), get_markershape(reference)
        if sub_markershape != ref_markershape
            report[:markershape] = "Marker shape does not match expected shape :$(ref_markershape)."
        end

        sub_markercolor, ref_markercolor = get_markercolor(submission), get_markercolor(reference)
        if sub_markercolor != ref_markercolor
            report[:markercolor] = "Marker color does not match reference color."
        end
    end

    return report
end


"Check whether submission series data matches reference series data up to elementwise percent difference."
function compare_data(submission::Plots.Series, reference::Plots.Series, pct_diff_tol::Number=5.0)
    report = Dict{Symbol, String}()

    pct_diff(sub, ref) = 100 * abs((sub - ref) / ref)
    sub_label = get_label(submission)

    xsub, xref = get_xdata(submission), get_xdata(reference)

    # if number of points does not match, we're done
    if length(xsub) != length(xref)
        report[:xdata] = "Series should have $(length(xref)) data points."
        return report

    # if x-axis values do not line up, no point in checking y-axis values
    elseif maximum(pct_diff.(xsub, xref)) > pct_diff_tol
        report[:xdata] = "x-axis values do not match reference."
        return report
    end

    # if x-axis values do line up, y-axis values should line up also
    ysub, yref = get_ydata(submission), get_ydata(reference)
    if maximum(pct_diff.(ysub, yref)) > pct_diff_tol
        report[:ydata] = "y-axis values do not match reference."
    end

    # if there is z data, check that also
    if !isnothing(get_zdata(reference))
        zsub, zref = get_zdata(submission), get_zdata(reference)
        if get_seriestype(reference) == :heatmap
            if maximum(pct_diff.(zsub.surf, zref.surf)) > pct_diff_tol
                report[:zdata] = "Heatmap z-data does not match reference."
            end
        elseif maximum(pct_diff.(zsub, zref)) > pct_diff_tol
            report[:zdata] = "z-axis values do not match reference."
        end
    end

    return report
end


"""
Recursively search `dir` for a subdirectory with the same name as
    `plot`
"""
macro check_plot(plot, dir="./plot")
    plot_name = string(:($(plot)))

    if !isdir(:($(dir)))
        return :(check_plot_basics($(esc(plot))))
    end

    script_folder = folder_search(:($(dir)), plot_name)

    if isnothing(script_folder)
        return :(check_plot_basics($(esc(plot))))
    end

    jl_files = filter(f -> f[(end - 2):end] == ".jl", readdir(script_folder))

    if length(jl_files) == 0
        @error "Plot script missing in $(script_folder)."
    elseif length(jl_files) > 1
        @error "Multiple .jl files found in $(script_folder)."
    end

    script_path = joinpath(script_folder, jl_files |> first)
    return :(compare_plots($(esc(plot)), $(script_path)))
end
