import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime
import seaborn as sns

# Set paths
homepath = "D:/PhD/UrbanClimate paper/Analysis/R_wd"
data_file = f"{homepath}/alldataFinal.csv"

# Read the cleaned data
alldata_times = pd.read_csv(data_file)

# Convert date and time columns to appropriate formats
alldata_times['chrondate'] = pd.to_datetime(alldata_times['chrondate']).dt.date
alldata_times['chrontimes'] = pd.to_datetime(alldata_times['chrontimes']).dt.time

# Convert season and diurnal to categorical
alldata_times['season'] = alldata_times['season'].astype('category')
alldata_times['diurnal'] = alldata_times['diurnal'].astype('category')

# Calculate daily averages and standard deviations
unique_dates = alldata_times['chrondate'].unique()
unique_locations = alldata_times['location'].unique()

# Create a DataFrame for daily data
daily_data = pd.DataFrame([(date, loc) for date in unique_dates for loc in unique_locations],
                          columns=['chrondate', 'location'])

# Add season
daily_data['season'] = daily_data['chrondate'].map(
    lambda date: alldata_times.loc[alldata_times['chrondate'] == date, 'season'].iloc[0]
)

# Calculate daily averages and standard deviations
for _, row in daily_data.iterrows():
    date = row['chrondate']
    location = row['location']
    filtered_data = alldata_times[(alldata_times['chrondate'] == date) & (alldata_times['location'] == location)]
    daily_data.loc[(daily_data['chrondate'] == date) & (daily_data['location'] == location), 'daily_av_t'] = filtered_data['temp'].mean()
    daily_data.loc[(daily_data['chrondate'] == date) & (daily_data['location'] == location), 'daily_av_h'] = filtered_data['humidity'].mean()
    daily_data.loc[(daily_data['chrondate'] == date) & (daily_data['location'] == location), 'daily_sd_t'] = filtered_data['temp'].std()
    daily_data.loc[(daily_data['chrondate'] == date) & (daily_data['location'] == location), 'daily_sd_h'] = filtered_data['humidity'].std()

# Remove rows with missing data
daily_data.dropna(inplace=True)

# Calculate annual averages and standard deviations per location
annual_stats = daily_data.groupby('location').agg(
    annual_t=('daily_av_t', 'mean'),
    annual_h=('daily_av_h', 'mean'),
    sd_annual_t=('daily_av_t', 'std'),
    sd_annual_h=('daily_av_h', 'std')
).reset_index()

# Merge annual stats back to daily data
daily_data = daily_data.merge(annual_stats, on='location', how='left')

# Save results
daily_data.to_csv(f"{homepath}/daily_stats_cleaned.csv", index=False)

# Plotting daily temperatures
plt.figure(figsize=(12, 6))
for loc in unique_locations:
    loc_data = daily_data[daily_data['location'] == loc]
    plt.plot(loc_data['chrondate'], loc_data['daily_av_t'], label=f'Location {loc}')
plt.xlabel('Date')
plt.ylabel('Daily Average Temperature (°C)')
plt.title('Daily Average Temperature by Location')
plt.legend()
plt.grid()
plt.show()

# Plotting daily humidity
plt.figure(figsize=(12, 6))
for loc in unique_locations:
    loc_data = daily_data[daily_data['location'] == loc]
    plt.plot(loc_data['chrondate'], loc_data['daily_av_h'], label=f'Location {loc}')
plt.xlabel('Date')
plt.ylabel('Daily Average Humidity (%)')
plt.title('Daily Average Humidity by Location')
plt.legend()
plt.grid()
plt.show()

# Save annual stats
annual_stats.to_csv(f"{homepath}/annual_stats.csv", index=False)

# Plot annual temperature statistics
plt.figure(figsize=(10, 5))
sns.barplot(data=annual_stats, x='location', y='annual_t', palette='viridis', ci=None)
plt.errorbar(annual_stats['location'], annual_stats['annual_t'], yerr=annual_stats['sd_annual_t'], fmt='o', color='red')
plt.title('Annual Temperature (Mean and SD) by Location')
plt.ylabel('Temperature (°C)')
plt.xlabel('Location')
plt.xticks(rotation=45)
plt.grid(axis='y')
plt.show()

# Plot annual humidity statistics
plt.figure(figsize=(10, 5))
sns.barplot(data=annual_stats, x='location', y='annual_h', palette='coolwarm', ci=None)
plt.errorbar(annual_stats['location'], annual_stats['annual_h'], yerr=annual_stats['sd_annual_h'], fmt='o', color='blue')
plt.title('Annual Humidity (Mean and SD) by Location')
plt.ylabel('Humidity (%)')
plt.xlabel('Location')
plt.xticks(rotation=45)
plt.grid(axis='y')
plt.show()
