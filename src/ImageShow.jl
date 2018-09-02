module ImageShow

using Requires
using FileIO
using ImageCore, Colors, FixedPointNumbers

const _have_restrict=Ref(false)
function _use_restrict(val::Bool)
    _have_restrict[] = val
end
function __init__()
    @require ImageTransformations="02fcd773-0e25-5acc-982a-7f6622650795" _use_restrict(true)
end
include("showmime.jl")

# facilitate testing from importers
testdir() = joinpath(@__DIR__,"..","test")

end
