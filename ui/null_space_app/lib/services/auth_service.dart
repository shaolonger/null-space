/// Service for handling biometric authentication
/// 
/// This service provides biometric authentication capabilities including
/// checking biometric availability, authenticating users with biometrics,
/// and securely storing/retrieving vault passwords for biometric unlock.
/// It supports Face ID and Touch ID on iOS, and Fingerprint and Face unlock
/// on Android.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Exception thrown when authentication operations fail
class AuthServiceException implements Exception {
  final String message;
  final Object? cause;

  AuthServiceException(this.message, {this.cause});

  @override
  String toString() {
    final buffer = StringBuffer('AuthServiceException: $message');
    if (cause != null) {
      buffer.write(' - Caused by: $cause');
    }
    return buffer.toString();
  }
}

/// Service for biometric authentication
/// 
/// Provides methods to check biometric availability, authenticate users
/// using device biometrics (Face ID, Touch ID, Fingerprint, Face unlock),
/// and securely store vault passwords for biometric unlock.
/// 
/// Example usage:
/// ```dart
/// final authService = AuthService();
/// 
/// if (await authService.canUseBiometrics()) {
///   // Store password after successful password unlock
///   await authService.storeVaultPassword(vaultId: 'vault123', password: 'secret');
///   
///   // Later, unlock with biometrics
///   final password = await authService.unlockWithBiometrics(
///     vaultId: 'vault123',
///     reason: 'Please authenticate to unlock vault',
///   );
///   if (password != null) {
///     // Use the retrieved password to unlock the vault
///   }
/// }
/// ```
class AuthService {
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  AuthService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  /// Get the storage key for a vault's password
  String _getVaultPasswordKey(String vaultId) => 'vault_password_$vaultId';

  /// Check if biometrics are available on this device
  /// 
  /// This checks both device capability and enrollment status.
  /// Returns true if the device supports biometrics AND the user
  /// has enrolled biometric credentials.
  /// 
  /// Returns false if:
  /// - Device doesn't support biometrics
  /// - Biometrics are not enrolled
  /// - An error occurs during the check
  Future<bool> canUseBiometrics() async {
    try {
      // Check if device supports biometrics
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        return false;
      }

      // Check if biometrics are enrolled
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        return false;
      }

      // Get available biometric types
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      // Return true if at least one biometric type is available
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get list of available biometric types on this device
  /// 
  /// Returns a list of [BiometricType] values representing the
  /// available biometric authentication methods (e.g., face, fingerprint, iris).
  /// 
  /// Returns an empty list if no biometrics are available or if an error occurs.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate user with biometrics
  /// 
  /// Shows the platform-specific biometric authentication prompt.
  /// 
  /// [reason] - The reason displayed to the user for requesting authentication.
  ///            This should be a clear, user-friendly explanation.
  /// 
  /// [useErrorDialogs] - If true, shows error dialogs on certain failures.
  ///                     Default is true.
  /// 
  /// [stickyAuth] - If true, prevents the authentication dialog from being
  ///                dismissed by tapping outside of it. Default is false.
  /// 
  /// Returns true if authentication succeeds, false otherwise.
  /// 
  /// This method handles various failure cases:
  /// - User cancels: Returns false
  /// - Authentication fails: Returns false
  /// - Biometric not available: Returns false
  /// - System errors: Returns false and logs the error
  /// 
  /// Throws [AuthServiceException] only for unexpected errors that should
  /// be handled by the caller.
  Future<bool> authenticateWithBiometrics({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      // First check if biometrics are available
      final canAuthenticate = await canUseBiometrics();
      if (!canAuthenticate) {
        debugPrint('Biometrics not available for authentication');
        return false;
      }

      // Attempt biometric authentication
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true, // Only use biometrics, no PIN/password fallback
        ),
      );

