using Test

@testset "ImageShow" begin
    include("writemime.jl")

    include("gif.jl")
    include("keyboard.jl")
    include("multipage.jl")
end
