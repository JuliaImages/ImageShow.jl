@testset "Real Arrays" begin

    @test simshow([1, 2, 3, 4]) == ColorTypes.Gray{Float64}[Gray{Float64}(0.25), Gray{Float64}(0.5), Gray{Float64}(0.75), Gray{Float64}(1.0)]
    @test simshow([0.1, 0.1], set_one = true) == ColorTypes.Gray{Float64}[Gray{Float64}(1.0), Gray{Float64}(1.0)]
    @test simshow([0.1, 0.1], set_one = false) == ColorTypes.Gray{Float64}[Gray{Float64}(0.1), Gray{Float64}(0.1)]
    @test simshow([0.1, 0.1], set_one = false) == ColorTypes.Gray{Float64}[Gray{Float64}(0.1), Gray{Float64}(0.1)]
    @test simshow([0.1, -0.1], set_one = true, set_zero = false) == ColorTypes.Gray{Float64}[Gray{Float64}(1.0), Gray{Float64}(-1.0)]
    @test simshow([0.1, -0.1], set_one = true, set_zero = true) == ColorTypes.Gray{Float64}[Gray{Float64}(1.0), Gray{Float64}(0.0)]
    @test simshow([0.1, -0.1], set_one = false, set_zero = true) == ColorTypes.Gray{Float64}[Gray{Float64}(0.2), Gray{Float64}(0.0)]
    @test simshow([0.1, -0.1], set_one = false, set_zero = false) == ColorTypes.Gray{Float64}[Gray{Float64}(0.1), Gray{Float64}(-0.1)]
    @test simshow([0.1, 0], γ = 2, set_one = false) == ColorTypes.Gray{Float64}[Gray{Float64}(0.010000000000000002), Gray{Float64}(0.0)]
    @test simshow([0.1, 0], f = (x-> zeros((2,))), set_one = false) == ColorTypes.Gray{Float64}[Gray{Float64}(0.0), Gray{Float64}(0.0)]


    @test simshow([0, 1, 2], cmap = :thermal) == ColorTypes.RGB{Float64}[RGB{Float64}(0.015556013331540799,0.13824424546464084,0.2018108864558305), RGB{Float64}(0.6893346807608062,0.37270416310862364,0.5096912535037159), RGB{Float64}(0.9090418416674036,0.9821574063216706,0.3555078064299531)]

end


@testset "Complex Arrays" begin
    @test simshow([1.0, 1im, -1, -1im, 1.0 - 0.0001im]) == ColorTypes.HSV{Float64}[HSV{Float64}(0.0,1.0,0.999999995), HSV{Float64}(90.0,1.0,0.999999995), HSV{Float64}(180.0,1.0,0.999999995), HSV{Float64}(-90.0,1.0,0.999999995), HSV{Float64}(-0.00572957793220964,1.0,1.0)]

    @test simshow([1.0 / 2, (1im) / 2, -1 / 2, (-1im) / 2, 1.0 - 0.0001im], absγ = 2) == ColorTypes.HSV{Float64}[HSV{Float64}(0.0,1.0,0.24999999750000002), HSV{Float64}(90.0,1.0,0.24999999750000002), HSV{Float64}(180.0,1.0,0.24999999750000002), HSV{Float64}(-90.0,1.0,0.24999999750000002), HSV{Float64}(-0.00572957793220964,1.0,1.0)]


    @test simshow([1.0, (1im) / 4, -1 / 8, (-1im) / 2, 1.0 - 0.0001im], absf = (x->begin
                y = copy(x)
                y .= x[1]
                y
            end)) == ColorTypes.HSV{Float64}[HSV{Float64}(0.0,1.0,0.999999995), HSV{Float64}(90.0,1.0,0.999999995), HSV{Float64}(180.0,1.0,0.999999995), HSV{Float64}(-90.0,1.0,0.999999995), HSV{Float64}(-0.00572957793220964,1.0,0.999999995)]
    simshow([0.1, 0im], f = (x->begin
                1.1 .* ones(ComplexF32, (2,))
            end)) == HSV{Float64}[HSV{Float64}(0.0,1.0,1.0), HSV{Float64}(0.0,1.0,1.0)]
end

@testset "Colorant Array" begin
    @test simshow(ColorTypes.Gray.([0.123])) == ColorTypes.Gray{Float64}[Gray{Float64}(0.123)]

end
