import { CryptoManager } from 'src/crypto';

class CryptoManagerComponent extends HTMLElement {
  constructor() {
    super();
    this.cryptoManager = CryptoManager.getInstance();
  }

  connectedCallback() {
    if (!this.shadowRoot) {
      const template = this.querySelector('template');
      const shadowRoot = this.attachShadow({ mode: 'open' });
      shadowRoot.appendChild(template.content.cloneNode(true));
    }

    this.wrapper = this.shadowRoot.getElementById('wrapper');

    this.statusMessage = this.shadowRoot.getElementById('statusMessage');

    this.lockButton = this.shadowRoot.getElementById('lockButton');
    this.lockButton.addEventListener('click', () => this.cryptoManager.lock());

    this.unlockButton = this.shadowRoot.getElementById('unlockButton');
    this.unlockButton.addEventListener('click', () => this.showUnlockForm());

    this.changePassphraseButton = this.shadowRoot.getElementById(
      'changePassphraseButton'
    );
    this.changePassphraseButton.addEventListener('click', () =>
      this.showChangePassphraseForm()
    );

    this.initForm = this.shadowRoot.getElementById('initForm');
    this.unlockForm = this.shadowRoot.getElementById('unlockForm');
    this.changePassphraseForm = this.shadowRoot.getElementById(
      'changePassphraseForm'
    );

    this.initForm.addEventListener(
      'submit',
      this.handleInitFormSubmit.bind(this)
    );

    this.unlockForm.addEventListener(
      'submit',
      this.handleUnlockFormSubmit.bind(this)
    );

    this.changePassphraseForm.addEventListener(
      'submit',
      this.handleChangePassphraseFormSubmit.bind(this)
    );

    this.shadowRoot
      .getElementById('cancelUnlockButton')
      .addEventListener('click', () => (this.wrapper.dataset.view = 'main'));

    this.shadowRoot
      .getElementById('cancelChangePassphraseButton')
      .addEventListener('click', () => (this.wrapper.dataset.view = 'main'));

    this.initialize();
  }

  async initialize() {
    this.cryptoManager.addEventListener('decryptready', () => {
      this.wrapper.dataset.locked = 'false';
      this.updateStatus('Your account is unlocked.');
    });

    this.cryptoManager.addEventListener('decryptnotready', () => {
      this.wrapper.dataset.locked = 'true';
      this.updateStatus('Your account is locked');
    });

    await this.cryptoManager.autoload();

    if (!this.cryptoManager.encryptedPrivateKey) {
      this.updateStatus(
        'No private key present yet; choose a passphrase to generate one.'
      );

      this.view('init');
    }
  }

  updateStatus(message) {
    this.statusMessage.textContent = message;
  }

  view(viewName) {
    this.wrapper.dataset.view = viewName;
  }

  async handleInitFormSubmit(event) {
    event.preventDefault();
    if (this.cryptoManager.encryptedPrivateKey) {
      return;
    }

    const passphrase = this.shadowRoot.getElementById('initPassphrase').value;

    await this.cryptoManager.generateKeyPair();
    await this.cryptoManager.encryptPrivateKey(passphrase);
    await this.cryptoManager.saveToServer();
    CryptoManager.savePassphraseToLocalStorage(passphrase);
    this.updateStatus('Private key generated and encrypted successfully.');
    this.initForm.classList.add('hidden');
  }

  async handleUnlockFormSubmit(event) {
    event.preventDefault();

    if (!this.cryptoManager.encryptedPrivateKey) {
      return;
    }

    const passphrase = this.shadowRoot.getElementById('unlockPassphrase').value;

    try {
      await this.cryptoManager.unlock(passphrase);

      CryptoManager.savePassphraseToLocalStorage(passphrase);
      this.updateStatus('Private key decrypted successfully.');
      this.unlockForm.classList.add('hidden');
    } catch (error) {
      this.updateStatus('Invalid passphrase. Please try again.');
    }
  }

  async handleChangePassphraseFormSubmit(event) {
    event.preventDefault();
    const oldPassphrase = this.shadowRoot.getElementById('oldPassphrase').value;
    const newPassphrase = this.shadowRoot.getElementById('newPassphrase').value;
    const confirmPassphrase =
      this.shadowRoot.getElementById('confirmPassphrase').value;

    if (newPassphrase !== confirmPassphrase) {
      this.updateStatus('New passphrase and confirmation do not match.');
      return;
    }

    try {
      await this.cryptoManager.changePassphrase(oldPassphrase, newPassphrase);
      await this.cryptoManager.saveToServer();
      CryptoManager.savePassphraseToLocalStorage(newPassphrase);
      this.updateStatus('Passphrase changed successfully.');

      this.shadowRoot.getElementById('oldPassphrase').value = '';
      this.shadowRoot.getElementById('newPassphrase').value = '';
      this.shadowRoot.getElementById('confirmPassphrase').value = '';
      this.changePassphraseForm.classList.add('hidden');
    } catch (error) {
      this.updateStatus(
        'Failed to change passphrase. Please check your old passphrase and try again.'
      );
    }
  }
}

customElements.define('crypto-manager', CryptoManagerComponent);
