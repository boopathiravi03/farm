import { useEffect, useState } from "react";
import socket from "../services/socket";
import {
  getNotifications,
  getUnreadCount,
  markNotificationRead,
} from "../services/api";
import "./NotificationBell.css";

function NotificationBell() {
  const [notifications, setNotifications] = useState([]);
  const [unread, setUnread] = useState(0);
  const [open, setOpen] = useState(false);

  const user = JSON.parse(localStorage.getItem("user"));

  useEffect(() => {
    if (!user) return;

    loadNotifications();

    socket.emit("joinUser", user._id || user.id);

    socket.on("newNotification", (notification) => {
      setNotifications((prev) => [notification, ...prev]);

      setUnread((prev) => prev + 1);
    });

    return () => {
      socket.off("newNotification");
    };
  }, []);

  async function loadNotifications() {
    try {
      const data = await getNotifications();

      setNotifications(data);

      const count = await getUnreadCount();

      setUnread(count.count);
    } catch (error) {
      console.error(error);
    }
  }

  async function handleRead(id) {
    try {
      await markNotificationRead(id);

      setNotifications((prev) =>
        prev.map((item) =>
          item._id === id ? { ...item, isRead: true } : item,
        ),
      );

      setUnread((prev) => (prev > 0 ? prev - 1 : 0));
    } catch (error) {
      console.error(error);
    }
  }

  return (
    <div className="notification-container">
      <button className="notification-button" onClick={() => setOpen(!open)}>
        🔔
        {unread > 0 && <span className="notification-count">{unread}</span>}
      </button>

      {open && (
        <div className="notification-panel">
          <div className="notification-header">
            <h3>Notifications</h3>
          </div>

          {notifications.length === 0 ? (
            <p className="empty-notification">No notifications</p>
          ) : (
            notifications.map((notification) => (
              <div
                key={notification._id}
                className={`notification-item ${
                  !notification.isRead ? "unread" : ""
                }`}
                onClick={() => handleRead(notification._id)}
              >
                <strong>{notification.title}</strong>

                <p>{notification.message}</p>

                <small>
                  {new Date(notification.createdAt).toLocaleString()}
                </small>
              </div>
            ))
          )}
        </div>
      )}
    </div>
  );
}

export default NotificationBell;
