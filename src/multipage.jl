ansi_moveup(n::Int) = string("\e[", n, "A")
const ansi_movecol1 = "\e[1G"

"""
    play(framestack::AbstractVector{T}; kwargs...) where {T<:AbstractArray}
    play(arr::T, dim::Int; kwargs...)

Play a video of a framestack of image arrays, or 3D array along dimension `dim`.

Control keys:
- `p` or `space-bar`: pause/resume
- `f`, `←`(left arrow), or `↑`(up arrow): step backward
- `b`, `→`(right arrow), or `↓`(down arrow): step forward
- `ctrl-c` or `q`: exit

kwargs:

- `fps::Real=30`

# Examples

```julia
julia> using TestImages, ImageShow

julia> img3d = testimage("mri-stack") |> collect;

julia> ImageShow.play(img3d, 3)

julia> framestack = [img3d[:, :, i] for i in axes(img3d, 3)];

julia> ImageShow.play(framestack)
```
"""
function play(framestack::AbstractVector{<:AbstractArray}; fps::Real=30, paused=false)
    nframes = length(framestack)

    # vars
    frame_idx = 1
    actual_fps = 0
    should_exit = false

    function render_frame(frame_idx, actual_fps; first_frame)
        frame = framestack[frame_idx]
        cols, rows = size(frame)

        if !first_frame
            print(ansi_moveup(2), ansi_movecol1)
        end
        println("Frame: $frame_idx/$nframes FPS: $(round(actual_fps, digits=1))", " "^5)
        println("exit: ctrl-c. play/pause: space-bar. seek: arrow keys")

        display(frame)
    end
    render_frame(frame_idx, actual_fps; first_frame=true)

    keytask = @async begin
        while !should_exit
            control_value = read_key()

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
play(img::AbstractArray{<:Colorant}, dim; kwargs...) = play(map(i->selectdim(img, dim, i), axes(img, dim)); kwargs...)

# minimal keyboard event support
"""
    read_key() -> control_value

read control key from keyboard input.

# Reference table

| value               | control_value     | effect                 |
| ------------------- | ----------------- | -------------------    |
| UP, LEFT, f, F      | :CONTROL_BACKWARD | show previous frame    |
| DOWN, RIGHT, b, B   | :CONTROL_FORWARD  | show next frame        |
| SPACE, p, P         | :CONTROL_PAUSE    | pause/resume play      |
| CTRL-c, q, Q        | :CONTROL_EXIT     | exit current play      |
| others...           | :CONTROL_VOID     | no effect              |
"""
function read_key()
    setraw!(io, raw) = ccall(:jl_tty_set_mode, Int32, (Ptr{Cvoid},Int32), io.handle, raw)
    control_value = :CONTROL_VOID
    try
        setraw!(stdin, true)
        keyin = read(stdin, Char)
        if keyin == '\e'
            # some special keys are more than one byte, e.g., left key is `\e[D`
            # reference: https://en.wikipedia.org/wiki/ANSI_escape_code
            keyin = read(stdin, Char)
            if keyin == '['
                keyin = read(stdin, Char)
                if keyin in ['A', 'D'] # up, left
                    control_value = :CONTROL_BACKWARD
                elseif keyin in ['B', 'C'] # down, right
                    control_value = :CONTROL_FORWARD
                end
            end
        elseif 'A' <= keyin <= 'Z' || 'a' <= keyin <= 'z'
            keyin = lowercase(keyin)
            if keyin == 'p'
                control_value = :CONTROL_PAUSE
            elseif keyin == 'q'
                control_value = :CONTROL_EXIT
            elseif keyin == 'f'
                control_value = :CONTROL_FORWARD
            elseif keyin == 'b'
                control_value = :CONTROL_BACKWARD
            end
        elseif keyin == ' '
            control_value = :CONTROL_PAUSE
        end
    catch e
        if e isa InterruptException # Ctrl-C
            control_value = :CONTROL_EXIT
        else
            rethrow(e)
        end
    finally
        setraw!(stdin, false)
    end
    return control_value
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
