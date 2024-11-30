// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EnigmaToken is ERC20, ERC20Burnable, Pausable, Ownable {
    // Максимальное количество токенов
    uint256 public constant MAX_SUPPLY = 1000000000 * 10**18; // 1 миллиард токенов
    
    // Награда за стейкинг (5% годовых)
    uint256 public constant STAKING_REWARD_RATE = 5;
    
    // Минимальный период стейкинга (30 дней)
    uint256 public constant MIN_STAKING_PERIOD = 30 days;
    
    struct Stake {
        uint256 amount;
        uint256 timestamp;
        uint256 lastRewardTimestamp;
    }
    
    // Маппинг стейков пользователей
    mapping(address => Stake) public stakes;
    
    constructor() ERC20("Enigma Token", "ENIG") {
        _mint(msg.sender, MAX_SUPPLY);
    }
    
    function pause() public onlyOwner {
        _pause();
    }
    
    function unpause() public onlyOwner {
        _unpause();
    }
    
    // Стейкинг токенов
    function stake(uint256 _amount) external whenNotPaused {
        require(_amount > 0, "Cannot stake 0 tokens");
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance");
        
        // Обновляем или создаем стейк
        Stake storage userStake = stakes[msg.sender];
        
        if (userStake.amount > 0) {
            // Если уже есть стейк, начисляем награду
            _distributeReward(msg.sender);
        }
        
        // Переводим токены на контракт
        _transfer(msg.sender, address(this), _amount);
        
        // Обновляем данные стейка
        userStake.amount += _amount;
        userStake.timestamp = block.timestamp;
        userStake.lastRewardTimestamp = block.timestamp;
    }
    
    // Вывод токенов из стейкинга
    function unstake() external whenNotPaused {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No staked tokens");
        require(
            block.timestamp >= userStake.timestamp + MIN_STAKING_PERIOD,
            "Staking period not ended"
        );
        
        // Начисляем финальную награду
        _distributeReward(msg.sender);
        
        // Возвращаем токены
        uint256 amount = userStake.amount;
        userStake.amount = 0;
        _transfer(address(this), msg.sender, amount);
    }
    
    // Расчет и распределение награды
    function _distributeReward(address _staker) internal {
        Stake storage userStake = stakes[_staker];
        
        if (userStake.amount == 0) return;
        
        uint256 timeElapsed = block.timestamp - userStake.lastRewardTimestamp;
        uint256 reward = (userStake.amount * STAKING_REWARD_RATE * timeElapsed) / (365 days * 100);
        
        if (reward > 0) {
            _mint(_staker, reward);
            userStake.lastRewardTimestamp = block.timestamp;
        }
    }
    
    // Получение информации о стейке
    function getStakeInfo(address _staker) external view returns (
        uint256 amount,
        uint256 timestamp,
        uint256 pendingReward
    ) {
        Stake memory userStake = stakes[_staker];
        
        uint256 timeElapsed = block.timestamp - userStake.lastRewardTimestamp;
        uint256 reward = (userStake.amount * STAKING_REWARD_RATE * timeElapsed) / (365 days * 100);
        
        return (
            userStake.amount,
            userStake.timestamp,
            reward
        );
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
} 