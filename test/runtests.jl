using Test

@testset "ImageShow" begin
    include("writemime.jl")

    # `gif` requires ImageMagick v1.2.0, which requires Julia 1.3
    if VERSION >= v"1.3.0"
        include("gif.jl")
    end

    @info "There are some keyboard IO tests. To make sure test passes as expected, please don't press any key until test finishes."
    include("keyboard.jl")
    include("multipage.jl")
end
