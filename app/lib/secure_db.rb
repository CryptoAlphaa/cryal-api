require 'base64'
require 'rbnacl'

# Encrypt and Decrypt from Database
class SecureDB
  # Generate key for Rake tasks (typically not called at runtime)
  def self.generate_key
    key = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes)
    Base64.strict_encode64 key
  end

  # Call setup once to pass in config variable with DB_KEY attribute
  def self.setup(config)
    @config = config
  end

  def self.key
    @key ||= Base64.strict_decode64(@config.DB_KEY)
  end

  # Encrypt or else return nil if data is nil
  def self.encrypt(plaintext)
    return nil unless plaintext
    plaintext_encoded = plaintext.encode('utf-8')
    simple_box = RbNaCl::SimpleBox.from_secret_key(key)
    ciphertext = simple_box.encrypt(plaintext_encoded)
    Base64.strict_encode64(ciphertext)
  end

  def self.hash(plaintext)
    return nil unless plaintext
    hashed_data = RbNaCl::Hash.sha256(plaintext)
    base64_encoded_hash = Base64.strict_encode64(hashed_data)
    base64_encoded_hash
  end

  # Decrypt or else return nil if database value is nil already
  def self.decrypt(ciphertext64)
    return nil unless ciphertext64
    ciphertext = Base64.strict_decode64(ciphertext64)
    simple_box = RbNaCl::SimpleBox.from_secret_key(key)
    decrypted_cipher = simple_box.decrypt(ciphertext)
    decrypted_utf8 = decrypted_cipher.force_encoding('utf-8')
    decrypted_utf8
  end
end