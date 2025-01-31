import pandas as pd
import numpy as np
import scipy.stats as stats
import statsmodels.stats.multitest as smm
import matplotlib.pyplot as plt
import seaborn as sns

# Load the dataset
file_path = r"C:\Users\joanw\Downloads\pearson-kruskal-tests (1)\pearson-kruskal-tests\UTwentedropsall.csv"  # Replace with your file path
df = pd.read_csv(file_path, delimiter=';')

# Define variable groups
location_vars = ['elevation', 'dist.river', 'dist.commerc', 'buff10.lc.tg', 'buff10.lc.t',
                 'buff10.lc.i', 'buff300.lc.tg', 'buff300.lc.t', 'buff300.lc.i']

micro_climate_vars = ['mean.t.year', 'mean.t.july', 'mean.t.jan', 'mean.h.year', 'mean.h.july', 
                      'mean.h.jan', 'min.t.year.night', 'min.t.july.night', 'min.t.jan.night', 
                      'range.t.year.night', 'range.t.july.night', 'range.t.jan.night', 
                      'max.t.10he', 'max.h.10he', 'av_LSTsCOMP.winter', 'av_LSTsCOMP.summer']

independent_vars = ['elevation', 'dist.commerc', 'buff10.lc.t', 'buff300.lc.t', 'buff300.lc.i', 
                    'mean.t.year', 'mean.h.july', 'mean.h.jan', 'min.t.july.night', 
                    'min.t.jan.night', 'range.t.july.night', 'range.t.jan.night', 
                    'max.h.10he', 'av_LSTsCOMP.summer']

# Pearson correlation and Hommel adjustment
def pearson_correlation(df, variables):
    corr_matrix = df[variables].corr(method='pearson')
    p_values = pd.DataFrame(np.zeros_like(corr_matrix), columns=variables, index=variables)

    for i in range(len(variables)):
        for j in range(i+1, len(variables)):
            r, p = stats.pearsonr(df[variables[i]].dropna(), df[variables[j]].dropna())
            corr_matrix.iloc[i, j] = corr_matrix.iloc[j, i] = r
            p_values.iloc[i, j] = p_values.iloc[j, i] = p

    # Apply Hommel adjustment
    p_values_array = p_values.to_numpy()[np.triu_indices(len(variables), k=1)]
    _, p_adjusted, _, _ = smm.multipletests(p_values_array, method='hommel')

    # Fill adjusted p-values into the dataframe
    upper_indices = np.triu_indices(len(variables), k=1)
    for idx, adj_p in zip(zip(*upper_indices), p_adjusted):
        p_values.iloc[idx] = adj_p
        p_values.iloc[idx[::-1]] = adj_p  # Mirror lower triangle

    return corr_matrix, p_values

# Apply Pearson correlation
location_corr, location_pvals = pearson_correlation(df, location_vars)
micro_climate_corr, micro_climate_pvals = pearson_correlation(df, micro_climate_vars)
independent_corr, independent_pvals = pearson_correlation(df, independent_vars)

# Save results
location_corr.to_csv("location_correlation.csv")
location_pvals.to_csv("location_pvalues.csv")
micro_climate_corr.to_csv("micro_climate_correlation.csv")
micro_climate_pvals.to_csv("micro_climate_pvalues.csv")
independent_corr.to_csv("independent_correlation.csv")
independent_pvals.to_csv("independent_pvalues.csv")

# Define categorical variables
categorical_vars = ['spot.surface', 'buff10.vegstr']

# Perform Kruskal-Wallis tests
kruskal_results = []
for cat_var in categorical_vars:
    if cat_var in df.columns:
        for micro_var in micro_climate_vars:
            groups = [df[micro_var][df[cat_var] == cat].dropna() for cat in df[cat_var].unique()]
            # Ensure there is variability in at least one group
            if len(groups) > 1 and any(len(set(group)) > 1 for group in groups):
                try:
                    stat, p = stats.kruskal(*groups)
                    kruskal_results.append((cat_var, micro_var, stat, p))
                except ValueError as e:
                    print(f"Error with {micro_var} grouped by {cat_var}: {e}")

# Convert results to DataFrame
kruskal_df = pd.DataFrame(kruskal_results, columns=['Categorical Variable', 'Micro-climate Variable', 'Kruskal-Wallis Statistic', 'p-value'])

# Apply Hommel adjustment
p_values_kruskal = kruskal_df['p-value'].values
_, p_adjusted_kruskal, _, _ = smm.multipletests(p_values_kruskal, method='hommel')
kruskal_df['Adjusted p-value'] = p_adjusted_kruskal

# Save Kruskal-Wallis results
kruskal_df.to_csv("kruskal_wallis_results.csv")

# Generate box plots
plot_data = [
    ('mean.t.year', 'buff10.vegstr', 'Mean annual temp [C]', 'Vegetation structure 10 m buffer'),
    ('mean.h.summer', 'buff10.vegstr', 'Mean humidity summer [%]', 'Vegetation structure 10 m buffer'),
    ('min.t.summer.night', 'buff10.vegstr', 'Min night temp in Summer [°C]', 'Vegetation structure 10 m buffer'),
    ('range.t.summer.night', 'buff10.vegstr', 'Range of Min Night Temp in Summer [°C]', 'Vegetation structure 10 m buffer')
]

for y_var, x_var, y_label, x_label in plot_data:
    if y_var in df.columns and x_var in df.columns:
        plt.figure(figsize=(8, 6))
        sns.boxplot(x=df[x_var], y=df[y_var])
        plt.xlabel(x_label)
        plt.ylabel(y_label)
        plt.title(f"Boxplot of {y_label} by {x_label}")
        plt.xticks(rotation=45)
        plt.savefig(f"boxplot_{y_var}_vs_{x_var}.png", dpi=300, bbox_inches='tight')  # Save plot
        plt.show()
    else:
        print(f"Skipping plot for {y_var} vs {x_var}: Missing data.")