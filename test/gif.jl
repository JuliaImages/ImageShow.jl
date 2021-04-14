using TestImages, ImageCore, ImageShow
using Test, Suppressor
using FileIO
using ImageDistances

@testset "GIF" begin
    toucan = testimage("toucan") # 150×162 RGBA image
    moon = testimage("moon") # 256×256 Gray image

    # This might be a non-error in future
    @test_throws ArgumentError ImageShow.gif(toucan, moon)
    warning_msg = Suppressor.@capture_err ImageShow.gif([toucan, moon]; fps=0.5)
    @test occursin("FPS should be larger than 1", warning_msg)

    @testset "show" begin
        # TODO: the `fps` keyword is unable to test

        img = RGB.(testimage("mri-stack")) # ImageMagick saves GIF as RGB/ARGB array
        ref_gif = ImageShow.gif(img)

        @test !showable(MIME("image/gif"), img)
        @test showable(MIME("image/gif"), ref_gif)

        workdir = "tmp"
        mktempdir() do workdir
            fn = joinpath(workdir, "writemime.gif")
            open(fn, "w") do file
                show(file, MIME("image/gif"), ImageShow.gif(img))
            end
            @test load(fn) == ref_gif

            framestack = [img[:, :, i] for i in axes(img, 3)]
            fn = joinpath(workdir, "writemime.gif")
            open(fn, "w") do file
                show(file, MIME("image/gif"), ImageShow.gif(framestack))
            end
            @test load(fn) == ref_gif

            framestack = [toucan, moon]
            fn = joinpath(workdir, "writemime.gif")
            open(fn, "w") do file
                show(file, MIME("image/gif"), ImageShow.gif(framestack))
            end
            @test euclidean(RGB.(load(fn)), RGB.(ImageShow.gif(framestack))) <= 5.5

            sizes = 16:4:64
            values = range(0, stop=1, length=length(sizes))
            gif = ImageShow.gif(values, sizes) do v, x
                fill(v, ntuple(_->x, 2)...)
            end
            fn = joinpath(workdir, "writemime.gif")
            open(fn, "w") do file
                show(file, MIME("image/gif"), gif)
            end
            @test euclidean(RGB.(load(fn)), RGB.(gif)) <= 0.5
        end
    end

    @testset "gif as a readonly array" begin
        A = fill(1.0, 4, 8)
        B = fill(2.0, 2, 2)
        gif = ImageShow.gif([A, B])
        @test axes(gif) == (1:4, 1:8, 1:2)
        @test size(gif) == (4, 8, 2)
        cv = channelview(gif)
        @test all(cv[:, :, 1] .== 1.0) && all(cv[2:3, 4:5, 2] .== 2.0)
    end
end