      return authenticated;
    } on PlatformException catch (e) {
      // Handle specific platform exceptions
      debugPrint('Platform exception during biometric authentication: ${e.code} - ${e.message}');
      
      // Common error codes:
      // - NotAvailable: Biometrics not available
      // - NotEnrolled: No biometrics enrolled
      // - LockedOut: Too many failed attempts
      // - PermanentlyLockedOut: Device locked out
      // - PasscodeNotSet: Device has no passcode/PIN set
      
      // For all platform exceptions, return false (authentication failed)
      return false;
    } catch (e) {
      // Log unexpected errors
      debugPrint('Unexpected error during biometric authentication: $e');
      return false;
    }
  }

  /// Stop any ongoing authentication
  /// 
  /// Cancels the current biometric authentication prompt if one is showing.
  /// This is useful when the user navigates away or the operation is cancelled.
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      debugPrint('Error stopping authentication: $e');
    }
  }

  /// Store vault password securely for biometric unlock
  /// 
  /// Stores the vault password in platform-specific secure storage
  /// (Keychain on iOS, Keystore on Android) so it can be retrieved
  /// after successful biometric authentication.
  /// 
  /// [vaultId] - The ID of the vault
  /// [password] - The password to store securely
  /// 
  /// Throws [AuthServiceException] if storage fails.
  Future<void> storeVaultPassword({
    required String vaultId,
    required String password,
  }) async {
    try {
      final key = _getVaultPasswordKey(vaultId);
      await _secureStorage.write(key: key, value: password);
    } catch (e) {
      throw AuthServiceException(
        'Failed to store vault password',
        cause: e,
      );
    }
  }

  /// Retrieve vault password after biometric authentication
  /// 
  /// Retrieves the stored vault password from secure storage.
  /// This should only be called after successful biometric authentication.
  /// 
  /// [vaultId] - The ID of the vault
  /// 
  /// Returns the stored password, or null if not found.
  /// 
  /// Throws [AuthServiceException] if retrieval fails.
  Future<String?> getStoredVaultPassword({required String vaultId}) async {
    try {
      final key = _getVaultPasswordKey(vaultId);
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw AuthServiceException(
        'Failed to retrieve vault password',
        cause: e,
      );
    }
  }

  /// Remove stored vault password
  /// 
  /// Deletes the stored password for a vault from secure storage.
  /// This should be called when biometric unlock is disabled or
  /// when the vault is deleted.
  /// 
  /// [vaultId] - The ID of the vault
  Future<void> removeStoredVaultPassword({required String vaultId}) async {
    try {
      final key = _getVaultPasswordKey(vaultId);
      await _secureStorage.delete(key: key);
    } catch (e) {
      debugPrint('Error removing stored vault password: $e');
    }
  }

  /// Check if a vault has a stored password for biometric unlock
  /// 
  /// [vaultId] - The ID of the vault
  /// 
  /// Returns true if a password is stored, false otherwise.
  Future<bool> hasStoredPassword({required String vaultId}) async {
    try {
      final password = await getStoredVaultPassword(vaultId: vaultId);
      return password != null && password.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking stored password: $e');
      return false;
    }
  }

  /// Unlock vault with biometrics
  /// 
  /// Authenticates the user with biometrics and retrieves the stored
  /// vault password if authentication succeeds.
  /// 
  /// [vaultId] - The ID of the vault to unlock
  /// [reason] - The reason displayed to the user for requesting authentication
  /// 
  /// Returns the vault password if authentication succeeds and a password
  /// is stored, null otherwise.
  Future<String?> unlockWithBiometrics({
    required String vaultId,
    required String reason,
  }) async {
    // Check if password is stored
    final hasPassword = await hasStoredPassword(vaultId: vaultId);
    if (!hasPassword) {
      debugPrint('No stored password for vault $vaultId');
      return null;
    }

    // Authenticate with biometrics
    final authenticated = await authenticateWithBiometrics(
      reason: reason,
      useErrorDialogs: true,
      stickyAuth: false,
    );

    if (!authenticated) {
      return null;
    }

    // Retrieve the stored password
    return await getStoredVaultPassword(vaultId: vaultId);
  }
}
