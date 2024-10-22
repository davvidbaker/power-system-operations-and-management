using LinearAlgebra
using Plots

years = 1:5
measurements = [6197, 6337, 7411, 7940, 8473]
plot(years, measurements, label="demand")

## CLOSED FORM SOLUTION
# equal weights scenario
H = hcat(ones(5), years)
z = measurements
W = diagm(ones(5)) # weights

X = (H' * W * H)^-1 * H' * W * z
a = X[1]
b = X[2]
println("\n\nIntercept (A): $(round(a, digits=1)), Slope (B): $(round(b, digits=1))")
println("forecasted peak demand in year 6: $(round(a + b*6, digits=1)) MW\n\n")
plot!(years, [a + b * t for t ∈ years], label="equal weighted regression")

# weighted scenario
T = 5
weight(t) = 0.7^(T - t)
weights = weight.(years)
W = diagm(weights) # weights

X = (H' * W * H)^-1 * H' * W * z
a = X[1]
b = X[2]
println("\n\nIntercept (A): $(round(a, digits=1)), Slope (B): $(round(b, digits=1))")
println("forecasted peak demand in year 6: $(round(a + b*6, digits=1)) MW")
plot!(years, [a + b * t for t ∈ years], label="weighted regression")
