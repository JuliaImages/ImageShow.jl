using ImageShow, ImageCore
using TestImages, FileIO
using Test

function check_summary(n, msg)
    function generate_summary_regex(n)
        summary_regex = raw"""Frame: \d+/\d+ FPS: \d+\.\d+\s+\nexit: "q" play\/pause: "space-bar" seek: "arrow keys"\n"""
        Regex(mapreduce(i->summary_regex, (x,y)->x*raw".*"*y, 1:n))
    end
    function _check_summary(n, msg)
        return match(generate_summary_regex(n), msg) !== nothing
    end

    return _check_summary(n, msg) && !_check_summary(n+1, msg)
end

@testset "multipage" begin
    @testset "play" begin
        img = RGB.(testimage("mri-stack"))
        framestack = [img[:, :, i] for i in 1:size(img, 3)]

        mktempdir() do workdir
            tmpfile = joinpath(workdir, "multipage.png")
            save(tmpfile, framestack[1])
            frame_size = stat(tmpfile).size

            # Case: quit immediately -- render once
            summary_output_io = IOBuffer()
            key_input_io = IOBuffer(UInt8['q'])
            open(tmpfile, "w") do fn
                ImageShow._play(framestack; fps=1, paused=true, quit_after_play=true, display_io=fn, summary_io=summary_output_io, keyboard_io=key_input_io)
            end
            summary_msg = String(take!(summary_output_io))
            @test check_summary(1, summary_msg)
            @test RGB.(load(tmpfile)) == framestack[1]
            @test 1.0 == stat(tmpfile).size/frame_size

            # Case: quit after one forward -- render twice
            fn = open(tmpfile, "w")
            summary_output_io = IOBuffer()
            key_input_io = IOBuffer(UInt8['f', 'q'])
            open(tmpfile, "w") do fn
                ImageShow._play(framestack; fps=5, paused=true, quit_after_play=true, display_io=fn, summary_io=summary_output_io, keyboard_io=key_input_io)
            end
            summary_msg = String(take!(summary_output_io))
            @test check_summary(2, summary_msg)
            # NOTE: show method will append to the given file handler, however, PNG reader will only
            #        read the first valid png data; all extra data block are discarded.
            # This somehow still proves that we're writing more than one image to the display_io
            @test RGB.(load(tmpfile)) == framestack[1]
            @test 1.8 < stat(tmpfile).size/frame_size <= 2.2

            # Case: quit after resume play -- render twice
            summary_output_io = IOBuffer()
            key_input_io = IOBuffer(UInt8[' ', 'q'])
            open(tmpfile, "w") do fn
                ImageShow._play(framestack; fps=5, paused=true, quit_after_play=true, display_io=fn, summary_io=summary_output_io, keyboard_io=key_input_io)
            end
            summary_msg = String(take!(summary_output_io))
            @test check_summary(2, summary_msg)
            # NOTE: show method will append to the given file handler, however, PNG reader will only
            #        read the first valid png data; all extra data block are discarded.
            # This somehow still proves that we're writing more than one image to the display_io
            @test RGB.(load(tmpfile)) == framestack[1]
            @test 1.8 < stat(tmpfile).size/frame_size <= 2.2

            # Case: quit after a useless control -- only render once
            summary_output_io = IOBuffer()
            key_input_io = IOBuffer(UInt8['b', '?', 'q'])
            open(tmpfile, "w") do fn
                ImageShow._play(framestack; fps=5, paused=true, quit_after_play=true, display_io=fn, summary_io=summary_output_io, keyboard_io=key_input_io)
            end
            summary_msg = String(take!(summary_output_io))
            @test check_summary(1, summary_msg)
            @test RGB.(load(tmpfile)) == framestack[1]
            @test 1.0 == stat(tmpfile).size/frame_size

            # Case: quit after all play
            summary_output_io = IOBuffer()
            key_input_io = IOBuffer()
            # use a small fps to make sure each frame are actually written
            open(tmpfile, "w") do fn
                ImageShow._play(framestack; fps=15, paused=false, quit_after_play=true, display_io=fn, summary_io=summary_output_io, keyboard_io=key_input_io)
            end
            summary_msg = String(take!(summary_output_io))
            @test check_summary(length(framestack), summary_msg)
            # NOTE: show method will append to the given file handler, however, PNG reader will only
            #        read the first valid png data; all extra data block are discarded.
            # This somehow still proves that we're writing more than one image to the display_io
            @test RGB.(load(tmpfile)) == framestack[1]
            @test 0.8*length(framestack) < stat(tmpfile).size/frame_size < length(framestack)
        end
    end

    @testset "utils" begin
        # Although it's a no-op, it gets blocked at fps=2, which is about 0.5 second
        f() = nothing
        f() # precompile it
        t = @elapsed ImageShow.fixed_fps(f, 0.5)
        @test 1.5 < t < 2.5
    end
end
