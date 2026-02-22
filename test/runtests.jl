using Test
using TransposeMatrix

@testset "transpose2x2!" begin
    A = reshape(UInt8.(0:(2 ^ 2 - 1)), (2, 2))
    B = similar(A)
    transpose2x2!(B, A)
    @test B == permutedims(A)
end

@testset "transpose4x4!" begin
    A = reshape(UInt8.(0:(4 ^ 2 - 1)), (4, 4))
    B = similar(A)
    transpose4x4!(B, A)
    @test B == permutedims(A)
end

@testset "transpose8x8!" begin
    A = reshape(UInt8.(0:(8 ^ 2 - 1)), (8, 8))
    B = similar(A)
    transpose8x8!(B, A)
    @test B == permutedims(A)
end

@testset "transpose16x16!" begin
    A = reshape((0:(16 ^ 2 - 1)) .% UInt8, (16, 16))
    B = similar(A)
    transpose16x16!(B, A)
    @test B == permutedims(A)
end

@testset "transposeNxN! (N=$N)" for N in [2, 4, 8, 16, 32, 64]
    A = rand(UInt8, N, N)
    B = similar(A)
    transposeNxN!(B, A, Val(N))
    @test B == permutedims(A)
end

@testset "transpose! (n=$n, N=$N)" for n in [128, 256, 512], N in [2, 4, 8, 16, 32, 64]
    A = rand(UInt8, n, n)
    B = similar(A)
    transpose!(B, A, Val(N))
    @test B == permutedims(A)
end
