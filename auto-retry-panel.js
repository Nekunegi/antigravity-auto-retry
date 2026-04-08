(() => {
  // Retryボタンの自動クリックスクリプト（パネル用）
  const RETRY_LABELS = ["retry"];
  const CLICK_COOLDOWN_MS = 1500;
  const lastClick = new WeakMap();

  function isDisabled(el) {
    return el.disabled || el.getAttribute("aria-disabled") === "true";
  }

  function getText(el) {
    return (el.innerText || el.textContent || "").trim().toLowerCase();
  }

  function isVisible(el) {
    const rect = el.getBoundingClientRect();
    return rect.width > 0 && rect.height > 0;
  }

  function matchesRetry(el) {
    const text = getText(el);
    return RETRY_LABELS.some(label => text === label);
  }

  function clickIfRetry(el) {
    if (!el || isDisabled(el) || !isVisible(el) || !matchesRetry(el)) return false;
    const now = Date.now();
    const prev = lastClick.get(el) || 0;
    if (now - prev < CLICK_COOLDOWN_MS) return false;
    lastClick.set(el, now);
    try {
      el.click();
      console.log("[auto-retry-panel] Retryボタンをクリックしました:", getText(el));
      return true;
    } catch (_) {
      return false;
    }
  }

  function findAndClick(root) {
    let clicked = false;
    const exact = root.querySelectorAll?.("button.cursor-pointer.bg-ide-button-background") || [];
    for (const el of exact) if (clickIfRetry(el)) clicked = true;

    const candidates = root.querySelectorAll?.("button, [role='button']") || [];
    for (const el of candidates) if (clickIfRetry(el)) clicked = true;

    return clicked;
  }

  function run() {
    findAndClick(document);
  }

  window.addEventListener("load", () => {
    run();
    // 500ms間隔で定期チェック
    setInterval(run, 500);
    // DOMの変更を監視して即座に反応
    const obs = new MutationObserver(run);
    obs.observe(document.documentElement, { childList: true, subtree: true });
    console.log("[auto-retry-panel] パネル自動リトライが有効化されました");
  });
})();
