const express = require("express");
const axios = require("axios");
const Groq = require("groq-sdk");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

const WEATHER_URL = "https://api.open-meteo.com/v1/forecast";
const GEOCODING_URL = "https://geocoding-api.open-meteo.com/v1/search";

// ======================================================
// WEATHER CODE INTERPRETER
// ======================================================

function getWeatherDescription(code) {
  const weatherCodes = {
    0: "Clear sky",
    1: "Mainly clear",
    2: "Partly cloudy",
    3: "Overcast",
    45: "Fog",
    48: "Depositing rime fog",
    51: "Light drizzle",
    53: "Moderate drizzle",
    55: "Dense drizzle",
    56: "Light freezing drizzle",
    57: "Dense freezing drizzle",
    61: "Slight rain",
    63: "Moderate rain",
    65: "Heavy rain",
    66: "Light freezing rain",
    67: "Heavy freezing rain",
    71: "Slight snowfall",
    73: "Moderate snowfall",
    75: "Heavy snowfall",
    77: "Snow grains",
    80: "Slight rain showers",
    81: "Moderate rain showers",
    82: "Violent rain showers",
    85: "Slight snow showers",
    86: "Heavy snow showers",
    95: "Thunderstorm",
    96: "Thunderstorm with slight hail",
    99: "Thunderstorm with heavy hail",
  };

  return weatherCodes[code] || "Unknown";
}

// ======================================================
// DEFAULT CHENNAI WEATHER (Backward Compatibility)
// ======================================================

router.get("/", authMiddleware, async (req, res) => {
  try {
    const weather = {
      location: "Chennai",
      temperature: 30,
      humidity: 72,
      rainfall: 8,
      windSpeed: 14,
      condition: "Partly Cloudy",
    };

    res.json({
      success: true,
      weather,
    });
  } catch (error) {
    console.error("Weather error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch weather",
    });
  }
});

// ======================================================
// LOCATION SEARCH
// ======================================================

router.get("/location-search", authMiddleware, async (req, res) => {
  try {
    const query = String(req.query.q || "").trim();

    if (query.length < 2) {
      return res.json({
        success: true,
        locations: [],
      });
    }

    const response = await axios.get(GEOCODING_URL, {
      params: {
        name: query,
        count: 8,
        language: "en",
        format: "json",
        countryCode: "IN",
      },
      timeout: 10000,
    });

    const locations = response.data.results || [];

    res.json({
      success: true,
      locations: locations.map((location) => ({
        id: location.id,
        name: location.name,
        latitude: location.latitude,
        longitude: location.longitude,
        country: location.country,
        state: location.admin1 || "",
        district: location.admin2 || "",
        elevation: location.elevation,
        timezone: location.timezone,
      })),
    });
  } catch (error) {
    console.error("Location search error:", error.message);
    res.status(500).json({
      success: false,
      message: "Location search failed",
    });
  }
});

// ======================================================
// WEATHER FORECAST
// ======================================================

