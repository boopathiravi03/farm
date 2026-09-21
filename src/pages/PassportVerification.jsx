import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";

import { getPassport } from "../services/api";

import "./PassportVerification.css";

function PassportVerification() {
  const { passportId } = useParams();

  const [passport, setPassport] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    loadPassport();
  }, [passportId]);

  async function loadPassport() {
    try {
      const result = await getPassport(passportId);

      if (result.success) {
        setPassport(result.passport);
      } else {
        setError("Passport not found");
      }
    } catch (error) {
      console.error(error);
      setError("Unable to verify passport");
    }

    setLoading(false);
  }

  if (loading) {
    return (
      <div className="verification-loading">🔍 Verifying crop passport...</div>
    );
  }

  if (error) {
    return <div className="verification-error">❌ {error}</div>;
  }

  const crop = passport?.crop;
  const farmer = passport?.farmer;

  return (
    <div className="verification-page">
      <div className="verified-badge">✓ VERIFIED</div>

      <h1>🌾 Crop Passport</h1>

      <p className="passport-id">{passport.passportId}</p>

      <div className="verification-card">
        <h2>{crop?.cropName || "Crop"}</h2>

        <div className="verification-row">
          <span>Category</span>
          <strong>{crop?.category || "N/A"}</strong>
        </div>

        <div className="verification-row">
          <span>Quantity</span>
          <strong>
            {crop?.quantity} {crop?.unit}
          </strong>
        </div>

        <div className="verification-row">
          <span>Price</span>
          <strong>
            ₹{crop?.price}/{crop?.unit}
          </strong>
        </div>

        <div className="verification-row">
          <span>Location</span>
          <strong>📍 {crop?.location || "N/A"}</strong>
        </div>

        <div className="verification-row">
          <span>Farmer</span>
          <strong>{farmer?.name || "Verified Farmer"}</strong>
        </div>

        <div className="verification-row">
          <span>Quality</span>
          <strong>{passport.quality}</strong>
        </div>

        <div className="verification-row">
          <span>Status</span>
          <strong>{crop?.status || "available"}</strong>
        </div>

        <div className="verification-row">
          <span>Certification</span>
          <strong>{passport.certification}</strong>
        </div>
      </div>

      <div className="verification-footer">
        🔐 Verified through Farm Trading
      </div>
    </div>
  );
}

export default PassportVerification;
