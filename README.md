# PlotCheck.jl

*Checking user-generated plots for basic plotting conventions, and comparing user plots to reference plots*

## Usage
This package checks user-generated plots, informing a user if they made a mistake. to perform basic checks on a plot, do the following:

```julia
using Plots, PlotCheck

my_plot = plot(rand(5); color=:blue)
plot!(my_plot, rand(5); color=:blue)
@check_plot my_plot
```

You should see the following output:
```julia
[info | PlotCheck]: No reference plot found; basic checks only.
[warn | PlotCheck]: Subplot is missing a title.
[warn | PlotCheck]: The horizontal axis is missing a label.
[warn | PlotCheck]: The vertical axis is missing a label.
[warn | PlotCheck]: Line colors should be unique.
```
The first line indicates that `@check_plot` could not find a reference plot to compare the submitted plot against. The next few lines list important plot features that are missing from the submitted plot. Finally, the last line warns us that two series have been plotted with the same series color, which is generally a bad idea.

If a reference plot is available, `@check_plot` is more thorough. See "Comparative checks for plots with a reference" below for details. To see how to add your own reference plots for PlotCheck to check submissions against, see "How to add reference plots".

## Basic checks for plots with no reference
In many cases, we want to let the user (typically a student) generate plots however they like. The only thing we want PlotCheck to do in these cases is look for the following:
- Each subplot has a title.
- Each subplot axis has an xlabel and a ylabel.
- The colors used for each plotted series are unique.

## Comparative checks for plots with a reference
PlotCheck becomes more powerful when a reference plot is available. In these cases, we would like for the user/student to generate one specific plot. While they are free to change things like color and size, their submitted plot needs to line up closely with our reference in the following ways:
- The number of subplots must match, and subplots must be in the same order.
- For each subplot:
  - The title, xlabel, and ylabel strings must match those of our reference plot.
  - The series plotted must be labeled exactly the same as those of our reference plot.
  - For each series:
    - The visual markers should match our reference (e.g. line segments, markers, or both).
    - The data should also match our reference (within some tolerance).

## How to add reference plots
There is no reliable way to save a plot object in Julia. Trying to save a `Plots.Plot` object to a JLD file actually causes a StackOverflowError!

Instead, we can save a script which generates the reference plot. The `@check_plot` macro will search for this script as follows:
1. Suppose we have the following directory structure:
```
codex.ipynb
.codex/
  plotcheck/
    first_plot/
      plotscript.jl
      data.jld2
    second_plot/
      plotscript.jl
      data.jld2
```
`codex.ipynb` is the codex that the student is working on. In the same folder as that Jupyter notebook, there is a folder called `.codex/plotcheck` containing a subdirectory for each reference plot. Each subdirectory has a `plotscript.jl` file which, when `include`d, generates the reference plot. To reduce the number of folders and files required to represent the two plots, we can store all relevant plot features as follows:
```julia
using PlotCheck
plotscript2disk(".codex/plotcheck/first_plot/plotscript.jl", ".codex/plotcheck/first_plot.jld2")
plotscript2disk(".codex/plotcheck/second_plot/plotscript.jl", ".codex/plotcheck/second_plot.jld2")
```
Now there are two new files in the plotcheck directory:
```
codex.ipynb
.codex/
  plotcheck/
    first_plot.jld2
    second_plot.jld2
    first_plot/
      plotscript.jl
      data.jld2
    second_plot/
      plotscript.jl
      data.jld2
```
Now we can check a plot against the reference plots represented by the `jld2` files as follows:
```julia
using Plots, PlotCheck

first_plot = plot(...)
second_plot = plot(...)

@check_plot first_plot
@check_plot second_plot
```
The line `@check_plot first_plot` checks the folder `.codex/plotcheck` for a file called `first_plot.jld2`. It will then compare features of the plot `first_plot` to data extracted from that file.
2. To help the student make their plot, we can show them a PNG render of it, but with a dark background so they cannot turn it into their instructor as their own work. To save a reference plot with darkened background as a PNG file, do the following:
```julia
generate_reference(".codex/plotcheck/first_plot/plotscript.jl", ".codex/plotimg/first_plot.png")
```
This will create a `first_plot.png` image file in `.codex/plotimg`.
