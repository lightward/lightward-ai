export const CSRF = {
  token: null,
  tokenMetaTag: document.querySelector('meta[name="csrf-token"]'),
  tokenRefreshInterval: 10 * 60 * 1000, // 10 minutes

  getToken() {
    if (!this.token) {
      this.token = this.tokenMetaTag ? this.tokenMetaTag.content : null;
    }
    return this.token;
  },

  refreshToken() {
    fetch(window.location.href, {
      method: 'GET',
      headers: {
        'Content-Type': 'text/html',
      },
      credentials: 'same-origin', // Ensures cookies are included in the request
    })
      .then((response) => response.text())
      .then((html) => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        const newTokenMetaTag = doc.querySelector('meta[name="csrf-token"]');
        if (newTokenMetaTag) {
          this.token = newTokenMetaTag.content;
          this.tokenMetaTag.content = this.token;
        }
      })
      .catch((error) => console.error('CSRF token refresh error:', error));
  },

  startAutoRefresh() {
    this.refreshToken();
    setInterval(() => this.refreshToken(), this.tokenRefreshInterval);
  },
};

// Start the auto-refresh when this script is loaded
CSRF.startAutoRefresh();
