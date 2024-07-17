// crypto.js

export class CryptoManager extends EventTarget {
  static getInstance() {
    if (!CryptoManager.instance) {
      CryptoManager.instance = new CryptoManager();
      window.cryptoManager = CryptoManager.instance;
    }

    return CryptoManager.instance;
  }

  static getPassphraseFromLocalStorage() {
    const encryptedPassphrase = localStorage.getItem('encryptedPassphrase');

    return encryptedPassphrase ? atob(encryptedPassphrase) : undefined;
  }

  static savePassphraseToLocalStorage(passphrase) {
    localStorage.setItem('encryptedPassphrase', btoa(passphrase));
  }

  constructor() {
    super();

    this.publicKey = null;
    this.privateKey = null;
    this.privateKeyEncrypted = null;
    this.salt = null;
    this.encryptready = false;
    this.decryptready = false;
    this.autoloading = false;
  }

  emitEvent(eventName, detail = {}) {
    const event = new CustomEvent(eventName, { detail });
    this.dispatchEvent(event);
  }

  async generateKeyPair() {
    const keyPair = await window.crypto.subtle.generateKey(
      {
        name: 'RSA-OAEP',
        modulusLength: 2048,
        publicExponent: new Uint8Array([1, 0, 1]),
        hash: 'SHA-256',
      },
      true,
      ['encrypt', 'decrypt']
    );

    this.publicKey = keyPair.publicKey;
    this.privateKey = keyPair.privateKey;

    this.encryptready = true;
    this.emitEvent('encryptready');

    this.decryptready = true;
    this.emitEvent('decryptready');
  }

  async encryptPrivateKey(passphrase) {
    if (!this.privateKey) {
      throw new Error('Private key not available');
    }

    this.salt = window.crypto.getRandomValues(new Uint8Array(16));
    const keyMaterial = await this.getKeyMaterial(passphrase);
    const key = await this.deriveKey(keyMaterial, this.salt);

    this.privateKeyEncrypted = await window.crypto.subtle.encrypt(
      { name: 'AES-GCM', iv: this.salt },
      key,
      await window.crypto.subtle.exportKey('pkcs8', this.privateKey)
    );
  }

  lock() {
    this.privateKey = null;
    localStorage.removeItem('encryptedPassphrase');
    this.decryptready = false;
    this.emitEvent('decryptnotready');
  }

  async unlock(passphrase) {
    if (!this.privateKeyEncrypted) {
      throw new Error('Encrypted private key not available');
    }

    this.decryptready = false;
    this.encryptready = false;

    // start from scratch pls
    this.privateKey = null;

    const keyMaterial = await this.getKeyMaterial(passphrase);
    const key = await this.deriveKey(keyMaterial, this.salt);

    let privateKeyData;

    try {
      privateKeyData = await window.crypto.subtle.decrypt(
        { name: 'AES-GCM', iv: this.salt },
        key,
        this.privateKeyEncrypted
      );
    } catch (error) {
      throw new Error('Incorrect passphrase');
    }

    this.privateKey = await window.crypto.subtle.importKey(
      'pkcs8',
      privateKeyData,
      { name: 'RSA-OAEP', hash: 'SHA-256' },
      true,
      ['decrypt']
    );

    this.decryptready = true;
    this.emitEvent('decryptready');

    this.encryptready = true;
    this.emitEvent('encryptready');
  }

  async getKeyMaterial(passphrase) {
    return window.crypto.subtle.importKey(
      'raw',
      new TextEncoder().encode(passphrase),
      { name: 'PBKDF2' },
      false,
      ['deriveBits', 'deriveKey']
    );
  }

  async deriveKey(keyMaterial, salt) {
    return window.crypto.subtle.deriveKey(
      {
        name: 'PBKDF2',
        salt: salt,
        iterations: 100000,
        hash: 'SHA-256',
      },
      keyMaterial,
      { name: 'AES-GCM', length: 256 },
      true,
      ['encrypt', 'decrypt']
    );
  }

  async changePassphrase(oldPassphrase, newPassphrase) {
    await this.unlock(oldPassphrase);
    await this.encryptPrivateKey(newPassphrase);
  }

  async encrypt(data) {
    const dataBuffer = await window.crypto.subtle.encrypt(
      {
        name: 'RSA-OAEP',
      },
      this.publicKey,
      new TextEncoder().encode(data)
    );

    return this.arrayBufferToBase64(dataBuffer);
  }

