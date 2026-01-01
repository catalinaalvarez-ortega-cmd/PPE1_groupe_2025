(() => {

  document.body.classList.add("has-io");

  const revealEls = Array.from(document.querySelectorAll(".reveal"));
  if (revealEls.length) {
    const io = new IntersectionObserver((entries) => {
      entries.forEach(en => {
        if (en.isIntersecting) en.target.classList.add("is-visible");
      });
    }, { threshold: 0.12 });

    revealEls.forEach(el => io.observe(el));
  }

  document.querySelectorAll(".js-spotlight").forEach(card => {
    card.addEventListener("mousemove", (e) => {
      const r = card.getBoundingClientRect();
      const x = ((e.clientX - r.left) / r.width) * 100;
      const y = ((e.clientY - r.top) / r.height) * 100;
      card.style.setProperty("--mx", x + "%");
      card.style.setProperty("--my", y + "%");
    });
  });

  const toTop = document.getElementById("toTop");
  if (toTop) {
    function onScroll(){ toTop.classList.toggle("is-visible", window.scrollY > 500); }
    window.addEventListener("scroll", onScroll, { passive: true });
    onScroll();
    toTop.addEventListener("click", () => window.scrollTo({ top: 0, behavior: "smooth" }));
  }
})();
