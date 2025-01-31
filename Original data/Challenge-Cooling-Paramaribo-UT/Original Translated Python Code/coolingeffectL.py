import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Set paths
homepath = "D:/PhD/UrbanClimate paper/Analysis/R_wd"
data_file = f"{homepath}/alldataFinal.csv"

# Load the data
alldata_times = pd.read_csv(data_file)

# Process date and time
alldata_times['chrondate'] = pd.to_datetime(alldata_times['chrondate'])
alldata_times['chrontimes'] = pd.to_datetime(alldata_times['chrontimes'], format='%H:%M:%S').dt.hour

# Convert categorical columns
alldata_times['season'] = alldata_times['season'].astype('category')
alldata_times['diurnal'] = alldata_times['diurnal'].astype('category')

# Create hourly temperature and humidity averages
chrontimes = np.arange(24)
locations = alldata_times['location'].unique()

temp_hours = pd.DataFrame([(time, loc) for time in chrontimes for loc in locations], columns=['chrontimes', 'location'])

# Calculate mean temperatures and humidity for annual and seasonal
def calculate_means(data, time, location, column, condition=None):
    filtered = data[(data['chrontimes'] == time) & (data['location'] == location)]
    if condition:
        filtered = filtered[filtered['season'] == condition]
    return filtered[column].mean()

for index, row in temp_hours.iterrows():
    time, location = row['chrontimes'], row['location']
    temp_hours.loc[index, 'meanT_year'] = calculate_means(alldata_times, time, location, 'temp')
    temp_hours.loc[index, 'meanH_year'] = calculate_means(alldata_times, time, location, 'humidity')
    temp_hours.loc[index, 'meanT_dry'] = calculate_means(alldata_times, time, location, 'temp', 'dry')
    temp_hours.loc[index, 'meanT_wet'] = calculate_means(alldata_times, time, location, 'temp', 'wet')
    temp_hours.loc[index, 'meanH_dry'] = calculate_means(alldata_times, time, location, 'humidity', 'dry')
    temp_hours.loc[index, 'meanH_wet'] = calculate_means(alldata_times, time, location, 'humidity', 'wet')

# Calculate delta T for annual, dry, and wet seasons
def calculate_delta(temp_hours, avg_col, ref_col):
    return temp_hours.groupby('chrontimes').apply(
        lambda x: x[avg_col].mean() - x.set_index('location')[ref_col]
    ).unstack()

cooling_annual = calculate_delta(temp_hours, 'meanT_year', 'meanT_year')
cooling_dry = calculate_delta(temp_hours, 'meanT_dry', 'meanT_dry')
cooling_wet = calculate_delta(temp_hours, 'meanT_wet', 'meanT_wet')

# Plotting function for delta T
def plot_delta_t(cooling_data, title):
    plt.figure(figsize=(10, 6))
    for location in locations:
        plt.plot(cooling_data.index, cooling_data[location], label=f'Location {location}')
    plt.axhline(0, color='black', linestyle='--', linewidth=0.8)
    plt.title(title)
    plt.xlabel('Time of Day')
    plt.ylabel('Delta T (°C)')
    plt.xticks(np.arange(0, 24, step=2))
    plt.legend(loc='best', fontsize='small')
    plt.grid(True)
    plt.show()

# Plot delta T for annual, dry, and wet seasons
plot_delta_t(cooling_annual, 'Annual Cooling Effect')
plot_delta_t(cooling_dry, 'Dry Season Cooling Effect')
plot_delta_t(cooling_wet, 'Wet Season Cooling Effect')

# Scatter plot of temperatures at 6 AM and 1 PM
def scatter_6am_1pm(data, temp_col_6am, temp_col_1pm, title):
    plt.figure(figsize=(6, 6))
    plt.scatter(data[temp_col_1pm], data[temp_col_6am], s=100, c='blue', alpha=0.5)
    plt.title(title)
    plt.xlabel('1 PM Temperature (°C)')
    plt.ylabel('6 AM Temperature (°C)')
    plt.grid(True)
    plt.show()

scatter_6am_1pm(temp_hours, 'meanT_year', 'meanT_dry', 'Dry Season 6 AM vs 1 PM')

# Plot humidity trends
def plot_humidity_trends(data):
    plt.figure(figsize=(10, 6))
    for location in locations:
        plt.plot(data.index, data[location], label=f'Location {location}')
    plt.axhline(0, color='black', linestyle='--', linewidth=0.8)
    plt.title('Mean Relative Humidity')
    plt.xlabel('Time of Day')
    plt.ylabel('Relative Humidity (%)')
    plt.xticks(np.arange(0, 24, step=2))
    plt.legend(loc='best', fontsize='small')
    plt.grid(True)
    plt.show()

humidity_data = calculate_delta(temp_hours, 'meanH_year', 'meanH_year')
plot_humidity_trends(humidity_data)
