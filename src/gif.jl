struct AnimatedGIF{T, A<:AbstractArray} <: AbstractArray{T, 3}
    data::A
    fps::Int

    # NOTE: the default fps is chosen purely by experience and may be changed in the future
    function AnimatedGIF{T, A}(data::A; fps::Real=min(10, size(data, 3)÷2)) where {T, A<:AbstractArray}
        if fps < 1
            fps = 1
            @warn "FPS should be larger than 1" FPS=fps
        end

        new{T, A}(data, ceil(Int, fps))
    end
end
AnimatedGIF(data::AbstractArray; kwargs...) = AnimatedGIF{eltype(data), typeof(data)}(data; kwargs...)

# Display gif requires ImageMagick v1.2.0, which requires Julia 1.3
Base.showable(::MIME"image/gif", agif::AnimatedGIF) = VERSION >= v"1.3.0"
function Base.show(io::IO, ::MIME"image/gif", agif::AnimatedGIF)
    FileIO.save(_format_stream(format"GIF", io), agif.data; fps=agif.fps)
end

Base.size(A::AnimatedGIF) = size(A.data)
Base.axes(A::AnimatedGIF) = axes(A.data)
Base.@propagate_inbounds Base.getindex(A::AnimatedGIF, inds::Vararg{Int}) = getindex(A.data, inds...)

"""
    gif(img; kwargs...)
    gif(frames; kwargs...)

Convert 3D `img` or 2D frame list `frames` to animated gif array.

!!! compat "ImageMagick 1.2"
    `ImageMagick` at least v1.2.0 (which requires Julia at least v1.3.0) is required to generate
    gif image. You can install it via `pkg> add ImageMagick`.

# Arguments

- `img::AbstractArray{T, 3}`: the last dimension is the time axis.
- `frames`: vector of 2d arrays.

# Parameters

- `fps::Int`: frame per second.

# Examples:

You can use this to view a 3D image:

```julia
using ImageShow, TestImages
ImageShow.gif(testimage("mri-stack"))
```

Or use it to dynamically check how different parameters change the function behavior:

```julia
using TestImages, ImageShow, ImageTransformations
img = testimage("cameraman")
ImageShow.gif([imrotate(img, θ, axes(img)) for θ in -π/4:π/16:π/4]; fps=3)
```

See also `mosaic`, provided by `MosaicViews`/`ImageCore`, for a 2d alternative of `gif`.
"""
gif(img::AbstractArray{<:Colorant, 3}; kwargs...) = AnimatedGIF(img; kwargs...)
gif(img::AbstractArray{<:Real, 3}; kwargs...) = AnimatedGIF(of_eltype(Gray, img); kwargs...)
function gif(frames::AbstractVector{<:AbstractMatrix}; kwargs...)
    FT = eltype(eltype(frames))
    fillvalue = zero(FT) # require ColorVectorSpace for RGB and Gray

    # FIXME: sym_paddedviews+StackView makes it unable to infer the types
    # TODO: sym_paddedviews(zero(FT), frames...) would just break whatever the fancy lazy
    #       feature `frames` has and thus slows the code
    sz = size(first(frames))
    frames = all(A->sz == size(A), frames) ? frames : sym_paddedviews(zero(FT), frames...)
    stacked_frames = StackView{FT}(frames, Val(3))
    gif(stacked_frames; kwargs...)
end

# Because any object can be callable (not just `Function`), we add this method to distinguish
# the `f` function version and throw a menaingful message.
# TODO: Maybe we could just support `gif(framestack...)`?
gif(::AbstractMatrix, ::AbstractMatrix...) = throw(ArgumentError("Do you mean `gif([A, Bs...])"))

"""
    gif(f, Xs; kwargs...)
    gif(f, Xs, Ys...; kwargs...)

A lazy version of `gif([f(X) for X in Xs]; kwargs...)` that allocates memory only when needed.

# Parameters

- `fps::Int`: frame per second.

# Examples 

Rotate the image and see how things going:

```julia
using TestImages, ImageShow, ImageTransformations
img = testimage("cameraman")
ImageShow.gif(-π/4:π/16:π/4]; fps=3) do θ
    imrotate(img, θ, axes(img))
end
```

The following example is less meaningful, but it shows how multiple arguments are passed:

```julia
sizes = 16:4:64
values = range(0, stop=1, length=length(sizes))
gif = ImageShow.gif(values, sizes) do v, x
    fill(RGB(v, v, v), ntuple(_->x, 2)...)
end
```
"""
gif(f, arg1, args...; kwargs...) = gif(mappedarray(f, arg1, args...); kwargs...)
# MappedArrays are not efficient here https://github.com/JuliaArrays/MappedArrays.jl/issues/46
gif(frames::AbstractMappedArray; kwargs...) = gif(collect(frames); kwargs...)
