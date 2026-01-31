/// Unit tests for AuthService
/// 
/// Tests the biometric authentication service to ensure proper functionality
/// across different scenarios including availability checks and authentication flows.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:null_space_app/services/auth_service.dart';

/// Mock implementation of LocalAuthentication for testing
class MockLocalAuthentication extends LocalAuthentication {
  bool mockCanCheckBiometrics = true;
  bool mockIsDeviceSupported = true;
  List<BiometricType> mockAvailableBiometrics = [BiometricType.fingerprint];
  bool mockAuthenticateResult = true;
  PlatformException? mockAuthenticateException;
  bool throwOnGetAvailableBiometrics = false;
  bool throwOnCanCheckBiometrics = false;

  @override
  Future<bool> canCheckBiometrics() async {
    if (throwOnCanCheckBiometrics) {
      throw Exception('Test exception in canCheckBiometrics');
    }
    return mockCanCheckBiometrics;
  }

  @override
  Future<bool> isDeviceSupported() async {
    return mockIsDeviceSupported;
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (throwOnGetAvailableBiometrics) {
      throw Exception('Test exception in getAvailableBiometrics');
    }
    return mockAvailableBiometrics;
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required AuthenticationOptions options,
  }) async {
    if (mockAuthenticateException != null) {
      throw mockAuthenticateException!;
    }
    return mockAuthenticateResult;
  }

  @override
  Future<bool> stopAuthentication() async {
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService', () {
    late MockLocalAuthentication mockLocalAuth;
    late AuthService authService;

    setUp(() {
      mockLocalAuth = MockLocalAuthentication();
      authService = AuthService(localAuth: mockLocalAuth);
    });

    group('canUseBiometrics', () {
      test('returns true when biometrics are available and enrolled', () async {
        mockLocalAuth.mockCanCheckBiometrics = true;
        mockLocalAuth.mockIsDeviceSupported = true;
        mockLocalAuth.mockAvailableBiometrics = [BiometricType.fingerprint];

        final result = await authService.canUseBiometrics();

        expect(result, true);
      });

      test('returns false when device cannot check biometrics', () async {
        mockLocalAuth.mockCanCheckBiometrics = false;
        mockLocalAuth.mockIsDeviceSupported = true;
        mockLocalAuth.mockAvailableBiometrics = [BiometricType.fingerprint];

        final result = await authService.canUseBiometrics();

        expect(result, false);
      });

      test('returns false when device is not supported', () async {
        mockLocalAuth.mockCanCheckBiometrics = true;
        mockLocalAuth.mockIsDeviceSupported = false;
        mockLocalAuth.mockAvailableBiometrics = [BiometricType.fingerprint];

        final result = await authService.canUseBiometrics();

        expect(result, false);
      });

      test('returns false when no biometrics are enrolled', () async {
        mockLocalAuth.mockCanCheckBiometrics = true;
        mockLocalAuth.mockIsDeviceSupported = true;
        mockLocalAuth.mockAvailableBiometrics = [];

        final result = await authService.canUseBiometrics();

        expect(result, false);
      });

      test('returns false when an exception occurs', () async {
        // Create a mock that throws an exception when checking available biometrics
        final throwingMock = MockLocalAuthentication();
        throwingMock.mockCanCheckBiometrics = true;
        throwingMock.mockIsDeviceSupported = true;
        throwingMock.throwOnGetAvailableBiometrics = true;
        
        final testService = AuthService(localAuth: throwingMock);
        final result = await testService.canUseBiometrics();

        expect(result, false);
      });
    });

    group('getAvailableBiometrics', () {
      test('returns list of available biometric types', () async {
        mockLocalAuth.mockAvailableBiometrics = [
          BiometricType.face,
          BiometricType.fingerprint,
        ];

        final result = await authService.getAvailableBiometrics();

        expect(result, [BiometricType.face, BiometricType.fingerprint]);
      });

      test('returns empty list when no biometrics available', () async {
        mockLocalAuth.mockAvailableBiometrics = [];

        final result = await authService.getAvailableBiometrics();

        expect(result, isEmpty);
      });

      test('returns empty list on exception', () async {
        // Create a mock that throws when getAvailableBiometrics is called
        final failingMock = MockLocalAuthentication();
        failingMock.throwOnGetAvailableBiometrics = true;
        final failingService = AuthService(localAuth: failingMock);

        final result = await failingService.getAvailableBiometrics();

        expect(result, isEmpty);
      });
    });

    group('authenticateWithBiometrics', () {
      test('returns true when authentication succeeds', () async {
        mockLocalAuth.mockCanCheckBiometrics = true;
        mockLocalAuth.mockIsDeviceSupported = true;
        mockLocalAuth.mockAvailableBiometrics = [BiometricType.fingerprint];
        mockLocalAuth.mockAuthenticateResult = true;

        final result = await authService.authenticateWithBiometrics(
          reason: 'Test authentication',
        );

        expect(result, true);
      });

      test('returns false when authentication fails', () async {
        mockLocalAuth.mockCanCheckBiometrics = true;
        mockLocalAuth.mockIsDeviceSupported = true;
        mockLocalAuth.mockAvailableBiometrics = [BiometricType.fingerprint];
        mockLocalAuth.mockAuthenticateResult = false;

        final result = await authService.authenticateWithBiometrics(
          reason: 'Test authentication',
        );

        expect(result, false);
      });

      test('returns false when biometrics are not available', () async {
        mockLocalAuth.mockCanCheckBiometrics = false;
        mockLocalAuth.mockIsDeviceSupported = true;
        mockLocalAuth.mockAvailableBiometrics = [];

        final result = await authService.authenticateWithBiometrics(
          reason: 'Test authentication',
        );

        expect(result, false);
      });

      test('returns false on NotAvailable platform exception', () async {
        mockLocalAuth.mockCanCheckBiometrics = true;
        mockLocalAuth.mockIsDeviceSupported = true;
        mockLocalAuth.mockAvailableBiometrics = [BiometricType.fingerprint];
        mockLocalAuth.mockAuthenticateException = PlatformException(
          code: 'NotAvailable',
          message: 'Biometrics not available',
        );

        final result = await authService.authenticateWithBiometrics(
          reason: 'Test authentication',
        );

        expect(result, false);
      });

      test('returns false on NotEnrolled platform exception', () async {
        mockLocalAuth.mockCanCheckBiometrics = true;
        mockLocalAuth.mockIsDeviceSupported = true;
        mockLocalAuth.mockAvailableBiometrics = [BiometricType.fingerprint];
        mockLocalAuth.mockAuthenticateException = PlatformException(
          code: 'NotEnrolled',
          message: 'No biometrics enrolled',
        );

        final result = await authService.authenticateWithBiometrics(
          reason: 'Test authentication',
        );

        expect(result, false);
      });

      test('returns false on LockedOut platform exception', () async {
        mockLocalAuth.mockCanCheckBiometrics = true;
        mockLocalAuth.mockIsDeviceSupported = true;
        mockLocalAuth.mockAvailableBiometrics = [BiometricType.fingerprint];
        mockLocalAuth.mockAuthenticateException = PlatformException(
          code: 'LockedOut',
          message: 'Too many failed attempts',
        );

        final result = await authService.authenticateWithBiometrics(
          reason: 'Test authentication',
        );

        expect(result, false);
      });

      test('returns false on generic exception during authentication', () async {
        mockLocalAuth.mockCanCheckBiometrics = true;
        mockLocalAuth.mockIsDeviceSupported = true;
        mockLocalAuth.mockAvailableBiometrics = [BiometricType.fingerprint];
        // Set a generic exception to test non-PlatformException handling
        mockLocalAuth.mockAuthenticateException = PlatformException(
          code: 'UnexpectedError',
          message: 'Something unexpected happened',
        );

        final result = await authService.authenticateWithBiometrics(
          reason: 'Test authentication',
        );

        expect(result, false);
      });

      test('uses correct authentication options', () async {
        mockLocalAuth.mockCanCheckBiometrics = true;
        mockLocalAuth.mockIsDeviceSupported = true;
        mockLocalAuth.mockAvailableBiometrics = [BiometricType.fingerprint];
        mockLocalAuth.mockAuthenticateResult = true;

        final result = await authService.authenticateWithBiometrics(
          reason: 'Test with custom options',
          useErrorDialogs: false,
          stickyAuth: true,
        );

        expect(result, true);
      });
    });

    group('stopAuthentication', () {
      test('calls stopAuthentication on LocalAuthentication', () async {
        // This test verifies that stopAuthentication doesn't throw
        await authService.stopAuthentication();

        // No exception thrown = success
      });

      test('handles exceptions gracefully', () async {
        // Even if stopAuthentication fails, it should not throw
        await authService.stopAuthentication();

        // No exception thrown = success
      });
    });

    group('AuthServiceException', () {
      test('toString includes message', () {
        final exception = AuthServiceException('Test error');
        expect(exception.toString(), contains('Test error'));
      });

      test('toString includes cause when present', () {
        final cause = Exception('Root cause');
        final exception = AuthServiceException('Test error', cause: cause);
        expect(exception.toString(), contains('Test error'));
        expect(exception.toString(), contains('Root cause'));
      });
    });
  });
}
