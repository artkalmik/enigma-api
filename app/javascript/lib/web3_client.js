import Web3 from 'web3';
import EnigmaMessaging from '../contracts/EnigmaMessaging.json';
import EnigmaToken from '../contracts/EnigmaToken.json';

class Web3Client {
  constructor() {
    this.web3 = null;
    this.messagingContract = null;
    this.tokenContract = null;
    this.account = null;
  }

  async initialize() {
    if (window.ethereum) {
      this.web3 = new Web3(window.ethereum);
      try {
        // Запрос доступа к аккаунту
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        const accounts = await this.web3.eth.getAccounts();
        this.account = accounts[0];
        
        // Инициализация контрактов
        const networkId = await this.web3.eth.net.getId();
        const messagingNetwork = EnigmaMessaging.networks[networkId];
        const tokenNetwork = EnigmaToken.networks[networkId];
        
        if (messagingNetwork && tokenNetwork) {
          this.messagingContract = new this.web3.eth.Contract(
            EnigmaMessaging.abi,
            messagingNetwork.address
          );
          
          this.tokenContract = new this.web3.eth.Contract(
            EnigmaToken.abi,
            tokenNetwork.address
          );
        }
        
        return true;
      } catch (error) {
        console.error('User denied account access or error occurred:', error);
        return false;
      }
    } else {
      console.error('Web3 provider not found');
      return false;
    }
  }

  async storeMessage(messageHash, recipient) {
    if (!this.messagingContract || !this.account) {
      throw new Error('Web3 not initialized');
    }
    
    return this.messagingContract.methods
      .storeMessage(messageHash, recipient)
      .send({ from: this.account });
  }

  async verifyMessage(messageHash) {
    if (!this.messagingContract) {
      throw new Error('Web3 not initialized');
    }
    
    return this.messagingContract.methods
      .verifyMessage(messageHash)
      .call();
  }

  async getBalance() {
    if (!this.tokenContract || !this.account) {
      throw new Error('Web3 not initialized');
    }
    
    return this.tokenContract.methods
      .balanceOf(this.account)
      .call();
  }

  async transferTokens(recipient, amount) {
    if (!this.tokenContract || !this.account) {
      throw new Error('Web3 not initialized');
    }
    
    return this.tokenContract.methods
      .transfer(recipient, amount)
      .send({ from: this.account });
  }
}

export default new Web3Client(); 