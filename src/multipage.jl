include("keyboard.jl")

ansi_moveup(n::Int) = string("\e[", n, "A")
const ansi_movecol1 = "\e[1G"

"""
    play(framestack::AbstractVector{T}; kwargs...) where {T<:AbstractArray}
    play(arr::T, dim=3; kwargs...)

Play a video of a framestack of image arrays, or 3D array along dimension `dim`.

Control keys:
- `p` or `space-bar`: pause/resume
- `b`, `←`(left arrow), or `↑`(up arrow): step backward
- `f`, `→`(right arrow), or `↓`(down arrow): step forward
- `ctrl-c` or `q`: exit

kwargs:

- `fps`: frame per second.

# Examples

```julia
using TestImages, ImageShow

img3d = RGB.(testimage("mri-stack"))
ImageShow.play(img3d)

framestack = [img3d[:, :, i] for i in axes(img3d, 3)];
ImageShow.play(framestack)
```
"""
function play(framestack::AbstractVector{<:AbstractMatrix}; fps::Real=min(10, length(framestack)÷2))
    # NOTE: the default fps is chosen purely by experience and may be changed in the future
    _play(framestack; fps=fps, paused=false, quit_after_play=true)
end
play(img::AbstractArray{<:Colorant, 3}, dim=3; kwargs...) = play(map(i->selectdim(img, dim, i), axes(img, dim)); kwargs...)

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
        println(summary_io, "exit: ctrl-c. play/pause: space-bar. seek: arrow keys")

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
        end
    end

    try
        last_frame_idx = frame_idx

        while !should_exit && 1<= frame_idx <= nframes
            # when paused, only update the frame when last_frame_idx changes, i.e., only when
            # user hit arrow keys.
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
            paused && sleep(0.001)
        end
    catch e
        e isa InterruptException || rethrow(e)
    finally
        # stop running read_key task so that REPL/stdin is not blocked
        @async Base.throwto(keytask, InterruptException())
        wait(keytask)
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
