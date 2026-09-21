import { BrowserRouter, Routes, Route } from "react-router-dom";
import FarmerDashboard from "./pages/FarmerDashboard";
import BuyerDashboard from "./pages/BuyerDashboard";
import AdminDashboard from "./pages/AdminDashboard";
import PaymentPage from "./pages/PaymentPage";
import PaymentHistory from "./pages/PaymentHistory";
import FarmerEarnings from "./pages/FarmerEarnings";
import OrderTracking from "./pages/OrderTracking";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<BuyerDashboard />} />
        <Route path="/farmer" element={<FarmerDashboard />} />
        <Route path="/buyer" element={<BuyerDashboard />} />
        <Route path="/admin" element={<AdminDashboard />} />
        <Route path="/payment" element={<PaymentPage />} />
        <Route path="/payment-history" element={<PaymentHistory />} />
        <Route path="/farmer-earnings" element={<FarmerEarnings />} />
        <Route path="/order-tracking" element={<OrderTracking />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;

