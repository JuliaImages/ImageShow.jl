include("keyboard.jl")

ansi_moveup(n::Int) = string("\e[", n, "A")
const ansi_movecol1 = "\e[1G"

"""
    play(framestack::AbstractVector{T}; kwargs...) where {T<:AbstractArray}
    play(arr::T, dim=3; kwargs...)

(Experimental) Play a video of a framestack of image arrays, or 3D array along dimension `dim`.

!!! compat "ImageShow 0.3"
    The `play` function requires at least ImageShow 0.3.

# Control keys

- `p` or `space-bar`: pause/resume
- `b`, `←`(left arrow), or `↑`(up arrow): step backward
- `f`, `→`(right arrow), or `↓`(down arrow): step forward
- `ctrl-c` or `q`: exit

# Parameters

- `fps`: frame per second.

# Examples

```julia
using ImageCore, TestImages, ImageShow

img3d = RGB.(testimage("mri-stack"))
ImageShow.play(img3d) # or ImageShow.play(img3d, 3)

framestack = [img3d[:, :, i] for i in axes(img3d, 3)];
ImageShow.play(framestack)
```

See also [`explore`](@ref ImageShow.explore) for a similar version that pauses at the start
and the end.
"""
function play(framestack::AbstractVector{<:AbstractMatrix}; fps::Real=15)
    # NOTE: the default fps is chosen purely by experience and may be changed in the future
    _play(framestack; fps=fps, paused=false, quit_after_play=true)
end
play(img::AbstractArray{<:Colorant, 3}, dim=3; kwargs...) = play(map(i->selectdim(img, dim, i), axes(img, dim)); kwargs...)

"""
    play(f, Xs; kwargs...)
    play(f, Xs, Ys...; kwargs...)

(Experimental) A lazy version of `play([f(X) for X in Xs]; kwargs...)` that allocates memory only when needed.

!!! compat "ImageShow 0.3"
    The `play` function requires at least ImageShow 0.3.

# Parameters

- `fps::Int`: frame per second.

# Examples 

Rotate the image and see how things going:

```julia
using TestImages, ImageShow, ImageTransformations
img = testimage("cameraman")
ImageShow.play(-π/4:π/16:π/4]; fps=3) do θ
    imrotate(img, θ, axes(img))
end
```

The following example is less meaningful, but it shows how multiple arguments are passed:

```julia
sizes = 16:4:64
values = range(0, stop=1, length=length(sizes))
ImageShow.play(values, sizes; fps=3) do v, x
    fill(RGB(v, v, v), ntuple(_->x, 2)...)
end
```
"""
play(f, arg1, args...; kwargs...) = play(mappedarray(f, arg1, args...); kwargs...)
# MappedArrays are not efficient here https://github.com/JuliaArrays/MappedArrays.jl/issues/46
play(frames::AbstractMappedArray; kwargs...) = play(collect(frames); kwargs...)

"""
    explore(framestack::AbstractVector{T}; kwargs...) where {T<:AbstractArray}
    explore(arr::T, dim=3; kwargs...)

(Experimental) Play a video of a framestack of image arrays, or 3D array along dimension `dim`.

!!! compat "ImageShow 0.3"
    The `play` function requires at least ImageShow 0.3.

Same as [`play`](@ref ImageShow.play), but will pause at the start and the end of the play. For the detailed
usage, please see the [`play` documentation](@ref ImageShow.play).
"""
function explore(framestack::AbstractVector{<:AbstractMatrix}; fps::Real=15)
    _play(framestack; fps=fps, paused=true, quit_after_play=false)
end
explore(img::AbstractArray{<:Colorant, 3}, dim=3; kwargs...) = explore(map(i->selectdim(img, dim, i), axes(img, dim)); kwargs...)

"""
    explore(f, Xs; kwargs...)
    explore(f, Xs, Ys...; kwargs...)

(Experimental)  A lazy version of `explore([f(X) for X in Xs]; kwargs...)` that allocates memory only when needed.
"""
explore(f, arg1, args...; kwargs...) = explore(mappedarray(f, arg1, args...); kwargs...)
# MappedArrays are not efficient here https://github.com/JuliaArrays/MappedArrays.jl/issues/46
explore(frames::AbstractMappedArray; kwargs...) = explore(collect(frames); kwargs...)

