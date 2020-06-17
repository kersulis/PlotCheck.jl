"""
    string_values = collect_string_values(d[, string_values])

Recursively search through dictionary `d` for values which are strings.
    Values which are `Dict`s are searched, and their string values are
    appended as well.
"""
function collect_string_values(d::Dict, string_values::Vector{String}=String[])
    for v in values(d)
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
    if reference_available
        postscript = "*(Checked against reference plot.)*\n"
    else
        postscript = "*(No reference; basic checks only.)*\n"
    end

    subplot_reports = (format_report(r, reference_available) for r in reports)

    formatted_report = title * join(subplot_reports) * postscript |> Markdown.parse
    display(formatted_report)
    return formatted_report
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
                    series_string = "$(series_name): Checked.\n\n"
                else
                    series_string = "$(series_name): Issues found.\n\n"

                    # markdown list format
                    series_messages = ["- $(s)\n" for s in series_messages]

                    series_string *= join(series_messages)
                end
            end
            push!(series_strings, series_string)
        end
        return "---\n" * report_title * join(series_strings) * "---\n"
    else
        messages = collect_string_values(report)
        return "---\n" * report_title * join(messages) * "---\n"
    end
end
