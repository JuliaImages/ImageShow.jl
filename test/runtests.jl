using Test

@testset "ImageShow" begin
    include("writemime.jl")

    # `gif` requires ImageMagick v1.2.0, which requires Julia 1.3
    if VERSION >= v"1.3.0"
        include("gif.jl")
    end
end
