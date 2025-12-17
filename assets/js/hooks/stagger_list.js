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
      child.style.animationDelay = `${index * 0.1}s`;
      child.classList.add("animate-slide-up");
    });
  },
};

export default StaggerList;
