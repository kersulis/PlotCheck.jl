p1 = plot([1, 2, 3], [2, 3, 1]; xlabel="x_plot", ylabel="y_plot", title="path plot", xscale=:log10, label="")

p2 = scatter(
    [1 2; 2 3; 3 4], [2 1; 3 2; 4 3];
    xlabel="x_scatter",
    title="scatter plot",
    marker=[:o :+],
    markersize=[4 7],
    aspect_ratio=1.0,
    label=["series 1" "series 2"],
    ylim=(0, 6)
)
plot!([1, 2, 3], [5, 4, 3]; label="series 3")
plot!([1, 2, 3], [3, 5, 4]; marker=:circle, label="series 4")

p3 = plot(
    [1, 2, 3], [3, 2, 1];
    linecolor=:blue,
    markercolor=:red,
    markershape=:circle,
    title="bad colors"
)
plot!([1, 3], [1, 2]; linecolor=:blue, markershape=:o, markercolor=:blue)
scatter!([1, 3], [2, 3]; markercolor=:blue)

p = plot(p1, p2, p3; size=(800, 300), layout=(1, 3))
