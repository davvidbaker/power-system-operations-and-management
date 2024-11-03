using PrettyTables
using DataFrames

G = [1, 2]
a = [115.2, 265.6]
b = [28.7, 25.1]
c = [0.025, 0.012]

function check_for_convergence(x_arr)
    cur = x_arr[end]
    prev = x_arr[end-1]
    for i in eachindex(cur)
        if abs(cur[i] - prev[i]) > 1e-6
            return false
        end
    end
    return true
end

function solve_economic_dispatch(Δ_p=0)

    P_d = 382 + Δ_p

    dq_dp1(p1, p2) = 0.008 + 0.0002p1 + 0.00002p2
    dq_dp2(p1, p2) = 0.0102 + 0.0001p2 + 0.00002p1

    # losses
    q(p1, p2) = 0.008p1 + 0.0001p1^2 + 0.0102p2 + 0.00005p2^2 + 0.00002p1 * p2

    f1(p1, p2, λ) = b[1] + 2c[1] * p1 - λ * (1 - dq_dp1(p1, p2))
    f2(p1, p2, λ) = b[2] + 2c[2] * p2 - λ * (1 - dq_dp2(p1, p2))
    f3(p1, p2) = p1 + p2 - q(p1, p2) - P_d


    # we start with our solution to fixed loss economic dispatch
    # shape of x is [p1,p2,λ]
    x_arr = [[76.48, 309.34, 32.52]]

    iteration = 1
    while true
        x = (p1, p2, λ) = x_arr[end]

        J = [
            2c[1]+0.0002λ 0.00002λ dq_dp1(p1, p2)-1
            0.00002λ 2c[2]+0.0001λ dq_dp2(p1, p2)-1
            1-dq_dp1(p1, p2) 1-dq_dp2(p1, p2) 0
        ]

        F = [f1(p1, p2, λ); f2(p1, p2, λ); f3(p1, p2)]

        x_new = x - (J^-1) * F
        push!(x_arr, x_new)
        if (check_for_convergence(x_arr))
            println("converged in $iteration iterations")
            break
        end
        iteration += 1
    end

    df = DataFrame(
        Iteration=["fixed losses starting point", 1:iteration...],
        p1=[x[1] for x ∈ x_arr],
        p2=[x[2] for x ∈ x_arr],
        λ=[x[3] for x ∈ x_arr]
    )
    header = (["iteration", "p₁", "p₂", "λ"], ["", "MW", "MW", "\$/MW"])
    pretty_table(df, header=header, header_crayon=crayon"yellow bold")
    return x_arr[end]
end

(p1, p2, λ) = solve_economic_dispatch()
(p1_larger_load, p2_larger_load, λ) = solve_economic_dispatch(1) # incrementing the load by 1 MW to get participation factors

pf_1 = p1_larger_load - p1
pf_2 = p2_larger_load - p2

println("Participation factor for g1: $(round(pf_1, digits=3))")
println("Participation factor for g2: $(round(pf_2, digits=3))")