if isdefined(FileIO, :action)
    # FileIO >= 1.6
    _png_stream(io) = FileIO.Stream{format"PNG"}(io)
else
    _png_stream(io) = FileIO.Stream(format"PNG", io)
end