  async decrypt(ciphertext) {
    if (!this.privateKey) {
      throw new Error('Private key not available');
    }

    const dataBuffer = this.base64ToArrayBuffer(ciphertext);

    const decrypted = await window.crypto.subtle.decrypt(
      {
        name: 'RSA-OAEP',
      },
      this.privateKey,
      dataBuffer
    );

    return new TextDecoder().decode(decrypted);
  }

  async autoload() {
    if (this.autoloading) return;

    this.autoloading = true;

    await this.load();

    const passphrase = CryptoManager.getPassphraseFromLocalStorage();
    if (passphrase && this.privateKeyEncrypted) {
      try {
        await this.unlock(passphrase);
      } catch (error) {
        console.error(
          'Failed to unlock using passphrase from localstorage',
          error
        );
      }
    }

    this.autoloading = false;
  }

  isInitialized() {
    return (
      this.publicKey !== null &&
      this.privateKeyEncrypted !== null &&
      this.salt !== null
    );
  }

  async load() {
    if (this.isInitialized()) {
      return;
    }

    const currentUserDataElement = document.getElementById('current-user-data');
    const data = JSON.parse(currentUserDataElement.textContent);
    await this.importPublicKey(data.public_key_base64);
    this.importPrivateKeyEncrypted(data.private_key_ciphertext);
    this.importSalt(data.salt_base64);
  }

  async save() {
    if (!this.isInitialized()) {
      throw new Error('CryptoManager not initialized');
    }

    try {
      const response = await fetch('/account', {
        method: 'PATCH',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken(), // Rails CSRF protection
        },
        credentials: 'same-origin',
        body: JSON.stringify({
          user: {
            public_key_base64: await this.exportPublicKey(),
            private_key_ciphertext: this.exportPrivateKeyEncrypted(),
            salt_base64: this.exportSalt(),
          },
        }),
      });

      if (!response.ok) {
        throw new Error('Network response was not ok');
      }

      const result = await response.json();
      return result.status === 'success';
    } catch (error) {
      console.error('Error saving crypto data to server:', error);
      return false;
    }
  }

  // Helper methods for key import/export and data conversion

  async importPublicKey(publicKeyString) {
    if (!publicKeyString) {
      this.publicKey = undefined;
      this.emitEvent('encryptnotready');
      this.encryptready = false;
      return;
    }

    try {
      const publicKeyBuffer = this.base64ToArrayBuffer(publicKeyString);
      const publicKey = await window.crypto.subtle.importKey(
        'spki',
        publicKeyBuffer,
        {
          name: 'RSA-OAEP',
          hash: 'SHA-256',
        },
        true,
        ['encrypt']
      );

      this.publicKey = publicKey;
      this.emitEvent('encryptready');
      this.encryptready = true;
    } catch (error) {
      console.error('Error importing public key:', error);
    }
  }

  importPrivateKeyEncrypted(privateKeyEncryptedString) {
    this.privateKeyEncrypted = privateKeyEncryptedString
      ? this.base64ToArrayBuffer(privateKeyEncryptedString)
      : undefined;
  }

  importSalt(saltString) {
    this.salt = saltString ? this.base64ToArrayBuffer(saltString) : undefined;
  }

  async exportPublicKey() {
    const exported = await window.crypto.subtle.exportKey(
      'spki',
      this.publicKey
    );
    return this.arrayBufferToBase64(exported);
  }

  exportPrivateKeyEncrypted() {
    return this.privateKeyEncrypted
      ? this.arrayBufferToBase64(this.privateKeyEncrypted)
      : undefined;
  }

  exportSalt() {
    return this.salt ? this.arrayBufferToBase64(this.salt) : undefined;
  }

  arrayBufferToBase64(buffer) {
    return btoa(String.fromCharCode.apply(null, new Uint8Array(buffer)));
  }

  base64ToArrayBuffer(base64) {
    const binaryString = atob(base64);
    const bytes = new Uint8Array(binaryString.length);
    for (let i = 0; i < binaryString.length; i++) {
      bytes[i] = binaryString.charCodeAt(i);
    }
    return bytes.buffer;
  }

  getCSRFToken() {
    return document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content');
  }
}
