from pathlib import Path
import joblib
from sklearn.ensemble import RandomForestRegressor

# speed, distance, hour, day, street_type
X = [
    [30, 4.2, 8, 0, 0], [25, 3.1, 9, 0, 2],
    [40, 5.0, 14, 1, 0], [18, 2.5, 17, 4, 2],
    [20, 1.0, 10, 2, 1], [35, 6.0, 11, 3, 0],
    [12, 2.0, 16, 5, 2], [28, 3.0, 7, 6, 1],
]
y = [10, 14, 9, 16, 6, 14, 18, 10] # minutes

model = RandomForestRegressor(
    n_estimators=100, random_state=42
)
model.fit(X, y)

path = Path(__file__).with_name("ETA_Model_Training_v1.ipynb")
joblib.dump(model, path)
print(f"Saved demo model: {path}")