router.get("/forecast", authMiddleware, async (req, res) => {
  try {
    const latitude = Number(req.query.latitude);
    const longitude = Number(req.query.longitude);
    const location = req.query.location || "Farm";

    if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
      return res.status(400).json({
        success: false,
        message: "Valid latitude and longitude are required",
      });
    }

    const response = await axios.get(WEATHER_URL, {
      params: {
        latitude,
        longitude,
        timezone: "auto",
        forecast_days: 7,
        current: [
          "temperature_2m",
          "relative_humidity_2m",
          "apparent_temperature",
          "precipitation",
          "rain",
          "showers",
          "weather_code",
          "cloud_cover",
          "wind_speed_10m",
          "wind_gusts_10m",
          "wind_direction_10m",
        ].join(","),
        hourly: [
          "temperature_2m",
          "relative_humidity_2m",
          "precipitation_probability",
          "precipitation",
          "rain",
          "showers",
          "weather_code",
          "cloud_cover",
          "wind_speed_10m",
          "wind_gusts_10m",
          "soil_temperature_0cm",
          "soil_temperature_6cm",
          "soil_moisture_0_to_1cm",
          "soil_moisture_1_to_3cm",
          "soil_moisture_3_to_9cm",
          "soil_moisture_9_to_27cm",
          "et0_fao_evapotranspiration",
        ].join(","),
        daily: [
          "weather_code",
          "temperature_2m_max",
          "temperature_2m_min",
          "apparent_temperature_max",
          "apparent_temperature_min",
          "sunrise",
          "sunset",
          "precipitation_sum",
          "rain_sum",
          "precipitation_probability_max",
          "wind_speed_10m_max",
          "wind_gusts_10m_max",
          "et0_fao_evapotranspiration",
        ].join(","),
      },
      timeout: 15000,
    });

    const data = response.data;

    const current = {
      time: data.current?.time,
      temperature: data.current?.temperature_2m,
      humidity: data.current?.relative_humidity_2m,
      apparentTemperature: data.current?.apparent_temperature,
      precipitation: data.current?.precipitation,
      rain: data.current?.rain,
      showers: data.current?.showers,
      weatherCode: data.current?.weather_code,
      condition: getWeatherDescription(data.current?.weather_code),
      cloudCover: data.current?.cloud_cover,
      windSpeed: data.current?.wind_speed_10m,
      windGust: data.current?.wind_gusts_10m,
      windDirection: data.current?.wind_direction_10m,
    };

    // 7-day daily forecast
    const daily = [];
    const dailyCount = data.daily?.time?.length || 0;

    for (let i = 0; i < dailyCount; i++) {
      daily.push({
        date: data.daily.time[i],
        condition: getWeatherDescription(data.daily.weather_code[i]),
        weatherCode: data.daily.weather_code[i],
        maxTemperature: data.daily.temperature_2m_max[i],
        minTemperature: data.daily.temperature_2m_min[i],
        apparentMax: data.daily.apparent_temperature_max[i],
        apparentMin: data.daily.apparent_temperature_min[i],
        rainfall: data.daily.precipitation_sum[i],
        rain: data.daily.rain_sum[i],
        rainProbability: data.daily.precipitation_probability_max[i],
        windSpeed: data.daily.wind_speed_10m_max[i],
        windGust: data.daily.wind_gusts_10m_max[i],
        sunrise: data.daily.sunrise[i],
        sunset: data.daily.sunset[i],
        evapotranspiration: data.daily.et0_fao_evapotranspiration[i],
      });
    }

    // Next 48 hours forecast
    const hourly = [];
    const hourlyCount = data.hourly?.time?.length || 0;
    const limit = Math.min(hourlyCount, 48);

    for (let i = 0; i < limit; i++) {
      hourly.push({
        time: data.hourly.time[i],
        temperature: data.hourly.temperature_2m[i],
        humidity: data.hourly.relative_humidity_2m[i],
        rainProbability: data.hourly.precipitation_probability[i],
        precipitation: data.hourly.precipitation[i],
        rain: data.hourly.rain[i],
        showers: data.hourly.showers[i],
        condition: getWeatherDescription(data.hourly.weather_code[i]),
        weatherCode: data.hourly.weather_code[i],
        windSpeed: data.hourly.wind_speed_10m[i],
        windGust: data.hourly.wind_gusts_10m[i],
        soilTemperature: data.hourly.soil_temperature_0cm[i],
        soilTemperature6cm: data.hourly.soil_temperature_6cm[i],
        soilMoisture01: data.hourly.soil_moisture_0_to_1cm[i],
        soilMoisture13: data.hourly.soil_moisture_1_to_3cm[i],
        soilMoisture39: data.hourly.soil_moisture_3_to_9cm[i],
        soilMoisture927: data.hourly.soil_moisture_9_to_27cm[i],
        evapotranspiration: data.hourly.et0_fao_evapotranspiration[i],
      });
    }

    res.json({
      success: true,
      location: {
        name: location,
        latitude,
        longitude,
        timezone: data.timezone,
        elevation: data.elevation,
      },
      current,
      daily,
      hourly,
      source: "Open-Meteo Weather Forecast API",
      fetchedAt: new Date(),
    });
  } catch (error) {
    console.error("Weather forecast error:", error.message);
    res.status(500).json({
      success: false,
      message: "Unable to fetch live weather forecast",
    });
  }
});

// ======================================================
// FARM WEATHER ALERTS
// ======================================================

