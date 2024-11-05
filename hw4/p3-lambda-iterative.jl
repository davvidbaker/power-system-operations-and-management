using PrettyTables
using DataFrames

G = [1, 2]
a = [115.2, 265.6]
b = [28.7, 25.1]
c = [0.025, 0.012]
P_d = 382

# initial guess as the answer from fixed loss ED
λ = 32.52

q(p1, p2) = 0.008p1 + 0.0001p1^2 + 0.0102p2 + 0.00005p2^2 + 0.00002p1 * p2

p1_arr = []
p2_arr = []
λ_arr = []
mismatch_arr = []

iteration = 0
while true
    iteration += 1
    push!(λ_arr, λ)

    A = [
        2c[1]+0.0002λ 0.00002λ
        0.00002λ 2c[2]+0.0001λ
    ]
    rhs = [λ - 0.008λ - b[1]
        λ - 0.0102λ - b[2]]

    p_new = (A^-1) * rhs

    p1 = p_new[1]
    p2 = p_new[2]

    push!(p1_arr, p1)
    push!(p2_arr, p2)

    mismatch = P_d + q(p1, p2) - (p1 + p2)
    push!(mismatch_arr, mismatch)

    if abs(mismatch) < 1e-3
        break
    end

    # update λ for next iteration
    λ = λ + 0.01 * mismatch
end
df = DataFrame(
    Iteration=["fixed losses starting point", 1:iteration-1...],
    λ=λ_arr,
    p1=p1_arr,
    p2=p2_arr,
    mismatch=mismatch_arr,
)
header = (["iteration", "λ", "p₁", "p₂", "mismatch"], ["", "\$/MW", "MW", "MW", "MW"])
pretty_table(df, header=header, header_crayon=crayon"yellow bold")
