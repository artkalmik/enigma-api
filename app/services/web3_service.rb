class Web3Service
  def initialize
    @web3 = Eth::Client.create(ethereum_endpoint)
    @contract = load_contract
  end

  def store_message(sender_address, recipient_address, ipfs_hash)
    # Создаем хеш сообщения
    message_hash = Eth::Utils.keccak256(
      [sender_address, recipient_address, ipfs_hash].join
    )

    # Отправляем транзакцию
    tx = @contract.functions.storeMessage.send_transaction(
      message_hash,
      recipient_address,
      from: sender_address,
      gas_limit: 200_000
    )

    # Ждем подтверждения
    receipt = @web3.eth_get_transaction_receipt(tx)
    raise 'Transaction failed' unless receipt['status'] == '0x1'

    message_hash
  end

  def revoke_message(message_hash)
    tx = @contract.functions.revokeMessage.send_transaction(
      message_hash,
      gas_limit: 100_000
    )

    receipt = @web3.eth_get_transaction_receipt(tx)
    raise 'Transaction failed' unless receipt['status'] == '0x1'

    true
  end

  def verify_message(message_hash)
    @contract.functions.verifyMessage.call(message_hash)
  end

  private

  def ethereum_endpoint
    if Rails.env.production?
      ENV.fetch('ETHEREUM_MAINNET_ENDPOINT')
    else
      ENV.fetch('ETHEREUM_TESTNET_ENDPOINT')
    end
  end

  def load_contract
    contract_address = ENV.fetch('ENIGMA_MESSAGING_CONTRACT_ADDRESS')
    contract_abi = JSON.parse(File.read(Rails.root.join('contracts', 'EnigmaMessaging.json')))['abi']
    
    Eth::Contract.new(
      address: contract_address,
      abi: contract_abi,
      client: @web3
    )
  end
end 