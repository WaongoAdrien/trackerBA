/* Theme switch, shared by all five pages.
   Loaded in <head> so the attribute is on <html> before the first paint —
   moving it to the end of <body> would show a flash of the dark theme. */
(function () {
  "use strict";

  var KEY  = "tracker-theme";
  var root = document.documentElement;

  function stored() {
    try { return localStorage.getItem(KEY); } catch (e) { return null; }
  }

  function preferred() {
    return window.matchMedia && window.matchMedia("(prefers-color-scheme: light)").matches
      ? "light" : "dark";
  }

  var saved = stored();
  var theme = (saved === "light" || saved === "dark") ? saved : preferred();

  function apply(next) {
    theme = next;
    root.setAttribute("data-theme", theme);
    var label = theme === "light" ? "Dark mode" : "Light mode";
    var buttons = document.querySelectorAll("[data-theme-toggle]");
    for (var i = 0; i < buttons.length; i++) {
      buttons[i].textContent = theme === "light" ? "☾ Dark" : "☀ Light";
      buttons[i].title = label;
      buttons[i].setAttribute("aria-label", label);
    }
  }

  apply(theme);

  // The buttons do not exist yet at head time, so label them once they do.
  document.addEventListener("DOMContentLoaded", function () { apply(theme); });

  document.addEventListener("click", function (e) {
    var btn = e.target.closest && e.target.closest("[data-theme-toggle]");
    if (!btn) return;
    var next = theme === "light" ? "dark" : "light";
    try { localStorage.setItem(KEY, next); } catch (err) {}
    apply(next);
  });

  // Follow the system only while the user has not picked a side themselves.
  if (window.matchMedia) {
    var mq = window.matchMedia("(prefers-color-scheme: light)");
    var onChange = function () { if (!stored()) apply(preferred()); };
    if (mq.addEventListener) mq.addEventListener("change", onChange);
    else if (mq.addListener) mq.addListener(onChange);
  }
})();
