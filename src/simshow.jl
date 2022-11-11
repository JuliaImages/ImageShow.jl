export simshow

"""
    simshow(arr; set_one=false, set_zero=false,
                f=nothing, γ=1)

Displays a real valued array . Brightness encodes magnitude.
Works within Jupyter and Pluto.
# Keyword args
The transforms are applied in that order.
* `set_zero=false` subtracts the minimum to set minimum to 1
* `set_one=false` divides by the maximum to set maximum to 1
* `f` applies an arbitrary function to the abs array
* `γ` applies a gamma correction to the abs 
* `cmap=:gray` applies a colormap provided by ColorSchemes.jl. If `cmap=:gray` simply `Colors.Gray` is used
    and with different colormaps the result is an `Colors.RGB` element type
"""
function simshow(arr::AbstractArray{T};
                 set_one=true, set_zero=false,
                 f = nothing,
                 γ = one(T),
                 cmap=:gray) where {T<:Real}
    arr = set_zero ? arr .- minimum(arr) : arr

    if set_one
        m = maximum(arr)
        if !iszero(m)
            arr = arr ./ maximum(arr)
        end
    end

    arr = isnothing(f) ? arr : f(arr)

    if !isone(γ)
        arr = arr .^ γ
    end

    if cmap == :gray
        Gray.(arr)
    else
        get(colorschemes[cmap], arr)
    end
end


"""
    simshow(arr)

Displays a complex array. Color encodes phase, brightness encodes magnitude.
Works within Jupyter and Pluto.
# Keyword args
The transforms are applied in that order.
* `f` applies a function `f` to the array.
* `absf` applies a function `absf` to the absolute of the array
* `absγ` applies a gamma correction to the abs 
"""
function simshow(arr::AbstractArray{T};
                 f=nothing,
                 absγ=one(T),
                 absf=nothing) where (T<:Complex)

    if !isnothing(f)
        arr = f(arr)
    end

    Tr = real(T)
    # scale abs to 1
    absarr = abs.(arr)
    absarr ./= maximum(absarr)

    if !isnothing(absf)
        absarr .= absf(absarr)
    end
    
    if !isone(absγ)
        absarr .= absarr .^ absγ
    end

    angarr = angle.(arr) ./ Tr(2pi) * Tr(360)

    HSV.(angarr, one(Tr), absarr)
end



"""
    simshow(arr::AbstractArray{<:Colors.ColorTypes.Colorant})
If `simshow` receives an array which already contains color information, just display it.
"""
function simshow(arr::AbstractArray{<:Colors.ColorTypes.Colorant})
    return arr
end
