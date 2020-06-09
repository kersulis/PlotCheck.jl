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
plot/
    first_plot
      script.jl
      data.jld
      second_plot
    script.jl
      data.jld
      second_plot.png
```
  `codex.ipynb` is the codex that the student is working on. In the same folder as that Jupyter notebook, there is a folder called `plot` containing a subdirectory for each reference plot. Each subdirectory must have a `script.jl` file which, when `include`d, generates the reference plot. The script file can pull data from `data.jld` for plotting (`data.jld` can have any name, or be a .csv file, etc.). The only rule is that `include(script.jl)` must return the desired reference plot.
2. Now suppose the student runs a codex cell with the line `@check_plot first_plot`. The macro will look through `plot` for a subdirectory called `first_plot`. Within that directory, it will look for a `script.jl` file. It will use this file to generate a reference plot, then compare the student's submitted plot to that reference.
3. To help the student make their plot, we can show them a PNG render of it, but with a dark background so they cannot turn it into their instructor as their own work. To save a reference plot with darkened background as a PNG file, do the following:
  ```julia
  generate_reference("./plot/first_plot/script.jl", "./plot/first_plot/first_plot.png")
  ```
  This will create a `first_plot.png` image in the same directory as the corresponding `script.jl` file. In the directory structure shown above, note that the `second_plot` subdirectory already has such a PNG file.

  You can also generate reference images for all reference plots as follows:
  ```julia
  generate_references("./plot")
  ```
