# ImageShow

[![][travis-img]][travis-url]
[![][pkgeval-img]][pkgeval-url]
[![][codecov-img]][codecov-url]

This small package implements image `show` methods suitable for
graphical platforms such as [IJulia](https://github.com/JuliaLang/IJulia.jl),
[VS Code](https://github.com/julia-vscode/julia-vscode) and [Juno](https://junolab.org/).
It is intended to provide convenient
inline presentation of greyscale or color images.

The intention is that this package will be invisible to most users; it
should typically be invoked by other library packages. Of course, power users
are invited to check out the test suite to see what we think you might do,
and to suggest enhancements.

One user-apparent aspect (for users with good vision) is that large
images are displayed with anti-aliased reduction if the
ImageTransformations package is loaded, but with simple down-sampling
otherwise. (ImageTransformations is notably imported by Images, so
`using Images` will provide the nicer display.)

The functionality of ImageShow has historically been included in the
Images umbrella package.

<!-- URLS -->

[pkgeval-img]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/I/ImageShow.svg
[pkgeval-url]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html
[travis-img]: https://travis-ci.org/JuliaImages/ImageShow.jl.svg?branch=master
[travis-url]: https://travis-ci.org/JuliaImages/ImageShow.jl
[codecov-img]: https://codecov.io/github/JuliaImages/ImageShow.jl/coverage.svg?branch=master
[codecov-url]: https://codecov.io/github/JuliaImages/ImageShow.jl?branch=master
