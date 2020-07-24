using Plots

x = [1, 2, 3]
y = [1, 2, 3]
z = [1, 2, 3]

reference = scatter(x, y, z)

plot!(reverse(x), y, z)

reference
