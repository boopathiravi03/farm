import { useState } from "react";
import { analyzeCropQuality } from "../services/api";
import "./CropQualityAI.css";

function CropQualityAI() {
  const [image, setImage] = useState(null);
  const [cropName, setCropName] = useState("Tomato");
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  function handleImageChange(event) {
    const selectedFile = event.target.files[0];

    if (selectedFile) {
      setImage(selectedFile);
      setResult(null);
    }
  }

  async function analyzeImage() {
    if (!image) {
      alert("Please select a crop image");
      return;
    }

    setLoading(true);

    try {
      const response = await analyzeCropQuality(
        image.name,
        cropName
      );

      if (response.success) {
        setResult(response);
      } else {
        alert(response.message || "Analysis failed");
      }
    } catch (error) {
      console.error(error);
      alert("Unable to analyze crop image");
    }

    setLoading(false);
  }

  return (
    <div className="quality-page">
      {/* HEADER */}
      <div className="quality-header">
        <h1>📷 AI Crop Quality Detection</h1>
        <p>
          Upload a crop image to analyze its quality and freshness.
        </p>
      </div>

      {/* UPLOAD CARD */}
      <div className="quality-upload-card">
        <div className="upload-icon">🌾</div>
        <h2>Upload Crop Image</h2>
        <p>Select a clear image of your crop.</p>

        <select
          value={cropName}
          onChange={(e) => setCropName(e.target.value)}
        >
          <option>Tomato</option>
          <option>Rice</option>
          <option>Groundnut</option>
          <option>Maize</option>
          <option>Cotton</option>
          <option>Banana</option>
        </select>

        <label className="upload-button">
          📁 Choose Image
          <input
            type="file"
            accept="image/*"
            onChange={handleImageChange}
          />
        </label>

        {image && (
          <div className="selected-file">
            <span>📷</span>
            <div>
              <strong>{image.name}</strong>
              <small>{(image.size / 1024).toFixed(1)} KB</small>
            </div>
          </div>
        )}

        <button
          className="analyze-button"
          onClick={analyzeImage}
          disabled={loading}
        >
          {loading ? "🤖 Analyzing..." : "🤖 Analyze Crop Quality"}
        </button>
      </div>

      {/* RESULT */}
      {result && (
        <div className="quality-result">
          <div className="result-header">
            <div>
              <span>AI Analysis Result</span>
              <h2>🌱 {result.cropName}</h2>
            </div>

            <div className="confidence">
              <strong>{result.confidence}%</strong>
              <span>Confidence</span>
            </div>
          </div>

          <div className="result-grid">
            <div className="result-box">
              <span>Quality</span>
              <strong>{result.quality}</strong>
            </div>

            <div className="result-box">
              <span>Freshness</span>
              <strong>{result.freshness}</strong>
            </div>

            <div className="result-box">
              <span>Confidence</span>
              <strong>{result.confidence}%</strong>
            </div>
          </div>

          <div className="recommendation">
            <h3>💡 Recommendation</h3>
            <p>{result.recommendation}</p>
          </div>
        </div>
      )}
    </div>
  );
}

export default CropQualityAI;
