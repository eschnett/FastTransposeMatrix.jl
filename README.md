# FastTransposeMatrix.jl

Transpose matrices in memory efficiently via SIMD instructions. This
can be about ten times faster than calling `permutedims!`.

[![CI](https://github.com/eschnett/FastTransposeMatrix.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/eschnett/FastTransposeMatrix.jl/actions/workflows/CI.yml)

## General Remark

In general, transposing a matrix in memory should be
avoided. It is usually much faster to just index the matrix
differently. This is what Julia's `transpose` does -- it changes the
type of the matrix to indicate that the indices need to be swapped
when accessing matrix elements.

However, sometimes it does make sense to actually transpose a matrix
in memory. For example, if you know that the matrix will be accessed
column-wise many times in the future, then transposing it in memory
can speed things up tenfold. If the matrix will be stored on disk, and
if only individual columns will be accessed, then the time savings can
be even greater.

## How to use it

```julia
using FastTransposeMatrix

n = 1024
A = rand(UInt8, n, n);
B = similar(A);

@benchmark transpose!(B, A, Val(16))
```

The last argument (`Val(16)`) chooses the block size used in the
transpose algorithm. A block size between 16 and 64 works generally
well. Swmaller block sizes are usually less efficient. The block size
needs to be a power of 2, and it needs to divide the matrix size
evenly.

Higher-dimensional arrays can be transposed by using `reshape`.

## Benchmark results

We transpose a matrix of size 1024 × 1024 without multi-threading. We
compare against Julia's `permutedims!`, and compare various block
sizes via the script `bin/bench.jl`, which uses
[BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl).

We compare the median times. (Smaller times are better.) In this case,
`FastTransposeMatrix` is roughly ten times faster.

### Apple M3 Pro

- OS: macOS (arm64-apple-darwin24.0.0)
- CPU: 12 × Apple M3 Pro
- LLVM: libLLVM-18.1.7 (ORCJIT, apple-m3)

|   Element type |     `UInt8`   |     `UInt32`  |
|     Block size | Median time   |  Median time  |
|----------------|---------------|---------------|
| `permutedims!` |  560.375 μs   |   781.917 μs  |
|              2 | 1082.000 μs   |  1113.000 μs  |
|              4 |  353.542 μs   |   379.291 μs  |
|              8 |  144.167 μs   | **198.042 μs**|
|             16 | **64.417 μs** |   209.250 μs  |
|             32 |   68.875 μs   |   238.791 μs  |
|             64 |   85.708 μs   |   213.834 μs  |


### Intel Xeon Gold

- CPU: 32 × Intel(R) Xeon(R) Gold 5416S
- WORD_SIZE: 64
- LLVM: libLLVM-18.1.7 (ORCJIT, sapphirerapids)

|   Element type |     `UInt8`   |     `UInt32`   |
|     Block size | Median time   |  Median time   |
|----------------|---------------|----------------|
| `permutedims!` |  948.053 μs   |  3766.000 μs   |
|              2 | 1457.000 μs   |  2738.000 μs   |
|              4 |  479.790 μs   |  1049.000 μs   |
|              8 |  195.489 μs   |   589.208 μs   |
|             16 |  153.323 μs   |   456.843 μs   |
|             32 |   98.965 μs   | **428.710 μs** |
|             64 | **85.390 μs** |   537.207 μs   |
