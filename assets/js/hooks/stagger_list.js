const StaggerList = {
  mounted() {
    this.applyStagger();
  },

  updated() {
    this.applyStagger();
  },

  applyStagger() {
    const children = this.el.querySelectorAll("[data-stagger]");
    children.forEach((child, index) => {
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

export default StaggerList;
