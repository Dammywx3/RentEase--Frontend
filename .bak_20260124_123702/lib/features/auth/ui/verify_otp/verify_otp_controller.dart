import 'package:flutter/foundation.dart';
import '../../../auth/data/auth_repo.dart';
import '../../../../core/network/api_error.dart';
import 'verify_otp_state.dart';

class VerifyOtpController extends ChangeNotifier {
  VerifyOtpController({AuthRepo? repo}) : _repo = repo ?? AuthRepo();

  final AuthRepo _repo;

  VerifyOtpState _state = const VerifyOtpState();
  VerifyOtpState get state => _state;

  void _set(VerifyOtpState s) {
    _state = s;
    notifyListeners();
  }

  Future<bool> verify({required String emailOrPhone, required String otp}) async {
    _set(_state.copyWith(loading: true, error: null, verified: false));
    try {
      await _repo.verifyOtp(emailOrPhone: emailOrPhone, otp: otp);
      _set(_state.copyWith(loading: false, error: null, verified: true));
      return true;
    } on ApiError catch (e) {
      _set(_state.copyWith(loading: false, error: e.message, verified: false));
      return false;
    } catch (_) {
      _set(_state.copyWith(loading: false, error: 'OTP verification failed.', verified: false));
      return false;
    }
  }
}
