import { useEffect, useState } from "react";
import { getMyCrops, deleteCrop, updateCrop } from "../services/api";

function MyCrops() {
  const [crops, setCrops] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editCrop, setEditCrop] = useState(null);

  useEffect(() => {
    loadCrops();
  }, []);

  const loadCrops = async () => {
    try {
      const data = await getMyCrops();
      if (Array.isArray(data)) {
        setCrops(data);
      }
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    const confirmDelete = window.confirm(
      "Are you sure you want to delete this crop?",
    );
    if (!confirmDelete) return;

    const result = await deleteCrop(id);
    if (result.message) {
      setCrops(crops.filter((crop) => crop._id !== id));
    }
  };

  const handleStatusChange = async (id, status) => {
    const result = await updateCrop(id, { status });
    if (result.crop) {
      setCrops(crops.map((crop) => (crop._id === id ? result.crop : crop)));
    }
  };

  const handleEditSubmit = async (e) => {
    e.preventDefault();
    const result = await updateCrop(editCrop._id, {
      cropName: editCrop.cropName,
      category: editCrop.category,
      quantity: editCrop.quantity,
      unit: editCrop.unit,
      price: editCrop.price,
      location: editCrop.location,
      description: editCrop.description,
    });

    if (result.crop) {
      setCrops(
        crops.map((crop) => (crop._id === editCrop._id ? result.crop : crop)),
      );
      setEditCrop(null);
    }
  };

  if (loading) {
    return <p>Loading crops...</p>;
  }

  return (
    <div>
      <h2>My Crop Listings</h2>

      {editCrop && (
        <form onSubmit={handleEditSubmit} style={{ marginBottom: "20px" }}>
          <h3>Edit Crop</h3>
          <input
            placeholder="Crop Name"
            value={editCrop.cropName}
            onChange={(e) =>
              setEditCrop({ ...editCrop, cropName: e.target.value })
            }
          />
          <input
            type="number"
            placeholder="Quantity"
            value={editCrop.quantity}
            onChange={(e) =>
              setEditCrop({ ...editCrop, quantity: e.target.value })
            }
          />
          <input
            type="number"
            placeholder="Price"
            value={editCrop.price}
            onChange={(e) =>
              setEditCrop({ ...editCrop, price: e.target.value })
            }
          />
          <button type="submit">Save Changes</button>
          <button type="button" onClick={() => setEditCrop(null)}>
            Cancel
          </button>
        </form>
      )}

      {crops.length === 0 ? (
        <p>No crops listed yet.</p>
      ) : (
        crops.map((crop) => (
          <div
            key={crop._id}
            style={{
              border: "1px solid #ccc",
              padding: "10px",
              marginBottom: "10px",
            }}
          >
            <h3>{crop.cropName}</h3>
            <p>Category: {crop.category}</p>
            <p>
              Quantity: {crop.quantity} {crop.unit}
            </p>
            <p>Price: ₹{crop.price}</p>
            <p>Location: {crop.location}</p>
            <p>Status: {crop.status}</p>

            <button onClick={() => setEditCrop(crop)}>Edit</button>
            <button onClick={() => handleStatusChange(crop._id, "sold")}>
              Mark as Sold
            </button>
            <button onClick={() => handleStatusChange(crop._id, "available")}>
              Make Available
            </button>
            <button onClick={() => handleDelete(crop._id)}>Delete</button>
          </div>
        ))
      )}
    </div>
  );
}

export default MyCrops;
