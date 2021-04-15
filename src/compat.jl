if isdefined(FileIO, :action)
    # FileIO >= 1.6
    _format_stream(format, io) = FileIO.Stream{format}(io)
else
    _format_stream(format, io) = FileIO.Stream(format, io)
end


if VERSION < v"1.2.0"
    isnothing(x) = x === nothing
end
