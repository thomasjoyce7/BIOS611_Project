import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

runner_weather_data = pd.read_csv('joined_data/runner_weather_data.csv')

runner_weather_data['Time_sec'] = pd.to_timedelta(runner_weather_data['Time']).dt.total_seconds()

heatmap_data = runner_weather_data[["Year","Time_sec","PRECIP_mm","SUNSHINE_hrs","CLOUD_hrs",
                                    "ATMOS_PRESS_mbar","AVG_TEMP_F","MIN_TEMP_F","MAX_TEMP_F"]]

# Calculate the correlation matrix
correlation_matrix = heatmap_data.corr()

# Create the heatmap
plt.figure(figsize=(10, 8))
sns.heatmap(correlation_matrix, annot=True, cmap='Blues', fmt=".2f", cbar_kws={'label': 'r'})

# Display the plot
plt.title("Berlin Marathon Heatmap of Feature Correlations")

plt.savefig('figures/correlation_heatmap.png', format='png', dpi=300, bbox_inches='tight')
