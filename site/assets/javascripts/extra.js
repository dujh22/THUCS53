document$.subscribe(() => {
  document.querySelectorAll(".md-typeset table").forEach((table) => {
    if (table.parentElement?.classList.contains("table-scroll")) return;
    const wrapper = document.createElement("div");
    wrapper.className = "table-scroll";
    table.parentNode.insertBefore(wrapper, table);
    wrapper.appendChild(table);
  });

  const cards = document.querySelectorAll(".portal-card, .stat-card, .timeline-item");
  if (!cards.length || window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 });

  cards.forEach((card, index) => {
    card.style.setProperty("--reveal-delay", `${Math.min(index * 45, 240)}ms`);
    card.classList.add("reveal-ready");
    observer.observe(card);
  });
});
