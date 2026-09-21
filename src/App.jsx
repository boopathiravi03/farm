import { BrowserRouter, Routes, Route } from "react-router-dom";
import FarmerDashboard from "./pages/FarmerDashboard";
import BuyerDashboard from "./pages/BuyerDashboard";
import AdminDashboard from "./pages/AdminDashboard";
import PaymentPage from "./pages/PaymentPage";
import PaymentHistory from "./pages/PaymentHistory";
import FarmerEarnings from "./pages/FarmerEarnings";
import OrderTracking from "./pages/OrderTracking";
import AIFarmerAssistant from "./pages/AIFarmerAssistant";
import FarmerAnalytics from "./pages/FarmerAnalytics";
import WeatherRecommendations from "./pages/WeatherRecommendations";
import MarketplaceMap from "./pages/MarketplaceMap";
import AddCrop from "./pages/AddCrop";
import CropQualityAI from "./pages/CropQualityAI";
import CropPassport from "./pages/CropPassport";
import PassportVerification from "./pages/PassportVerification";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<BuyerDashboard />} />
        <Route path="/farmer" element={<FarmerDashboard />} />
        <Route path="/buyer" element={<BuyerDashboard />} />
        <Route path="/admin" element={<AdminDashboard />} />
        <Route path="/admin-dashboard" element={<AdminDashboard />} />
        <Route path="/payment" element={<PaymentPage />} />
        <Route path="/payment-history" element={<PaymentHistory />} />
        <Route path="/farmer-earnings" element={<FarmerEarnings />} />
        <Route path="/order-tracking" element={<OrderTracking />} />
        <Route path="/ai-assistant" element={<AIFarmerAssistant />} />
        <Route path="/farmer-analytics" element={<FarmerAnalytics />} />
        <Route path="/weather-advisor" element={<WeatherRecommendations />} />
        <Route path="/marketplace-map" element={<MarketplaceMap />} />
        <Route path="/add-crop" element={<AddCrop />} />
        <Route path="/crop-quality" element={<CropQualityAI />} />
        <Route path="/crop-passport" element={<CropPassport />} />
        <Route
          path="/passport/:passportId"
          element={<PassportVerification />}
        />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
