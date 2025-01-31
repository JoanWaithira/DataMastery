import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import pearsonr
from itertools import combinations

# Set paths
homepath = "C://Users//SchwarzN//Surfdrive//outreach//publications//work-in-progress//LB_climateParamaribo//Data//"
data_file = f"{homepath}/Paramaribodropsall.csv"

# Load the data
alldata = pd.read_csv(data_file)

# Select relevant metrics
alldata_metric = alldata[[
    'elevation', 'dist.river', 'dist.commerc', 
    'buff10.lc.tg', 'buff10.lc.t', 'buff10.lc.i',
    'buff300.lc.tg', 'buff300.lc.t', 'buff300.lc.i',
    'mean.t.wet', 'mean.t.dry', 'mean.t.year', 'mean.t.oct21', 'mean.t.mj22',
    'mean.h.wet', 'mean.h.dry', 'mean.h.year',
    'min.t.wet.night', 'min.t.dry.night', 'min.t.oct21.night', 'min.t.mj22.night',
    'range.t.wet.night', 'range.t.dry.night', 'range.t.oct21.night', 'range.t.mj22.night',
    'max.t.10he', 'max.h.10he',
    'av_LSTsCOMP.wet', 'av_LSTsCOMP.dry'
]]

# Summary statistics
summary = alldata_metric.describe()

# Generate pairwise correlation plot
sns.pairplot(alldata_metric, kind='scatter', plot_kws={'alpha': 0.5})
plt.savefig("Correlations.pdf", format="pdf", bbox_inches="tight")

# Compute correlations for independent variables
independent_vars = alldata[[
    'elevation', 'dist.river', 'dist.commerc',
    'buff10.lc.tg', 'buff10.lc.t', 'buff10.lc.i',
    'buff300.lc.tg', 'buff300.lc.t', 'buff300.lc.i'
]]

correlations = independent_vars.corr(method='pearson')
correlations.to_csv("independents.corrcoefficients.csv")

# p-values for correlations
p_values = pd.DataFrame(
    [[pearsonr(independent_vars[col1], independent_vars[col2])[1] 
      if col1 != col2 else np.nan
      for col2 in independent_vars.columns] for col1 in independent_vars.columns],
    index=independent_vars.columns, columns=independent_vars.columns
)
p_values.to_csv("independents.corrpvalues.csv")

# Mosaic plots and boxplots
def create_boxplots(data, x, y_columns, xlabel, folder=""):
    plt.figure(figsize=(10, len(y_columns) * 5))
    for i, col in enumerate(y_columns, 1):
        plt.subplot(len(y_columns), 1, i)
        sns.boxplot(x=x, y=col, data=data)
        plt.xlabel(xlabel)
        plt.ylabel(col)
        plt.title(f"{xlabel} vs {col}")
    plt.tight_layout()
    plt.savefig(f"{folder}/{xlabel}_boxplots.pdf", format="pdf")
    plt.close()

categorical_columns = ['spot.surface', 'buff10.surface', 'buff10.vegstr']
numeric_columns = [
    'elevation', 'dist.river', 'dist.commerc',
    'buff10.lc.i', 'buff10.lc.tg', 'buff10.lc.t',
    'buff300.lc.i', 'buff300.lc.tg', 'buff300.lc.t'
]

for cat_col in categorical_columns:
    create_boxplots(alldata, cat_col, numeric_columns, cat_col)

# Recode categorical variables
def recode_values(column, mapping):
    return column.replace(mapping)

recode_mapping = {
    'Impervious': 'Imp',
    'Vegetation': 'Veg',
    'Organic matter': 'Org m',
    'Bare with veg': 'B + v',
    'Impervious / bare': 'Imp + b',
    'Forest/trees': 'F + t'
}

for col in ['spot.surface', 'buff10.surface', 'buff10.vegstr']:
    if col in alldata.columns:
        alldata[col] = recode_values(alldata[col], recode_mapping)

# Save updated dataset
alldata.to_csv("Updated_Paramaribodropsall.csv", index=False)

# Dependent variable correlations
dependent_vars = alldata[[
    'mean.t.year', 'mean.t.oct21', 'mean.t.mj22',
    'mean.h.year', 'mean.h.oct21', 'mean.h.mj22',
    'min.t.year.night', 'min.t.oct21.night', 'min.t.mj22.night',
    'range.t.year.night', 'range.t.oct21.night', 'range.t.mj22.night',
    'max.t.10he', 'max.h.10he',
    'av_LSTsCOMP.wet', 'av_LSTsCOMP.dry'
]]

dep_corr = dependent_vars.corr(method='pearson')
dep_corr.to_csv("dependents.corrcoefficients.csv")

dep_p_values = pd.DataFrame(
    [[pearsonr(dependent_vars[col1], dependent_vars[col2])[1] 
      if col1 != col2 else np.nan
      for col2 in dependent_vars.columns] for col1 in dependent_vars.columns],
    index=dependent_vars.columns, columns=dependent_vars.columns
)
dep_p_values.to_csv("dependents.corrpvalues.csv")
