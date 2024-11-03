using JuMP
import GAMS
using DataFrames



function calculate_economic_dispatch(P_d, G, a, b, c)
    λ = ((P_d) + sum(b[i] / (2c[i]) for (i, g) ∈ enumerate(G))) / sum(1 / (2c[i]) for (i, g) ∈ enumerate(G))
    println("λ = $(round(λ, digits=2))")
    println("")

    for (i, g) ∈ enumerate(G)
        p = (λ - b[i]) / (2c[i])
        println("p[$g] = $(round(p, digits=2)) MW")
    end
end

gens = 1:3
a = [6, 5, 3]
b = [0.5, 0.6, 0.4]
c = [0.0006, 0.0005, 0.0007]
calculate_economic_dispatch(500, gens, a, b, c)
calculate_economic_dispatch(800, gens, a, b, c)

# recalculate without first unit
calculate_economic_dispatch(800 - 250, gens[2:end], a[2:end], b[2:end], c[2:end])


function solve_economic_dispatch(P_d)

    model = Model(GAMS.Optimizer)
    set_optimizer_attribute(model, "solver", "CPLEX")

    p_max = [250, 250, 350]
    p_min = [100, 100, 100]

    @variable(model, P[G] ≥ 0)
    @objective(model, Min, sum(a[g] + b[g] * P[g] + c[g] * P[g]^2 for g ∈ gens))
    @constraint(model, sum(P[g] for g ∈ gens) == P_d)
    # gen constraints
    @constraint(model, [g ∈ gens], P[g] ≤ p_max[g])
    @constraint(model, [g ∈ gens], P[g] ≥ p_min[g])

    optimize!(model)

    v = all_variables(model)
    df = DataFrame(
        variable=v,
        val=value.(v),
    )
    show(df, eltypes=false)
    println("\n\n\tObjective value: \$$(objective_value(model))")
end

solve_economic_dispatch(500)
solve_economic_dispatch(800)