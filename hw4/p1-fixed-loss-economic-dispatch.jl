using JuMP
import GAMS
using DataFrames
G = [1, 2]
a = [115.2, 265.6]
b = [28.7, 25.1]
c = [0.025, 0.012]

P_d = 382
P_loss = 0.01 * P_d

λ = ((P_d + P_loss) + sum(b[g] / (2c[g]) for g ∈ G)) / sum(1 / (2c[g]) for g ∈ G)
println("λ = $(round(λ, digits=2))")
println("")

for g ∈ G
    p = (λ - b[g]) / (2c[g])
    println("p[$g] = $(round(p, digits=2)) MW")
end

model = Model(GAMS.Optimizer)
set_optimizer_attribute(model, "solver", "CPLEX")

p_max = [180, 315]

@variable(model, P[G] ≥ 0)
@objective(model, Min, sum(a[g] + b[g] * P[g] + c[g] * P[g]^2 for g ∈ G))
@constraint(model, sum(P[g] for g ∈ G) == P_d + P_loss)
# could also add max gen constraint
# @constraint(model, [g ∈ G], P[g] ≤ p_max[g])

optimize!(model)

v = all_variables(model)
df = DataFrame(
    variable=v,
    val=value.(v),
)
show(df, eltypes=false)
println("\n\n\tObjective value: \$$(objective_value(model))")