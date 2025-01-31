import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Set paths
homepath = "C://Users//SchwarzN//Surfdrive//outreach//publications//work-in-progress//LB_climateParamaribo//Data//"
data_file = f"{homepath}/alldataFINAL.csv"

# Load the data
alldata = pd.read_csv(data_file)

# Convert date and time columns to datetime
alldata['chrondate'] = pd.to_datetime(alldata['chrondate'])
alldata['chrontimes'] = pd.to_datetime(alldata['chrontimes'], format='%H:%M:%S').dt.time
alldata['season'] = alldata['season'].astype('category')
alldata['diurnal'] = alldata['diurnal'].astype('category')
alldata['location'] = alldata['location'].astype('category')

# Summary statistics
print(alldata['chrondate'].describe())
print(alldata['chrontimes'].describe())

# Create a DataFrame for hourly data with locations and seasons
chrontimes = sorted(alldata['chrontimes'].unique())
locations = sorted(alldata['location'].unique())
seasons = ["dry", "wet", "all year", "Oct21", "MJ22"]

hourly_data = pd.DataFrame([(time, loc, season) for time in chrontimes for loc in locations for season in seasons],
                           columns=['chrontimes', 'location', 'season'])

# Initialize columns
hourly_data['meanT'] = np.nan
hourly_data['sdT'] = np.nan
hourly_data['meanH'] = np.nan
hourly_data['sdH'] = np.nan

# Function to calculate statistics for different conditions
def calculate_stats(data, time, location, season, temp_col='temp', humidity_col='humidity'):
    if season == "all year":
        subset = data[(data['chrontimes'] == time) & (data['location'] == location)]
    elif season == "Oct21":
        subset = data[(data['chrontimes'] == time) & (data['location'] == location) & (data['month'] == 10)]
    elif season == "MJ22":
        subset = data[(data['chrontimes'] == time) & (data['location'] == location) & 
                      (data['chrondate'] > "2022-05-14") & (data['chrondate'] < "2022-06-16")]
    else:  # for dry or wet seasons
        subset = data[(data['chrontimes'] == time) & (data['location'] == location) & (data['season'] == season)]

    temp_mean = subset[temp_col].mean(skipna=True)
    temp_sd = subset[temp_col].std(skipna=True)
    hum_mean = subset[humidity_col].mean(skipna=True)
    hum_sd = subset[humidity_col].std(skipna=True)
    return temp_mean, temp_sd, hum_mean, hum_sd

# Populate statistics in hourly_data
for idx, row in hourly_data.iterrows():
    time, location, season = row['chrontimes'], row['location'], row['season']
    meanT, sdT, meanH, sdH = calculate_stats(alldata, time, location, season)
    hourly_data.loc[idx, ['meanT', 'sdT', 'meanH', 'sdH']] = [meanT, sdT, meanH, sdH]

# Combine hourly data across locations
combined_data = hourly_data.groupby(['chrontimes', 'season']).agg(
    meanT=('meanT', 'mean'),
    sdT=('sdT', 'mean'),
    meanH=('meanH', 'mean'),
    sdH=('sdH', 'mean')
).reset_index()

# Compute seasonal averages
seasonal_means = combined_data.groupby('season').agg(
    avg_temp=('meanT', 'mean'),
    avg_humidity=('meanH', 'mean')
)
print(seasonal_means)

# Plot diurnal dynamics for each season
def plot_diurnal(data, y_col, ylabel, title, ylim, filename):
    plt.figure(figsize=(10, 6))
    for season in seasons:
        season_data = data[data['season'] == season]
        plt.plot(season_data['chrontimes'], season_data[y_col], label=season)
    plt.title(title)
    plt.xlabel('Time of Day')
    plt.ylabel(ylabel)
    plt.ylim(ylim)
    plt.legend()
    plt.grid()
    plt.savefig(f"{homepath}/{filename}.pdf", format='pdf')
    plt.show()

# Plot temperature dynamics
plot_diurnal(combined_data, 'meanT', 'Temperature (°C)', 'Mean Temperature by Season', (20, 40), 'Mean_Temperature')

# Plot humidity dynamics
plot_diurnal(combined_data, 'meanH', 'Relative Humidity (%)', 'Mean Humidity by Season', (40, 100), 'Mean_Humidity')

# Plot standard deviation of temperature
plot_diurnal(combined_data, 'sdT', 'Temperature SD (°C)', 'Temperature SD by Season', (0, 5), 'Temp_SD')

# Plot standard deviation of humidity
plot_diurnal(combined_data, 'sdH', 'Humidity SD (%)', 'Humidity SD by Season', (0, 20), 'Humidity_SD')
