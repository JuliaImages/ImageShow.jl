# ImageShow

[![][travis-img]][travis-url]
[![][pkgeval-img]][pkgeval-url]
[![][codecov-img]][codecov-url]

This small package implements image `show` methods suitable for
graphical platforms such as [IJulia](https://github.com/JuliaLang/IJulia.jl),
[VS Code](https://github.com/julia-vscode/julia-vscode) and [Juno](https://junolab.org/).
It is intended to provide convenient
inline presentation of greyscale or color images.


Things that users of `ImageShow` might need to know:

* Once you load this package, `AbstractMatrix{<:Colorant}` will be displayed as PNG image.
* Advanced anti-aliased reduction is applied if `ImageTransformations` are loaded.
* `using Images` automatically loads `ImageShow` and `ImageTransformations` for you.

## Functions

This package also provides a non-exported function `gif` to interpret your 3D image or 2d images as
an animated GIF image.

```julia
using ImageShow, TestImages, ImageTransformations
# Or
# using Images, TestImages

# 3d image
ImageShow.gif(testimage("mri-stack"))

# 2d images
toucan = testimage("toucan") # 150×162 RGBA image
moon = testimage("moon") # 256×256 Gray image
ImageShow.gif([toucan, moon])

# a do-function version
img = testimage("cameraman")
ImageShow.gif(-π/4:π/16:π/4]; fps=3) do θ
    imrotate(img, θ, axes(img))
end
```

See also `mosaic`, provided by `MosaicViews`/`ImageCore`, for a 2d alternative of `gif`.

# Acknowledgement

The functionality of ImageShow has historically been included in the
Images umbrella package.

<!-- URLS -->

[pkgeval-img]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/I/ImageShow.svg
[pkgeval-url]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html
[travis-img]: https://travis-ci.org/JuliaImages/ImageShow.jl.svg?branch=master
[travis-url]: https://travis-ci.org/JuliaImages/ImageShow.jl
[codecov-img]: https://codecov.io/github/JuliaImages/ImageShow.jl/coverage.svg?branch=master
[codecov-url]: https://codecov.io/github/JuliaImages/ImageShow.jl?branch=master
