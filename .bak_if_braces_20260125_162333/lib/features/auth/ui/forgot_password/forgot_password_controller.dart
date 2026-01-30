import 'package:flutter/foundation.dart';
import '../../../auth/data/auth_repo.dart';
import '../../../../core/network/api_error.dart';
import 'forgot_password_state.dart';

class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController({AuthRepo? repo}) : _repo = repo ?? AuthRepo();

  final AuthRepo _repo;

  ForgotPasswordState _state = const ForgotPasswordState();
  ForgotPasswordState get state => _state;

  void _set(ForgotPasswordState s) {
    _state = s;
    notifyListeners();
  }

  Future<bool> requestReset({required String emailOrPhone}) async {
    _set(_state.copyWith(loading: true, error: null, sent: false));
    try {
      await _repo.requestPasswordReset(emailOrPhone: emailOrPhone);
      _set(_state.copyWith(loading: false, error: null, sent: true));
      return true;
    } on ApiError catch (e) {
      _set(_state.copyWith(loading: false, error: e.message, sent: false));
      return false;
    } catch (_) {
      _set(
        _state.copyWith(
          loading: false,
          error: 'Could not request reset.',
          sent: false,
        ),
      );
      return false;
    }
  }
}
