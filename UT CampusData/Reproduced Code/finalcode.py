import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

# --------------------------- Code 1: Seasonal and Hourly Analysis ---------------------------

# Load the dataset
data_path_1 = r"C:\Users\joanw\Downloads\Datamastery (1)\Datamastery\CampusData\campusdata.csv"
if not os.path.exists(data_path_1):
    raise FileNotFoundError(f"The file at {data_path_1} does not exist.")

data1 = pd.read_csv(data_path_1)

# Drop unnecessary columns
data1 = data1.drop(columns=['Unnamed: 0', 'X', 'serialno', 'originalfile'], errors='ignore')

# Add a 'season' column based on the 'month' column
def assign_season_1(month):
    if month in [12, 1, 2]:
        return 'winter'
    elif month in [3, 4, 5]:
        return 'spring'
    elif month in [6, 7, 8]:
        return 'summer'
    elif month in [9, 10, 11]:
        return 'autumn'

data1['season'] = data1['month'].apply(assign_season_1)

# Convert columns to appropriate data types
data1['chrondate'] = pd.to_datetime(data1['chrondate'], format='%d/%m/%y', errors='coerce')
data1['chrontimes'] = pd.to_datetime(data1['chrontimes'], format='%H:%M:%S', errors='coerce').dt.hour
data1['location'] = data1['location'].astype('category')

# Check for missing values and drop rows with NaNs in critical columns
required_columns_1 = ['hour', 'humidity', 'temp', 'season', 'location']
data1 = data1.dropna(subset=required_columns_1)

# Filter relevant columns for delta T analysis
filtered_data_1 = data1[['month', 'chrontimes', 'temp', 'location', 'season']]

# Calculate delta T
delta_t_data_1 = filtered_data_1.copy()
average_temp_1 = delta_t_data_1.groupby(['chrontimes', 'season'])['temp'].transform('mean')
delta_t_data_1['deltaT'] = delta_t_data_1['temp'] - average_temp_1

# Group by season, location, and hour of day to calculate the mean delta T across all years
seasonal_mean_by_location_1 = delta_t_data_1.groupby(['season', 'location', 'chrontimes']).agg(
    mean_deltaT=('deltaT', 'mean')
).reset_index()

# Filter relevant columns for humidity analysis
humidity_data_1 = data1[['hour', 'humidity', 'location', 'season']]

# Group by location, hour of day, and season to calculate the mean relative humidity
humidity_grouped_1 = humidity_data_1.groupby(['season', 'location', 'hour']).agg(
    mean_humidity=('humidity', 'mean')
).reset_index()

# Define the output directory (ensure this directory exists)
output_dir_1 = r"C:\Users\joanw\Downloads\Datamastery (1)\Datamastery\CampusData"
os.makedirs(output_dir_1, exist_ok=True)

# Plotting functions
def plot_seasonal_mean_delta_t_1(data, season, filename, title):
    plt.figure(figsize=(14, 7))
    season_data = data[data['season'] == season]

    for loc in season_data['location'].unique():
        loc_data = season_data[season_data['location'] == loc]
        plt.plot(loc_data['chrontimes'], loc_data['mean_deltaT'], label=f'{loc}')

    plt.title(title)
    plt.xlabel('Hour of Day')
    plt.ylabel('Mean Delta T (°C)')
    plt.axhline(0, color='black', linestyle='--', linewidth=0.8)
    plt.legend(title='Sensor (Drop)', bbox_to_anchor=(1.05, 1), loc='upper left', fontsize='small', ncol=2)
    plt.grid()
    plt.xticks(np.arange(0, 24, step=2))
    plt.savefig(filename, format='pdf', bbox_inches='tight')
    plt.show()

# Generate and save delta T plots for each season
seasons = ['winter', 'spring', 'summer', 'autumn']
for season in seasons:
    plot_seasonal_mean_delta_t_1(
        seasonal_mean_by_location_1,
        season,
        f"{output_dir_1}seasonal_mean_delta_t_by_drop_{season}.pdf",
        f'Seasonal Mean Delta T Per Drop ({season.capitalize()})'
    )

# --------------------------- Code 2: Daily Temperature Analysis ---------------------------

# Load the dataset
data_path_2 = r"C:\Users\joanw\Downloads\Datamastery (1)\Datamastery\CampusData\campusdata.csv"
if not os.path.exists(data_path_2):
    raise FileNotFoundError(f"The file at {data_path_2} does not exist.")

data2 = pd.read_csv(data_path_2)

# Drop unnecessary columns
data2 = data2.drop(columns=['Unnamed: 0', 'X', 'serialno', 'originalfile'], errors='ignore')

