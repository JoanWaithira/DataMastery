import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Define the file paths
# homepath = "C:/Users/joanw/OneDrive - University of Twente/Desktop/R Code/Data"
data_file = "revised2.csv"

# Read the cleaned data
alldata_times = pd.read_csv(data_file, on_bad_lines='skip', delimiter=';', low_memory=False)


# Convert columns to appropriate data types
alldata_times['chrondate'] = pd.to_datetime(alldata_times['chrondate'], format='%m/%d/%y', errors='coerce')

# Ensure 'chrontimes' is in the correct format
alldata_times['chrontimes'] = pd.to_timedelta(alldata_times['chrontimes'].apply(lambda x: x + ':00' if isinstance(x, str) and len(x.split(':')) == 2 else x))

# Convert chrontimes to timedelta if it's not already
alldata_times['chrontimes'] = pd.to_timedelta(alldata_times['chrontimes'], errors='coerce')

# Ensure correct data types for categorical variables
alldata_times['season'] = alldata_times['season'].astype('category')
alldata_times['diurnal'] = alldata_times['diurnal'].astype('category')

# Convert 'temp' column to numeric, forcing errors to NaN
alldata_times['temp'] = pd.to_numeric(alldata_times['temp'], errors='coerce')

# Extract the hour from chrontimes for grouping
alldata_times['hour'] = alldata_times['chrontimes'].dt.seconds // 3600

# Calculate hourly average temperatures across days and locations
chrontime = list(range(24))
locations = alldata_times['location'].unique()

# Create a DataFrame with all combinations of chrontimes and locations
temp_hours = pd.DataFrame([(t, loc) for t in chrontime for loc in locations],
                          columns=['chrontimes', 'location'])

def assign_diurnal(row):
    if row['chrontimes'] in range(6, 17):  # 6 AM to 4 PM considered day
        return 'day'
    else:
        return 'night'

temp_hours['diurnal'] = temp_hours.apply(assign_diurnal, axis=1)

# Calculate annual mean temperature and humidity per hour
def calculate_means(row, alldata_times):
    # Ensure 'temp' is numeric, coercing errors to NaN
    alldata_times['temp'] = pd.to_numeric(alldata_times['temp'], errors='coerce')
    
    # Apply your existing logic to calculate the mean
    mask = (alldata_times['chrondate'] == row['chrondate']) & (alldata_times['hour'] == row['hour'])
    mean_temp = alldata_times.loc[mask, 'temp'].mean()
    mean_humidity = alldata_times.loc[mask, 'humidity'].mean()
    
    return mean_temp, mean_humidity


temp_hours[['meanT_year', 'meanH_year']] = temp_hours.apply(lambda row: calculate_means(row, alldata_times), axis=1)

# Seasonal mean temperature and humidity calculations
def calculate_seasonal_means(row, alldata, season):
    hour = row['chrontimes']
    location = row['location']
    mask = (alldata['hour'] == hour) & (alldata['location'] == location) & (alldata['season'] == season)
    mean_temp = alldata.loc[mask, 'temp'].mean()
    mean_humidity = alldata.loc[mask, 'humidity'].mean()
    return pd.Series([mean_temp, mean_humidity])

temp_hours[['meanT_summer', 'meanH_summer']] = temp_hours.apply(lambda row: calculate_seasonal_means(row, alldata_times, 'summer'), axis=1)
temp_hours[['meanT_winter', 'meanH_winter']] = temp_hours.apply(lambda row: calculate_seasonal_means(row, alldata_times, 'winter'), axis=1)

# Save processed data to a CSV (optional)
temp_hours.sort_values(by=['chrontimes'], inplace=True)
temp_hours.to_csv(f"hourly_temp_processed.csv", index=False)

# Print a summary of the results
print(temp_hours.head())

# Calculate delta T (Average T across as reference)
cooling_A = pd.DataFrame({'chrontimes': chrontime})

# Calculate average across drops per hour
def calculate_mean_across(hour, temp_hours):
    return temp_hours[temp_hours['chrontimes'] == hour]['meanT_year'].mean()

