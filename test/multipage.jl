using ImageShow, ImageCore
using TestImages, FileIO
using Test

function check_summary(n, msg)
    function generate_summary_regex(n)
        summary_regex = raw"Frame: \d+/\d+ FPS: \d+\.\d+\s+\nexit: ctrl-c\. play\/pause: space-bar\. seek: arrow keys\n"
        Regex(mapreduce(i->summary_regex, (x,y)->x*raw".*"*y, 1:n))
    end
    function _check_summary(n, msg)
        return !isnothing(match(generate_summary_regex(n), msg))
    end

    return _check_summary(n, msg) && !_check_summary(n+1, msg)
end

@testset "multipage" begin
    @testset "play" begin
        img = RGB.(testimage("mri-stack"))
        framestack = [img[:, :, i] for i in 1:size(img, 3)]

        workdir = "tmp"
        mktempdir() do workdir
            filename = joinpath(workdir, "multipage.png")
            fn = open(filename, "w")
            summary_output_io = IOBuffer()

            save(filename, framestack[1])
            frame_size = stat(filename).size
            
            # Case: quit immediately
            key_input_io = IOBuffer(UInt8['q'])
            ImageShow._play(framestack; fps=1, paused=false, quit_after_play=true, display_io=fn, summary_io=summary_output_io, keyboard_io=key_input_io)
            summary_msg = String(take!(summary_output_io))
            @test check_summary(2, summary_msg) # If paused=false, it will print summary twice
            @test RGB.(load(filename)) == framestack[1]
            @test 1 == stat(filename).size/frame_size

            # Case: quit after all play
            fn = open(filename, "w")
            summary_output_io = IOBuffer()
            # use a small fps to make sure each frame are actually written
            ImageShow._play(framestack; fps=15, paused=false, quit_after_play=true, display_io=fn, summary_io=summary_output_io, keyboard_io=stdin)
            summary_msg = String(take!(summary_output_io))
            @test check_summary(length(framestack), summary_msg)
            # FIXME: show method will append to the given file handler, however, PNG reader will only
            #        read the first valid png data; all extra data block are discarded.
            # This somehow still proves that we're writing more than one image to the display_io
            @test RGB.(load(filename)) == framestack[1]
            @test 20 < stat(filename).size/frame_size < length(framestack)
        end
    end

    @testset "utils" begin
        # Although it's a no-op, it gets blocked at fps=2, which is about 0.5 second
        t = @elapsed ImageShow.fixed_fps(2) do
            nothing
        end
        @test 0.4 < t < 0.6
    end
end
