require 'ipfs-api'

class IpfsService
  def initialize
    @client = IPFS::Client.new(host: 'ipfs', port: 5001)
  end

  def store_message(encrypted_content)
    # Добавляем зашифрованное сообщение в IPFS
    response = @client.add(encrypted_content)
    response.hashcode
  end

  def get_message(ipfs_hash)
    # Получаем зашифрованное сообщение из IPFS
    @client.cat(ipfs_hash)
  end

  def store_file(encrypted_file)
    # Добавляем зашифрованный файл в IPFS
    response = @client.add(encrypted_file)
    response.hashcode
  end

  def get_file(ipfs_hash)
    # Получаем зашифрованный файл из IPFS
    @client.cat(ipfs_hash)
  end

  def pin_hash(ipfs_hash)
    # Закрепляем хеш в IPFS для предотвращения удаления
    @client.pin.add(ipfs_hash)
  end

  def unpin_hash(ipfs_hash)
    # Открепляем хеш, позволяя ему быть удаленным при сборке мусора
    @client.pin.rm(ipfs_hash)
  end
end 