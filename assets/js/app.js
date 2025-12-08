// Phoenix and LiveView imports
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import PlacesAutocomplete from "./hooks/places_autocomplete";

// Physics engine
import Matter from "matter-js";

let Hooks = {};

// ============================================
// THEME TOGGLE HOOK
// ============================================
Hooks.ThemeToggle = {
  mounted() {
    this.initTheme();

    this.el.addEventListener("click", (e) => {
      if (e.target.closest("button")) {
        this.toggleTheme();
      }
    });
  },

  initTheme() {
    const savedTheme = localStorage.getItem("theme");
    const html = document.documentElement;

    if (savedTheme) {
      if (savedTheme === "dark") {
        html.classList.add("dark");
      }
    } else {
      const prefersDark = window.matchMedia(
        "(prefers-color-scheme: dark)",
      ).matches;
      if (prefersDark) {
        html.classList.add("dark");
      }
    }

    window
      .matchMedia("(prefers-color-scheme: dark)")
      .addEventListener("change", (e) => {
        if (!localStorage.getItem("theme")) {
          if (e.matches) {
            html.classList.add("dark");
          } else {
            html.classList.remove("dark");
          }
        }
      });
  },

  toggleTheme() {
    const html = document.documentElement;
    const isDark = html.classList.contains("dark");

    // Add transition class for smooth theme change
    html.classList.add("transitioning");

    if (isDark) {
      html.classList.remove("dark");
      localStorage.setItem("theme", "light");
    } else {
      html.classList.add("dark");
      localStorage.setItem("theme", "dark");
    }

    // Remove transition class after animation
    setTimeout(() => {
      html.classList.remove("transitioning");
    }, 400);
  },
};

// ============================================
// SONG CARD CHAOS HOOK
// Applies randomized rotation and offset to cards
// ============================================
Hooks.CardChaos = {
  mounted() {
    this.applyRandomChaos();
  },

  updated() {
    // Reapply chaos if the card is re-rendered
    if (!this.el.style.getPropertyValue("--card-rotate")) {
      this.applyRandomChaos();
    }
  },

  applyRandomChaos() {
    // Subtle chaos: gentle tilt with more horizontal variance
    const rotation = (Math.random() * 4 - 1).toFixed(2);
    const offsetX = (Math.random() * 30 - 15).toFixed(1);
    const offsetY = (Math.random() * 6 - 3).toFixed(1);

    // Alternate cards left/right for visual variety
    const index = Array.from(this.el.parentNode?.children || []).indexOf(
      this.el,
    );
    const directionBias = index % 2 === 0 ? 1 : -1;
    const biasedOffsetX = parseFloat(offsetX) + directionBias * 8; // Add 8px bias based on position (increased from 5)
    const biasedRotation = parseFloat(rotation) + directionBias * 0.3; // Add slight rotation bias (reduced from 0.8)

    // Apply transform directly via inline style for maximum compatibility
    this.el.style.setProperty(
      "transform",
      `rotate(${biasedRotation.toFixed(2)}deg) translate(${biasedOffsetX.toFixed(1)}px, ${offsetY}px)`,
      "important",
    );

    // Also set CSS variables as backup
    this.el.style.setProperty(
      "--card-rotate",
      `${biasedRotation.toFixed(2)}deg`,
    );
    this.el.style.setProperty(
      "--card-offset-x",
      `${biasedOffsetX.toFixed(1)}px`,
    );
    this.el.style.setProperty("--card-offset-y", `${offsetY}px`);

    // Store original values for physics reset
    this.el.dataset.baseRotate = biasedRotation.toFixed(2);
    this.el.dataset.baseOffsetX = biasedOffsetX.toFixed(1);
    this.el.dataset.baseOffsetY = offsetY;
  },
};

