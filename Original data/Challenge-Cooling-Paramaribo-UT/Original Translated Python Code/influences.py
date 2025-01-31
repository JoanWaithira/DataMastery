import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import pearsonr, kruskal
from statsmodels.stats.multitest import multipletests

# Set paths
homepath = "C://Users//SchwarzN//Surfdrive//outreach//publications//workInProgress//LB_climateParamaribo//Data//"
data_file = f"{homepath}/Paramaribodropsall.csv"

# Load the data
alldata = pd.read_csv(data_file)

# Select relevant metric variables
alldata_metric = alldata[[
    'elevation', 'dist.commerc',
    'buff10.lc.t', 'buff10.lc.i',
    'buff300.lc.t', 'buff300.lc.i',
    'mean.t.year', 'mean.h.year',
    'min.t.oct21.night', 'min.t.mj22.night',
    'range.t.oct21.night', 'range.t.mj22.night',
    'av_LSTsCOMP.dry'
]]

# Summary statistics
summary_stats = alldata_metric.describe()

# Generate correlation matrix and save as a PDF
sns.pairplot(alldata_metric, kind='scatter', plot_kws={'alpha': 0.6})
plt.savefig("Influences.pdf", format='pdf', bbox_inches="tight")
plt.show()

# Correlation analysis
def calculate_correlation(data):
    corr_matrix = data.corr(method='pearson')
    p_values = pd.DataFrame(
        [[pearsonr(data[col1], data[col2])[1] if col1 != col2 else np.nan
          for col2 in data.columns] for col1 in data.columns],
        columns=data.columns, index=data.columns
    )
    return corr_matrix, p_values

corr_coefficients, corr_p_values = calculate_correlation(alldata_metric)

# Adjust p-values using Hommel method
p_values_flattened = corr_p_values.unstack().dropna()
adjusted_pvals = multipletests(p_values_flattened, method='hommel')[1]
corr_p_values_adjusted = pd.DataFrame(
    adjusted_pvals.reshape(corr_p_values.shape),
    columns=corr_p_values.columns,
    index=corr_p_values.index
)

# Save correlation results
corr_coefficients.to_csv("influences.corrcoefficients.csv")
corr_p_values_adjusted.to_csv("influences.corrpvalues.csv")

# Boxplots for categorical variables
def plot_boxplots(data, category_col, value_cols, filename_prefix):
    plt.figure(figsize=(10, len(value_cols) * 4))
    for i, col in enumerate(value_cols, start=1):
        plt.subplot(len(value_cols), 1, i)
        sns.boxplot(x=category_col, y=col, data=data)
        plt.title(f"{col} by {category_col}")
        plt.xlabel(category_col)
        plt.ylabel(col)
    plt.tight_layout()
    plt.savefig(f"{filename_prefix}.pdf", format='pdf')
    plt.close()

# Define categorical variables and target columns
categorical_vars = ['buff10.vegstr', 'spot.surface']
value_columns = [
    'mean.t.year', 'mean.h.oct21', 'mean.h.mj22',
    'min.t.oct21.night', 'min.t.mj22.night',
    'range.t.oct21.night', 'range.t.mj22.night',
    'av_LSTsCOMP.dry'
]

for cat_var in categorical_vars:
    plot_boxplots(alldata, cat_var, value_columns, f"Influences_boxplots_{cat_var}")

# Kruskal-Wallis tests for categorical variables
def kruskal_tests(data, category_col, value_cols):
    results = {}
    for col in value_cols:
        stat, p_value = kruskal(*[group[col].dropna() for name, group in data.groupby(category_col)])
        results[col] = {'stat': stat, 'p_value': p_value}
    return pd.DataFrame(results).T

kruskal_results_buff10 = kruskal_tests(alldata, 'buff10.vegstr', value_columns)
kruskal_results_spot = kruskal_tests(alldata, 'spot.surface', value_columns)

# Adjust p-values for multiple comparisons
for kruskal_df in [kruskal_results_buff10, kruskal_results_spot]:
    kruskal_df['p_value_adj'] = multipletests(kruskal_df['p_value'], method='hommel')[1]

# Save Kruskal-Wallis test results
kruskal_results_buff10.to_csv("kruskal_results_buff10.csv")
kruskal_results_spot.to_csv("kruskal_results_spot.csv")

# Example: Simple linear regression
from statsmodels.formula.api import ols
import statsmodels.api as sm

model = ols('mean_t_year ~ buff10_lc_t', data=alldata.rename(columns=lambda x: x.replace('.', '_'))).fit()
print(model.summary())

# Save model coefficients
model_summary = model.summary2().tables[1]
model_summary.to_csv("linear_model_results.csv")
