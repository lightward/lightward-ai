// crypto-decrypt.js

import { CryptoManager } from 'src/concerns/crypto';

class CryptoDecrypt extends HTMLElement {
  constructor() {
    super();
    this.cryptoManager = CryptoManager.getInstance();
  }

  async connectedCallback() {
    if (!this.shadowRoot) {
      const template = this.querySelector('template');
      const shadowRoot = this.attachShadow({ mode: 'open' });
      shadowRoot.appendChild(template.content.cloneNode(true));
    }

    this.contentSpan = this.shadowRoot.getElementById('content');
    this.ciphertext = this.innerHTML.trim();

    await this.cryptoManager.autoload();

    if (this.cryptoManager.decryptready) {
      this.attemptDecryption();
    } else {
      this.cryptoManager.addEventListener('decryptready', () =>
        this.attemptDecryption()
      );
    }
  }

  async attemptDecryption() {
    if (this.cryptoManager.decryptready && this.ciphertext) {
      try {
        const plaintext = await this.cryptoManager.decrypt(this.ciphertext);
        this.contentSpan.textContent = plaintext;

        // update parent element with decrypted content
        const parent = this.parentNode;
        if (parent) {
          parent.innerHTML = plaintext;
        }
      } catch (error) {
        debugger;
        console.error('Decryption failed:', error);
        this.contentSpan.textContent = 'Decryption failed';
      }
    }
  }
}

customElements.define('crypto-decrypt', CryptoDecrypt);
