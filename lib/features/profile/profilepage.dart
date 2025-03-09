import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/themes/colors.dart';

// Cubit States
abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profileData;
  ProfileLoaded(this.profileData);
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// Cubit to fetch profile data
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  Future<void> fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    emit(ProfileLoading());
    try {
      final response = await http.get(
        Uri.parse('https://harajalmamlaka.com/api/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'] as Map<String, dynamic>;
        emit(ProfileLoaded(data));
      } else {
        emit(ProfileError('فشل في تحميل البيانات'));
      }
    } catch (e) {
      emit(ProfileError('حدث خطأ أثناء الاتصال'));
    }
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  late ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = ProfileCubit();
    WidgetsBinding.instance.addObserver(this);
    _updateStatusAndRefresh(1); // تحديث الحالة عند الفتح
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateStatusAndRefresh(0); // تحديث الحالة عند الإغلاق
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateStatusAndRefresh(1); // عند العودة للتطبيق
    } else if (state == AppLifecycleState.paused) {
      _updateStatusAndRefresh(0); // عند إغلاق التطبيق
    }
  }

  Future<void> _updateStatusAndRefresh(int status) async {
    try {
      // تحديث الحالة في الخادم
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      await http.post(
        Uri.parse('https://harajalmamlaka.com/api/update-status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'active_status': status}),
      );

      // إعادة تحميل البيانات للحصول على التحديثات
      await _profileCubit.fetchProfile();
    } catch (e) {
      print('خطأ في تحديث الحالة: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _profileCubit..fetchProfile(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('الملف الشخصي', style: TextStyle(color: Colors.white)),
          backgroundColor: ColorApp.green_color,
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              final data = state.profileData;
              return SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: ColorApp.green_color,
                      child: Text(
                        data['name'][0],
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildInfoRow('الاسم', data['name']),
                    _buildInfoRow('البريد الإلكتروني', data['email']),
                    _buildInfoRow('الهاتف', data['phone']?.toString()),
                    _buildInfoRow('العنوان', data['address']),
                    SizedBox(height: 20),
                _buildStatusIndicator(int.tryParse(data['active_status'].toString()) ?? 0),

                  ],
                ),
              );
            } else if (state is ProfileError) {
              return Center(child: Text(state.message));
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value ?? 'غير متوفر',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(int status) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: status == 1 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 1 ? Icons.circle : Icons.circle_outlined,
            color: status == 1 ? Colors.green : Colors.red,
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            status == 1 ? 'نشط الآن' : 'غير نشط',
            style: TextStyle(
              color: status == 1 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}