router.post("/alerts", authMiddleware, async (req, res) => {
  try {
    const { daily = [], hourly = [], crop = "" } = req.body;
    const alerts = [];

    // Rain alerts
    const heavyRain = daily.find((day) => Number(day.rainfall || 0) >= 25);
    if (heavyRain) {
      alerts.push({
        type: "heavy_rain",
        severity: "high",
        title: "Heavy Rain Expected",
        message: `Around ${heavyRain.rainfall} mm rainfall may occur. Avoid unnecessary spraying and protect harvested crops.`,
        action: "Delay spraying and secure harvested produce.",
      });
    }

    // High rain probability
    const highRainProbability = daily.find(
      (day) => Number(day.rainProbability || 0) >= 70,
    );
    if (highRainProbability) {
      alerts.push({
        type: "rain_probability",
        severity: "medium",
        title: "High Rain Probability",
        message: `${highRainProbability.rainProbability}% rain probability is forecast.`,
        action: "Plan irrigation and field work accordingly.",
      });
    }

    // High temperature
    const hotDay = daily.find((day) => Number(day.maxTemperature || 0) >= 38);
    if (hotDay) {
      alerts.push({
        type: "heat",
        severity: "high",
        title: "High Temperature",
        message: `Temperature may reach ${hotDay.maxTemperature}°C.`,
        action: "Monitor crop moisture and consider irrigation during cooler hours.",
      });
    }

    // Strong wind
    const strongWind = daily.find((day) => Number(day.windGust || 0) >= 45);
    if (strongWind) {
      alerts.push({
        type: "wind",
        severity: "high",
        title: "Strong Wind Expected",
        message: `Wind gusts may reach ${strongWind.windGust} km/h.`,
        action: "Secure supports and avoid spraying during strong winds.",
      });
    }

    // Hourly immediate rain
    const immediateRain = hourly.find(
      (hour) => Number(hour.rainProbability || 0) >= 80,
    );
    if (immediateRain) {
      alerts.push({
        type: "hourly_rain",
        severity: "medium",
        title: "Rain Likely Soon",
        message: "High rainfall probability has been detected in upcoming hours.",
        action: "Avoid irrigation and outdoor spraying until conditions improve.",
      });
    }

    // Harvest warning
    if (crop && daily.some((day) => Number(day.rainfall || 0) >= 10)) {
      alerts.push({
        type: "harvest",
        severity: "medium",
        title: "Harvest Planning Alert",
        message: `Rain is forecast while you are growing ${crop}.`,
        action: "If the crop is harvest-ready, plan harvesting around dry periods.",
      });
    }

    res.json({
      success: true,
      alerts,
    });
  } catch (error) {
    console.error("Alerts error:", error);
    res.status(500).json({
      success: false,
      message: "Unable to generate weather alerts",
    });
  }
});

// ======================================================
// GROQ FARM ADVISOR
// ======================================================

router.post("/ai-advice", authMiddleware, async (req, res) => {
  try {
    if (!process.env.GROQ_API_KEY) {
      return res.status(500).json({
        success: false,
        message: "GROQ_API_KEY is not configured",
      });
    }

    const {
      crop,
      location,
      weather,
      forecast,
      soilType,
      growthStage,
    } = req.body;

    const prompt = `
You are Farm Trading AI, an agricultural weather advisor.
Provide practical advice for an Indian farmer.

Farm location: ${location || "Not provided"}
Crop: ${crop || "Not provided"}
Growth stage: ${growthStage || "Not provided"}
Soil: ${soilType || "Not provided"}
Current weather: ${JSON.stringify(weather || {})}
Forecast: ${JSON.stringify(forecast || [])}

Analyze:
1. Rain risk
2. Heat stress
3. Irrigation requirement
4. Spraying suitability
5. Fertilizer timing
6. Harvesting conditions
7. Crop protection
8. Next 3 days priority actions

Return ONLY JSON:
{
  "overallRisk": "Low | Medium | High",
  "summary": "Brief summary of overall conditions",
  "irrigation": {
    "status": "Irrigate | Reduce irrigation | Monitor | Avoid irrigation",
    "reason": "Clear explanation"
  },
  "spraying": {
    "status": "Suitable | Not suitable | Caution",
    "reason": "Clear explanation"
  },
  "fertilizer": {
    "status": "Suitable | Delay | Monitor",
    "reason": "Clear explanation"
  },
  "harvest": {
    "status": "Good | Caution | Delay",
    "reason": "Clear explanation"
  },
  "cropProtection": "Practical protective measures",
  "actions": [
    "Action 1",
    "Action 2",
    "Action 3"
  ],
  "warnings": [
    "Warning if any"
  ]
}

Rules:
- Do not invent weather values; rely on provided parameters.
- Provide actionable Indian farming guidance.
`;

    const candidateModels = [
      process.env.GROQ_CHAT_MODEL,
      "llama-3.3-70b-versatile",
      "openai/gpt-oss-120b",
      "groq/compound-mini",
    ].filter(Boolean);

    let completion = null;
    let lastError = null;

    for (const model of candidateModels) {
      try {
        completion = await groq.chat.completions.create({
          model,
          messages: [
            {
              role: "system",
              content: "You are an agricultural weather advisor.",
            },
            {
              role: "user",
              content: prompt,
            },
          ],
          temperature: 0.25,
          max_completion_tokens: 1200,
          response_format: {
            type: "json_object",
          },
        });
        if (completion) break;
      } catch (err) {
        lastError = err;
        if (
          err.status === 404 ||
          (err.message && err.message.toLowerCase().includes("not found")) ||
          (err.message && err.message.toLowerCase().includes("does not exist"))
        ) {
          console.warn(`Weather advice model ${model} not available, trying next fallback...`);
          continue;
        }
        throw err;
      }
    }

    if (!completion && lastError) {
      throw lastError;
    }

    const raw = completion.choices?.[0]?.message?.content || "{}";
    const result = JSON.parse(raw);

    res.json({
      success: true,
      advice: result,
      model: completion.model,
      generatedAt: new Date(),
    });
  } catch (error) {
    console.error("Groq weather advice error:", error.message);
    res.status(500).json({
      success: false,
      message: "AI weather advice is temporarily unavailable",
    });
  }
});