// ============================================
// PHYSICS CARD HOOK
// Full matter.js physics with drag, momentum, and spring return
// ============================================
Hooks.PhysicsCard = {
  mounted() {
    // Check for reduced motion preference
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      return;
    }

    this.initPhysics();
    this.bindEvents();
  },

  destroyed() {
    this.cleanup();
  },

  initPhysics() {
    // Store original transform values
    const computedStyle = getComputedStyle(this.el);
    this.baseRotate = parseFloat(this.el.dataset.baseRotate || 0);
    this.baseOffsetX = parseFloat(this.el.dataset.baseOffsetX || 0);
    this.baseOffsetY = parseFloat(this.el.dataset.baseOffsetY || 0);

    // Current physics state
    this.velocity = { x: 0, y: 0, rotate: 0 };
    this.offset = { x: 0, y: 0, rotate: 0 };
    this.isDragging = false;
    this.dragStart = { x: 0, y: 0 };
    this.lastDrag = { x: 0, y: 0, time: 0 };

    // Physics constants
    this.springStiffness = 0.08;
    this.damping = 0.85;
    this.maxOffset = 30;
    this.maxRotation = 8;
  },

  bindEvents() {
    // Touch events for mobile
    this.el.addEventListener("touchstart", this.handleDragStart.bind(this), {
      passive: true,
    });
    this.el.addEventListener("touchmove", this.handleDragMove.bind(this), {
      passive: true,
    });
    this.el.addEventListener("touchend", this.handleDragEnd.bind(this));

    // Mouse events for desktop
    this.el.addEventListener("mousedown", this.handleDragStart.bind(this));
    document.addEventListener("mousemove", this.handleMouseMove.bind(this));
    document.addEventListener("mouseup", this.handleDragEnd.bind(this));

    // Store bound reference for cleanup
    this._mouseMoveHandler = this.handleMouseMove.bind(this);
    this._mouseUpHandler = this.handleDragEnd.bind(this);
  },

  cleanup() {
    document.removeEventListener("mousemove", this._mouseMoveHandler);
    document.removeEventListener("mouseup", this._mouseUpHandler);
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame);
    }
  },

  handleDragStart(e) {
    const point = e.touches ? e.touches[0] : e;
    this.isDragging = true;
    this.dragStart = { x: point.clientX, y: point.clientY };
    this.lastDrag = { x: point.clientX, y: point.clientY, time: Date.now() };
    this.el.style.transition = "none";
  },

  handleDragMove(e) {
    if (!this.isDragging) return;

    const point = e.touches ? e.touches[0] : e;
    const dx = point.clientX - this.dragStart.x;
    const dy = point.clientY - this.dragStart.y;

    // Calculate velocity from movement
    const now = Date.now();
    const dt = Math.max(now - this.lastDrag.time, 1);
    this.velocity.x = ((point.clientX - this.lastDrag.x) / dt) * 16;
    this.velocity.y = ((point.clientY - this.lastDrag.y) / dt) * 16;

    this.lastDrag = { x: point.clientX, y: point.clientY, time: now };

    // Apply constrained offset
    this.offset.x = Math.max(
      -this.maxOffset,
      Math.min(this.maxOffset, dx * 0.3),
    );
    this.offset.y = Math.max(
      -this.maxOffset,
      Math.min(this.maxOffset, dy * 0.3),
    );
    this.offset.rotate = -dx * 0.02;

    this.applyTransform();
  },

  handleMouseMove(e) {
    if (!this.isDragging) return;
    this.handleDragMove(e);
  },

  handleDragEnd() {
    if (!this.isDragging) return;
    this.isDragging = false;

    // Cap velocity
    this.velocity.x = Math.max(-15, Math.min(15, this.velocity.x));
    this.velocity.y = Math.max(-15, Math.min(15, this.velocity.y));

    // Start spring animation back to rest
    this.animateSpring();
  },

  animateSpring() {
    // Apply spring physics to return to base position
    const animate = () => {
      // Add velocity to offset
      this.offset.x += this.velocity.x;
      this.offset.y += this.velocity.y;

      // Apply spring force toward rest position
      const springForceX = -this.offset.x * this.springStiffness;
      const springForceY = -this.offset.y * this.springStiffness;
      const springForceRotate = -this.offset.rotate * this.springStiffness;

      this.velocity.x += springForceX;
      this.velocity.y += springForceY;
      this.velocity.rotate = (this.velocity.rotate || 0) + springForceRotate;

      // Apply damping
      this.velocity.x *= this.damping;
      this.velocity.y *= this.damping;
      this.velocity.rotate *= this.damping;

      this.offset.rotate += this.velocity.rotate;

      // Clamp offsets
      this.offset.x = Math.max(
        -this.maxOffset * 2,
        Math.min(this.maxOffset * 2, this.offset.x),
      );
      this.offset.y = Math.max(
        -this.maxOffset * 2,
        Math.min(this.maxOffset * 2, this.offset.y),
      );
      this.offset.rotate = Math.max(
        -this.maxRotation,
        Math.min(this.maxRotation, this.offset.rotate),
      );

      this.applyTransform();

      // Continue animation if still moving
      const totalVelocity =
        Math.abs(this.velocity.x) +
        Math.abs(this.velocity.y) +
        Math.abs(this.velocity.rotate || 0);
      const totalOffset =
        Math.abs(this.offset.x) +
        Math.abs(this.offset.y) +
        Math.abs(this.offset.rotate);

      if (totalVelocity > 0.01 || totalOffset > 0.1) {
        this.animationFrame = requestAnimationFrame(animate);
      } else {
        // Snap to rest
        this.offset = { x: 0, y: 0, rotate: 0 };
        this.velocity = { x: 0, y: 0, rotate: 0 };
        this.applyTransform();
        this.el.style.transition = "";
      }
    };

    this.animationFrame = requestAnimationFrame(animate);
  },

  applyTransform() {
    const totalRotate = this.baseRotate + this.offset.rotate;
    const totalX = this.baseOffsetX + this.offset.x;
    const totalY = this.baseOffsetY + this.offset.y;

    this.el.style.setProperty("--card-rotate", `${totalRotate}deg`);
    this.el.style.setProperty("--card-offset-x", `${totalX}px`);
    this.el.style.setProperty("--card-offset-y", `${totalY}px`);
  },

  // Trigger vote bounce animation
  voteBounce() {
    this.el.classList.add("voting");
    setTimeout(() => {
      this.el.classList.remove("voting");
    }, 400);
  },
};

