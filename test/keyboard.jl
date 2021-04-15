using ImageShow
using ImageShow: read_key

@testset "keyboard" begin
    # TODO: Ctrl-C (InterruptException) is not tested
    @testset "read_key" begin
        inputs = [
            (UInt8['\e', '[', 'A'], :CONTROL_BACKWARD), # UP
            (UInt8['\e', '[', 'D'], :CONTROL_BACKWARD), # LEFT
            (UInt8['\e', '[', 'B'], :CONTROL_FORWARD), # DOWN
            (UInt8['\e', '[', 'C'], :CONTROL_FORWARD), # RIGHT

            (UInt8[' '],            :CONTROL_PAUSE), # SPACE
            (UInt8['p'],            :CONTROL_PAUSE),
            (UInt8['P'],            :CONTROL_PAUSE),
            (UInt8['q'],            :CONTROL_EXIT),
            (UInt8['Q'],            :CONTROL_EXIT),
            (UInt8['f'],            :CONTROL_FORWARD),
            (UInt8['F'],            :CONTROL_FORWARD),
            (UInt8['b'],            :CONTROL_BACKWARD),
            (UInt8['B'],            :CONTROL_BACKWARD),

            # key events that currenctly has no effect

            # although VIM users might want this :)
            (UInt8['j'],            :CONTROL_VOID),
            (UInt8['k'],            :CONTROL_VOID),
            (UInt8['h'],            :CONTROL_VOID),
            (UInt8['l'],            :CONTROL_VOID),
        ]
        for (chs, ref) in inputs
            io = IOBuffer(chs)
            @test ref == read_key(io)
        end
    end
end
