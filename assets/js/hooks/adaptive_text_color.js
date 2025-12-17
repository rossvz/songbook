const AdaptiveTextColor = {
  mounted() {
    this.applyColors();

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

    const albumLuminance = this.getLuminance(rgb.r, rgb.g, rgb.b);

    const isDarkMode = document.documentElement.classList.contains("dark");

    const effectiveLuminance = isDarkMode
      ? albumLuminance * 0.35
      : albumLuminance * 0.4 + 0.6;

    const textColors = this.getAccessibleTextColors(effectiveLuminance);

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
    if (bgLuminance < 0.5) {
      return {
        title: "#ffffff",
        artist: "rgba(255, 255, 255, 0.90)",
        album: "rgba(255, 255, 255, 0.75)",
      };
    } else {
      return {
        title: "#1a1a1a",
        artist: "#2d2d2d",
        album: "#454545",
      };
    }
  },
};

export default AdaptiveTextColor;
