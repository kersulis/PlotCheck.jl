using Plots, PlotCheck, Test

@testset "path plot" begin
    p = include("./plot/multiple_subplots/plotscript.jl")
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
    p = include("./plot/multiple_subplots/plotscript.jl")
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
    p = include("./plot/multiple_subplots/plotscript.jl")
    subplot = PlotCheck.get_subplots(p)[3]

    @test PlotCheck.get_title(subplot) == "bad colors"

    @test length(PlotCheck.get_series_list(subplot)) == 3
    s1, s2, s3 = PlotCheck.get_series_list(subplot)

    @test !PlotCheck.path_matches_marker(subplot)
    @test !PlotCheck.line_colors_unique(subplot)
    @test !PlotCheck.marker_colors_unique(subplot)
end

@testset "check_plot" begin
    # plot check works if axes are labeled and there is a title
    p = plot([1, 2, 3], [4, 3, 2]; xlabel="xlabel", ylabel="ylabel", title="title", color=:blue)
    @check_plot p

    # fails if no xlabel or ylabel
    plot!(p; xlabel="")
    @check_plot p
    plot!(p; xlabel="xlabel", ylabel="")
    @check_plot p

    # gives warning if no title
    plot!(p, ylabel="ylabel", title="")
    @check_plot p
    plot!(p; title="title")
    @check_plot p

    # line colors must be unique
    p = plot([1, 2, 3], [4, 3, 2]; xlabel="xlabel", ylabel="ylabel", title="title", color=:blue)
    plot!([1, 2, 3], [3, 2, 1]; color=:blue)
    @check_plot p

    # marker colors must be unique
    p = scatter([1, 2, 3], [4, 3, 2]; xlabel="xlabel", ylabel="ylabel", title="title", color=:blue)
    scatter!([1, 2, 3], [3, 2, 1]; color=:blue)
    @check_plot p

    # series line and marker colors should match
    p = plot([1, 2, 3], [4, 3, 2]; xlabel="xlabel", ylabel="ylabel", title="title", color=:blue, markershape=:o, markercolor=:red)
    @check_plot p
end

@testset "compare_plots single series" begin
    reference = plot([1, 2, 3], [3, 2, 1]; xlabel="xlabel", ylabel="ylabel", title="title", color=:blue, label="Series 1")

    # subplot titles should match
    submission = plot([1, 2, 3], [3, 2, 1]; xlabel="xlabel", ylabel="ylabel", title="wrong", color=:blue, label="Series 1")

    # @test_logs (:warn, "Subplot 1 title does not match expected title 'title'.")
    compare_plots(submission, reference)

    # subplot axis labels should match
    submission = plot([1, 2, 3], [3, 2, 1]; xlabel="wrong", ylabel="ylabel", title="title", color=:blue, label="Series 1")

    # @test_logs (:warn, "Subplot 1 xlabel does not match reference.")
    compare_plots(submission, reference)

    submission = plot([1, 2, 3], [3, 2, 1]; xlabel="xlabel", ylabel="wrong", title="title", color=:blue, label="Series 1")

    # @test_logs (:warn, "Subplot 1 ylabel does not match reference.")
    compare_plots(submission, reference)

    # labels need not match if there is only one series, but there will be a warning
    submission = plot([1, 2, 3], [3, 2, 1]; xlabel="xlabel", ylabel="ylabel", title="title", label="wrong", color=:blue)

    # @test_logs (:warn, "Label for series 'wrong' does not match reference label 'Series 1'.")
    compare_plots(submission, reference)
end

@testset "compare_plots multiple series" begin
    submission = include("./plot/multiple_subplots/plotscript.jl")
    @test_nowarn compare_plots(submission, "./plot/multiple_subplots/plotscript.jl")

    # reference with two series
    reference = plot([1, 2, 3], [3, 2, 1]; xlabel="xlabel", ylabel="ylabel", title="title", color=:blue, label="Series 1")
    plot!([1, 2, 3], [4, 3, 2], color=:red, label="Series 2", marker=:o)

    # Series with label 'Series 2' missing.
    submission = plot([1, 2, 3], [3, 2, 1]; xlabel="xlabel", ylabel="ylabel", title="title", color=:blue, label="Series 1")
    # @test_throws AssertionError
    compare_plots(submission, reference)

    # Series 'Series 2' should have markers indicating individual points.
    submission = plot([1, 2, 3], [3, 2, 1]; xlabel="xlabel", ylabel="ylabel", title="title", color=:blue, label="Series 1")
    plot!([1, 2, 3], [4, 3, 2], color=:red, label="Series 2")
    # @test_throws AssertionError
    compare_plots(submission, reference)

    # Series 'Series 1' should have line segments connecting points.
    submission = scatter([1, 2, 3], [3, 2, 1]; xlabel="xlabel", ylabel="ylabel", title="title", color=:blue, label="Series 1")
    scatter!([1, 2, 3], [4, 3, 2], color=:red, label="Series 2")
    # @test_throws AssertionError
    compare_plots(submission, reference)

    # Series 'Series 2' should have markers indicating individual points.
    submission = plot([1, 2, 3], [3, 2, 1]; xlabel="xlabel", ylabel="ylabel", title="title", color=:blue, label="Series 1")
    plot!([1, 2, 3], [4, 3, 2], color=:red, label="Series 2")

    # @test_throws AssertionError
    compare_plots(submission, reference)

    # warning, not error, if only the marker shape differs
    submission = plot([1, 2, 3], [3, 2, 1]; xlabel="xlabel", ylabel="ylabel", title="title", color=:blue, label="Series 1")
    plot!([1, 2, 3], [4, 3, 2], color=:red, label="Series 2", marker=:+)
    # @test_logs (:warn, "Marker shape for series 'Series 2' does not match reference shape :octagon.")
    compare_plots(submission, reference)

    submission = plot([1, 2, 3], [3, 2, 1]; xlabel="xlabel", ylabel="ylabel", title="title", color=:green, label="Series 1")
    plot!([1, 2, 3], [4, 3, 2], color=:red, label="Series 2", marker=:o)

    compare_plots(submission, reference)
end

@testset "@check_plot" begin
    area_perimeter_vs_radius = generate_reference(joinpath("./plot", "area_perimeter_vs_radius", "plotscript.jl"))
    @check_plot area_perimeter_vs_radius @__DIR__

    "/home/jk/.julia/dev/PlotCheck/test/plot"

    heatmap_test = generate_reference(joinpath("./plot", "heatmap_test", "plotscript.jl"))
    @check_plot heatmap_test "/home/jk/.julia/dev/PlotCheck/test/plot"

    three_dimension_test = generate_reference(joinpath("./plot", "three_dimension_test", "plotscript.jl"))
    @check_plot three_dimension_test "/home/jk/.julia/dev/PlotCheck/test/plot"
end
