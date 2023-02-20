module ImageShow

import Base64
using FileIO
using ImageCore, OffsetArrays
import ImageBase: restrict

using StackViews
using ImageCore.MappedArrays
using ImageCore.PaddedViews
using ColorSchemes

include("showmime.jl")
include("gif.jl")
include("multipage.jl")
include("compat.jl")
include("simshow.jl")

# facilitate testing from importers
testdir() = joinpath(@__DIR__,"..","test")

end
