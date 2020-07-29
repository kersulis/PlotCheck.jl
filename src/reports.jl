"""
    string_values = collect_string_values(d[, string_values])

Recursively search through dictionary `d` for values which are strings.
    Values which are `Dict`s are searched, and their string values are
    appended as well.
"""
function collect_string_values(d::Dict, string_values::Vector{String}=String[]; skip_keys::Vector=[])
    for v in [(!(k in skip_keys) ? v : nothing) for (k, v) in d]
        if v isa String
            push!(string_values, v)
        elseif v isa Dict
            collect_string_values(v, string_values)
        end
    end
    return string_values
end


function print_reports(reports::Vector{Dict{Symbol, Any}}, reference_available::Bool=false)
    title = "PlotCheck Report\n---\n"

    issues_found = length(reports) > 0

    if reference_available
        if issues_found
            postscript = "Checked against reference plot. Issues found."
        else
            postscript = "Checked against reference plot."
        end
    else
        if issues_found
            postscript = "Basic checks performed. Issues found."
        else
            postscript = "Basic checks performed."
        end
    end

    subplot_reports = (format_report(r, reference_available) for r in reports)

    formatted_report = title * join(subplot_reports) |> Markdown.parse
    display(formatted_report)
    println(postscript)
    return
end


function format_report(report::Dict{Symbol, Any}, reference_available::Bool=false)
    subplot_name = report[:subplot_name]
    report_title = "**$(subplot_name)**\n\n"
    series_strings = Vector{String}()

    if reference_available
        for (series_name, series_report) in report[:series]
            if series_report |> ismissing # series is missing altogether
                series_string = "$(series_name): Missing!\n\n"
            else
                series_messages = collect_string_values(series_report)

                if isempty(series_messages)
                    series_string = "Series '$(series_name)': Checked.\n\n"
                else
                    series_string = "Series '$(series_name)': Found the following issues.\n"

                    # markdown list format
                    series_messages = ["- $(s)\n" for s in series_messages]

                    series_string *= join(series_messages)
                end
            end
            push!(series_strings, series_string)
        end
        return "---\n" * report_title * join(series_strings) * "---\n"
    else
        messages = collect_string_values(report; skip_keys=[:subplot_name])
        if isempty(messages)
            subplot_string = "Checked.\n\n"
        else
            subplot_string = ["- $(s)\n" for s in messages] |> join
        end
        return "---\n" * report_title * subplot_string * "---\n\n"
    end
end
