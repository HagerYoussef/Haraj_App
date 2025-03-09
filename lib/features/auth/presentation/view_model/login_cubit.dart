import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'login_states.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> loginUser(String email, String password) async {
    emit(LoginLoading());
    final url = Uri.parse('https://harajalmamlaka.com/api/login');

    try {
      final response = await http.post(
        url,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        final token = responseData['token'];
        print('Token: $token');
        emit(LoginSuccess(token));
      } else {
        final responseError = json.decode(response.body);
        emit(LoginFailure(responseError['message'] ?? 'Login failed.'));
      }
    } catch (e) {
      emit(LoginFailure('An error occurred: $e'));
    }
  }
}


