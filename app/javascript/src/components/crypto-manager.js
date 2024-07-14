import { CryptoManager } from 'src/crypto';

class CryptoManagerComponent extends HTMLElement {
  constructor() {
    super();
    this.cryptoManager = new CryptoManager();
  }

  connectedCallback() {
    if (!this.shadowRoot) {
      const template = this.querySelector('template');
      const shadowRoot = this.attachShadow({ mode: 'open' });
      shadowRoot.appendChild(template.content.cloneNode(true));
    }

    this.statusMessage = this.shadowRoot.getElementById('statusMessage');
    this.passphraseForm = this.shadowRoot.getElementById('passphraseForm');
    this.changePassphraseForm = this.shadowRoot.getElementById(
      'changePassphraseForm'
    );

    this.passphraseForm.addEventListener(
      'submit',
      this.handlePassphraseSubmit.bind(this)
    );
    this.changePassphraseForm.addEventListener(
      'submit',
      this.handleChangePassphrase.bind(this)
    );

    this.initialize();
  }

  async initialize() {
    const maybePassphrase = this.getPassphraseFromLocalStorage();
    await this.cryptoManager.loadFromServer(maybePassphrase);

    if (!this.cryptoManager.encryptedPrivateKey) {
      this.updateStatus(
        'No private key present yet; choose a passphrase to generate one.'
      );
      this.promptForPassphrase();
    } else if (!this.cryptoManager.privateKey) {
      this.updateStatus(
        'Private key encrypted; please enter your passphrase to decrypt it.'
      );
      this.promptForPassphrase();
    } else {
      this.updateStatus('Private key decrypted successfully.');
      this.showChangePassphraseForm();
    }
  }

  generateSecurePassphrase() {
    const array = new Uint8Array(32);
    window.crypto.getRandomValues(array);
    return Array.from(array, (byte) => byte.toString(16).padStart(2, '0')).join(
      ''
    );
  }

  getPassphraseFromLocalStorage() {
    return atob(localStorage.getItem('encryptedPassphrase'));
  }

  savePassphraseToLocalStorage(passphrase) {
    localStorage.setItem('encryptedPassphrase', btoa(passphrase));
  }

  promptForPassphrase() {
    this.passphraseForm.classList.remove('hidden');
  }

  async handlePassphraseSubmit(event) {
    event.preventDefault();
    const passphrase = this.shadowRoot.getElementById('passphrase').value;

    if (!this.cryptoManager.encryptedPrivateKey) {
      await this.cryptoManager.generateKeyPair();
      await this.cryptoManager.encryptPrivateKey(passphrase);
      await this.cryptoManager.saveToServer();
      this.savePassphraseToLocalStorage(passphrase);
      this.updateStatus('Private key generated and encrypted successfully.');
      this.passphraseForm.classList.add('hidden');
      this.showChangePassphraseForm();
      return;
    }

    try {
      await this.cryptoManager.decryptPrivateKey(passphrase);
      this.savePassphraseToLocalStorage(passphrase);
      this.updateStatus('Private key decrypted successfully.');
      this.passphraseForm.classList.add('hidden');
      this.showChangePassphraseForm();
    } catch (error) {
      this.updateStatus('Invalid passphrase. Please try again.');
    }
  }

  async handleChangePassphrase(event) {
    event.preventDefault();
    const oldPassphrase = this.shadowRoot.getElementById('oldPassphrase').value;
    const newPassphrase = this.shadowRoot.getElementById('newPassphrase').value;
    try {
      await this.cryptoManager.changePassphrase(oldPassphrase, newPassphrase);
      await this.cryptoManager.saveToServer();
      this.savePassphraseToLocalStorage(newPassphrase);
      this.updateStatus('Passphrase changed successfully.');
    } catch (error) {
      this.updateStatus(
        'Failed to change passphrase. Please check your old passphrase and try again.'
      );
    }
  }

  updateStatus(message) {
    this.statusMessage.textContent = message;
  }

  showChangePassphraseForm() {
    this.changePassphraseForm.classList.remove('hidden');
  }
}

customElements.define('crypto-manager', CryptoManagerComponent);
