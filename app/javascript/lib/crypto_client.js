import { box, randomBytes } from 'tweetnacl';
import {
  decodeUTF8,
  encodeUTF8,
  encodeBase64,
  decodeBase64
} from 'tweetnacl-util';

class CryptoClient {
  constructor() {
    this.keyPair = null;
  }

  async initialize() {
    this.keyPair = box.keyPair();
    return {
      publicKey: encodeBase64(this.keyPair.publicKey),
      secretKey: encodeBase64(this.keyPair.secretKey)
    };
  }

  async encryptMessage(message, recipientPublicKey) {
    if (!this.keyPair) {
      throw new Error('CryptoClient not initialized');
    }

    const ephemeralKeyPair = box.keyPair();
    const nonce = randomBytes(box.nonceLength);
    
    const messageUint8 = decodeUTF8(message);
    const recipientPublicKeyUint8 = decodeBase64(recipientPublicKey);
    
    const encryptedMessage = box(
      messageUint8,
      nonce,
      recipientPublicKeyUint8,
      this.keyPair.secretKey
    );

    return {
      encrypted: encodeBase64(encryptedMessage),
      nonce: encodeBase64(nonce),
      ephemeralPublicKey: encodeBase64(ephemeralKeyPair.publicKey)
    };
  }

  async decryptMessage(encryptedData, senderPublicKey) {
    if (!this.keyPair) {
      throw new Error('CryptoClient not initialized');
    }

    const encryptedMessageUint8 = decodeBase64(encryptedData.encrypted);
    const nonceUint8 = decodeBase64(encryptedData.nonce);
    const senderPublicKeyUint8 = decodeBase64(senderPublicKey);
    
    const decryptedMessage = box.open(
      encryptedMessageUint8,
      nonceUint8,
      senderPublicKeyUint8,
      this.keyPair.secretKey
    );

    if (!decryptedMessage) {
      throw new Error('Failed to decrypt message');
    }

    return encodeUTF8(decryptedMessage);
  }

  // Генерация хеша сообщения для сохранения в блокчейне
  async generateMessageHash(message) {
    const encoder = new TextEncoder();
    const data = encoder.encode(message);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  }

  // Проверка целостности сообщения
  async verifyMessageIntegrity(message, hash) {
    const calculatedHash = await this.generateMessageHash(message);
    return calculatedHash === hash;
  }
}

export default new CryptoClient(); 