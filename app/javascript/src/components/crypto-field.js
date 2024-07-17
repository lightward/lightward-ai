import { CryptoManager } from 'src/concerns/crypto';

class CryptoField extends HTMLElement {
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

    this.fieldId = this.getAttribute('field-id');
    this.shadowElement = this.shadowRoot.querySelector(`#${this.fieldId}`);
    this.lightElement = this.querySelector(`#${this.fieldId}`);

    if (!this.shadowElement || !this.lightElement) {
      console.error(`No field found with id: ${this.fieldId}`);
      return;
    }

    this.setupElements();
    this.setupEventListeners();

    await this.cryptoManager.autoload();

    if (this.cryptoManager.locked === false) {
      this.decryptField();
    } else {
      this.cryptoManager.addEventListener('unlocked', () =>
        this.decryptField()
      );
    }
  }

  setupElements() {
    // Ensure shadow element doesn't interfere with form submission
    this.shadowElement.removeAttribute('name');

    // Disable shadow element until decryption is ready
    this.shadowElement.disabled = true;
  }

  setupEventListeners() {
    this.shadowElement.addEventListener(
      'input',
      this.handlePlaintextInput.bind(this)
    );
  }

  async handlePlaintextInput() {
    if (this.cryptoManager.publicKey) {
      const plaintext = this.shadowElement.value;
      if (plaintext) {
        this.lightElement.value = await this.cryptoManager.encrypt(plaintext);
      } else {
        this.lightElement.value = '';
      }
    }
  }

  async decryptField() {
    if (this.cryptoManager.locked === false) {
      if (this.lightElement.value) {
        try {
          const plaintext = await this.cryptoManager.decrypt(
            this.lightElement.value
          );
          this.shadowElement.value = plaintext;
        } catch (error) {
          console.error('Decryption failed:', error);
        }
      }

      this.shadowElement.disabled = false;
    }
  }
}

customElements.define('crypto-field', CryptoField);
