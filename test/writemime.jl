using ImageShow, ImageCore, FileIO, OffsetArrays
using ImageCore: PaddedViews
import ImageBase: restrict
import AxisArrays: AxisArray

using Test

const workdir = joinpath(tempdir(), "Images")
if !isdir(workdir)
    mkdir(workdir)
end

@testset "show (MIME)" begin
    # Test that we remembered to turn off Colors.jl's colorswatch display
    @test !showable(MIME("image/svg+xml"), rand(Gray{N0f8}, 5, 5))
    @test !showable(MIME("image/svg+xml"), rand(RGB{N0f8},  5, 5))
    @test showable(MIME("image/png"), rand(Gray{N0f8}, 5, 5))
    @test showable(MIME("image/png"), rand(RGB{N0f8},  5, 5))
    @testset "no compression or expansion" begin
        A = N0f8[0.01 0.99; 0.25 0.75]
        fn = joinpath(workdir, "writemime.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), Gray.(A), minpixels=0, maxpixels=typemax(Int))
        end
        b = load(fn)
        @test b == A

        img = fill(RGB{N0f16}(1,0,0), 1, 1)
        open(fn, "w") do file
            show(IOContext(file, :full_fidelity=>true), MIME("image/png"), img, minpixels=0, maxpixels=typemax(Int))
        end
        b = load(fn)
        @test b == img

        A = N0f8[0.01 0.99; 0.25 0.75]
        fn = joinpath(workdir, "writemime.png")
        open(fn, "w") do file
            show(IOContext(file, :full_fidelity=>true), MIME("image/png"), Gray.(A), minpixels=5, maxpixels=typemax(Int))
        end
        @test load(fn) == A

        A = N0f8[0.01 0.4 0.99; 0.25 0.8 0.75; 0.6 0.2 0.0]
        fn = joinpath(workdir, "writemime.png")
        open(fn, "w") do file
            show(IOContext(file, :full_fidelity=>true), MIME("image/png"), Gray.(A), minpixels=0, maxpixels=5)
        end
        @test load(fn) == A

        # a genuinely big image (tests the defaults)
        abig = colorview(Gray, normedview(rand(UInt8, 1024, 1023)))
        fn = joinpath(workdir, "big.png")
        open(fn, "w") do file
            show(IOContext(file, :full_fidelity=>true), MIME("image/png"), abig, maxpixels=10^6)
        end
        b = load(fn)
        @test b == abig
    end
    @testset "colorspace normalization" begin
        img = fill(HSV{Float64}(0.5, 0.5, 0.5), 1, 1)
        fn = joinpath(workdir, "writemime.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), img, minpixels=0, maxpixels=typemax(Int))
        end
        b = load(fn)
        @test b == convert(Array{RGB{N0f8}}, img)
        img = fill(RGB{N0f16}(1,0,0), 1, 1)
        open(fn, "w") do file
            show(file, MIME("image/png"), img, minpixels=0, maxpixels=typemax(Int))
        end
        b = load(fn)
        @test eltype(b) <: AbstractRGB && eltype(eltype(b)) == N0f8 && b[1] == RGB(1,0,0)
        img = fill(RGBA{Float32}(1,0,0,0.5), 1, 1)
        open(fn, "w") do file
            show(file, MIME("image/png"), img, minpixels=0, maxpixels=typemax(Int))
        end
        b = load(fn)
        @test isa(b, Matrix{RGBA{N0f8}}) && b[1] == RGBA{N0f8}(1,0,0,0.5)
        img = Gray.([0.1 0.2; -0.5 0.8])
        open(fn, "w") do file
            show(file, MIME("image/png"), img, minpixels=0, maxpixels=typemax(Int))
        end
        b = load(fn)
        @test isa(b, Matrix{Gray{N0f8}}) && b == Gray{N0f8}[0.1 0.2; 0 0.8]
    end
    @testset "small images (expansion)" begin
        A = N0f8[0.01 0.99; 0.25 0.75]
        fn = joinpath(workdir, "writemime.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), Gray.(A), minpixels=5, maxpixels=typemax(Int))
        end
        @test load(fn) == A[[1,1,2,2],[1,1,2,2]]
    end
end

@testset "Big images and matrices" begin
    @testset "big images (use of restrict)" begin
        A = N0f8[0.01 0.4 0.99; 0.25 0.8 0.75; 0.6 0.2 0.0]
        Ar = restrict(A)
        fn = joinpath(workdir, "writemime.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), Gray.(A), minpixels=0, maxpixels=5)
        end
        @test load(fn) == N0f8.(Ar)
        # a genuinely big image (tests the defaults)
        abig = colorview(Gray, normedview(rand(UInt8, 1024, 1023)))
        fn = joinpath(workdir, "big.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), abig, maxpixels=10^6)
        end
        b = load(fn)
        btmp = restrict(abig, (1,2))
        @test b == N0f8.(btmp)
    end
    @testset "display matrix of images" begin
        img() = colorview(Gray, rand([0.250 0.5; 0.75 1.0], rand(2:10), rand(2:10)))
        io = IOBuffer()
        # test that these methods don't fail
        show(io, MIME"text/html"(), [img() for i=1:2])
        show(io, MIME"text/html"(), [img() for i=1:2, j=1:2])
        show(io, MIME"text/html"(), [img() for i=1:2, j=1:2, k=1:2])
    end
    @testset "display matrix of 1-D images" begin
        flat_imgs = [zeros(Gray{Float32}, 1)]
        io = IOBuffer()
        # These methods should not invoke the ImageShow.jl display code, but they
        # used to throw errors: https://github.com/JuliaImages/Images.jl/issues/623
        @test !applicable(ImageShow._show_odd, io, MIME"text/html"(), flat_imgs)
        @test !applicable(ImageShow._show_even, io, MIME"text/html"(), flat_imgs)
    end
    @testset "Non-1 indexing" begin
        A = N0f8[0.01 0.99; 0.25 0.75]
        Aoff = OffsetArray(A, 0:1, 2:3)
        fn = joinpath(workdir, "oas.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), Gray.(Aoff), minpixels=5, maxpixels=typemax(Int))
        end
        @test load(fn) == A[[1,1,2,2],[1,1,2,2]]
        # Also test a type that doesn't have a specialization so as to trigger the generic
        # fallback
        A = PaddedView(0, reshape([1], 1, 1), (0:1, 1:2))
        Ac = collect(A)
        open(fn, "w") do file
            show(file, MIME("image/png"), Gray.(A), minpixels=5, maxpixels=typemax(Int))
        end
        @test load(fn) == Ac[[1,1,2,2],[1,1,2,2]]
    end
    @testset "Array types that may not recognized by IO backends" begin
        A = N0f8[0.01 0.99; 0.25 0.75]
        A_axis = AxisArray(A)
        fn = joinpath(workdir, "axis.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), Gray.(A_axis), minpixels=5, maxpixels=typemax(Int))
        end
        @test load(fn) == A[[1,1,2,2],[1,1,2,2]]
    end
    @testset "HTML display" begin
        sshow(mime, x) = (io = IOBuffer(); show(io, mime, x); String(take!(io)))
        @test startswith(
            sshow(MIME("text/html"), zeros(Gray{Float32}, 1, 1)),
            if VERSION >= v"1.3" # ImageIO
                "<img src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAAAAAB"
            else # ImageMagick
                "<img src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkAQAAAAB"
            end)
        @test startswith(
            sshow(MIME("text/html"), zeros(RGB{Float32}, 1, 1)),
            if VERSION >= v"1.3" # ImageIO
                "<img src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD"
            else # ImageMagick
                "<img src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkAQAAAABY"
            end)
    end
end
try
    # if this fails, it is not our fault
    rm(workdir, recursive=true)
catch
    # do nothing
end


nothing
