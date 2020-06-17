export generate_reference, generate_references


"""
    reference = generate_reference(reference_script_path[, img_path])

Assuming `include(reference_script_path)` returns the desired
    reference plot `reference`, change the plot's appearance
    to distinguish it from submissions (so one cannot simply
    turn in the reference plot as one's own).

If optional `img_path` (with appropriate extension) is provided,
    save an image of the reference plot at that location.
"""
function generate_reference(script_path::String, img_path::String="")
    reference = include(script_path)
    plot!(
    reference;
     background_color_outside=:lightgray,
     background_color_inside=:lightgray,
     margin=(10.0 * Plots.mm)
     )

    if !isempty(img_path)
        savefig(reference, img_path)
        @info "$(img_path) generated from $(script_path)."
    end
    return reference
end


"""
    generate_references(dir[, script_name, img_ext])

Search through `dir` for all subdirectories that contain a file
    called `script_name`. For each of these subdirectories, the script
    file is run (via `include) to generate a reference plot. The
    reference plot is then saved as an image file with the indicated
    extension, and stored in the same subdirectory as the script.
"""
function generate_references(
    dir::String,
    script_name::String="plotscript.jl",
    img_ext::String=".png"
    )
    script_paths = file_search(dir, script_name)
    for script_path in script_paths
        img_folder = dirname(script_path)
        img_name = img_folder |> basename
        img_path = joinpath(img_folder, img_name) * img_ext

        generate_reference(script_path, img_path)
    end
end
