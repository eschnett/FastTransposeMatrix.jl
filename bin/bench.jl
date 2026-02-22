using BenchmarkTools
using FastTransposeMatrix

n = 1024

T = UInt8
A = rand(T, n, n);
B = similar(A);

@benchmark permutedims!(B, A, (2, 1))

@benchmark transpose!(B, A, Val(2))
@benchmark transpose!(B, A, Val(4))
@benchmark transpose!(B, A, Val(8))
@benchmark transpose!(B, A, Val(16))
@benchmark transpose!(B, A, Val(32))
@benchmark transpose!(B, A, Val(64))
