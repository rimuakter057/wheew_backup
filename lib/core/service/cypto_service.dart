import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptoService {
  static final CryptoService _instance = CryptoService._internal();
  factory CryptoService() => _instance;
  CryptoService._internal();

  final _algorithm = X25519();
  final _aesGcm = AesGcm.with256bits();
  final _storage = const FlutterSecureStorage();

  // Shared secret ক্যাশ (memory-তে, app চালু থাকা পর্যন্ত)
  final Map<String, SecretKey> _sharedSecretCache = {};

  static const _privateKeyStorageKey = 'user_private_key';
  static const _publicKeyStorageKey = 'user_public_key';

  // ------------------------------------------------------
  // ১. Key Pair জেনারেট ও ম্যানেজ করা
  // ------------------------------------------------------

  /// নতুন key pair তৈরি করে (X25519)
  Future<SimpleKeyPair> generateKeyPair() async {
    return await _algorithm.newKeyPair();
  }

  /// Private key কে secure storage-এ সেভ করে
  Future<void> savePrivateKey(SimpleKeyPair keyPair) async {
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    await _storage.write(
      key: _privateKeyStorageKey,
      value: base64Encode(privateKeyBytes),
    );

    final publicKey = await keyPair.extractPublicKey();
    await _storage.write(
      key: _publicKeyStorageKey,
      value: base64Encode(publicKey.bytes),
    );
  }

  /// Secure storage থেকে key pair ফিরিয়ে আনে
  Future<SimpleKeyPair?> loadKeyPair() async {
    final privateKeyBase64 = await _storage.read(key: _privateKeyStorageKey);
    if (privateKeyBase64 == null) return null;

    final privateKeyBytes = base64Decode(privateKeyBase64);

    return SimpleKeyPairData(
      privateKeyBytes,
      publicKey: SimplePublicKey(
        base64Decode((await _storage.read(key: _publicKeyStorageKey))!),
        type: KeyPairType.x25519,
      ),
      type: KeyPairType.x25519,
    );
  }

  /// চেক করে device-এ ইতিমধ্যে key pair আছে কিনা
  Future<bool> hasKeyPair() async {
    final key = await _storage.read(key: _privateKeyStorageKey);
    return key != null;
  }

  /// প্রথমবার app চালু হলে (বা signup-এর সময়) কল করবে
  /// রিটার্ন করে public key (base64), যেটা backend-এ আপলোড করতে হবে
  Future<String> initializeKeysIfNeeded() async {
    final exists = await hasKeyPair();

    if (!exists) {
      final keyPair = await generateKeyPair();
      await savePrivateKey(keyPair);
    }

    final publicKeyBase64 = await _storage.read(key: _publicKeyStorageKey);
    return publicKeyBase64!;
  }

  /// নিজের public key base64 আকারে দরকার হলে (backend আপলোডের জন্য)
  Future<String?> getMyPublicKeyBase64() async {
    return await _storage.read(key: _publicKeyStorageKey);
  }

  // ------------------------------------------------------
  // ২. Shared Secret তৈরি ও ক্যাশ করা
  // ------------------------------------------------------

  /// অন্য ইউজারের public key (base64 string, backend থেকে fetch করা)
  /// দিয়ে shared secret বানায় ও ক্যাশ করে
  Future<SecretKey> getOrCreateSharedSecret({
    required String otherUserId,
    required String otherUserPublicKeyBase64,
  }) async {
    if (_sharedSecretCache.containsKey(otherUserId)) {
      return _sharedSecretCache[otherUserId]!;
    }

    final myKeyPair = await loadKeyPair();
    if (myKeyPair == null) {
      throw Exception('Key pair পাওয়া যায়নি, আগে initializeKeysIfNeeded() কল করো');
    }

    final theirPublicKey = SimplePublicKey(
      base64Decode(otherUserPublicKeyBase64),
      type: KeyPairType.x25519,
    );

    final sharedSecret = await _algorithm.sharedSecretKey(
      keyPair: myKeyPair,
      remotePublicKey: theirPublicKey,
    );

    _sharedSecretCache[otherUserId] = sharedSecret;
    return sharedSecret;
  }

  /// লগআউট বা key rotate করলে ক্যাশ ক্লিয়ার করার জন্য
  void clearSharedSecretCache() {
    _sharedSecretCache.clear();
  }

  // ------------------------------------------------------
  // ৩. Encrypt / Decrypt
  // ------------------------------------------------------

  /// প্লেইন টেক্সট মেসেজ এনক্রিপ্ট করে
  /// রিটার্ন করে { ciphertext, nonce, mac } — সব base64 string আকারে
  Future<Map<String, String>> encryptMessage({
    required String plainText,
    required SecretKey sharedSecret,
  }) async {
    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plainText),
      secretKey: sharedSecret,
    );

    return {
      'ciphertext': base64Encode(secretBox.cipherText),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
    };
  }

  /// এনক্রিপ্টেড মেসেজ ডিক্রিপ্ট করে আসল টেক্সট বের করে
  Future<String> decryptMessage({
    required Map<String, String> encryptedData,
    required SecretKey sharedSecret,
  }) async {
    final secretBox = SecretBox(
      base64Decode(encryptedData['ciphertext']!),
      nonce: base64Decode(encryptedData['nonce']!),
      mac: Mac(base64Decode(encryptedData['mac']!)),
    );

    final decryptedBytes = await _aesGcm.decrypt(
      secretBox,
      secretKey: sharedSecret,
    );

    return utf8.decode(decryptedBytes);
  }

  // ------------------------------------------------------
  // ৪. Logout/Reset (ঐচ্ছিক, দরকার হলে ব্যবহার করবে)
  // ------------------------------------------------------

  Future<void> clearAllKeys() async {
    await _storage.delete(key: _privateKeyStorageKey);
    await _storage.delete(key: _publicKeyStorageKey);
    clearSharedSecretCache();
  }
}