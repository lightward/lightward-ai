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

    this.initForm = this.shadowRoot.getElementById('initForm');
    this.unlockForm = this.shadowRoot.getElementById('unlockForm');
    this.changePassphraseForm = this.shadowRoot.getElementById(
      'changePassphraseForm'
    );

    this.lockButton = this.shadowRoot.getElementById('lockButton');
    this.changePassphraseButton = this.shadowRoot.getElementById(
      'changePassphraseButton'
    );
    this.cancelChangePassphraseButton = this.shadowRoot.getElementById(
      'cancelChangePassphraseButton'
    );

    this.addEventListeners();
    this.initialize();
  }

  addEventListeners() {
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

    this.lockButton.addEventListener('click', () => this.lock());
    this.changePassphraseButton.addEventListener('click', () =>
      this.showChangePassphraseForm()
    );
    this.cancelChangePassphraseButton.addEventListener('click', () =>
      this.hideChangePassphraseForm()
    );
  }

  async initialize() {
    this.cryptoManager.addEventListener('decryptready', () =>
      this.setState('unlocked')
    );
    this.cryptoManager.addEventListener('decryptnotready', () =>
      this.setState('locked')
    );

    await this.cryptoManager.autoload();

    if (!this.cryptoManager.encryptedPrivateKey) {
      this.setState('uninitialized');
      this.updateStatus(
        'No private key present yet; choose a passphrase to generate one.'
      );
    } else if (this.cryptoManager.decryptready) {
      this.setState('unlocked');
    } else {
      this.setState('locked');
    }
  }

  setState(state) {
    this.wrapper.dataset.state = state;
    switch (state) {
      case 'uninitialized':
        this.updateStatus('Your account is not initialized.');
        break;
      case 'locked':
        this.updateStatus('Your account is locked.');
        break;
      case 'unlocked':
        this.updateStatus('Your account is unlocked.');
        break;
    }
  }

  updateStatus(message) {
    this.statusMessage.textContent = message;
  }

  async handleInitFormSubmit(event) {
    event.preventDefault();
    const passphrase = this.shadowRoot.getElementById('initPassphrase').value;
    const confirmPassphrase =
      this.shadowRoot.getElementById('confirmPassphrase').value;

    if (passphrase !== confirmPassphrase) {
      this.updateStatus('Passphrases do not match. Please try again.');
      return;
    }

    await this.cryptoManager.generateKeyPair();
    await this.cryptoManager.encryptPrivateKey(passphrase);
    await this.cryptoManager.saveToServer();
    CryptoManager.savePassphraseToLocalStorage(passphrase);
    this.updateStatus('Private key generated and encrypted successfully.');
    this.setState('unlocked');
  }

  async handleUnlockFormSubmit(event) {
    event.preventDefault();
    const passphrase = this.shadowRoot.getElementById('unlockPassphrase').value;

    try {
      await this.cryptoManager.unlock(passphrase);
      CryptoManager.savePassphraseToLocalStorage(passphrase);
      this.updateStatus('Private key decrypted successfully.');
      this.setState('unlocked');
    } catch (error) {
      this.updateStatus('Invalid passphrase. Please try again.');
    }
  }

  async handleChangePassphraseFormSubmit(event) {
    event.preventDefault();
    const oldPassphrase = this.shadowRoot.getElementById('oldPassphrase').value;
    const newPassphrase = this.shadowRoot.getElementById('newPassphrase').value;
    const confirmNewPassphrase = this.shadowRoot.getElementById(
      'confirmNewPassphrase'
    ).value;

    if (newPassphrase !== confirmNewPassphrase) {
      this.updateStatus('New passphrases do not match. Please try again.');
      return;
    }

    try {
      await this.cryptoManager.changePassphrase(oldPassphrase, newPassphrase);
      await this.cryptoManager.saveToServer();
      CryptoManager.savePassphraseToLocalStorage(newPassphrase);
      this.updateStatus('Passphrase changed successfully.');
      this.hideChangePassphraseForm();
    } catch (error) {
      this.updateStatus(
        'Failed to change passphrase. Please check your old passphrase and try again.'
      );
    }
  }

  lock() {
    this.cryptoManager.lock();
    this.setState('locked');
  }

  showChangePassphraseForm() {
    this.wrapper.dataset.state = 'changing-passphrase';
  }

  hideChangePassphraseForm() {
    this.wrapper.dataset.state = 'unlocked';
    this.shadowRoot.getElementById('oldPassphrase').value = '';
    this.shadowRoot.getElementById('newPassphrase').value = '';
    this.shadowRoot.getElementById('confirmNewPassphrase').value = '';
  }
}

customElements.define('crypto-manager', CryptoManagerComponent);
