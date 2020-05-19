export compare_plots

"""
    compare_plots(submission, reference)

Compare a submission plot to a reference plot, asserting the following:
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

    # compare number of subplots
    @assert length(sub_subplots) == length(ref_subplots) "Incorrect number of subplots."

    # compare subplots pairwise
    for (idx, (sub_subplot, ref_subplot)) in enumerate(zip(sub_subplots, ref_subplots))
        compare_subplots(sub_subplot, ref_subplot, string(idx))
    end
    return
end

"""
    compare_plots(submission, reference_script_path)

Assuming `include(reference_script_path)` returns the desired reference plot `reference`,
compare `submission` and `reference`.
"""
function compare_plots(submission::Plots.Plot, reference_script_path::String)
    reference = include(reference_script_path)
    compare_plots(submission, reference)
    return
end

function compare_subplots(submission::Plots.Subplot, reference::Plots.Subplot, idx::String="")
    # compare titles and axis labels
    if get_title(submission) != get_title(reference)
        @warn "Subplot $idx title does not match reference."
    end

    if get_xlabel(submission) != get_xlabel(reference)
        @warn "Subplot $idx xlabel does not match reference."
    end

    if get_ylabel(submission) != get_ylabel(reference)
        @warn "Subplot $idx ylabel does not match reference."
    end

    # compare series (by label, if multiple series)
    if reference |> get_series_list |> length == 1 # one series; no need to check label matching
        sub_series, ref_series = get_series(submission), get_series(reference)
        compare_series(sub_series, ref_series; force_label_match=false)
    else
        sub_series_list = get_series_list(submission)
        sub_series_labels = [get_label(series) for series in sub_series_list]
        for ref_series in get_series_list(reference)
            ref_label = ref_series |> get_label
            @assert ref_label in sub_series_labels "Series with label '$(ref_label)' missing."
            sub_series_ind = findfirst(sub_series_labels .== ref_label)
            sub_series = sub_series_list[sub_series_ind]
            compare_series(sub_series, ref_series)
        end
    end
    return
end

function compare_series(submission::Plots.Series, reference::Plots.Series; force_label_match=true)
    sub_label, ref_label = get_label(submission), get_label(reference)
    if sub_label != ref_label
        if force_label_match
            throw(AssertionError("Label for series '$(sub_label)' does not match reference label '$(ref_label)'."))
        else
            @warn "Label for series '$(sub_label)' does not match reference label '$(ref_label)'."
        end
    end

    compare_paths(submission, reference)
    compare_markers(submission, reference)
    compare_data(submission, reference)
end

"Check for presence of visible paths (connecting line segments between points)"
function compare_paths(submission::Plots.Series, reference::Plots.Series)
    sub_label = submission |> get_label
    submission_has_path, reference_has_path = has_path(submission), has_path(reference)

    if submission_has_path & !reference_has_path
        "Series '$(sub_label)' should not have line segments connecting points." |> AssertionError |> throw
    elseif !submission_has_path & reference_has_path
        "Series '$(sub_label)' should have line segments connecting points." |> AssertionError |> throw
    end

    if get_linecolor(submission) != get_linecolor(reference)
        @warn "Line color for series '$(sub_label)' does not match reference."
    end
end

"Check for presence of visible point markers"
function compare_markers(submission::Plots.Series, reference::Plots.Series)
    sub_label = submission |> get_label
    submission_has_marker, reference_has_marker = has_marker(submission), has_marker(reference)

    # check for missing or extraneous markers
    if submission_has_marker && !reference_has_marker
        "Series '$(sub_label)' should not have markers indicating individual points." |> AssertionError |> throw
    elseif !submission_has_marker && reference_has_marker
        "Series '$(sub_label)' should have markers indicating individual points." |> AssertionError |> throw

    # if both have markers, see if colors and shapes align
    elseif submission_has_marker && reference_has_marker
        sub_markershape, ref_markershape = get_markershape(submission), get_markershape(reference)
        if sub_markershape != ref_markershape
            @warn "Marker shape for series '$(sub_label)' does not match reference shape :$(ref_markershape)."
        end

        sub_markercolor, ref_markercolor = get_markercolor(submission), get_markercolor(reference)
        if sub_markercolor != ref_markercolor
            @warn "Marker color for series '$(sub_label)' does not match reference color."
        end
    end
end

"Check whether submission series data matches reference series data up to an elementwise percent difference."
function compare_data(submission::Plots.Series, reference::Plots.Series, pct_diff_tol::Number=5.0)
    pct_diff(sub, ref) = 100 * abs((sub - ref) / ref)
    sub_label = get_label(submission)

    xsub, xref = get_xdata(submission), get_xdata(reference)

    # if number of points does not match, we're done
    if length(xsub) != length(xref)
        @warn "Series '$(sub_label)' does not have the same number of points as reference."
        return
    end

    # if x-axis values do not line up, no point in checking y-axis values
    if maximum(pct_diff.(xsub, xref)) > pct_diff_tol
        @warn "x-axis values for series '$(sub_label)' do not match reference."
        return
    end

    # if x-axis values do line up, y-axis values should line up also
    ysub, yref = get_ydata(submission), get_ydata(reference)
    if maximum(pct_diff.(ysub, yref)) > pct_diff_tol
        @warn "y-axis values for series '$(sub_label)' do not match reference."
    end
    return
end
