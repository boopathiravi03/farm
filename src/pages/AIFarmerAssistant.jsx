import { useState } from "react";
import { askAI } from "../services/api";
import "./AIFarmerAssistant.css";

function AIFarmerAssistant() {
  const [message, setMessage] = useState("");
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(false);

  async function handleSend() {
    if (!message.trim()) {
      return;
    }

    const userMessage = message;

    setMessages((prev) => [
      ...prev,
      {
        sender: "user",
        text: userMessage,
      },
    ]);

    setMessage("");
    setLoading(true);

    try {
      const result = await askAI(userMessage);

      setMessages((prev) => [
        ...prev,
        {
          sender: "ai",
          text: result.answer || "Sorry, I couldn't answer that.",
        },
      ]);
    } catch (error) {
      setMessages((prev) => [
        ...prev,
        {
          sender: "ai",
          text: "Something went wrong. Please try again.",
        },
      ]);
    } finally {
      setLoading(false);
    }
  }

  function handleKeyDown(e) {
    if (e.key === "Enter") {
      handleSend();
    }
  }

  return (
    <div className="ai-page">
      <div className="ai-container">
        <div className="ai-header">
          <div className="ai-icon">🤖</div>
          <div>
            <h1>Farm Trading AI</h1>
            <p>Your smart farming assistant 🌾</p>
          </div>
        </div>

        <div className="ai-chat">
          {messages.length === 0 && (
            <div className="ai-welcome">
              <h2>Hello Farmer! 👋</h2>
              <p>How can I help you today?</p>

              <div className="suggestions">
                <button
                  onClick={() => setMessage("How can I improve my crop yield?")}
                >
                  🌱 Improve crop yield
                </button>

                <button
                  onClick={() => setMessage("Why are my tomato leaves yellow?")}
                >
                  🍅 Tomato problem
                </button>

                <button
                  onClick={() =>
                    setMessage("What should I check before selling my crop?")
                  }
                >
                  💰 Selling advice
                </button>

                <button
                  onClick={() => setMessage("How should I manage fertilizer?")}
                >
                  🌾 Fertilizer advice
                </button>
              </div>
            </div>
          )}

          {messages.map((item, index) => (
            <div
              key={index}
              className={
                item.sender === "user"
                  ? "message user-message"
                  : "message ai-message"
              }
            >
              <div className="message-avatar">
                {item.sender === "user" ? "👨‍🌾" : "🤖"}
              </div>

              <div className="message-text">{item.text}</div>
            </div>
          ))}

          {loading && (
            <div className="message ai-message">
              <div className="message-avatar">🤖</div>
              <div className="message-text">Thinking... 🌱</div>
            </div>
          )}
        </div>

        <div className="ai-input-area">
          <input
            type="text"
            placeholder="Ask your farming question..."
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyDown={handleKeyDown}
          />

          <button onClick={handleSend} disabled={loading}>
            ➤
          </button>
        </div>
      </div>
    </div>
  );
}

export default AIFarmerAssistant;
