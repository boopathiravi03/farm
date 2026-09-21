const API_URL = "http://localhost:5000/api";

export async function registerUser(userData) {
  const response = await fetch(`${API_URL}/auth/register`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(userData),
  });

  return response.json();
}

export async function loginUser(email, password) {
  const response = await fetch(`${API_URL}/auth/login`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      email,
      password,
    }),
  });

  return response.json();
}

export async function getCrops() {
  const response = await fetch(`${API_URL}/crops`);

  return response.json();
}

export async function addCrop(cropData) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/crops`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(cropData),
  });

  return response.json();
}

export const createCrop = addCrop;

export async function getMyCrops() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/crops/my-crops`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function updateCrop(id, cropData) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/crops/${id}`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(cropData),
  });

  return response.json();
}

export async function deleteCrop(id) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/crops/${id}`, {
    method: "DELETE",
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function searchCrops(params = {}) {
  const query = new URLSearchParams();

  if (params.search) {
    query.append("search", params.search);
  }

  if (params.category) {
    query.append("category", params.category);
  }

  if (params.location) {
    query.append("location", params.location);
  }

  if (params.minPrice) {
    query.append("minPrice", params.minPrice);
  }

  if (params.maxPrice) {
    query.append("maxPrice", params.maxPrice);
  }

  const response = await fetch(`${API_URL}/crops/search?${query.toString()}`);

  return response.json();
}

export async function placeOrder(orderData) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/orders`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(orderData),
  });

  return response.json();
}

export async function getMyOrders() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/orders/my-orders`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function getFarmerOrders() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/orders/farmer-orders`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function updateOrderStatus(orderId, status) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/orders/${orderId}/status`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      status,
    }),
  });

  return response.json();
}

export async function startNegotiation(negotiationData) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/negotiations`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(negotiationData),
  });

  return response.json();
}

export async function sendOffer(negotiationId, price, message) {
  const token = localStorage.getItem("token");

  const response = await fetch(
    `${API_URL}/negotiations/${negotiationId}/offer`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        price,
        message,
      }),
    },
  );

  return response.json();
}

export async function getNegotiation(negotiationId) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/negotiations/${negotiationId}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function acceptNegotiation(negotiationId) {
  const token = localStorage.getItem("token");

  const response = await fetch(
    `${API_URL}/negotiations/${negotiationId}/accept`,
    {
      method: "PUT",
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  return response.json();
}

export async function rejectNegotiation(negotiationId) {
  const token = localStorage.getItem("token");

  const response = await fetch(
    `${API_URL}/negotiations/${negotiationId}/reject`,
    {
      method: "PUT",
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  return response.json();
}

export async function getNotifications() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/notifications`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function getUnreadCount() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/notifications/unread-count`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function markNotificationRead(id) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/notifications/${id}/read`, {
    method: "PUT",
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function markAllNotificationsRead() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/notifications/read-all`, {
    method: "PUT",
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function makePayment(orderId, paymentMethod) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/payments`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      orderId,
      paymentMethod,
    }),
  });

  return response.json();
}

export async function getMyPayments() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/payments/my-payments`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function getFarmerEarnings() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/payments/farmer-earnings`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function createDelivery(orderId) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/deliveries`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      orderId,
    }),
  });

  return response.json();
}

export async function getDelivery(orderId) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/deliveries/order/${orderId}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function updateDeliveryStatus(deliveryId, status) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/deliveries/${deliveryId}/status`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      status,
    }),
  });

  return response.json();
}

export async function askAI(message) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/ai/chat`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      message,
    }),
  });

  return response.json();
}

export async function getFarmerAnalytics() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/analytics/farmer`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function getWeather() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/weather`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function getCropRecommendations(data) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/weather/recommend`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(data),
  });

  return response.json();
}

export async function analyzeCropQuality(imageName, cropName) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/ai/crop-quality`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      imageName,
      cropName,
    }),
  });

  return response.json();
}

export async function createCropPassport(cropId, quality, harvestDate) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/passports`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      cropId,
      quality,
      harvestDate,
    }),
  });

  return response.json();
}

export async function getMyPassports() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/passports/my`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function getPassport(passportId) {
  const response = await fetch(`${API_URL}/passports/${passportId}`);

  return response.json();
}

// ===============================
// ADMIN API
// ===============================

export async function getAdminStats() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/admin/stats`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function getAdminUsers() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/admin/users`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function deleteAdminUser(id) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/admin/users/${id}`, {
    method: "DELETE",
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function getAdminCrops() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/admin/crops`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function deleteAdminCrop(id) {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/admin/crops/${id}`, {
    method: "DELETE",
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

export async function getAdminOrders() {
  const token = localStorage.getItem("token");

  const response = await fetch(`${API_URL}/admin/orders`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