// ============================================
// VOTE BUTTON HOOK
// Handles vote interaction with bounce feedback
// ============================================
Hooks.VoteButton = {
  mounted() {
    this.el.addEventListener("click", () => {
      // Find parent song card and trigger bounce
      const card = this.el.closest('[phx-hook="PhysicsCard"]');
      if (card && card._liveHookInstance) {
        card._liveHookInstance.voteBounce();
      }

      // Add tactile feedback
      this.el.classList.add("scale-90");
      setTimeout(() => {
        this.el.classList.remove("scale-90");
      }, 150);
    });
  },
};

// ============================================
// GRADIENT GENERATOR HOOK
// Generates unique gradients from song title hash
// ============================================
Hooks.GradientFallback = {
  mounted() {
    const title = this.el.dataset.title || "";
    const colors = this.generateGradientColors(title);

    this.el.style.setProperty("--gradient-color-1", colors[0]);
    this.el.style.setProperty("--gradient-color-2", colors[1]);
    this.el.style.setProperty("--gradient-color-3", colors[2]);
  },

  generateGradientColors(str) {
    // Simple string hash
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = (hash << 5) - hash + char;
      hash = hash & hash;
    }

    // Generate three harmonious HSL colors
    const baseHue = Math.abs(hash % 360);
    const saturation = 50 + (Math.abs(hash >> 8) % 30); // 50-80%
    const lightness = 45 + (Math.abs(hash >> 16) % 20); // 45-65%

    return [
      `hsl(${baseHue}, ${saturation}%, ${lightness}%)`,
      `hsl(${(baseHue + 40) % 360}, ${saturation - 10}%, ${lightness + 5}%)`,
      `hsl(${(baseHue + 80) % 360}, ${saturation - 20}%, ${lightness + 10}%)`,
    ];
  },
};

