import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:untitled22/features/auth/presentation/view_model/register_states.dart';
import 'dart:convert';

import '../../data/models/register_model.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  Future<void> registerUser(RegisterModel registerModel) async {
    try {
      emit(RegisterLoading());

      final response = await http.post(
        Uri.parse('https://harajalmamlaka.com/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(registerModel.toJson()),
      );

      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        if (responseBody['message'] == 'Registeration successful') {

          final token = responseBody['token'];
          print('Token: $token');
          emit(RegisterSuccess());
        } else {

          emit(RegisterFailure('Unexpected error: ${responseBody['message']}'));
        }
      } else {

        final responseBody = response.body;
        emit(RegisterFailure('Registration failed: $responseBody'));
        print('Error Response: $responseBody');
      }
    } catch (e) {
      emit(RegisterFailure('An error occurred: $e'));
      print('Error: $e');
    }
  }

}

