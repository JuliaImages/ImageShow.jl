@testset "Compat: MosaicViews" begin
    # only test image cases

    @testset "2D inputs" begin
        A1 = fill(Gray(1.), 2, 2)
        A2 = fill(RGB(1., 0., 0.), 3, 3)
        A3 = fill(RGB(0., 1., 0.), 3, 3)
        out = mosaicview(A1, A2, A3) |> collect
        @test_reference "references/mosaicviews/2d_opaque_1.png" out by=isequal
        out = mosaicview(A1, A2, A3; npad=2, fillvalue=Gray(0.), nrow=2) |> collect
        @test_reference "references/mosaicviews/2d_opaque_2.png" out by=isequal
        out = mosaicview(A1, A2, A3; npad=2, fillvalue=Gray(0.), nrow=2, rowmajor=true) |> collect
        @test_reference "references/mosaicviews/2d_opaque_3.png" out by=isequal

        A1 = fill(GrayA(1.), 2, 2)
        A2 = fill(RGBA(1., 0., 0.), 3, 3)
        A3 = fill(RGBA(0., 1., 0.), 3, 3)
        out = mosaicview(A1, A2, A3) |> collect
        @test_reference "references/mosaicviews/2d_transparent_1.png" out by=isequal
        out = mosaicview(A1, A2, A3; npad=2, fillvalue=GrayA(0., 0.), nrow=2) |> collect
        @test_reference "references/mosaicviews/2d_transparent_2.png" out by=isequal
        out = mosaicview(A1, A2, A3; npad=2, fillvalue=GrayA(0., 0.), nrow=2, rowmajor=true) |> collect
        @test_reference "references/mosaicviews/2d_transparent_3.png" out by=isequal
    end

    @testset "3D inputs" begin
        A = fill(RGB(0., 0., 0.), 2, 2, 3)
        A[:, :, 1] .= RGB(1., 0., 0.)
        A[:, :, 2] .= RGB(0., 1., 0.)
        A[:, :, 3] .= RGB(0., 0., 1.)
        out = mosaicview(A) |> collect
        @test_reference "references/mosaicviews/3d_opaque_1.png" out by=isequal
        out = mosaicview(A; npad=2, fillvalue=Gray(0.), nrow=2) |> collect
        @test_reference "references/mosaicviews/3d_opaque_2.png" out by=isequal
        out = mosaicview(A; npad=2, fillvalue=Gray(0.), nrow=2, rowmajor=true) |> collect
        @test_reference "references/mosaicviews/3d_opaque_3.png" out by=isequal
        out = mosaicview(A, A; npad=2, fillvalue=Gray(0.), nrow=2) |> collect
        @test_reference "references/mosaicviews/3d_opaque_4.png" out by=isequal

        A = fill(RGBA(0., 0., 0.), 2, 2, 3)
        A[:, :, 1] .= RGBA(1., 0., 0.)
        A[:, :, 2] .= RGBA(0., 1., 0.)
        A[:, :, 3] .= RGBA(0., 0., 1.)
        out = mosaicview(A) |> collect
        @test_reference "references/mosaicviews/3d_transparent_1.png" out by=isequal
        out = mosaicview(A; npad=2, fillvalue=GrayA(0., 0.), nrow=2) |> collect
        @test_reference "references/mosaicviews/3d_transparent_2.png" out by=isequal
        out = mosaicview(A; npad=2, fillvalue=GrayA(0.), nrow=2, rowmajor=true) |> collect
        @test_reference "references/mosaicviews/3d_transparent_3.png" out by=isequal
        out = mosaicview(A, A; npad=2, fillvalue=GrayA(0.), nrow=2) |> collect
        @test_reference "references/mosaicviews/3d_transparent_4.png" out by=isequal
    end

    @testset "4D inputs" begin
        A = fill(RGB(0., 0., 0.), 2, 2, 2, 2)
        A[1, :, 1, 1] .= RGB(1., 0., 0.)
        A[:, :, 1, 2] .= RGB(0., 1., 0.)
        A[:, :, 2, 1] .= RGB(0., 0., 1.)
        out = mosaicview(A) |> collect
        @test_reference "references/mosaicviews/4d_opaque_1.png" out by=isequal
        out = mosaicview(A; npad=2, fillvalue=Gray(0.), nrow=2) |> collect
        @test_reference "references/mosaicviews/4d_opaque_2.png" out by=isequal
        out = mosaicview(A; npad=2, fillvalue=Gray(0.), nrow=2, rowmajor=true) |> collect
        @test_reference "references/mosaicviews/4d_opaque_3.png" out by=isequal
        out = mosaicview(A, A; npad=2, fillvalue=Gray(0.), nrow=2) |> collect
        @test_reference "references/mosaicviews/4d_opaque_4.png" out by=isequal

        A = fill(RGBA(0., 0., 0.), 2, 2, 2, 2)
        A[1, :, 1, 1] .= RGBA(1., 0., 0.)
        A[:, :, 1, 2] .= RGBA(0., 1., 0.)
        A[:, :, 2, 1] .= RGBA(0., 0., 1.)
        out = mosaicview(A) |> collect
        @test_reference "references/mosaicviews/4d_transparent_1.png" out by=isequal
        out = mosaicview(A; npad=2, fillvalue=GrayA(0., 0.), nrow=2) |> collect
        @test_reference "references/mosaicviews/4d_transparent_2.png" out by=isequal
        out = mosaicview(A; npad=2, fillvalue=GrayA(0., 0.), nrow=2, rowmajor=true) |> collect
        @test_reference "references/mosaicviews/4d_transparent_3.png" out by=isequal
        out = mosaicview(A, A; npad=2, fillvalue=GrayA(0.), nrow=2) |> collect
        @test_reference "references/mosaicviews/4d_transparent_4.png" out by=isequal
    end
end
