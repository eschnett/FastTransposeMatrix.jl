module FastTransposeMatrix

using SIMD

export transposeNxN!
@generated function transposeNxN!(B::AbstractMatrix{T}, A::AbstractMatrix{T}, ::Val{N}) where {T,N}
    N::Integer
    @assert ispow2(N)

    stmts = []

    step = 0

    # Load
    for n in 0:(N - 1)
        an = Symbol(:r, string(step), :l, string(n))
        push!(stmts, :($an = vloada(Vec{$N,T}, view(A, :, $(n+1)), 1)))
    end

    blocksize = N÷2
    while blocksize >= 1
        step += 1

        for n1 in 0:(2 * blocksize):(N - 1)
            vals = Int[]
            for m1 in 0:(2 * blocksize):(N - 1)
                for m in m1:(m1 + blocksize - 1)
                    push!(vals, m)
                end
                for m in m1:(m1 + blocksize - 1)
                    push!(vals, m+N)
                end
            end
            for n in n1:(n1 + blocksize - 1)
                anlo = Symbol(:r, string(step-1), :l, string(n))
                anhi = Symbol(:r, string(step-1), :l, string(n+blocksize))
                bn = Symbol(:r, string(step), :l, string(n))
                push!(stmts, :($bn = shufflevector($anlo, $anhi, Val(tuple($(vals...))))))
            end
            vals = Int[]
            for m1 in 0:(2 * blocksize):(N - 1)
                for m in m1:(m1 + blocksize - 1)
                    push!(vals, m+blocksize)
                end
                for m in m1:(m1 + blocksize - 1)
                    push!(vals, m+N+blocksize)
                end
            end
            for n in n1:(n1 + blocksize - 1)
                anlo = Symbol(:r, string(step-1), :l, string(n))
                anhi = Symbol(:r, string(step-1), :l, string(n+blocksize))
                bn = Symbol(:r, string(step), :l, string(n+blocksize))
                push!(stmts, :($bn = shufflevector($anlo, $anhi, Val(tuple($(vals...))))))
            end
        end

        blocksize ÷= 2
    end

    # Store
    for n in 0:(N - 1)
        an = Symbol(:r, string(step), :l, string(n))
        push!(stmts, :(vstorea($an, view(B, :, $(n+1)), 1)))
    end

    # Return
    push!(stmts, :(return nothing))

    body = quote
        @boundscheck begin
            size(A) == ($N, $N) || throw(DimensionMismatch("Matrix A does not have size ($N,$N)"))
            size(B) == ($N, $N) || throw(DimensionMismatch("Matrix B does not have size ($N,$N)"))
            stride(A, 1) == 1 || throw(ArgumentError("Matrix A does not have stride 1 for its first dimension"))
            stride(B, 1) == 1 || throw(ArgumentError("Matrix A does not have stride 1 for its first dimension"))
        end
        @inbounds begin
            $(stmts...)
        end
        return B
    end

    return body
end

export transpose!
function transpose!(B::AbstractMatrix{T}, A::AbstractMatrix{T}, ::Val{N}) where {T,N}
    n = size(A, 1)
    @assert n % N == 0
    @assert size(A) == size(B) == (n, n)

    for j in 1:N:n, i in 1:N:n
        transposeNxN!(view(B, i:i+N-1, j:j+N-1), view(A, j:j+N-1, i:i+N-1), Val(N))
    end

    return B
end

end
