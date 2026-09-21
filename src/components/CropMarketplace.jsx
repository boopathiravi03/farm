import { getCrops } from "../services/api";
import { useEffect, useState } from "react";

function CropMarketplace() {
  const [crops, setCrops] = useState([]);

  useEffect(() => {
    loadCrops();
  }, []);

  const loadCrops = async () => {
    try {
      const data = await getCrops();
      if (Array.isArray(data)) {
        setCrops(data);
      }
    } catch (error) {
      console.error("Failed to load crops:", error);
    }
  };

  return (
    <div className="crop-marketplace">
      <h2>Marketplace Crops</h2>
      {crops.map((crop) => (
        <div key={crop._id} className="crop-card">
          <h3>{crop.cropName}</h3>
          <p>Category: {crop.category}</p>
          <p>
            Quantity: {crop.quantity} {crop.unit}
          </p>
          <p>₹{crop.price}</p>
          <p>📍 {crop.location}</p>
          <p>👨🌾 {crop.farmer?.name}</p>
        </div>
      ))}
    </div>
  );
}

export default CropMarketplace;
