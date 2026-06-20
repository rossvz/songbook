import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import { hooks as colocatedHooks } from "phoenix-colocated/songbook";

import PlacesAutocomplete from "./hooks/places_autocomplete";
import CardChaos from "./hooks/card_chaos";
import GradientFallback from "./hooks/gradient_fallback";
import AdaptiveTextColor from "./hooks/adaptive_text_color";
import SwipeToHide from "./hooks/swipe_to_hide";
import StaggerList from "./hooks/stagger_list";

const Hooks = {
  ...colocatedHooks,
  PlacesAutocomplete,
  CardChaos,
  GradientFallback,
  AdaptiveTextColor,
  SwipeToHide,
  StaggerList,
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

const accentColor =
  getComputedStyle(document.documentElement)
    .getPropertyValue("--accent-primary")
    .trim() || "#4a7c8c";

topbar.config({
  barColors: { 0: accentColor },
  shadowColor: "rgba(0, 0, 0, .2)",
});

window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

liveSocket.connect();

window.liveSocket = liveSocket;
