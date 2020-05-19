export generate_reference

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
    end
    return reference
end
