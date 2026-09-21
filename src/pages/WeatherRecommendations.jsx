import { useEffect, useState } from "react";
import {
  getWeather,
  getCropRecommendations,
} from "../services/api";

import "./WeatherRecommendations.css";

function WeatherRecommendations() {
  const [weather, setWeather] = useState(null);
  const [soilType, setSoilType] = useState("Red Soil");
  const [recommendations, setRecommendations] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadWeather();
  }, []);

  async function loadWeather() {
    try {
      const result = await getWeather();

      if (result.success) {
        setWeather(result.weather);
      }
    } catch (error) {
      console.error(error);
    }
  }

  async function generateRecommendations() {
    if (!weather) return;

    setLoading(true);

    try {
      const result = await getCropRecommendations({
        temperature: weather.temperature,
        humidity: weather.humidity,
        rainfall: weather.rainfall,
        soilType,
      });

      if (result.success) {
        setRecommendations(result.recommendations);
      }
    } catch (error) {
      console.error(error);
    }

    setLoading(false);
  }

  return (
    <div className="weather-page">
      <div className="weather-header">
        <h1>🌦️ Weather & Crop Advisor</h1>
        <p>Check current conditions and find suitable crops.</p>
      </div>

      {/* WEATHER */}
      {weather && (
        <div className="weather-card">
          <div className="weather-location">
            <h2>📍 {weather.location}</h2>
            <span>{weather.condition}</span>
          </div>

          <div className="weather-main">
            <div className="temperature">
              🌡️ {weather.temperature}°C
            </div>
          </div>

          <div className="weather-details">
            <div>
              <span>💧</span>
              <p>Humidity</p>
              <strong>{weather.humidity}%</strong>
            </div>

            <div>
              <span>🌧️</span>
              <p>Rainfall</p>
              <strong>{weather.rainfall} mm</strong>
            </div>

            <div>
              <span>💨</span>
              <p>Wind Speed</p>
              <strong>{weather.windSpeed} km/h</strong>
            </div>
          </div>
        </div>
      )}

      {/* CROP ADVISOR */}
      <div className="advisor-card">
        <h2>🌱 Crop Recommendation</h2>
        <p>Select your soil type to find suitable crops.</p>

        <select
          value={soilType}
          onChange={(e) => setSoilType(e.target.value)}
        >
          <option>Red Soil</option>
          <option>Black Soil</option>
          <option>Clay Soil</option>
          <option>Sandy Soil</option>
          <option>Loamy Soil</option>
        </select>

        <button
          onClick={generateRecommendations}
          disabled={loading}
        >
          {loading ? "Analyzing..." : "🌾 Get Crop Recommendations"}
        </button>
      </div>

      {/* RESULTS */}
      {recommendations.length > 0 && (
        <div className="recommendation-section">
          <h2>🌾 Recommended Crops</h2>

          <div className="recommendation-grid">
            {recommendations.map((item, index) => (
              <div className="recommendation-card" key={index}>
                <div className="crop-icon">🌱</div>
                <h3>{item.crop}</h3>
                <span className="suitability">
                  {item.suitability} Suitability
                </span>
                <p>{item.reason}</p>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

export default WeatherRecommendations;
