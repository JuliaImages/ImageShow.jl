struct AnimatedGIF{A<:AbstractArray}
    data::A
end

Base.showable(::MIME"image/gif", agif::AnimatedGIF) = true
function Base.show(io::IO, ::MIME"image/gif", agif::AnimatedGIF)
    FileIO.save(FileIO.Stream(format"GIF", io), agif.data)
end

"""
    @gif img

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
macro gif(img)
    if displayable(MIME"image/gif"())
        :(AnimatedGIF($(esc(img))))
    else
        esc(img)
    end
end
