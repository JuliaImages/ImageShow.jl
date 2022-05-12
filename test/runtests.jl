using Test
using ImageShow
ImageShow.enable_html_render()

@testset "ImageShow" begin
    include("writemime.jl")

    include("gif.jl")
    include("keyboard.jl")
    include("multipage.jl")
end
