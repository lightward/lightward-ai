import { CryptoManager } from 'src/crypto';

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

    if (this.cryptoManager.decryptready) {
      this.decryptField();
    } else {
      this.cryptoManager.addEventListener('decryptready', () =>
        this.decryptField()
      );
    }
  }

  setupElements() {
    // Make light element invisible but focusable
    this.lightElement.style.opacity = '0';
    this.lightElement.style.position = 'absolute';
    this.lightElement.style.pointerEvents = 'none';

    // Ensure shadow element doesn't interfere with form submission
    this.shadowElement.removeAttribute('name');
  }

  setupEventListeners() {
    this.shadowElement.addEventListener(
      'input',
      this.handlePlaintextInput.bind(this)
    );
    this.lightElement.addEventListener(
      'focus',
      this.handleLightElementFocus.bind(this)
    );
    this.shadowElement.addEventListener(
      'blur',
      this.handleShadowElementBlur.bind(this)
    );
  }

  handleLightElementFocus() {
    // Transfer focus to shadow element
    this.shadowElement.focus();
  }

  handleShadowElementBlur() {
    // Validate light element on blur
    this.lightElement.dispatchEvent(new Event('change', { bubbles: true }));
  }

  async handlePlaintextInput() {
    if (this.cryptoManager.publicKey) {
      const plaintext = this.shadowElement.value;
      if (plaintext) {
        this.lightElement.value = await this.cryptoManager.encrypt(plaintext);
      } else {
        this.lightElement.value = '';
      }
      // Trigger validation on light element
      this.lightElement.dispatchEvent(new Event('input', { bubbles: true }));
    }
  }

  async decryptField() {
    if (this.cryptoManager.decryptready && this.lightElement.value) {
      try {
        const plaintext = await this.cryptoManager.decrypt(
          this.lightElement.value
        );
        this.shadowElement.value = plaintext;
      } catch (error) {
        console.error('Decryption failed:', error);
        this.shadowElement.value = '';
      }
    }
  }
}

customElements.define('crypto-field', CryptoField);
