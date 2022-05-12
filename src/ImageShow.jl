module ImageShow

import Base64
using FileIO
using ImageCore, OffsetArrays
import ImageBase: restrict

using StackViews
using ImageCore.MappedArrays
using ImageCore.PaddedViews

# opt-in HTML render for image
# work around https://github.com/JuliaImages/ImageShow.jl/pull/50#issuecomment-1124132500
const _ENABLE_HTML = Ref(false)
enable_html_render() = _ENABLE_HTML[] = true
disable_html_render() = _ENABLE_HTML[] = false
Base.showable(::MIME"text/html", ::AbstractMatrix{<:Colorant}) = _ENABLE_HTML[]

include("showmime.jl")
include("gif.jl")
include("multipage.jl")
include("compat.jl")

# facilitate testing from importers
testdir() = joinpath(@__DIR__,"..","test")

end