cooling_A['meanTacross'] = cooling_A['chrontimes'].apply(lambda x: calculate_mean_across(x, temp_hours))

# Calculate deltaT as meanTacross - dropT annual
def calculate_delta_T(hour, location, cooling_A, temp_hours):
    meanTacross = cooling_A.loc[cooling_A['chrontimes'] == hour, 'meanTacross'].values[0]
    filtered = temp_hours[(temp_hours['chrontimes'] == hour) & (temp_hours['location'] == location)]
    if not filtered.empty:
        meanT_year = filtered['meanT_year'].values[0]
        return meanTacross - meanT_year
    return np.nan  # Return NaN if no data available


for location in locations:
    cooling_A[f'deltaT_{location}'] = cooling_A['chrontimes'].apply(lambda x: calculate_delta_T(x, location, cooling_A, temp_hours))

cooling_A.sort_values(by=['chrontimes'], inplace=True)
print(cooling_A.head())

# Plot delta T
plt.figure(figsize=(12, 6))
for location in locations:
    plt.plot(cooling_A['chrontimes'], cooling_A[f'deltaT_{location}'], label=f'D{location}')
plt.axhline(0, color='black', linewidth=0.8, linestyle='--')
plt.title("Cooling effect compared to location average T")
plt.xlabel("Time of day")
plt.ylabel("Delta T (C)")
plt.legend(title="Locations")
plt.grid()
plt.show()

# Seasonal delta T
cooling_summer = cooling_A.copy()
for location in locations:
    cooling_summer[f'deltaT_{location}'] = cooling_summer['chrontimes'].apply(
        lambda x: calculate_delta_T(x, location, cooling_summer, temp_hours[temp_hours['diurnal'] == 'day'])
    )

cooling_winter = cooling_A.copy()
for location in locations:
    cooling_winter[f'deltaT_{location}'] = cooling_winter['chrontimes'].apply(
        lambda x: calculate_delta_T(x, location, cooling_winter, temp_hours[temp_hours['diurnal'] == 'night'])
    )

# Plot seasonal delta T
fig, axes = plt.subplots(2, 1, figsize=(12, 12))
for location in locations:
    axes[0].plot(cooling_summer['chrontimes'], cooling_summer[f'deltaT_{location}'], label=f'D{location}')
    axes[1].plot(cooling_winter['chrontimes'], cooling_winter[f'deltaT_{location}'], label=f'D{location}')

axes[0].set_title("summer Season Cooling")
axes[1].set_title("winter Season Cooling")
for ax in axes:
    ax.axhline(0, color='black', linewidth=0.8, linestyle='--')
    ax.set_xlabel("Time of day")
    ax.set_ylabel("Delta T (C)")
    ax.legend(title="Locations")
    ax.grid()

plt.tight_layout()
plt.show()

# Compare absolute meanT at 6AM and 1PM for all drops
cooling_B = pd.DataFrame({'location': locations})

for season in ['summer', 'winter']:
    for time in ['06:00:00', '13:00:00']:
        col_name = f'{season[:1].upper()}temp{time[:2]}AM'
        cooling_B[col_name] = cooling_B['location'].apply(lambda loc: 
            alldata_times[(alldata_times['chrontimes'] == time) & 
                          (alldata_times['location'] == loc) & 
                          (alldata_times['season'] == season)]['temp'].mean())

print(cooling_B)

# Scatterplot for 6AM vs 1PM temperatures
fig, axes = plt.subplots(1, 2, figsize=(14, 6))
for i, season in enumerate(['summer', 'winter']):
    x_col = f'{season[:1].upper()}temp13AM'
    y_col = f'{season[:1].upper()}temp06AM'
    sns.scatterplot(ax=axes[i], data=cooling_B, x=x_col, y=y_col, size='location', legend=False)
    axes[i].set_title(f"{season.capitalize()} Season Diurnal Cooling Effect")
    axes[i].set_xlabel("Temp 1.00 PM (C)")
    axes[i].set_ylabel("Temp 06.00 AM (C)")

plt.tight_layout()
plt.show()