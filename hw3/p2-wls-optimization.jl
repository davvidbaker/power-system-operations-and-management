using JuMP
import GAMS
using LinearAlgebra
using DataFrames
using Plots

function solve_wls(weights)
    model = Model(GAMS.Optimizer)
    set_optimizer_attribute(model, "solver", "CPLEX")
    # =============================================================
    # SETS
    years = 1:5
    # =============================================================
    # PARAMETERS
    measurements = [6197, 6337, 7411, 7940, 8473]
    # =============================================================
    # DECISION VARIABLES
    @variable(model, R[years]) # residual
    @variable(model, A) # intercept
    @variable(model, B) # slope
    # =============================================================
    # OBJECTIVE
    @objective(model, Min, sum(weights[i] * R[i]^2 for i ∈ years))
    # =============================================================
    # CONSTRAINTS
    for i ∈ years
        @constraint(model, R[i] == measurements[i] - (A + B * years[i]))
    end

    optimize!(model)

    v = all_variables(model)
    df = DataFrame(
        variable=name.(v),
        val=value.(v),
    )
    show(df, eltypes=false)

    demand_year_6 = value(A) + value(B) * 6
    println("\n\nIntercept (A): $(round(value(A), digits=1)), Slope (B): $(round(value(B), digits=1))")
    println("forecasted peak demand in year 6: $(round(demand_year_6, digits=1)) MW\n\n")
    return demand_year_6
end

weights = ones(length(years))
equal_weights_wls = solve_wls(weights)

T = 5
weight(t) = 0.7^(T - t)
weights = weight.(years)
weighted_wls = solve_wls(weights)

