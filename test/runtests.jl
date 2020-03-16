using Test, ReferenceTests
using ImageShow, ImageCore, FileIO, OffsetArrays, PaddedViews

@testset "ImageShow" begin
    include("writemime.jl")
    include("mosaicviews.jl")
end
