const GradientFallback = {
  mounted() {
    const title = this.el.dataset.title || "";
    const colors = this.generateGradientColors(title);

    this.el.style.setProperty("--gradient-color-1", colors[0]);
    this.el.style.setProperty("--gradient-color-2", colors[1]);
    this.el.style.setProperty("--gradient-color-3", colors[2]);
  },

  generateGradientColors(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = (hash << 5) - hash + char;
      hash = hash & hash;
    }

    const baseHue = Math.abs(hash % 360);
    const saturation = 50 + (Math.abs(hash >> 8) % 30);
    const lightness = 45 + (Math.abs(hash >> 16) % 20);

    return [
      `hsl(${baseHue}, ${saturation}%, ${lightness}%)`,
      `hsl(${(baseHue + 40) % 360}, ${saturation - 10}%, ${lightness + 5}%)`,
      `hsl(${(baseHue + 80) % 360}, ${saturation - 20}%, ${lightness + 10}%)`,
    ];
  },
};

export default GradientFallback;
