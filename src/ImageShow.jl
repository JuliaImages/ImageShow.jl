module ImageShow

using Requires
using FileIO
using ImageCore

const _have_restrict=Ref(false)
function _use_restrict(val::Bool)
    _have_restrict[] = val
end
function __init__()
    @require OffsetArrays="6fe1bfb0-de20-5000-8ca7-80f57d26f881" begin
        Base.show(io::IO, mime::MIME"image/png", img::OffsetArrays.OffsetArray{C}; kwargs...) where C<:Colorant =
            show(io, mime, parent(img); kwargs...)
    end
    @require ImageTransformations="02fcd773-0e25-5acc-982a-7f6622650795" _use_restrict(true)
end
include("showmime.jl")

# facilitate testing from importers
testdir() = joinpath(@__DIR__,"..","test")

end
