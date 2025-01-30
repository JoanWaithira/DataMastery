import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Set home path and load data
alldata_path = "revised2.csv"

# Read the cleaned data
alldata_times = pd.read_csv(alldata_path, on_bad_lines='skip', delimiter=';')

# Convert columns to appropriate data types
alldata_times['chrondate'] = pd.to_datetime(alldata_times['chrondate'], format='%m/%d/%y', errors='coerce')

# Ensure 'chrontimes' is in the correct format
print(alldata_times['chrontimes'].unique())
# If chrontimes is in hh:mm format, add ':00' to make it hh:mm:ss
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

# Function to assign diurnal (day/night) based on the hour
def assign_diurnal(row):
    # Ensure 'chrontimes' is a timedelta object and extract the hour
    if isinstance(row['chrontimes'], pd.Timedelta):
        hour = row['chrontimes'].seconds // 3600
    else:
        # If it's an integer (hour as integer), use it directly
        hour = row['chrontimes']
    return 'day' if 6 <= hour < 17 else 'night'

temp_hours['diurnal'] = temp_hours.apply(assign_diurnal, axis=1)

# Calculate annual mean temperature and humidity per hour
mean_temp_year = alldata_times.groupby(['hour', 'location'])['temp'].mean().reset_index()
mean_temp_year.columns = ['chrontimes', 'location', 'meanT_year']

mean_humidity_year = alldata_times.groupby(['hour', 'location'])['humidity'].mean().reset_index()
mean_humidity_year.columns = ['chrontimes', 'location', 'meanH_year']

temp_hours = temp_hours.merge(mean_temp_year, on=['chrontimes', 'location'], how='left')
temp_hours = temp_hours.merge(mean_humidity_year, on=['chrontimes', 'location'], how='left')

# Calculate seasonal mean temperature and humidity per hour
for season in ['dry', 'wet']:
    mean_temp_season = alldata_times[alldata_times['season'] == season].groupby(['hour', 'location'])['temp'].mean().reset_index()
    mean_temp_season.columns = ['chrontimes', 'location', f'meanT_{season}']

    mean_humidity_season = alldata_times[alldata_times['season'] == season].groupby(['hour', 'location'])['humidity'].mean().reset_index()
    mean_humidity_season.columns = ['chrontimes', 'location', f'meanH_{season}']

    temp_hours = temp_hours.merge(mean_temp_season, on=['chrontimes', 'location'], how='left')
    temp_hours = temp_hours.merge(mean_humidity_season, on=['chrontimes', 'location'], how='left')

# Calculate delta T for annual mean temperatures
cooling_A = temp_hours.groupby('chrontimes')['meanT_year'].mean().reset_index()
cooling_A.columns = ['chrontimes', 'meanTacross']

for location in locations:
    temp_col = temp_hours[temp_hours['location'] == location][['chrontimes', 'meanT_year']]
    temp_col.columns = ['chrontimes', f'deltaT_{location}']
    temp_col[f'deltaT_{location}'] = cooling_A['meanTacross'] - temp_col[f'deltaT_{location}']
    cooling_A = cooling_A.merge(temp_col, on='chrontimes', how='left')

# Handle any missing values after merge (if any)
cooling_A.fillna(method='ffill', inplace=True)

# Plot delta T
plt.figure(figsize=(10, 6))
for location in locations:
    plt.plot(cooling_A['chrontimes'], cooling_A[f'deltaT_{location}'], label=location)

plt.title('Cooling Effect Compared to Location Average T')
plt.xlabel('Time of Day')
plt.ylabel('Delta T (C)')
plt.legend(loc='upper right', fontsize='small')
plt.grid(True)
plt.show()

# Seasonal plots and further analysis can be implemented similarly following this structure.