# Convert date column to datetime if not already
if 'chrondate' in data2.columns:
    data2['chrondate'] = pd.to_datetime(data2['chrondate'], errors='coerce')
    data2['year'] = data2['chrondate'].dt.year
    data2['month'] = data2['chrondate'].dt.month
    data2['day'] = data2['chrondate'].dt.day

# Ensure relevant columns exist and filter missing data
required_columns_2 = ['temp', 'location', 'chrondate']
data2 = data2.dropna(subset=required_columns_2)

# Group by drop (sensor), day of the year, and calculate daily mean and SD averaged across years
data2['day_of_year'] = data2['chrondate'].dt.dayofyear

daily_stats_2 = data2.groupby(['location', 'day_of_year']).agg(
    mean_temp=('temp', 'mean'),
    std_temp=('temp', 'std')
).reset_index()

# Define the output directory
output_dir_2 = r"C:\Users\joanw\Downloads\Datamastery (1)\Datamastery\CampusData"
os.makedirs(output_dir_2, exist_ok=True)

# Plotting function for daily temperature stats per drop as scatter diagrams
def plot_daily_temp_stats_2(data, output_dir):
    locations = data['location'].unique()

    for loc in locations:
        loc_data = data[data['location'] == loc]

        plt.figure(figsize=(14, 7))
        plt.scatter(
            loc_data['day_of_year'], loc_data['mean_temp'], label='Mean Temperature (T)', alpha=0.7
        )
        plt.errorbar(
            loc_data['day_of_year'], loc_data['mean_temp'], yerr=loc_data['std_temp'], fmt='o', alpha=0.7, label='Standard Deviation (SD)'
        )

        plt.title(f'Daily Air Temperature (T) and SD - Location: {loc}')
        plt.xlabel('Day of Year')
        plt.ylabel('Temperature (°C)')
        plt.legend()
        plt.grid()

        # Save the plot
        output_file = os.path.join(output_dir, f'daily_temp_stats_location_{loc}.pdf')
        plt.savefig(output_file, format='pdf', bbox_inches='tight')
        plt.show()

# Generate and save the scatter plots
plot_daily_temp_stats_2(daily_stats_2, output_dir_2)

def plot_diurnal_with_dynamic_ylim(data, y_col, ylabel, title, filename):
    plt.figure(figsize=(14, 10))  # Large figure size for better visibility
    data['chrontimes_str'] = data['chrontimes'].astype(str)  # Convert chrontimes to string for plotting

    # Determine dynamic y-axis limits with a small buffer
    y_min = data[y_col].min() - 0.5
    y_max = data[y_col].max() + 0.5

    for season in seasons:
        season_data = data[data['season'] == season]
        if season_data.empty:
            print(f"Warning: No data for season '{season}'. Skipping plot.")
            continue
        plt.plot(season_data['chrontimes_str'], season_data[y_col], label=season)

    plt.title(title, fontsize=18)
    plt.xlabel('Time of Day', fontsize=16)
    plt.ylabel(ylabel, fontsize=16)
    plt.ylim(y_min, y_max)  # Apply dynamic y-axis limits
    plt.xticks(rotation=45, fontsize=14)  # Rotate x-axis labels for better readability
    plt.yticks(fontsize=14)
    plt.legend(title='Season', fontsize=14, title_fontsize=16, loc='best')
    plt.grid()
    plt.tight_layout(pad=3.0)  # Ensure adequate padding around the plot
    plt.savefig(filename, format='pdf', bbox_inches='tight')  # Save with tight bounding box
    plt.show()

# Generate all plots with dynamic y-axis limits
plot_diurnal_with_dynamic_ylim(
    combined_data,
    'meanT',
    'Temperature (°C)',
    'Mean Temperature by Season',
    f"{output_dir}/Mean_Temperature_Dynamic_Y.pdf"
)

plot_diurnal_with_dynamic_ylim(
    combined_data,
    'meanH',
    'Relative Humidity (%)',
    'Mean Humidity by Season',
    f"{output_dir}/Mean_Humidity_Dynamic_Y.pdf"
)

plot_diurnal_with_dynamic_ylim(
    combined_data,
    'sdT',
    'Temperature SD (°C)',
    'Temperature SD by Season',
    f"{output_dir}/Temp_SD_Dynamic_Y.pdf"
)

plot_diurnal_with_dynamic_ylim(
    combined_data,
    'sdH',
    'Humidity SD (%)',
    'Humidity SD by Season',
    f"{output_dir}/Humidity_SD_Dynamic_Y.pdf"
)

