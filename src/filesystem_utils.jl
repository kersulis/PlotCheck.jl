"Equivalent to `readdir(path; join=true)` in Julia 1.4+."
readdir_join(path::String) = [joinpath(path, x) for x in readdir(path)]


"Return only valid folders (not files)."
function folders_only(paths::Vector{String})
    return filter(path -> isdir(path), paths)
end


"Remove all folders and files whose basenames begin with `.`."
function no_dots(paths::Vector{String})
    return filter(path -> basename(path)[1] != '.', paths)
end


"Return all subdirectory paths in `dir` that do not start with `.`"
function crawl_dir(dir::String, subdir_paths::Vector{String}=String[])
    subdirs = readdir_join(dir) |> folders_only |> no_dots
    for subdir in subdirs
        push!(subdir_paths, subdir)
        crawl_dir(subdir, subdir_paths)
    end
    return subdir_paths
end


"""
    path = folder_search(dir, folder)

Recursively search through `dir` for a folder called `folder`.
    All files are skipped, along with any folders beginning with `.`
"""
function folder_search(dir::String, folder::String)
    (basename(dir) == folder) && return dir

    subdirs = readdir_join(dir) |> folders_only |> no_dots
    for subdir in subdirs
        path = folder_search(subdir, folder)
        !isnothing(path) && return path
    end
end


"Return `true` if `folder` contains `file`."
folder_has_file(folder::String, file::String) = file in readdir(folder)


"""
Return a vector of paths to all instances of `filename` found in
    any subdirectory of `dir`.
"""
function file_search(dir, filename)
    folders = crawl_dir(dir)
    folders_with_file = filter(f -> folder_has_file(f, filename), folders)
    return [joinpath(f, filename) for f in folders_with_file]
end
