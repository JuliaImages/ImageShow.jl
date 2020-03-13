# ImageShow

[![][travis-img]][travis-url]
[![][pkgeval-img]][pkgeval-url]
[![][codecov-img]][codecov-url]

This small package implements image `show` methods suitable for
graphical platforms such as [IJulia](https://github.com/JuliaLang/IJulia.jl),
[VS Code](https://github.com/julia-vscode/julia-vscode) and [Juno](https://junolab.org/).
It is intended to provide convenient
inline presentation of greyscale or color images.

Large images are displayed with anti-aliased reduction if the
ImageTransformations package is loaded, but with simple down-sampling
otherwise. (ImageTransformations is notably imported by Images, so
`using Images` will provide the nicer display.)

[MosaicViews.jl](https://github.com/JuliaArrays/MosaicViews.jl) is reexported by this
package to provide a handy visualization tool `mosaicview`. It is an enhanced version
of `cat` that "concatenate" images of different sizes and colorants.

```julia
julia> using ImageShow, TestImages

julia> lena = testimage("lena") # 256*256 RGB image

julia> cameraman = testimage("cameraman") # 512*512 Gray image

julia> mosaicview(lena, cameraman; nrow=1)

julia> img = testimage("mri")
3-dimensional AxisArray{ColorTypes.Gray{FixedPointNumbers.Normed{UInt8,8}},3,...} with axes:
    :P, 0:1:225
    :R, 0:1:185
    :S, 0:5:130
And data, a 226×186×27 Array{Gray{N0f8},3} with eltype ColorTypes.Gray{FixedPointNumbers.Normed{UInt8,8}}:

...

julia> mosaicview(img; fillvalue=0.5, npad=2, ncol=7, rowmajor=true)
```

![compare-images](https://user-images.githubusercontent.com/8684355/76654863-f5246100-65a6-11ea-8267-0d6e8c8d3712.png)

![mri-images](https://user-images.githubusercontent.com/8684355/76655141-a4613800-65a7-11ea-8fad-f71748da067b.png)


The functionality of ImageShow has historically been included in the
Images umbrella package.

<!-- URLS -->

[pkgeval-img]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/I/ImageShow.svg
[pkgeval-url]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html
[travis-img]: https://travis-ci.org/JuliaImages/ImageShow.jl.svg?branch=master
[travis-url]: https://travis-ci.org/JuliaImages/ImageShow.jl
[codecov-img]: https://codecov.io/github/JuliaImages/ImageShow.jl/coverage.svg?branch=master
[codecov-url]: https://codecov.io/github/JuliaImages/ImageShow.jl?branch=master
