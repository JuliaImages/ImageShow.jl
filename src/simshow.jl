export simshow

"""
    simshow(arr; set_zero=false, set_one=false, γ=1, cmap=:gray)

Displays a real valued array.
Works within Jupyter and Pluto.

# Keyword args

The transforms are applied in that order.
* `set_zero=false` subtracts the minimum to set minimum to 0
* `set_one=true` divides by the maximum to set maximum to 1
* `γ` applies a gamma correction
* `cmap=:gray` applies a colormap provided by ColorSchemes.jl. If `cmap=:gray` simply `Colors.Gray` is used
    and with different colormaps the result is an `Colors.RGB` element type. To use the different colormaps
    install ColorSchemes.jl and try colormaps such as `:jet`, `:deep`, `thermal`, etc.
"""
function simshow(arr::AbstractArray{T};
                 set_zero=false, set_one=true,
                 γ = one(T),
                 cmap=:gray) where {T<:Real}

    arr = set_zero ? arr .- minimum(arr) : arr

    if set_one
        m = maximum(arr)
        if !iszero(m)
            arr = arr ./ maximum(arr)
        end
    end

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
    simshow(arr; γ=1)

Displays a complex array. Color encodes phase, brightness encodes magnitude.
Works within Jupyter and Pluto.

# Keyword args
* `γ` applies a gamma correction to the magnitude
"""
function simshow(arr::AbstractArray{T};
                 γ=one(T)) where (T<:Complex)

    Tr = real(T)
    # scale abs to 1
    absarr = abs.(arr)
    absarr ./= maximum(absarr)

    if !isone(γ)
        absarr .= absarr .^ γ
    end

    angarr = angle.(arr) ./ Tr(2pi) * Tr(360)

    HSV.(angarr, one(Tr), absarr)
end

"""
    simshow(arr::AbstractArray{Colors.Gray{<: Fixed}})

"""
function simshow(arr::AbstractArray{Colors.Gray{T}}) where {T<:Fixed}
    return simshow(Array{Gray{Float64}}(arr))
end

"""
    simshow(arr::AbstractArray{<:Colors.ColorTypes.Colorant})

If `simshow` receives an array which already contains color information, just display it.
In that case, no keywords argument are applied.
"""
function simshow(arr::AbstractArray{<:Colors.ColorTypes.Colorant})
    return arr
end
