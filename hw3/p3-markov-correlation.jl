using Statistics
using Plots

years = 1:5
d = [6197.0, 6337.0, 7411.0, 7940.0, 8473.0]

numerator = mean(d[2:end] .* d[2:end]) # not sure if this should be 1:end or 2:end
denominator = mean(d[2:end] .* d[1:end-1])

a = numerator / denominator
println("a = $(round(a, digits=3))")

d_pred = [d[end]]
for i in 1:2
    d_t = a * d_pred[end]
    push!(d_pred, d_t)
end

d_pred_first = []
for i in 2:5
    push!(d_pred_first, a * d[i-1])
end

println("forecasted demand in year 6 = $(round(d_pred[2], digits=1)) MW")
println("forecasted demand in year 7 = $(round(d_pred[3], digits=1)) MW")

plt = plot(years, d,
    label="peak annual demand",
    ylabel="MW",
    xlabel="year",
)
# plot!(2:5, d_pred_first, label="asdf markov model forecast")
plot!(5:7, d_pred, label="markov model forecast")
display(plt)