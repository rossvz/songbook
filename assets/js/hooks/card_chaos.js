const CardChaos = {
  mounted() {
    this.applyRandomChaos();
  },

  updated() {
    if (!this.el.style.getPropertyValue("--card-rotate")) {
      this.applyRandomChaos();
    }
  },

  applyRandomChaos() {
    const rotation = (Math.random() * 4 - 1).toFixed(2);
    const offsetX = (Math.random() * 30 - 15).toFixed(1);
    const offsetY = (Math.random() * 6 - 3).toFixed(1);

    const index = Array.from(this.el.parentNode?.children || []).indexOf(
      this.el,
    );
    const directionBias = index % 2 === 0 ? 1 : -1;
    const biasedOffsetX = parseFloat(offsetX) + directionBias * 8;
    const biasedRotation = parseFloat(rotation) + directionBias * 0.3;

    this.el.style.setProperty(
      "transform",
      `rotate(${biasedRotation.toFixed(2)}deg) translate(${biasedOffsetX.toFixed(1)}px, ${offsetY}px)`,
      "important",
    );

    this.el.style.setProperty(
      "--card-rotate",
      `${biasedRotation.toFixed(2)}deg`,
    );
    this.el.style.setProperty(
      "--card-offset-x",
      `${biasedOffsetX.toFixed(1)}px`,
    );
    this.el.style.setProperty("--card-offset-y", `${offsetY}px`);

    this.el.dataset.baseRotate = biasedRotation.toFixed(2);
    this.el.dataset.baseOffsetX = biasedOffsetX.toFixed(1);
    this.el.dataset.baseOffsetY = offsetY;
  },
};

export default CardChaos;
