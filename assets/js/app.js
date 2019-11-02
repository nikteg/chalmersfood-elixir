// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

const menu = document.querySelector("#menu");
const button = menu.querySelector("button");

button.classList.add("mobile", "only");
const responsive_elems = menu.querySelectorAll(".mobile");
for (const elem of responsive_elems) {
  elem.classList.add("hidden");
}

button &&
  button.addEventListener("click", () => {
    const responsive_elems = menu.querySelectorAll(".mobile");

    for (const elem of responsive_elems) {
      elem.classList.toggle("hidden");
    }

    const icon = button.querySelector("i");

    if (icon.classList.contains("x")) {
      icon.classList.replace("x", "bars");
    } else {
      icon.classList.replace("bars", "x");
    }
  });

import { Socket } from "phoenix";
import LiveSocket from "phoenix_live_view";
import "phoenix_html";

let liveSocket = new LiveSocket("/live", Socket);
liveSocket.connect();