function _play(
        framestack::AbstractVector{<:AbstractMatrix};
        fps, paused, quit_after_play,
        # The following keywords are for advanced usages(e.g., test), common users are not expected
        # to use them directly.
        display_io::Union{Nothing, IO}=nothing,
        summary_io::IO=stdout,
        keyboard_io::IO=stdin
)
    nframes = length(framestack)

    # vars
    frame_idx = 1
    actual_fps = 0
    should_exit = false

    function render_frame(frame_idx, actual_fps; first_frame)
        frame = framestack[frame_idx]
        cols, rows = size(frame)

        if !first_frame
            print(summary_io, ansi_moveup(2), ansi_movecol1)
        end
        println(summary_io, "Frame: $frame_idx/$nframes FPS: $(round(actual_fps, digits=1))", " "^5)
        println(summary_io, "exit: \"q\" play/pause: \"space-bar\" seek: \"arrow keys\"")

        # When calling `display(MIME"image/png"(), img)`, VSCode/IJulia/Atom will eventually
        # create an `IOBuffer` to get the Base64+PNG encoded data, and send the encoded data to
        # the outside display pipeline, e.g., as JSON message.
        # For test purpose, we could directly show it to our manually created IO.
        isnothing(display_io) ? display(frame) : show(display_io, MIME"image/png"(), frame)
    end
    # These codes live in ImageShow and thus MIME"image/png" is always showable
    @assert showable(MIME"image/png"(), framestack[frame_idx])
    render_frame(frame_idx, actual_fps; first_frame=true)

    keytask = @async begin
        while !should_exit
            control_value = read_key(keyboard_io)

            if control_value == :CONTROL_BACKWARD
                frame_idx = max(frame_idx-1, 1)
            elseif control_value == :CONTROL_FORWARD
                frame_idx = min(frame_idx+1, nframes)
            elseif control_value == :CONTROL_PAUSE
                paused = !paused
            elseif control_value == :CONTROL_EXIT
                should_exit = true
            elseif control_value == :CONTROL_VOID
                nothing
            else
                error("Control value $control_value not recognized.")
            end
            sleep(1e-2) # 10ms should be enough for most keyboard event
            # @show control_value frame_idx paused should_exit
        end
    end
    keytask_channel = make_channel(keytask)

    try
        last_frame_idx = frame_idx

        while !should_exit && 1<= frame_idx <= nframes
            # when paused, only update the frame when last_frame_idx changes, i.e., only when
            # user hit arrow keys.
            # Otherwise the same frame will be rendered again and again and again and increases
            # the plot count in the plotpane endlessly.
            if frame_idx != last_frame_idx
                fps_value = paused ? 0 : actual_fps
                actual_fps = fixed_fps(fps) do
                    render_frame(frame_idx, actual_fps; first_frame=false)
                end
                last_frame_idx = frame_idx
            end
            if !quit_after_play && frame_idx == nframes
                # don't immediately quit the play
                paused = true
            end
            paused || (frame_idx += 1)
            # Wait for keyboard event update
            # This does not mean fps is at most 100
            paused && sleep(1e-2)
        end
    catch e
        e isa InterruptException || rethrow(e)
    finally
        # Stop the running read_key task so that REPL/stdin is not blocked.
        # If it's an IOBuffer then there's no need to do so becaused it will exit eventually
        # at `should_exit`.
        if !isa(keyboard_io, IOBuffer)
            safe_kill(keytask, keytask_channel)
        end
    end
    return nothing
end

"""
    fixed_fps(f::Function, fps::Real)

Run function f() at a fixed fps rate if possible.

Example:

The following codes render the frames at a given fps 60.

```julia
while true
    actual_fps = fixed_fps(60) do
        render_frame(...)
    end
end
```
"""
function fixed_fps(f, fps::Real)
    tim = Timer(1/fps)
    t = @elapsed f()
    wait(tim)
    close(tim)
    return 1/t
end
