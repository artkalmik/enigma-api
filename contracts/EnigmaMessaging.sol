// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./EnigmaToken.sol";

contract EnigmaMessaging is Ownable, ReentrancyGuard {
    EnigmaToken public token;
    
    struct Message {
        bytes32 messageHash;
        address sender;
        address recipient;
        uint256 timestamp;
        bool isRevoked;
    }
    
    // Маппинг хешей сообщений к их данным
    mapping(bytes32 => Message) public messages;
    
    // События
    event MessageStored(bytes32 indexed messageHash, address indexed sender, address indexed recipient);
    event MessageRevoked(bytes32 indexed messageHash, address indexed sender);
    event MessageVerified(bytes32 indexed messageHash, bool isValid);
    
    // Стоимость отправки сообщения в токенах
    uint256 public constant MESSAGE_COST = 1 * 10**18; // 1 TOKEN
    
    constructor(address _tokenAddress) {
        token = EnigmaToken(_tokenAddress);
    }
    
    // Сохранение сообщения
    function storeMessage(bytes32 _messageHash, address _recipient) external nonReentrant {
        require(_recipient != address(0), "Invalid recipient");
        require(messages[_messageHash].timestamp == 0, "Message already exists");
        
        // Списание токенов
        require(token.transferFrom(msg.sender, address(this), MESSAGE_COST), "Token transfer failed");
        
        // Сохранение сообщения
        messages[_messageHash] = Message({
            messageHash: _messageHash,
            sender: msg.sender,
            recipient: _recipient,
            timestamp: block.timestamp,
            isRevoked: false
        });
        
        emit MessageStored(_messageHash, msg.sender, _recipient);
    }
    
    // Отзыв сообщения
    function revokeMessage(bytes32 _messageHash) external {
        Message storage message = messages[_messageHash];
        require(message.timestamp > 0, "Message does not exist");
        require(message.sender == msg.sender, "Not message sender");
        require(!message.isRevoked, "Message already revoked");
        
        message.isRevoked = true;
        emit MessageRevoked(_messageHash, msg.sender);
    }
    
    // Проверка сообщения
    function verifyMessage(bytes32 _messageHash) external view returns (bool) {
        Message memory message = messages[_messageHash];
        bool isValid = message.timestamp > 0 && !message.isRevoked;
        
        return isValid;
    }
    
    // Получение данных сообщения
    function getMessage(bytes32 _messageHash) external view returns (
        address sender,
        address recipient,
        uint256 timestamp,
        bool isRevoked
    ) {
        Message memory message = messages[_messageHash];
        require(message.timestamp > 0, "Message does not exist");
        require(
            msg.sender == message.sender || msg.sender == message.recipient,
            "Not authorized"
        );
        
        return (
            message.sender,
            message.recipient,
            message.timestamp,
            message.isRevoked
        );
    }
    
    // Вывод токенов (только владелец)
    function withdrawTokens(uint256 _amount) external onlyOwner {
        require(token.transfer(owner(), _amount), "Token transfer failed");
    }
} 