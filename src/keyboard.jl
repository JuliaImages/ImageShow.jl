# minimal keyboard event support
"""
    read_key() -> control_value

read control key from keyboard input.

# Reference table

| value               | control_value     | effect                 |
| ------------------- | ----------------- | -------------------    |
| UP, LEFT, b         | :CONTROL_BACKWARD | show previous frame    |
| DOWN, RIGHT, f      | :CONTROL_FORWARD  | show next frame        |
| SPACE, p            | :CONTROL_PAUSE    | pause/resume play      |
| CTRL-c, q           | :CONTROL_EXIT     | exit current play      |
| others...           | :CONTROL_VOID     | no effect              |
"""
function read_key(io=stdin)
    control_value = :CONTROL_VOID
    try
        _setraw!(io, true)
        keyin = read(io, Char)
        if keyin == '\e'
            # some special keys are more than one byte, e.g., left key is `\e[D`
            # reference: https://en.wikipedia.org/wiki/ANSI_escape_code
            keyin = read(io, Char)
            if keyin == '['
                keyin = read(io, Char)
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
        _setraw!(io, false)
    end
    return control_value
end

_setraw!(io::Base.TTY, raw) = ccall(:jl_tty_set_mode, Int32, (Ptr{Cvoid},Int32), io.handle, raw)
_setraw!(::IO, raw) = nothing

# keytask handling
# This works, although I have no idea how it is working internally -- Johnny Chen
# https://discourse.julialang.org/t/how-to-kill-thread/34236/8
if VERSION >= v"1.3"
    struct Stop end
    struct Continue end
    function safe_hanging(ch::Channel)
        signal = Continue()
        while true
            isready(ch) && (signal = take!(ch))
            signal == Stop() && break
            sleep(1e-4)
        end
    end

    make_channel(task) = Channel(safe_hanging, taskref=task, spawn=true)
    function safe_kill(task, ch::Channel)
        put!(ch, Stop())
        wait(task)
    end
else
    # non-safe quit
    make_channel(task) = task
    function safe_kill(task, ch)
        # this is not safe at all
        @async Base.throwto(keytask, InterruptException())
        wait(task)
    end
end
