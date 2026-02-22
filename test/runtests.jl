using FastTransposeMatrix
using Test

@testset "transposeNxN! (T=$T, N=$N)" for T in [UInt8, UInt16, UInt32, UInt64], N in [2, 4, 8, 16, 32, 64]
    A = rand(T, N, N)
    B = similar(A)
    transposeNxN!(B, A, Val(N))
    @test B == permutedims(A)
end

@testset "transpose! (T=$T, n=$n, N=$N)" for T in [UInt8, UInt16, UInt32, UInt64], n in [128, 256, 512], N in [2, 4, 8, 16, 32, 64]
    A = rand(T, n, n)
    B = similar(A)
    transpose!(B, A, Val(N))
    @test B == permutedims(A)
end
