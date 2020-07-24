using Plots

x = -2:0.5:2
y = 0:5
z = [i + j for i in 1:length(y), j in 1:length(x)]
heatmap_test = heatmap(
    x, y, z;
    yflip=true,
    title="Heatmap",
    xlabel="xlabel",
    ylabel="ylabel"
)
