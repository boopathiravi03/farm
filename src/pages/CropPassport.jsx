import { useEffect, useState } from "react";
import { QRCodeCanvas } from "qrcode.react";

import {
  getMyCrops,
  createCropPassport,
  getMyPassports,
} from "../services/api";

import "./CropPassport.css";

function CropPassport() {
  const [crops, setCrops] = useState([]);
  const [passports, setPassports] = useState([]);
  const [selectedCrop, setSelectedCrop] = useState("");
  const [quality, setQuality] = useState("Not Tested");
  const [harvestDate, setHarvestDate] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    try {
      const cropResult = await getMyCrops();
      const passportResult = await getMyPassports();

      if (Array.isArray(cropResult)) {
        setCrops(cropResult);
      } else if (cropResult && cropResult.crops) {
        setCrops(cropResult.crops);
      }

      if (passportResult && passportResult.success) {
        setPassports(passportResult.passports || []);
      } else if (Array.isArray(passportResult)) {
        setPassports(passportResult);
      }
    } catch (error) {
      console.error(error);
    }
  }

  async function handleCreatePassport() {
    if (!selectedCrop) {
      alert("Please select a crop");
      return;
    }

    setLoading(true);

    try {
      const result = await createCropPassport(
        selectedCrop,
        quality,
        harvestDate
      );

      if (result.success) {
        alert("Crop passport created successfully!");
        await loadData();
        setSelectedCrop("");
      } else {
        alert(result.message || "Failed to create passport");
      }
    } catch (error) {
      console.error(error);
      alert("Unable to create passport");
    }

    setLoading(false);
  }

  const passportUrl = (passportId) => {
    return `${window.location.origin}/passport/${passportId}`;
  };

  return (
    <div className="passport-page">
      <div className="passport-header">
        <h1>📱 Crop Passport</h1>
        <p>Create a digital identity for your crops.</p>
      </div>

      {/* CREATE PASSPORT */}
      <div className="passport-create">
        <h2>🌾 Create Crop Passport</h2>

        <select
          value={selectedCrop}
          onChange={(e) => setSelectedCrop(e.target.value)}
        >
          <option value="">Select Crop</option>
          {crops.map((crop) => (
            <option key={crop._id} value={crop._id}>
              {crop.cropName} - {crop.quantity} {crop.unit}
            </option>
          ))}
        </select>

        <select
          value={quality}
          onChange={(e) => setQuality(e.target.value)}
        >
          <option>Not Tested</option>
          <option>Good</option>
          <option>Medium</option>
          <option>Poor</option>
        </select>

        <label>Harvest Date</label>
        <input
          type="date"
          value={harvestDate}
          onChange={(e) => setHarvestDate(e.target.value)}
        />

        <button onClick={handleCreatePassport} disabled={loading}>
          {loading ? "Creating..." : "📱 Create Passport"}
        </button>
      </div>

      {/* PASSPORT LIST */}
      <div className="passport-section">
        <h2>📋 My Crop Passports</h2>

        {passports.length === 0 ? (
          <div className="empty-passport">
            No crop passports created yet.
          </div>
        ) : (
          <div className="passport-grid">
            {passports.map((passport) => {
              const crop = passport.crop;
              const url = passportUrl(passport.passportId);

              return (
                <div className="passport-card" key={passport._id}>
                  <div className="passport-info">
                    <span className="passport-label">CROP PASSPORT</span>
                    <h3>🌾 {crop?.cropName || "Crop"}</h3>
                    <p>Passport ID:</p>
                    <strong>{passport.passportId}</strong>
                    <p>📍 {crop?.location || "Unknown"}</p>
                    <p>
                      💰 ₹{crop?.price || 0}/{crop?.unit || "kg"}
                    </p>
                    <p>
                      Quality: <b>{passport.quality}</b>
                    </p>
                  </div>

                  <div className="qr-section">
                    <QRCodeCanvas value={url} size={150} />
                    <p>Scan to verify</p>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

export default CropPassport;
