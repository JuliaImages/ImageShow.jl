module ImageShow

import Base64
using FileIO
using ImageCore, OffsetArrays
import ImageBase: restrict

using StackViews
using ImageCore.MappedArrays
using ImageCore.PaddedViews

include("showmime.jl")
include("gif.jl")
include("multipage.jl")
include("compat.jl")

# facilitate testing from importers
testdir() = joinpath(@__DIR__,"..","test")

end
