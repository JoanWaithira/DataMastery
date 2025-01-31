# Import necessary libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Set up workspace
homepath = "E:/PhD/UrbanClimate paper/Analysis/R_wd"
data_file = f"{homepath}/alldataFinal.csv"

# Load the cleaned data
alldata_times = pd.read_csv(data_file)

# Convert date and time columns to appropriate formats
alldata_times['chrondate'] = pd.to_datetime(alldata_times['chrondate']).dt.date
alldata_times['chrontimes'] = pd.to_datetime(alldata_times['chrontimes']).dt.time

# Convert season and diurnal to categorical
alldata_times['season'] = alldata_times['season'].astype('category')
alldata_times['diurnal'] = alldata_times['diurnal'].astype('category')

# Calculate hourly average temperatures across days and locations
chrontime = np.arange(0, 24)

# Create DataFrame for locations and times
temp_hours = pd.DataFrame([(t, loc) for t in chrontime for loc in alldata_times['location'].unique()],
                          columns=['chrontimes', 'location'])

# Add diurnal column (day or night)
temp_hours['diurnal'] = np.where((temp_hours['chrontimes'] >= 6) & (temp_hours['chrontimes'] <= 16), 'day', 'night')

# Calculate annual mean temperature and humidity per hour
def calc_mean(data, hour, location, column):
    return data[(data['hour'] == hour) & (data['location'] == location)][column].mean()

temp_hours['meanT_year'] = temp_hours.apply(
    lambda row: calc_mean(alldata_times, row['chrontimes'], row['location'], 'temp'), axis=1
)
temp_hours['meanH_year'] = temp_hours.apply(
    lambda row: calc_mean(alldata_times, row['chrontimes'], row['location'], 'humidity'), axis=1
)

# Add seasonal mean temperature and humidity per hour
for season in ['dry', 'wet']:
    temp_hours[f'meanT_{season}'] = temp_hours.apply(
        lambda row: calc_mean(
            alldata_times[alldata_times['season'] == season],
            row['chrontimes'], row['location'], 'temp'
        ), axis=1
    )
    temp_hours[f'meanH_{season}'] = temp_hours.apply(
        lambda row: calc_mean(
            alldata_times[alldata_times['season'] == season],
            row['chrontimes'], row['location'], 'humidity'
        ), axis=1
    )

# Calculate delta T (Temperature differences)
cooling_A = pd.DataFrame({'chrontimes': chrontime})
mean_across = temp_hours.groupby('chrontimes')['meanT_year'].mean()

for drop in alldata_times['location'].unique():
    cooling_A[f'deltaT_{drop}'] = mean_across - temp_hours.loc[temp_hours['location'] == drop, 'meanT_year'].values

# Plot delta T
plt.figure(figsize=(10, 6))
for drop in alldata_times['location'].unique():
    plt.plot(cooling_A['chrontimes'], cooling_A[f'deltaT_{drop}'], label=f'Drop {drop}')
plt.xlabel('Time of day')
plt.ylabel('Delta T (C)')
plt.title('Cooling effect compared to location average T')
plt.legend()
plt.grid()
plt.show()

# Save processed data if needed
cooling_A.to_csv(f"{homepath}/alt_hourlytemp.csv", index=False)
