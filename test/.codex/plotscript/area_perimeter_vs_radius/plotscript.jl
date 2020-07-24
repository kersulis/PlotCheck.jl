using Plots, FileIO

d = load(joinpath(@__DIR__, "data.jld"))
radius, area, perimeter = d["radius"], d["area"], d["perimeter"]

reference = plot(
    title="Circle area and perimeter vs radius",
    xlabel="Radius",
    ylabel="Area/Perimeter",
    legend=:topleft
)

plot!(
    radius, area;
    color=:red,
    marker=:circle,
    label="Area"
)

plot!(
    radius, perimeter;
    color=:blue,
    marker=:square,
    label="Perimeter"
)

reference