// ======================================================
// GROQ AI CROP RECOMMENDATION (LEGACY / EXTENDED COMPATIBILITY)
// ======================================================

router.post("/recommend", authMiddleware, async (req, res) => {
  try {
    const { temperature, humidity, rainfall, soilType, location, season } =
      req.body;

    if (!process.env.GROQ_API_KEY) {
      return res.status(500).json({
        success: false,
        message: "GROQ_API_KEY is not configured",
      });
    }

    const prompt = `
Generate agricultural crop recommendations using the following conditions:
Location: ${location || "Tamil Nadu, India"}
Temperature: ${temperature ?? "Not provided"} °C
Humidity: ${humidity ?? "Not provided"} %
Rainfall: ${rainfall ?? "Not provided"} mm
Soil: ${soilType || "Alluvial"}
Season: ${season || "Current"}

Return ONLY JSON:
{
  "recommendations": [
    {
      "crop": "Crop name",
      "suitability": "High | Medium | Low",
      "reason": "Short explanation",
      "careTip": "Practical farming tip"
    }
  ],
  "generalAdvice": "Short overall farming advice",
  "warning": "Important limitation or warning"
}
`;

    const candidateModels = [
      process.env.GROQ_CHAT_MODEL,
      "llama-3.3-70b-versatile",
      "openai/gpt-oss-120b",
      "groq/compound-mini",
    ].filter(Boolean);

    let completion = null;
    let lastError = null;

    for (const model of candidateModels) {
      try {
        completion = await groq.chat.completions.create({
          model,
          messages: [
            {
              role: "system",
              content: "You are an agricultural crop recommendation AI.",
            },
            {
              role: "user",
              content: prompt,
            },
          ],
          temperature: 0.3,
          max_completion_tokens: 900,
          response_format: {
            type: "json_object",
          },
        });
        if (completion) break;
      } catch (err) {
        lastError = err;
        if (
          err.status === 404 ||
          (err.message && err.message.toLowerCase().includes("not found")) ||
          (err.message && err.message.toLowerCase().includes("does not exist"))
        ) {
          continue;
        }
        throw err;
      }
    }

    if (!completion && lastError) {
      throw lastError;
    }

    const raw = completion.choices?.[0]?.message?.content || "{}";
    const result = JSON.parse(raw);

    res.json({
      success: true,
      recommendations: Array.isArray(result.recommendations)
        ? result.recommendations
        : [],
      generalAdvice: result.generalAdvice || "",
      warning: result.warning || "",
      model: completion?.model,
    });
  } catch (error) {
    console.error("Groq Recommendation Error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to generate AI crop recommendations",
    });
  }
});

module.exports = router;
