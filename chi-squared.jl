# This was for a quiz

using Distributions

# Set the degrees of freedom
dof = 15

# Create a chi-squared distribution with 15 degrees of freedom
chi2_dist = Chisq(dof)

# Example chi-squared test statistic (you can replace this with your actual test statistic)
chi2_stat = 24.5

# Calculate the p-value (1 - CDF of the chi-squared distribution at chi2_stat)
p_value = 1 - cdf(chi2_dist, chi2_stat)

println("Chi-squared statistic: ", chi2_stat)
println("Degrees of freedom: ", dof)
println("p-value: ", p_value)