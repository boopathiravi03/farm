import { useEffect, useState } from "react";
import {
  MapContainer,
  TileLayer,
  Marker,
  Popup,
} from "react-leaflet";
import L from "leaflet";
import { getCrops } from "../services/api";
import "leaflet/dist/leaflet.css";
import "./MarketplaceMap.css";

const markerIcon = new L.Icon({
  iconUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
  iconRetinaUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",
  shadowUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});

function MarketplaceMap() {
  const [crops, setCrops] = useState([]);
  const [loading, setLoading] = useState(true);

  // Default center: Chennai
  const defaultPosition = [13.0827, 80.2707];

  useEffect(() => {
    loadCrops();
  }, []);

  async function loadCrops() {
    try {
      const result = await getCrops();

      const cropList = Array.isArray(result) ? result : (result?.crops || []);
      const mappedCrops = cropList.filter(
        (crop) =>
          crop.latitude !== null &&
          crop.latitude !== undefined &&
          crop.longitude !== null &&
          crop.longitude !== undefined &&
          !isNaN(Number(crop.latitude)) &&
          !isNaN(Number(crop.longitude))
      );

      setCrops(mappedCrops);
    } catch (error) {
      console.error("Failed to load crops:", error);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="marketplace-map-page">
      <div className="map-header">
        <div>
          <h1>📍 Farm Marketplace Map</h1>
          <p>
            Discover crops available from farmers
            around different locations.
          </p>
        </div>

        <div className="crop-count">
          🌾 {crops.length} Listed Crops
        </div>
      </div>

      <div className="map-container">
        {loading ? (
          <div className="map-loading">
            Loading marketplace...
          </div>
        ) : (
          <MapContainer
            center={defaultPosition}
            zoom={8}
            scrollWheelZoom={true}
            className="farm-map"
          >
            <TileLayer
              attribution='&copy; OpenStreetMap contributors'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />

            {crops.map((crop) => (
              <Marker
                key={crop._id}
                position={[
                  Number(crop.latitude),
                  Number(crop.longitude),
                ]}
                icon={markerIcon}
              >
                <Popup>
                  <div className="crop-popup">
                    <h3>🌾 {crop.cropName}</h3>
                    <p>📍 {crop.location}</p>
                    <p>📦 {crop.quantity} {crop.unit}</p>
                    <p>💰 ₹{crop.price}/{crop.unit}</p>
                    {crop.description && <p>{crop.description}</p>}
                    <button
                      onClick={() =>
                        alert(
                          `Crop: ${crop.cropName}\nPrice: ₹${crop.price}`
                        )
                      }
                    >
                      View Crop
                    </button>
                  </div>
                </Popup>
              </Marker>
            ))}
          </MapContainer>
        )}
      </div>
    </div>
  );
}

export default MarketplaceMap;

