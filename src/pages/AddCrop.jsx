import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { createCrop } from "../services/api";

function AddCrop() {
  const navigate = useNavigate();
  const [cropName, setCropName] = useState("");
  const [category, setCategory] = useState("Vegetables");
  const [quantity, setQuantity] = useState("");
  const [unit, setUnit] = useState("kg");
  const [price, setPrice] = useState("");
  const [location, setLocation] = useState("");
  const [latitude, setLatitude] = useState("");
  const [longitude, setLongitude] = useState("");
  const [description, setDescription] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!cropName || !category || !quantity || !price || !location) {
      setMessage("Please fill all required fields");
      return;
    }

    setLoading(true);
    setMessage("");

    try {
      const cropData = {
        cropName,
        category,
        quantity: Number(quantity),
        unit,
        price: Number(price),
        location,
        latitude: latitude ? Number(latitude) : null,
        longitude: longitude ? Number(longitude) : null,
        description,
      };

      const result = await createCrop(cropData);
      if (result.crop) {
        setMessage("Crop added successfully! 🌾");
        setTimeout(() => {
          navigate("/farmer");
        }, 1200);
      } else {
        setMessage(result.message || "Failed to add crop");
      }
    } catch (error) {
      setMessage("Failed to add crop");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
      style={{
        maxWidth: "600px",
        margin: "40px auto",
        padding: "20px",
        background: "white",
        borderRadius: "12px",
        boxShadow: "0 4px 15px rgba(0,0,0,0.08)",
      }}
    >
      <h2>🌾 List New Crop</h2>
      {message && (
        <p style={{ padding: "10px", background: "#e8f5e9", borderRadius: "6px" }}>
          {message}
        </p>
      )}

      <form onSubmit={handleSubmit}>
        <div style={{ marginBottom: "15px" }}>
          <label>Crop Name *</label>
          <input
            type="text"
            style={{
              width: "100%",
              padding: "10px",
              borderRadius: "6px",
              border: "1px solid #ccc",
              marginTop: "5px",
            }}
            value={cropName}
            onChange={(e) => setCropName(e.target.value)}
            placeholder="e.g. Organic Tomato"
            required
          />
        </div>

        <div style={{ marginBottom: "15px" }}>
          <label>Category *</label>
          <select
            style={{
              width: "100%",
              padding: "10px",
              borderRadius: "6px",
              border: "1px solid #ccc",
              marginTop: "5px",
            }}
            value={category}
            onChange={(e) => setCategory(e.target.value)}
          >
            <option>Vegetables</option>
            <option>Fruits</option>
            <option>Grains</option>
            <option>Pulses</option>
            <option>Oilseeds</option>
            <option>Spices</option>
          </select>
        </div>

        <div
          style={{
            display: "grid",
            gridTemplateColumns: "1fr 1fr",
            gap: "15px",
            marginBottom: "15px",
          }}
        >
          <div>
            <label>Quantity *</label>
            <input
              type="number"
              style={{
                width: "100%",
                padding: "10px",
                borderRadius: "6px",
                border: "1px solid #ccc",
                marginTop: "5px",
              }}
              value={quantity}
              onChange={(e) => setQuantity(e.target.value)}
              placeholder="e.g. 500"
              required
            />
          </div>
          <div>
            <label>Unit</label>
            <select
              style={{
                width: "100%",
                padding: "10px",
                borderRadius: "6px",
                border: "1px solid #ccc",
                marginTop: "5px",
              }}
              value={unit}
              onChange={(e) => setUnit(e.target.value)}
            >
              <option value="kg">kg</option>
              <option value="quintal">quintal</option>
              <option value="ton">ton</option>
            </select>
          </div>
        </div>

        <div
          style={{
            display: "grid",
            gridTemplateColumns: "1fr 1fr",
            gap: "15px",
            marginBottom: "15px",
          }}
        >
          <div>
            <label>Price (₹/unit) *</label>
            <input
              type="number"
              style={{
                width: "100%",
                padding: "10px",
                borderRadius: "6px",
                border: "1px solid #ccc",
                marginTop: "5px",
              }}
              value={price}
              onChange={(e) => setPrice(e.target.value)}
              placeholder="e.g. 35"
              required
            />
          </div>
          <div>
            <label>Location *</label>
            <input
              type="text"
              style={{
                width: "100%",
                padding: "10px",
                borderRadius: "6px",
                border: "1px solid #ccc",
                marginTop: "5px",
              }}
              value={location}
              onChange={(e) => setLocation(e.target.value)}
              placeholder="e.g. Panruti"
              required
            />
          </div>
        </div>

        <div
          style={{
            display: "grid",
            gridTemplateColumns: "1fr 1fr",
            gap: "15px",
            marginBottom: "15px",
          }}
        >
          <div className="form-group">
            <label>Latitude</label>
            <input
              type="number"
              step="any"
              style={{
                width: "100%",
                padding: "10px",
                borderRadius: "6px",
                border: "1px solid #ccc",
                marginTop: "5px",
              }}
              value={latitude}
              onChange={(e) => setLatitude(e.target.value)}
              placeholder="Example: 11.7766"
            />
          </div>
          <div className="form-group">
            <label>Longitude</label>
            <input
              type="number"
              step="any"
              style={{
                width: "100%",
                padding: "10px",
                borderRadius: "6px",
                border: "1px solid #ccc",
                marginTop: "5px",
              }}
              value={longitude}
              onChange={(e) => setLongitude(e.target.value)}
              placeholder="Example: 79.5520"
            />
          </div>
        </div>

        <div style={{ marginBottom: "20px" }}>
          <label>Description</label>
          <textarea
            style={{
              width: "100%",
              padding: "10px",
              borderRadius: "6px",
              border: "1px solid #ccc",
              marginTop: "5px",
            }}
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Fresh farm produce, chemical-free..."
            rows={3}
          />
        </div>

        <button
          type="submit"
          disabled={loading}
          style={{
            width: "100%",
            padding: "12px",
            background: "#2e7d32",
            color: "white",
            border: "none",
            borderRadius: "6px",
            cursor: "pointer",
            fontSize: "16px",
            fontWeight: "bold",
          }}
        >
          {loading ? "Adding Crop..." : "🌾 List Crop on Marketplace"}
        </button>
      </form>
    </div>
  );
}

export default AddCrop;

