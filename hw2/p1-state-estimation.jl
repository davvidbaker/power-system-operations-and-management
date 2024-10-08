using LinearAlgebra
using DataFrames
using PrettyTables

# make fun B subscripts, only works for single digit indices
function symbolFn(i, j)
    subscript = String([Char(0x2080 + i), Char(0x2080 + j)])
    return Symbol("B", subscript)
end

function make_fun_B_subscripts(B)
    for row ∈ 1:length(eachrow(B))
        for col ∈ 1:length(eachcol(B))
            eval(:($(symbolFn(row, col)) = $(B[row, col])))
        end
    end
end

# constants
v₂ = 0.98
δ₁ = 0


function h(x)
    δ₂ = x[1]
    v₁ = x[2]

    return [
        v₁
        v₁ * v₂ * B₁₂ * sin(δ₁ - δ₂)
        v₂ * v₁ * B₂₁ * sin(δ₂ - δ₁)
        -v₂ * v₁ * B₂₁ * cos(δ₂ - δ₁) + v₂^2 * B₂₁
    ]

    return z
end

# susceptance matrix
B = [-15 15
    15 -15]

make_fun_B_subscripts(B)

σ = 0.045 # 4.5% standard deviation of error
W = Diagonal(ones(4) .* (σ^2)) # I think it is sigma squared but not sure

# measurements
Vᵐ₁ = 1.0
Pᵐ₁₂ = 1.65
Pᵐ₂₁ = -1.62
Qᵐ₂₁ = -0.23
z = [Vᵐ₁, Pᵐ₁₂, Pᵐ₂₁, Qᵐ₂₁]

# x is [δ₂, v₁]
# array of x's
arr_x = [[0.0, 1.0]]

for i in 1:2
    x = arr_x[i]
    δ₂ = x[1]
    v₁ = x[2]

    H = [0 1;
        -v₁*v₂*B₁₂*cos(δ₁ - δ₂) v₂*B₁₂*sin(δ₁ - δ₂)
        v₂*v₁*B₂₁*cos(δ₂ - δ₁) v₂*B₂₁*sin(δ₂ - δ₁)
        v₂*v₁*B₂₁*sin(δ₂ - δ₁) -v₂*B₂₁*cos(δ₂ - δ₁)
    ]


    x_new = x + ((H' * W * H)^-1) * (H' * W * (z - h(x)))
    push!(arr_x, x_new)
end

# display results
df = DataFrame(Iteration=["flat start", 1, 2], δ₂=[xx[1] for xx ∈ arr_x], v₁=[xx[2] for xx ∈ arr_x])
header = (["iteration", "δ₂", "v₁"], ["", "radians", "pu"])
pretty_table(df, header=header, header_crayon=crayon"yellow bold")
