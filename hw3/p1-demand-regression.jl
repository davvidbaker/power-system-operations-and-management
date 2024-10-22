using DataFrames, GLM, StatsModels
using Statistics
using Plots

demand_column_name = "peak annual demand MW"
demands = [6197, 6337, 7411, 7940, 8473]
weight(t) = 0.7^(T - t)
weights = weight.(1:5)
df = DataFrame(year=1:5, d=demand)
years = df[!, "year"]

plot(years, df[!, "d"],
    label="peak annual demand",
    ylabel="MW",
    xlabel="year",
    ylims=[0, 9000]
)

ols = lm(@formula(d ~ year), df)

d_predicted = predict(ols, DataFrame(year=1:6))
plot!(1:6, d_predicted, label="linear regression fit")

println(coeftable(ols))
println("forecasted peak demand in year 6: $(round(Int,d_predicted[6])) MW")

# OR, if we were meant to do this more by hand...
x = years
y = demands
x_mean = mean(x)
y_mean = mean(y)
N = length(years)

slope = sum((x[i] - x_mean) * (y[i] - y_mean) for i ∈ 1:N) / sum((x[i] - x_mean)^2 for i ∈ 1:N)
intercept = y_mean - slope*x_mean