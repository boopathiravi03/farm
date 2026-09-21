import { io } from "socket.io-client";

const socket = io("https://farm-trading-backend.onrender.com");

export default socket;
