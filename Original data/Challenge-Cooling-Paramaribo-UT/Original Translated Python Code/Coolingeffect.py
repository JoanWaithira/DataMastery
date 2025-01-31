import pandas as pd
import matplotlib.pyplot as plt

# Set the file path
homepath = "C://Users//SchwarzN//Surfdrive//outreach//publications//work-in-progress//LB_climateParamaribo//Data//"
data_file = f"{homepath}/Paramaribodropsall.csv"

# Load the data
alldata = pd.read_csv(data_file)

# Individual scatterplots for wet and dry seasons
# Scatterplot: Diurnal cooling dry season
plt.figure(figsize=(6, 4))
plt.scatter(
    alldata['Dtemp1PM'],
    alldata['Dtemp6AM'],
    s=300 * alldata['buff300.lc.t'],
    c='grey',
    label='Tree Coverage',
    alpha=0.6
)
for i, label in enumerate(alldata['DropID']):
    plt.text(alldata['Dtemp1PM'][i], alldata['Dtemp6AM'][i], label, fontsize=8, ha='right')
plt.title("a) Diurnal Cooling Dry Season")
plt.xlabel("1PM Mean T")
plt.ylabel("6AM Mean T")
plt.xlim(27, 33)
plt.ylim(23, 26)
plt.xticks(range(27, 34))
plt.yticks(range(23, 27))
plt.grid(True)
plt.savefig("Cooling2_a.pdf")
plt.show()

# Scatterplot: Diurnal cooling wet season
plt.figure(figsize=(6, 4))
plt.scatter(
    alldata['Wtemp1PM'],
    alldata['Wtemp6AM'],
    s=300 * alldata['buff300.lc.t'],
    c='grey',
    alpha=0.6
)
for i, label in enumerate(alldata['DropID']):
    plt.text(alldata['Wtemp1PM'][i], alldata['Wtemp6AM'][i], label, fontsize=8, ha='right')
plt.title("b) Diurnal Cooling Wet Season")
plt.xlabel("1PM Mean T")
plt.ylabel("6AM Mean T")
plt.xlim(27, 33)
plt.ylim(23, 26)
plt.xticks(range(27, 34))
plt.yticks(range(23, 27))
plt.grid(True)
plt.savefig("Cooling2_b.pdf")
plt.show()

# Scatterplot: Nighttime cooling dry season
plt.figure(figsize=(6, 4))
plt.scatter(
    alldata['range.t.oct21.night'],
    alldata['min.t.oct21.night'],
    s=300 * alldata['buff300.lc.t'],
    c='grey',
    alpha=0.6
)
for i, label in enumerate(alldata['DropID']):
    plt.text(alldata['range.t.oct21.night'][i], alldata['min.t.oct21.night'][i], label, fontsize=8, ha='right')
plt.title("c) Nighttime Cooling Dry Season")
plt.xlabel("Nighttime Range T")
plt.ylabel("Nighttime Min T")
plt.xlim(3, 8)
plt.ylim(23, 26)
plt.xticks(range(3, 9))
plt.yticks(range(23, 27))
plt.grid(True)
plt.savefig("Cooling2_c.pdf")
plt.show()

# Scatterplot: Nighttime cooling wet season
plt.figure(figsize=(6, 4))
plt.scatter(
    alldata['range.t.mj22.night'],
    alldata['min.t.mj22.night'],
    s=300 * alldata['buff300.lc.t'],
    c='grey',
    alpha=0.6
)
for i, label in enumerate(alldata['DropID']):
    plt.text(alldata['range.t.mj22.night'][i], alldata['min.t.mj22.night'][i], label, fontsize=8, ha='right')
plt.title("d) Nighttime Cooling Wet Season")
plt.xlabel("Nighttime Range T")
plt.ylabel("Nighttime Min T")
plt.xlim(3, 8)
plt.ylim(21, 24)
plt.xticks(range(3, 9))
plt.yticks(range(21, 25))
plt.grid(True)
plt.savefig("Cooling2_d.pdf")
plt.show()

# Scatterplot: Hot extremes
plt.figure(figsize=(6, 4))
plt.scatter(
    alldata['max.t.10he'],
    alldata['max.h.10he'],
    s=300 * alldata['buff300.lc.t'],
    c='grey',
    alpha=0.6
)
for i, label in enumerate(alldata['DropID']):
    plt.text(alldata['max.t.10he'][i], alldata['max.h.10he'][i], label, fontsize=8, ha='right')
plt.title("e) Hot Extremes")
plt.xlabel("Max T in Hot Extremes")
plt.ylabel("Max Humidity in Hot Extremes")
plt.xlim(30, 45)
plt.ylim(90, 102)
plt.xticks(range(30, 46, 5))
plt.yticks(range(90, 103, 5))
plt.grid(True)
plt.savefig("Cooling2_e.pdf")
plt.show()

# Scatterplot: Average standardized land surface temperatures
plt.figure(figsize=(6, 4))
plt.scatter(
    alldata['av_LSTsCOMP.wet'],
    alldata['av_LSTsCOMP.dry'],
    s=300 * alldata['buff300.lc.t'],
    c='grey',
    alpha=0.6
)
for i, label in enumerate(alldata['DropID']):
    plt.text(alldata['av_LSTsCOMP.wet'][i], alldata['av_LSTsCOMP.dry'][i], label, fontsize=8, ha='right')
plt.title("f) Average Standardized Land Surface Temperatures")
plt.xlabel("Land Surface T Wet Season")
plt.ylabel("Land Surface T Dry Season")
plt.xlim(-1.5, 2)
plt.ylim(-1.5, 2)
plt.xticks(range(-1, 3))
plt.yticks(range(-1, 3))
plt.grid(True)
plt.savefig("Cooling2_f.pdf")
plt.show()

# Save legend as a separate PDF
plt.figure(figsize=(4, 3))
plt.scatter([], [], s=300 * 0.1, c='grey', label='10% Tree Coverage')
plt.scatter([], [], s=300 * 0.5, c='grey', label='50% Tree Coverage')
plt.legend(title='Tree Coverage', loc='lower left', fontsize=10)
plt.axis('off')
plt.savefig("Cooling2_legend.pdf")
plt.show()