// ============================================
// ADAPTIVE TEXT COLOR HOOK
// Calculates accessible text colors based on dominant color
// ============================================
Hooks.AdaptiveTextColor = {
  mounted() {
    this.applyColors();

    // Re-apply colors when theme changes
    this.observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.attributeName === "class") {
          this.applyColors();
        }
      });
    });
    this.observer.observe(document.documentElement, { attributes: true });
  },

  destroyed() {
    if (this.observer) {
      this.observer.disconnect();
    }
  },

  updated() {
    this.applyColors();
  },

  applyColors() {
    const dominantColor = this.el.dataset.dominantColor;
    if (!dominantColor) return;

    const rgb = this.hexToRgb(dominantColor);
    if (!rgb) return;

    // Calculate relative luminance of the dominant color
    const albumLuminance = this.getLuminance(rgb.r, rgb.g, rgb.b);

    // Check if we're in dark mode
    const isDarkMode = document.documentElement.classList.contains("dark");

    // The card background blends the album color with the page background
    // In dark mode, the blend skews darker; in light mode, it skews lighter
    // Adjust the effective luminance based on the theme
    const effectiveLuminance = isDarkMode
      ? albumLuminance * 0.35 // Dark mode: even light albums blend dark, use light text
      : albumLuminance * 0.4 + 0.6; // Light mode makes backgrounds lighter

    // Choose text colors that meet WCAG AA contrast ratio (4.5:1)
    const textColors = this.getAccessibleTextColors(effectiveLuminance);

    // Apply CSS custom properties
    this.el.style.setProperty("--text-title", textColors.title);
    this.el.style.setProperty("--text-artist", textColors.artist);
    this.el.style.setProperty("--text-album", textColors.album);
  },

  hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result
      ? {
          r: parseInt(result[1], 16),
          g: parseInt(result[2], 16),
          b: parseInt(result[3], 16),
        }
      : null;
  },

  getLuminance(r, g, b) {
    // Convert to sRGB
    const [rs, gs, bs] = [r, g, b].map((c) => {
      c = c / 255;
      return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
    });
    return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
  },

  getContrastRatio(l1, l2) {
    const lighter = Math.max(l1, l2);
    const darker = Math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  },

  getAccessibleTextColors(bgLuminance) {
    // For dark backgrounds (low luminance), use light text
    // For light backgrounds (high luminance), use dark text
    if (bgLuminance < 0.5) {
      // Dark background - use light text with hierarchy
      return {
        title: "#ffffff",
        artist: "rgba(255, 255, 255, 0.90)",
        album: "rgba(255, 255, 255, 0.75)",
      };
    } else {
      // Light background - use solid dark text for maximum contrast
      return {
        title: "#1a1a1a",
        artist: "#2d2d2d",
        album: "#454545",
      };
    }
  },
};

// ============================================
// STAGGER ANIMATION HOOK
// Applies staggered animation delays to children
// ============================================
Hooks.StaggerList = {
  mounted() {
    this.applyStagger();
  },

  updated() {
    this.applyStagger();
  },

  applyStagger() {
    const children = this.el.querySelectorAll("[data-stagger]");
    children.forEach((child, index) => {
      // Use opacity-only fade for song cards (they have their own transform from CardChaos)
      if (
        child.classList.contains("song-card") ||
        child.classList.contains("show-card")
      ) {
        child.style.animationDelay = `${index * 0.05}s`;
        child.classList.add("animate-fade-in");
      } else {
        child.style.animationDelay = `${index * 0.05}s`;
        child.classList.add("animate-slide-up");
      }
    });
  },
};

// ============================================
// LOCAL TIME HOOK
// ============================================
Hooks.LocalTime = {
  mounted() {
    this.formatTime();
  },
  updated() {
    this.formatTime();
  },
  formatTime() {
    const datetime = this.el.dataset.datetime;
    if (datetime && datetime !== "Never") {
      const date = new Date(datetime);
      this.el.textContent = date.toLocaleString(undefined, {
        month: "short",
        day: "numeric",
        year: "numeric",
        hour: "numeric",
        minute: "2-digit",
        hour12: true,
      });
    }
  },
};

// Register existing hooks
Hooks.PlacesAutocomplete = PlacesAutocomplete;

// ============================================
// LIVESOCKET INITIALIZATION
// ============================================
let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Progress bar configuration with new accent color
topbar.config({
  barColors: { 0: "var(--accent-primary, #4a7c8c)" },
  shadowColor: "rgba(0, 0, 0, .2)",
});
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// Connect LiveSocket
liveSocket.connect();

// Expose for debugging
window.liveSocket = liveSocket;
