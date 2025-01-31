import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from itertools import product

# Set paths
homepath = "C:/Users/best004/OneDrive - Wageningen University & Research/PhD/RQ - ITC/Analysis/R_wd/Nina"
data_file = f"{homepath}/alldataFINAL.csv"

# Load data
alldata = pd.read_csv(data_file)

# Format columns
alldata['chrondate'] = pd.to_datetime(alldata['chrondate'])
alldata['chrontimes'] = pd.to_datetime(alldata['chrontimes'], format='%H:%M:%S').dt.hour
alldata['season'] = alldata['season'].astype('category')
alldata['diurnal'] = alldata['diurnal'].astype('category')
alldata['location'] = alldata['location'].astype('category')

# Unique times, locations, and seasons
chrontimes = sorted(alldata['chrontimes'].unique())
locations = sorted(alldata['location'].unique())
seasons = ["dry", "wet", "all year", "Oct21", "MJ22"]

# Create DataFrame for hourly stats
rows = list(product(chrontimes, locations, seasons))
hourly_data = pd.DataFrame(rows, columns=['chrontimes', 'location', 'season'])
hourly_data['meanT'] = np.nan
hourly_data['sdT'] = np.nan
hourly_data['meanH'] = np.nan
hourly_data['sdH'] = np.nan

# Calculate hourly stats
for index, row in hourly_data.iterrows():
    time, location, season = row['chrontimes'], row['location'], row['season']
    if season == "all year":
        subset = alldata[(alldata['chrontimes'] == time) & (alldata['location'] == location)]
    elif season == "Oct21":
        subset = alldata[(alldata['chrontimes'] == time) & (alldata['location'] == location) & (alldata['chrondate'].dt.month == 10)]
    elif season == "MJ22":
        subset = alldata[(alldata['chrontimes'] == time) & (alldata['location'] == location) & 
                         (alldata['chrondate'] > "2022-05-14") & (alldata['chrondate'] < "2022-06-16")]
    else:
        subset = alldata[(alldata['chrontimes'] == time) & (alldata['location'] == location) & (alldata['season'] == season)]

    hourly_data.loc[index, 'meanT'] = subset['temp'].mean(skipna=True)
    hourly_data.loc[index, 'sdT'] = subset['temp'].std(skipna=True)
    hourly_data.loc[index, 'meanH'] = subset['humidity'].mean(skipna=True)
    hourly_data.loc[index, 'sdH'] = subset['humidity'].std(skipna=True)

# Save hourly data
hourly_data.to_csv("alldataperhour.csv", index=False)

# Combined data for all locations
combined_data = hourly_data.groupby(['chrontimes', 'season']).agg(
    meanT=('meanT', 'mean'),
    sdT=('sdT', 'mean'),
    meanH=('meanH', 'mean'),
    sdH=('sdH', 'mean')
).reset_index()

# Averages
seasonal_means = combined_data.groupby('season').agg(
    avg_temp=('meanT', 'mean'),
    avg_humidity=('meanH', 'mean')
)
print(seasonal_means)

# Function to plot diurnal dynamics
def plot_diurnal(data, x_col, y_col, y_label, title, ylim, season_filter, filename):
    plt.figure(figsize=(10, 6))
    for location in locations:
        subset = data[(data['season'] == season_filter) & (data['location'] == location)]
        plt.plot(subset[x_col], subset[y_col], label=location)
    plt.title(title)
    plt.xlabel('Time of Day')
    plt.ylabel(y_label)
    plt.ylim(ylim)
    plt.legend(loc='upper right', fontsize='small')
    plt.grid()
    plt.savefig(filename, format='pdf')
    plt.show()

# Generate plots for each core season
plot_diurnal(hourly_data, 'chrontimes', 'meanT', 'Temperature (°C)', 'Mean Temperature (Wet Season)', (20, 40), 'MJ22', 'mean_temp_wet.pdf')
plot_diurnal(hourly_data, 'chrontimes', 'meanT', 'Temperature (°C)', 'Mean Temperature (Dry Season)', (20, 40), 'Oct21', 'mean_temp_dry.pdf')
plot_diurnal(hourly_data, 'chrontimes', 'sdT', 'Temperature SD (°C)', 'SD of Temperature (Wet Season)', (0, 5), 'MJ22', 'sd_temp_wet.pdf')
plot_diurnal(hourly_data, 'chrontimes', 'sdT', 'Temperature SD (°C)', 'SD of Temperature (Dry Season)', (0, 5), 'Oct21', 'sd_temp_dry.pdf')

plot_diurnal(hourly_data, 'chrontimes', 'meanH', 'Humidity (%)', 'Mean Humidity (Wet Season)', (40, 100), 'MJ22', 'mean_humidity_wet.pdf')
plot_diurnal(hourly_data, 'chrontimes', 'meanH', 'Humidity (%)', 'Mean Humidity (Dry Season)', (40, 100), 'Oct21', 'mean_humidity_dry.pdf')
plot_diurnal(hourly_data, 'chrontimes', 'sdH', 'Humidity SD (%)', 'SD of Humidity (Wet Season)', (0, 20), 'MJ22', 'sd_humidity_wet.pdf')
plot_diurnal(hourly_data, 'chrontimes', 'sdH', 'Humidity SD (%)', 'SD of Humidity (Dry Season)', (0, 20), 'Oct21', 'sd_humidity_dry.pdf')
