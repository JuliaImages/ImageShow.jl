# ImageShow

[![][travis-img]][travis-url]
[![][pkgeval-img]][pkgeval-url]
[![][codecov-img]][codecov-url]

This small package implements image `show` methods suitable for
graphical platforms such as [IJulia](https://github.com/JuliaLang/IJulia.jl),
[VS Code](https://github.com/julia-vscode/julia-vscode) and [Juno](https://junolab.org/).
It is intended to provide convenient
inline presentation of greyscale or color images.

Things that users of `ImageShow` need to know:

* Without `ImageShow`, 2d image `AbstractMatrix{<:Colorant}` will be encoded and displayed as a SVG image, which is not performant
  for generic image.
* Once you load this package, 2d image will be encoded and displayed as a PNG image. To encode the
  data as PNG image, either `ImageIO` or `ImageMagick` should be installed.
* `using Images` automatically loads `ImageShow` for you.

## Functions

This package provides three non-exported functions `play`/`explore` and `gif` to interpret your 3D
image or 2d images as either a video sequence or a gif.

- (Experimental) `play`/`explore` are interactive tools; it show images frame by frame as video sequence.
- `gif` is non-interactive; it encodes the image as gif.

Feel free to replace `gif` with `play`/`explore` and see how it works:

```julia
using ImageShow, TestImages, ImageTransformations

# 3d image
img3d = testimage("mri-stack") |> collect
ImageShow.gif(img3d)

# 2d images
toucan = testimage("toucan") # 150×162 RGBA image
moon = testimage("moon") # 256×256 Gray image
framestack = [toucan, moon];
ImageShow.gif(framestack)

# a do-function version
img = testimage("cameraman")
ImageShow.gif(-π/4:π/64:π/4; fps=10) do θ
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
