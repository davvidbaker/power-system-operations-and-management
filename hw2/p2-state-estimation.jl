using LinearAlgebra
using DataFrames
using PrettyTables

# constants
v_1 = 0.933
v_2 = 0.917
δ_1 = 0

function h(x)
    δ_2 = x[1]
    t = x[2]

    return [
        t * v_1 * v_2 * B_12 * sin(δ_1 - δ_2)
        (v_2 * v_1 / t) * B_21 * sin(δ_2 - δ_1)
        (-v_2 * v_1 / t) * B_21 * cos(δ_2 - δ_1) + (v_2 / t)^2 * B_21
    ]

    return z
end

# susceptance matrix entries
B_12 = B_21 = 8

make_fun_B_subscripts(B)

σ = 0.025# 2.5% standard deviation of error
W = Diagonal(ones(3) .* (σ^2))

# measurements
Pᵐ₁₂ = 0.245
Pᵐ₂₁ = -0.240
Qᵐ₂₁ = 0.170
z = [Pᵐ₁₂, Pᵐ₂₁, Qᵐ₂₁]

# x is [δ_2, t] (where t is tap ratio)
# array of x's
arr_x = [[0.0, 1]]

num_iterations=2
for i in 1:num_iterations
    x = arr_x[i]
    δ_2 = x[1]
    t = x[2]

    H = [-t*v_1*v_2*B_12*cos(δ_1 - δ_2) v_1*v_2*B_12*sin(δ_1 - δ_2)
        (v_2*v_1/t)*B_21*cos(δ_2 - δ_1) (-v_2*v_1/t^2)*B_21*sin(δ_2 - δ_1)
        (v_2*v_1/t)*B_21*sin(δ_2 - δ_1) (v_2*v_1/t^2)*B_21*cos(δ_2 - δ_1)-((2*v_2^2)/t^3)*B_21
    ]


    x_new = x + ((H' * W * H)^-1) * (H' * W * (z - h(x)))
    push!(arr_x, x_new)
end

# display results
df = DataFrame(Iteration=["flat start", (1:num_iterations)...], δ₂=[xx[1] for xx ∈ arr_x], t=[xx[2] for xx ∈ arr_x])
header = (["iteration", "δ₂", "t"], ["", "radians", "tap setting"])
pretty_table(df, header=header, header_crayon=crayon"yellow bold")
