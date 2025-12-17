const SwipeToHide = {
  mounted() {
    this.initSwipe();
  },

  destroyed() {
    this.cleanup();
  },

  updated() {
    if (!this.initialized) {
      this.initSwipe();
    }
  },

  initSwipe() {
    this.initialized = true;
    this.startX = 0;
    this.startY = 0;
    this.currentX = 0;
    this.isDragging = false;
    this.isHorizontalSwipe = null;
    this.threshold = -100;
    this.maxSwipe = -150;

    this.applyRandomChaos();

    this.el.style.touchAction = "pan-y";

    this.el.addEventListener("touchstart", this.handleTouchStart.bind(this), {
      passive: false,
    });
    this.el.addEventListener("touchmove", this.handleTouchMove.bind(this), {
      passive: false,
    });
    this.el.addEventListener("touchend", this.handleTouchEnd.bind(this));
    this.el.addEventListener("touchcancel", this.handleTouchEnd.bind(this));

    this.el.addEventListener("mousedown", this.handleMouseDown.bind(this));
    this._mouseMoveHandler = this.handleMouseMove.bind(this);
    this._mouseUpHandler = this.handleMouseUp.bind(this);
    document.addEventListener("mousemove", this._mouseMoveHandler);
    document.addEventListener("mouseup", this._mouseUpHandler);
  },

  cleanup() {
    document.removeEventListener("mousemove", this._mouseMoveHandler);
    document.removeEventListener("mouseup", this._mouseUpHandler);
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

    this.baseRotation = biasedRotation;
    this.baseOffsetX = biasedOffsetX;
    this.baseOffsetY = parseFloat(offsetY);

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
  },

  handleTouchStart(e) {
    if (e.target.closest(".btn-vote")) return;

    this.startX = e.touches[0].clientX;
    this.startY = e.touches[0].clientY;
    this.isDragging = true;
    this.isHorizontalSwipe = null;
    this.currentX = 0;
    this.el.style.transition = "none";
  },

  handleTouchMove(e) {
    if (!this.isDragging) return;

    const touch = e.touches[0];
    const deltaX = touch.clientX - this.startX;
    const deltaY = touch.clientY - this.startY;

    if (this.isHorizontalSwipe === null) {
      const absX = Math.abs(deltaX);
      const absY = Math.abs(deltaY);

      if (absX > 10 || absY > 10) {
        this.isHorizontalSwipe = absX > absY && deltaX < 0;
      }
    }

    if (this.isHorizontalSwipe) {
      e.preventDefault();
      e.stopPropagation();
      this.currentX = Math.max(this.maxSwipe, deltaX);
      this.applySwipeTransform();
    }
  },

  handleTouchEnd() {
    if (!this.isDragging) return;
    this.isDragging = false;

    if (this.isHorizontalSwipe) {
      this.finalizeSwipe();
    } else {
      this.currentX = 0;
    }

    this.isHorizontalSwipe = null;
  },

  handleMouseDown(e) {
    if (e.target.closest(".btn-vote")) return;

    this.startX = e.clientX;
    this.startY = e.clientY;
    this.isDragging = true;
    this.el.style.transition = "none";
  },

  handleMouseMove(e) {
    if (!this.isDragging) return;

    const deltaX = e.clientX - this.startX;
    if (deltaX < 0) {
      this.currentX = Math.max(this.maxSwipe, deltaX);
      this.applySwipeTransform();
    }
  },

  handleMouseUp() {
    if (!this.isDragging) return;
    this.isDragging = false;
    this.finalizeSwipe();
  },

  applySwipeTransform() {
    const progress = Math.abs(this.currentX / this.threshold);
    const opacity = 1 - progress * 0.3;
    const scale = 1 - progress * 0.05;

    const translateX = this.baseOffsetX + this.currentX;

    this.el.style.transform = `rotate(${this.baseRotation}deg) translate(${translateX}px, ${this.baseOffsetY}px) scale(${scale})`;
    this.el.style.opacity = opacity;

    const indicator = this.el.querySelector(".swipe-indicator");
    if (indicator) {
      indicator.style.opacity = progress > 0.8 ? 1 : progress;
    }
  },

  finalizeSwipe() {
    this.el.style.transition = "transform 0.3s ease, opacity 0.3s ease";

    if (this.currentX <= this.threshold) {
      this.el.style.transform = `rotate(${this.baseRotation}deg) translateX(-100%) scale(0.8)`;
      this.el.style.opacity = "0";

      const trackId = this.el.dataset.trackId;
      this.pushEvent("mark_as_played", { id: trackId });
    } else {
      this.el.style.transform = `rotate(${this.baseRotation}deg) translate(${this.baseOffsetX}px, ${this.baseOffsetY}px)`;
      this.el.style.opacity = "1";
    }

    this.currentX = 0;
  },
};

export default SwipeToHide;
