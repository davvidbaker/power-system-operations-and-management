using DataFrames, GLM, StatsModels
using Plots
using PrettyTables

years = 1981:1996
demands = Float64.([3179, 3694, 3981, 4672, 5158, 5361, 5803, 6152, 6279, 6664, 7004, 7215, 7503, 7657, 8149, 8491])

train_years = 1981:1988
train_d = demands[1:length(train_years)]

# have to start at 5 so you have t - 4 data available
df = DataFrame(
    y=train_years[5:end],
    d_t=train_d[5:end],
    d_t_1=train_d[4:end-1],
    d_t_2=train_d[3:end-2],
    d_t_3=train_d[2:end-3],
    d_t_4=train_d[1:end-4],
)

model = lm(@formula(d_t ~ d_t_1 + d_t_2 + d_t_3 + d_t_4), df)

predict(model, df)

pred_demands = train_d[1:4]
for (i, year) in enumerate(1985:1996)
    intercept, a, b, c, d = coef(model)
    d_next = (
        intercept
        + a * pred_demands[end]
        + b * pred_demands[end-1]
        + c * pred_demands[end-2]
        + d * pred_demands[end-3]
    )
    push!(pred_demands, d_next)
end


println("Model is")
println(model)

plt = plot(years[5:end], pred_demands[5:end], label="predicted", linewidth=3, opacity=0.5)
plot!(years, demands, label="actual", ylabel="peak load [GW]", xlabel="year")
display(plt)

df_answer = DataFrame(
    years=years, 
    actual=demands, 
    predicted=[missing, missing, missing, missing, pred_demands[5:end]...], 
    residuals=[missing, missing, missing, missing, (demands - pred_demands)[5:end]...]
)
plot(1989:1996, df_answer[9:16, "residuals"], xlabel="year", ylabel="residual value (MW)", legend=:none)
df_final = coalesce.(df_answer, "----")

header = (["years", "actual", "predicted", "residual"], ["", "MW", "MW", "MW"])
pretty_table(df_final, header=header, header_crayon=crayon"yellow bold")
