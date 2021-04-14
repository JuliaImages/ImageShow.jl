using TestImages, ImageCore, ImageShow
using Test
using FileIO
using ImageQualityIndexes

@testset "GIF" begin
    # TODO: the `fps` keyword is not tested

    # ImageMagick saves GIF as RGB array
    img = RGB.(testimage("mri-stack"))
    ref_gif = ImageShow.gif(img)

    @test !showable(MIME("image/gif"), img)
    @test showable(MIME("image/gif"), ref_gif)

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

        toucan = testimage("toucan") # 150×162 RGBA image
        moon = testimage("moon") # 256×256 Gray image
        framestack = [toucan, moon]
        fn = joinpath(workdir, "writemime.gif")
        open(fn, "w") do file
            show(file, MIME("image/gif"), ImageShow.gif(framestack))
        end
        @test assess_psnr(RGB.(load(fn)), RGB.(ImageShow.gif(framestack))) >= 40

        sizes = 16:4:64
        values = range(0, stop=1, length=length(sizes))
        gif = ImageShow.gif(values, sizes) do v, x
            fill(RGB(v, v, v), ntuple(_->x, 2)...)
        end
        fn = joinpath(workdir, "writemime.gif")
        open(fn, "w") do file
            show(file, MIME("image/gif"), gif)
        end
        @test assess_psnr(RGB.(load(fn)), gif) >= 60
    end

    # This might be a non-error in future
    toucan = testimage("toucan") # 150×162 RGBA image
    moon = testimage("moon") # 256×256 Gray image
    @test_throws ArgumentError ImageShow.gif(toucan, moon)
end
