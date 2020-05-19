using Plots, PlotCheck, Test

## plot to be tested
p = include("./reference_plot.jl")

@testset "path plot" begin
    subplot = PlotCheck.get_subplots(p)[1]

    @test PlotCheck.has_title(subplot)
    @test PlotCheck.get_title(subplot) == "path plot"
    @test PlotCheck.is_semilogx_plot(subplot)

    l, u = PlotCheck.get_xlim(subplot)
    @test l >= 0 && u >= 3

    l, u = PlotCheck.get_ylim(subplot)
    @test l <= 2 && u >= 3

    # series tests
    series = PlotCheck.get_series_list(subplot)[1]

    @test PlotCheck.get_label(series) == ""
    @test PlotCheck.get_markershape(series) == :none

    @test PlotCheck.has_path(series)
    @test !PlotCheck.has_marker(series)
end

@testset "scatter plot" begin
    subplot = PlotCheck.get_subplots(p)[2]

    @test PlotCheck.has_title(subplot)
    @test PlotCheck.is_linear_plot(subplot)

    @test length(PlotCheck.get_series_list(subplot)) == 4
    s1, s2, s3, s4 = PlotCheck.get_series_list(subplot)
    @test PlotCheck.get_markershape(s1) == :octagon
    @test PlotCheck.get_markersize(s1) == 4

    @test !PlotCheck.has_path(s1) && PlotCheck.has_marker(s1)
    @test !PlotCheck.has_path(s2) && PlotCheck.has_marker(s2)
    @test PlotCheck.has_path(s3) && !PlotCheck.has_marker(s3)
    @test PlotCheck.has_path(s4) && PlotCheck.has_marker(s4)

    @test PlotCheck.get_markersize(s2) == 7
end

@testset "bad colors" begin
    subplot = PlotCheck.get_subplots(p)[3]

    @test PlotCheck.get_title(subplot) == "bad colors"

    @test length(PlotCheck.get_series_list(subplot)) == 3
    s1, s2, s3 = PlotCheck.get_series_list(subplot)

    @test !PlotCheck.path_matches_marker(subplot)
    @test !PlotCheck.line_colors_unique(subplot)
    @test !PlotCheck.marker_colors_unique(subplot)
end

@testset "check_plot" begin
    subplot = PlotCheck.get_subplots(p)[1]
    PlotCheck.check_subplot(subplot)
end

@testset "compare_plots" begin
    PlotCheck.compare_plots(p, "./reference_plot.jl")
end
