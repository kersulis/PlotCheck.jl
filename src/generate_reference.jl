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
     background_color_inside=:lightgray
     )

    if !isempty(img_path)
        savefig(reference, img_path)
        info(_LOGGER, "$(img_path) generated from $(script_path).")
    end
    return reference
end

"""
    generate_references(plot_folder[, img_ext])

Assume plot_folder has a subdirectory for each plot
    we wish to create a reference for. Each such subdirectory is presumed
    to contain a single `.jl` file, which returns the desired reference
    plot upon `include()`. The reference plot is saved with the indicated
    extension, and named after the subdirectory.
"""
function generate_references(plot_folder::String, img_ext::String=".png")
    folders = filter(x -> x[1] != '.', readdir(plot_folder))
    for folder in folders
        println(joinpath(plot_folder, folder))
        files = readdir(joinpath(plot_folder, folder))

        script_name = filter(x -> split(x, ".") |> last == "jl", files) |> first
        script_path = joinpath(plot_folder, folder, script_name)

        img_name = basename(folder)
        img_path = joinpath(plot_folder, folder, img_name) * img_ext

        generate_reference(script_path, img_path)
    end
end
