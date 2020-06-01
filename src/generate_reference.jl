export generate_reference, generate_references

"""
    reference = generate_reference(reference_script_path[, png_path])

Assuming `include(reference_script_path)` returns the desired reference plot `reference`,
change the plot's appearance to distinguish it from submissions (so one cannot simply
turn in the reference plot as one's own).

If optional `png_path` is provided, save a PNG image of the reference plot.
"""
function generate_reference(reference_script_path::String, png_path::String="")
    reference = include(reference_script_path)
    plot!(reference, background_color_outside=:lightgray)

    if !isempty(png_path)
        savefig(reference, png_path)
        info(_LOGGER, "$(png_path) created based on reference figure script at $(reference_script_path).")
    end
    return reference
end

function generate_references(reference_script_folder::String, png_folder::String)
    for filename in readdir(reference_script_folder)
        filepath = joinpath(reference_script_folder, filename)
        figure_name = split(filename, ".") |> first
        pngpath = joinpath(png_folder, figure_name) * ".png"
        generate_reference(filepath, pngpath)
    end
end
