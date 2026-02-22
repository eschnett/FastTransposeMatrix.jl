# TransposeMatrix.jl

Transpose matrices in memory efficiently via SIMD instructions. This
can be about ten times faster than calling `permutedims!`.

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
using TransposeMatrix

n = 1024
A = rand(UInt8, n, n);
B = similar(A);

@benchmark transpose!(B, A, Val(16))
```

The last argument (`Val(16)`) chooses the block size used in the
transpose algorithm. A block size of 16 works generally well; smaller
and larger block sizes are often less efficient. The block size needs
to be a power of 2, and it needs to divide the matrix size evenly.
Block sizes larger than the cache line size (usually 64 Bytes on a
CPU) do not make sense performance-wise.

## Benchmark results

We transpose a matrix of size 1024x1024. We compare against Julia's
`permutedims!`, and compare various block sizes via the script
`bin/bench.jl`, which uses
[BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl).

### Apple M3 Pro

- OS: macOS (arm64-apple-darwin24.0.0)
- CPU: 12 × Apple M3 Pro
- LLVM: libLLVM-18.1.7 (ORCJIT, apple-m3)

|     Block size | Median time |
|----------------|-------------|
| `permutedims!` |  560.375 μs |
|              2 | 1082.000 μs |
|              4 |  353.542 μs |
|              8 |  144.167 μs |
|             16 |   64.417 μs |
|             32 |   68.875 μs |
|             64 |   85.708 μs |


### 

- OS: macOS (arm64-apple-darwin24.0.0)
- CPU: 12 × Apple M3 Pro
- LLVM: libLLVM-18.1.7 (ORCJIT, apple-m3)

|     Block size | Median time |
|----------------|-------------|
| `permutedims!` |  560.375 μs |
|              2 | 1082.000 μs |
|              4 |  353.542 μs |
|              8 |  144.167 μs |
|             16 |   64.417 μs |
|             32 |   68.875 μs |
|             64 |   85.708 μs |

