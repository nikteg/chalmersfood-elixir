import "../css/app.css";

import { Socket } from "phoenix";
import LiveSocket from "phoenix_live_view";
import "phoenix_html";

let liveSocket = new LiveSocket("/live", Socket);
liveSocket.connect();
