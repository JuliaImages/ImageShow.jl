struct AnimatedGIF{A<:AbstractArray}
    data::A
    fps::Float64

    function AnimatedGIF(data::A; fps=10) where A<:AbstractArray
        new{A}(data, fps)
    end
end

Base.showable(::MIME"image/gif", agif::AnimatedGIF) = true
function Base.show(io::IO, ::MIME"image/gif", agif::AnimatedGIF)
    FileIO.save(_format_stream(format"GIF", io), agif.data; fps=agif.fps)
end

"""
    @gif img [fps=10]

If displayable, display 3D image `img` as animated gif.

# Examples:

```julia
julia> using ImageShow, TestImages

julia> ImageShow.@gif testimage("mri-stack")
```

!!! note
    `ImageMagick` backend is required to generate gif. You can install it via
    `pkg> add ImageMagick`.
"""
macro gif(img, kws...)
    if !displayable(MIME"image/gif"())
        return esc(img)
    end

    expr = :(AnimatedGIF($(esc(img))))
    for kw in kws
        (kw isa Expr && kw.head == :(=)) || error("invalid signature for @gif")
        k, v = kw.args
        push!(expr.args, Expr(:kw, k, esc(v)))
    end
    return expr
end
