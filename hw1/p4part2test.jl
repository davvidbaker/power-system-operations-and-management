using LinearAlgebra
using DataFrames

B_mat = [
    -18 10 8;
    10 -22 12;
    8 12 -20]
B_P = [22 -12;
    -12 20]
B_P_inv = inv(B_P)

# converts actual index to one-based (already in Julia)
function B(row, col)
    return B_mat[row, col]
end

# known variables
V_1 = 1.02
V_2 = 1.01
V_3 = 1.0
P_2 = 0.7
P_3 = -2

# flat start
deltas = [[0.0, 0.0]]

POWER_TOLERANCE = 1e-2

i = 0
while true
    i += 1
    d2 = deltas[end][1]  # Julia is 1-indexed
    d3 = deltas[end][2]

    matrix_A = B_P_inv * inv(Diagonal([V_2, V_3]))

    mismatch_P2 = P_2 - (V_2 * (V_1 * B(2, 1) * sin(d2) + V_3 * B(2, 3) * sin(d2 - d3)))
    mismatch_P3 = P_3 - (V_3 * (V_1 * B(3, 1) * sin(d3) + V_2 * B(3, 2) * sin(d3 - d2)))
    mismatch_P = [mismatch_P2; mismatch_P3]

    d = reshape(deltas[end], 2, 1)
    new_deltas = d .+ matrix_A * mismatch_P

    push!(deltas, vec(new_deltas))

    # convergence condition
    if abs(mismatch_P2) < POWER_TOLERANCE && abs(mismatch_P3) < POWER_TOLERANCE
        break
    end
end

println("took $i iterations to converge")


df = DataFrame("angle for bus 2 [radians]" => [xx[1] for xx in deltas[2:end]],
    "angle for bus 3 [radians]" => [xx[2] for xx in deltas[2:end]]
)

d2 = deltas[end][1]
d3 = deltas[end][2]
Q_sync_condenser = 0.5 + -V_3 * (
    V_1 * B(1, 3) * cos(d3) + V_2 * B(2, 3) * cos(d3 - d2) + V_3 * B(3, 3)
)

println("Q_sync_condenser: ", Q_sync_condenser)

df