using JuMP
import GAMS
using DataFrames
using HiGHS
using Ipopt

G = [1, 2]
a = [115.2, 265.6]
b = [28.7, 25.1]
c = [0.025, 0.012]
P_d = 382

model = Model(Ipopt.Optimizer)
p_max = [180, 315]

@variable(model, P[G] ≥ 0)
@objective(model, Min, sum(a[g] + b[g] * P[g] + c[g] * P[g]^2 for g ∈ G))
q_loss = 0.008P[1] + 0.0001P[1]^2 + 0.0102P[2] + 0.00005P[2]^2 + 0.00002P[1] * P[2]

@constraint(model, sum(P[g] for g ∈ G) == P_d + q_loss)
# could also add max gen constraint
@constraint(model, [g ∈ G], P[g] ≤ p_max[g])

optimize!(model)

v = all_variables(model)
df = DataFrame(
    variable=v,
    val=value.(v),
)
show(df, eltypes=false)
println("\n\n\tObjective value: \$$(objective_value(model))")

for c in all_constraints(model, include_variable_in_set_constraints=false)
    println(c)
    println("dual: $(dual(c)) \n\n")
end