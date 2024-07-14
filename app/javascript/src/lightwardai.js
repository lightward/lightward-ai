// LightwardAI.js

import { pbkdf2Sync, randomBytes } from 'crypto';

const LightwardAI = {
  publicKey: null,
  encryptedPrivateKey: null,
  salt: null,

  // Generate a secure key from passphrase
  deriveKey(passphrase, salt) {
    return pbkdf2Sync(passphrase, salt, 100000, 32, 'sha256');
  },

  // Generate a new key pair
  async generateKeyPair() {
    const keyPair = await window.crypto.subtle.generateKey(
      {
        name: 'RSA-OAEP',
        modulusLength: 4096,
        publicExponent: new Uint8Array([1, 0, 1]),
        hash: 'SHA-256',
      },
      true,
      ['encrypt', 'decrypt']
    );

    const publicKey = await window.crypto.subtle.exportKey(
      'spki',
      keyPair.publicKey
    );
    const privateKey = await window.crypto.subtle.exportKey(
      'pkcs8',
      keyPair.privateKey
    );

    this.publicKey = btoa(
      String.fromCharCode.apply(null, new Uint8Array(publicKey))
    );
    return btoa(String.fromCharCode.apply(null, new Uint8Array(privateKey)));
  },

  // Encrypt private key with passphrase
  encryptPrivateKey(privateKey, passphrase) {
    this.salt = randomBytes(16).toString('hex');
    const key = this.deriveKey(passphrase, this.salt);
    const iv = randomBytes(16);
    const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
    let encrypted = cipher.update(privateKey, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    this.encryptedPrivateKey = iv.toString('hex') + ':' + encrypted;
  },

  // Decrypt private key with passphrase
  decryptPrivateKey(passphrase) {
    if (!this.encryptedPrivateKey)
      throw new Error('No encrypted private key available');
    if (!this.salt) throw new Error('Salt not found');
    const key = this.deriveKey(passphrase, this.salt);
    const [ivHex, encryptedData] = this.encryptedPrivateKey.split(':');
    const iv = Buffer.from(ivHex, 'hex');
    const decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);
    let decrypted = decipher.update(encryptedData, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
  },

  // Get current state
  getState() {
    return {
      hasPublicKey: !!this.publicKey,
      hasEncryptedPrivateKey: !!this.encryptedPrivateKey,
      hasPassphrase: !!this.salt,
    };
  },

  // Clear all data
  clear() {
    this.publicKey = null;
    this.encryptedPrivateKey = null;
    this.salt = null;
  },

  // Save crypto data to server
  async saveCryptoData() {
    if (!this.publicKey || !this.encryptedPrivateKey || !this.salt) {
      throw new Error('Incomplete crypto data');
    }

    const response = await fetch('/account', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({
        user: {
          public_key: this.publicKey,
          encrypted_private_key: this.encryptedPrivateKey,
          salt: this.salt,
        },
      }),
    });

    if (!response.ok) {
      throw new Error('Failed to save crypto data');
    }

    return await response.json();
  },

  // Load crypto data from server
  async loadCryptoData() {
    const response = await fetch('/account', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error('Failed to load crypto data');
    }

    const data = await response.json();
    this.publicKey = data.public_key;
    this.encryptedPrivateKey = data.encrypted_private_key;
    this.salt = data.salt;
  },

  // Initialize or update crypto data
  async initializeOrUpdateCrypto(passphrase) {
    await this.loadCryptoData();

    if (!this.publicKey || !this.encryptedPrivateKey) {
      const privateKey = await this.generateKeyPair();
      this.encryptPrivateKey(privateKey, passphrase);
      await this.saveCryptoData();
    }
  },
};

export default LightwardAI;
