import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart'as flutter;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled22/features/home/presentation/view/widgets/custom_bottom_navigation_bar.dart';
import 'package:untitled22/features/home/presentation/view/widgets/custom_floating_action_bottom.dart';
import 'package:untitled22/features/home/presentation/view/widgets/custom_menu.dart';
import 'package:untitled22/features/home/presentation/view/widgets/home_body.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/theme_provider.dart';
import '../../../auth/presentation/view/login_view.dart';
import '../../../details/presentation/view/details_view.dart';
import '../../../lang/language_manager.dart';
import '../../../offer/add_offer_page.dart';
import '../view_model/cubit/product_cubit.dart';
import '../view_model/cubit/prodyuct_state.dart';
import 'package:http/http.dart' as http;
//import 'package:pusher_client/pusher_client.dart';
import 'dart:convert';


String _formatDateTime(String? dateTime) {
  if (dateTime == null || dateTime.isEmpty) {
    return "غير متوفر"; // تجنب الخطأ إذا كان التاريخ غير موجود
  }

  try {
    DateTime utcTime = DateTime.parse(dateTime).toUtc(); // تحويل النص إلى DateTime
    DateTime localTime = utcTime.add(Duration(hours: 2)); // تحويل إلى توقيت مصر (UTC+2)
    return DateFormat('dd MMM yyyy - hh:mm a').format(localTime); // تنسيق الوقت
  } catch (e) {
    print("خطأ في تنسيق التاريخ: $e");
    return "تنسيق غير صحيح"; // في حالة حدوث خطأ، عرض رسالة واضحة
  }
}

class HomeView extends StatelessWidget {
  static const String routeName = 'Home Screen';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductsCubit()..fetchProducts(),
      child: _HomeViewContent(),
    );
  }
}

class _HomeViewContent extends StatefulWidget {
  @override
  __HomeViewContentState createState() => __HomeViewContentState();
}

class __HomeViewContentState extends State<_HomeViewContent> {
  bool isMainStoriesSelected = true;
  bool isSubCategoriesSelected = false;
  bool isProductsSelected = false;

  int _currentIndex = 0;
  bool isMenuOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isDarkMode = false; // تعريف متغير لحفظ الوضع

  // استرجاع إيميل المستخدم من الـ SharedPreferences
  Future<String?> _getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
        'email'); // assuming 'user_email' هو المفتاح الذي خزنت فيه الإيميل
  }

  // استرجاع حالة Dark Mode من SharedPreferences

  // حفظ حالة Dark Mode في SharedPreferences
  Future<void> _saveDarkModePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
   // استرجاع الوضع عند بدء الصفحة
  }

  Future<void> _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false; // قراءة القيمة المخزنة
    });
  }

  Future<int?> fetchCurrentUserId(String token) async {
    try {
      Dio dio = Dio();
      Response response = await dio.get(
        'https://harajalmamlaka.com/api/profile',  // Endpoint لجيب البروفايل
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        return response.data['data']['id'];  // هنا بنجيب الـ id من الـ data
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user ID: $e');
      return null;
    }
  }

  void _onItemTapped(int index) async {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      // استرجاع إيميل المستخدم من الـ SharedPreferences
      String? userEmail = await _getUserEmail();

      if (userEmail != null) {
        var theme = ThemeProvider();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FavoriteItemsPage(
              userEmail: userEmail,
              themeProvider: theme,
            ),
          ),
        );
      } else {
        _showVerificationModal();
      }
    } else if (index == 2) {

      SharedPreferences.getInstance().then((prefs) {
        String creatorName = prefs.getString('creator_name') ?? 'اسم غير معروف';
        String creatorEmail =
            prefs.getString('creator_email') ?? 'بريد إلكتروني غير معروف';
        String chatRoomId =
            prefs.getString('room_id') ?? 'بريد إلكتروني غير معروف';

        // استرجاع البريد الإلكتروني للمستخدم
        String? userEmail = prefs.getString('email');
        if (userEmail == null ) {
          _showVerificationModal();
        }
        if (userEmail != null ) {

          Future<void> navigateToChatsListPage(BuildContext context) async {
            final prefs = await SharedPreferences.getInstance();
            String? token = prefs.getString('token');
            if (token != null) {
              int? currentUserId = await fetchCurrentUserId(token);

              if (currentUserId != null) {
                print("currentuserid$currentUserId");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatsListPage(token: token, ),
                  ),
                );
              } else {
                print('Failed to fetch user ID');
              }
            } else {
              print('No token found in SharedPreferences');
            }
          }
          navigateToChatsListPage(context);
        }
      });
    }
  }

  void _showVerificationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0.w,
            right: 16.0.w,
            top: 16.0.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0.h,
          ),
          child: LoginView(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor:
          themeProvider.isDarkMode ? ColorApp.dark_color : ColorApp.white_color,
      // تغيير الخلفية حسب الوضع

      body: Stack(
        children: [
          BlocBuilder<ProductsCubit, ProductsState>(builder: (context, state) {
            if (state is ProductsLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ProductsLoaded) {
              return HomeBody(
                products: state.products,
                categories: [], // قد تحتاج هنا لجلب الفئات أيضًا من API أو من مصدر آخر
              );
            } else if (state is ProductsError) {
              return Center(child: Text(state.message));
            }
            return Center(child: Text('No products available.'));
          }),
          CustomMenu(isMenuOpen: isMenuOpen),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () async {
          String? userEmail = await _getUserEmail();

          if (userEmail != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddOfferPage(
                          themeProvider: Provider.of<ThemeProvider>(context),
                        )));
          } else if (userEmail == null) {
            _showVerificationModal();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class FavoriteItemsPage extends StatefulWidget {
  final String userEmail;
  final ThemeProvider themeProvider;

  FavoriteItemsPage({required this.userEmail, required this.themeProvider});
  @override
  State<FavoriteItemsPage> createState() => _FavoriteItemsPageState();
}

class _FavoriteItemsPageState extends State<FavoriteItemsPage> {
  @override
  void initState() {
    // TODO: implement initState

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? ColorApp.green_color.withOpacity(0.8) // تعديل للدارك مود
            : ColorApp.green_color,
        title: Text(
          AppLocalizations.of(context)!.translate('fav'),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).appBarTheme.iconTheme?.color,
        ),
      ),
      body: Container(
        color: widget.themeProvider.isDarkMode

            ? ColorApp.dark_color:  Colors.grey[300],
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadFavoriteItems(widget.userEmail),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading data',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No favorite items found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            } else {
              List<Map<String, dynamic>> favoriteItems = snapshot.data!;
              return ListView.builder(
                itemCount: favoriteItems.length,
                itemBuilder: (context, index) {
                  var item = favoriteItems[index];
                  print('ssss');
                  print(item['created_at']);
                  return Container(
                      color: widget.themeProvider.isDarkMode

                          ? ColorApp.dark_color:  Colors.white,
                    child: Directionality(
                      textDirection: flutter.TextDirection.ltr,
                      child: InkWell(
                        onTap: () async{

                          Navigator.pushNamed(context, ProductDetailsPage.routeName,
                              arguments: item!['id']);},
                        child: Row(
                          children: [
                            Expanded(
                              child: CachedNetworkImage(
                                imageUrl: item['image'] ?? 'https://via.placeholder.com/120',
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.broken_image),
                                fit: BoxFit.cover,
                              ),
                            ),

                            SizedBox(width: 15.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    item!['title'] ?? 'No Title',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                      color: widget.themeProvider.isDarkMode
                                          ? Colors.white
                                          : ColorApp.green_color,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 15.h),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      '${item!['price'] ?? 'N/A'} USD',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10.sp,
                                        color: widget.themeProvider.isDarkMode
                                            ? Colors.white
                                            : ColorApp.green_color,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Text(
                                        _formatDateTime(item['created_at'] ?? ''),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: widget.themeProvider.isDarkMode ? Colors.white : Colors.grey[700],
                                        ),
                                      ),
                                      Icon(Icons.access_time,
                                          size: 14,
                                          color: widget.themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey),

                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        (item!['location'] ?? '').replaceFirst(' ', '\n'),
                                        style: TextStyle(
                                          color: widget.themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey,
                                          fontSize: 12.sp,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),

                                      Icon(Icons.location_on_sharp,
                                          size: 12.sp,
                                          color: widget.themeProvider.isDarkMode
                                              ? Colors.grey[300]
                                              : Colors.grey),
                                      Text(
                                        item!['creator']?['name']??'No Name',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: widget.themeProvider.isDarkMode
                                              ? Colors.white
                                              : ColorApp.green_color,
                                        ),
                                      ),
                                      SizedBox(width: 1.w),
                                      CircleAvatar(
                                        backgroundImage: CachedNetworkImageProvider(
                                            item!['creator']?['avatar']??''
                                        ),
                                        onBackgroundImageError: (e, _) => Icon(Icons.person), // إضافة معالج للأخطاء
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  String _getPlaceholderImage(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? 'https://via.placeholder.com/120' // دارك
        : 'https://via.placeholder.com/120';
  }

  String _getAvatarPlaceholder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? 'https://via.placeholder.com/120' // دارك
        : 'https://via.placeholder.com/150';
  }

  Future<List<Map<String, dynamic>>> _loadFavoriteItems(
      String userEmail) async {
    // ... نفس الكود السابق ...
    {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String key = 'favorite_items_$userEmail';
      List<String> favoriteItems = prefs.getStringList(key) ?? [];

      List<Map<String, dynamic>> itemsList = [];

      for (var item in favoriteItems) {
        if (item.startsWith('{')) {
          try {
            Map<String, dynamic> decodedItem =
                jsonDecode(item) as Map<String, dynamic>;
            if (decodedItem.containsKey('id')) {
              decodedItem.putIfAbsent('title', () => '');
              decodedItem.putIfAbsent('location', () => '');
              decodedItem.putIfAbsent('price', () => '');
              decodedItem.putIfAbsent('image', () => '');
              decodedItem.putIfAbsent('imageAva', () => '');
              decodedItem.putIfAbsent('nameCreator', () => '');
              decodedItem.putIfAbsent('media', () => []);
              decodedItem.putIfAbsent('created_at', () => '');
              decodedItem.putIfAbsent('creator', () => {});
              itemsList.add(decodedItem);
            } else {
              print("Item skipped due to missing 'id': $item");
            }
          } catch (e) {
            print("Error decoding item: $item");
          }
        } else {
          // Handle plain strings by adding default values
          itemsList.add({
            'id': '', // Default or generate a unique ID
            'title': item,
            'location': '',
            'price': '',
            'image': '',
            'created_at': '',
            'creator': {
              'avatar': '',
              'name': '',

            },
          });
        }
      }

      return itemsList;
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) {
      return "غير متوفر"; // تجنب الخطأ إذا كان التاريخ غير موجود
    }

    try {
      DateTime utcTime = DateTime.parse(dateTime).toUtc(); // تحويل النص إلى DateTime
      DateTime localTime = utcTime.add(Duration(hours: 2)); // تحويل إلى توقيت مصر (UTC+2)
      return DateFormat('dd MMM yyyy - hh:mm a').format(localTime); // تنسيق الوقت
    } catch (e) {
      print("خطأ في تنسيق التاريخ: $e");
      return "تنسيق غير صحيح"; // في حالة حدوث خطأ، عرض رسالة واضحة
    }
  }

}

class InfoPage extends StatelessWidget {
  final String creatorName;
  final String creatorEmail;

  InfoPage({required this.creatorName, required this.creatorEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        backgroundColor: ColorApp.green_color,
        centerTitle: true,
        title: Text(
          'الدردشة',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Directionality(
            textDirection: flutter.TextDirection.ltr,
            child: ListTile(
              title: Row(
                children: [
                CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, color: Colors.white, size: 40),
                backgroundColor: ColorApp.green_color,
              ),

                  SizedBox(
                    width: 5,
                  ),
                  Text(creatorName),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      creatorName: creatorName,
                      creatorEmail: creatorEmail,
                    ),
                  ),
                );
              },
            ),
          )),
    );
  }
}


// class ChatPagee extends StatefulWidget {
//   @override
//   _ChatPageeState createState() => _ChatPageeState();
// }
//
// class _ChatPageeState extends State<ChatPagee> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late Future<String> userEmailFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     userEmailFuture = _getUserEmail();
//   }
//
//   Future<String> _getUserEmail() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('email') ?? '';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: InkWell(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Icon(
//             Icons.arrow_back_ios,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: ColorApp.green_color,
//         centerTitle: true,
//         title: Text(
//           'الدردشة',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       body: FutureBuilder<String>(
//         future: userEmailFuture,
//         builder: (context, userEmailSnapshot) {
//           if (userEmailSnapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (userEmailSnapshot.hasError) {
//             return Center(child: Text('خطأ: ${userEmailSnapshot.error}'));
//           }
//           if (!userEmailSnapshot.hasData || userEmailSnapshot.data!.isEmpty) {
//             return const Center(child: Text("لا يوجد بريد إلكتروني"));
//           }
//
//           final userEmail = userEmailSnapshot.data!;
//
//           return StreamBuilder<QuerySnapshot>(
//             stream: _firestore
//                 .collection('chats')
//                 .doc(userEmail)
//                 .collection('users')
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (snapshot.hasError) {
//                 return Center(child: Text('خطأ: ${snapshot.error}'));
//               }
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return const Center(child: Text("لا يوجد مستخدمين"));
//               }
//
//               final users = snapshot.data!.docs;
//
//               return ListView.builder(
//                 itemCount: users.length,
//                 itemBuilder: (context, index) {
//                   final user = users[index];
//                   final userData = user.data() as Map<String, dynamic>;
//                   final email = userData['email'] ?? user.id;
//
//                   // المرجع لجلب آخر رسالة
//                   final messagesRefUser = _firestore
//                       .collection('chats')
//                       .doc(userEmail)
//                       .collection('users')
//                       .doc(user.id)
//                       .collection('messages')
//                       .orderBy('timestamp', descending: true)
//                       .limit(1);
//
//                   final messagesRefCreator = _firestore
//                       .collection('chats')
//                       .doc(user.id)
//                       .collection('users')
//                       .doc(userEmail)
//                       .collection('messages')
//                       .orderBy('timestamp', descending: true)
//                       .limit(1);
//
//                   return InkWell(
//                     onTap: () async {
//                       // تحديث جميع الرسائل غير المقروءة إلى isRead = true
//                       final messagesRef = _firestore
//                           .collection('chats')
//                           .doc(userEmail)
//                           .collection('users')
//                           .doc(user.id)
//                           .collection('messages')
//                           .where('isRead', isEqualTo: false);
//
//                       final unreadMessages = await messagesRef.get();
//                       WriteBatch batch = _firestore.batch();
//
//                       for (var doc in unreadMessages.docs) {
//                         batch.update(doc.reference, {'isRead': true});
//                       }
//
//                       await batch.commit(); // تنفيذ التحديث دفعة واحدة
//
//                       // الانتقال إلى صفحة المحادثة
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ChatScreen(
//                             creatorName: email,
//                             creatorEmail: email,
//                           ),
//                         ),
//                       );
//                     },
//
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         radius: 30,
//                         child: Icon(Icons.person, color: Colors.white, size: 40),
//                         backgroundColor: ColorApp.green_color,
//                       ),
//                       title: Text(
//                         email.contains('@') ? email.split('@')[0] : email,
//                       ),
//                       subtitle: Row(
//                         children: [
//                           StreamBuilder<QuerySnapshot>(
//                             stream: messagesRefUser.snapshots(),
//                             builder: (context, messageSnapshotUser) {
//                               if (messageSnapshotUser.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return const Text('...جار التحميل');
//                               }
//                               if (messageSnapshotUser.hasError) {
//                                 return const Text('خطأ في تحميل الرسالة');
//                               }
//                               final userLastMessage = messageSnapshotUser
//                                   .data?.docs.isNotEmpty ??
//                                   false
//                                   ? messageSnapshotUser.data!.docs.first.data()
//                               as Map<String, dynamic>
//                                   : null;
//                               final userMessageText =
//                                   userLastMessage?['text'] ?? '';
//                               final userTimestamp =
//                               userLastMessage?['timestamp'] as Timestamp?;
//
//                               return StreamBuilder<QuerySnapshot>(
//                                 stream: messagesRefCreator.snapshots(),
//                                 builder: (context, messageSnapshotCreator) {
//                                   if (messageSnapshotCreator.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return const Text('...جار التحميل');
//                                   }
//                                   if (messageSnapshotCreator.hasError) {
//                                     return const Text('خطأ في تحميل الرسالة');
//                                   }
//                                   final creatorLastMessage =
//                                   messageSnapshotCreator
//                                       .data?.docs.isNotEmpty ??
//                                       false
//                                       ? messageSnapshotCreator
//                                       .data!.docs.first
//                                       .data() as Map<String, dynamic>
//                                       : null;
//                                   final creatorMessageText =
//                                       creatorLastMessage?['text'] ?? '';
//                                   final creatorTimestamp =
//                                   creatorLastMessage?['timestamp']
//                                   as Timestamp?;
//
//                                   if (userTimestamp != null &&
//                                       creatorTimestamp != null) {
//                                     final userDateTime = userTimestamp.toDate();
//                                     final creatorDateTime =
//                                     creatorTimestamp.toDate();
//
//                                     final lastMessageText =
//                                     userDateTime.isAfter(creatorDateTime)
//                                         ? userMessageText
//                                         : creatorMessageText;
//
//                                     return Text(
//                                       lastMessageText,
//                                       overflow: TextOverflow.ellipsis,
//                                     );
//                                   }
//
//                                   return const Text('لا توجد رسائل');
//                                 },
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                       trailing: StreamBuilder<QuerySnapshot>(
//                         stream: _firestore
//                             .collection('chats')
//                             .doc(userEmail)
//                             .collection('users')
//                             .doc(user.id)
//                             .collection('messages')
//                             .where('isRead', isEqualTo: false)
//                             .snapshots(),
//                         builder: (context, unreadSnapshot) {
//                           if (unreadSnapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return SizedBox();
//                           }
//                           if (unreadSnapshot.hasError) {
//                             return Icon(Icons.error, color: Colors.red);
//                           }
//
//                           int unreadCount =
//                               unreadSnapshot.data?.docs.length ?? 0;
//
//                           return unreadCount > 0
//                               ? CircleAvatar(
//                             radius: 12,
//                             backgroundColor: Colors.red,
//                             child: Text(
//                               unreadCount.toString(),
//                               style: TextStyle(
//                                   color: Colors.white, fontSize: 12),
//                             ),
//                           )
//                               : SizedBox();
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

class Message {
  final String id;
  final String text;
  final int senderId;
  final int receiverId;
  final DateTime createdAt;
  final bool isRead;
  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      text: json['message'] ?? '',
      senderId: json['senderId'] != null ? json['senderId'] as int : 0,
      receiverId: json['receiverId'] != null ? json['receiverId'] as int : 0,
      createdAt: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}

class ChatService {
  final String baseUrl = 'https://harajalmamlaka.com/api';
  final String token;
  final int currentUserId;

  ChatService({required this.token, required this.currentUserId});

  Future<void> sendMessage(String message, int receiverId) async {
    try {
      final apiResponse = await http.post(
        Uri.parse('$baseUrl/send-message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
          'receiver_id': receiverId,
        }),
      );

      if (apiResponse.statusCode == 201) {
        final responseData = jsonDecode(apiResponse.body);
        await FirebaseFirestore.instance.collection('messages').add({
          'id': responseData['id']?.toString() ?? '',
          'senderId': currentUserId,
          'receiverId': receiverId,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      } else {
        throw Exception('API Error: ${apiResponse.body}');
      }
    } catch (e) {
      throw Exception('Send Error: ${e.toString()}');
    }
  }

  Future<List<Message>> fetchMessages(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is! List) {
          throw Exception('Invalid API response format');
        }

        final messages = data.map((json) => Message.fromJson(json)).toList();

        final batch = FirebaseFirestore.instance.batch();
        final messagesRef = FirebaseFirestore.instance.collection('messages');

        for (var message in messages) {
          final newDoc = messagesRef.doc();
          batch.set(newDoc, {
            'id': newDoc.id,
            'senderId': message.senderId,
            'receiverId': message.receiverId,
            'message': message.text,
            'timestamp': message.createdAt != null
                ? Timestamp.fromDate(message.createdAt)
                : Timestamp.now(),
          });
        }

        await batch.commit();
        return messages;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stacktrace) {
      print('Fetch Error: $e');
      print(stacktrace);
      return []; // رجعي قائمة فارغة بدلاً من رمي خطأ
    }
  }

}

class ChatPage extends StatefulWidget {
  final String token;
  final int userId;
  final int currentUserId;

  const ChatPage({
    Key? key,
    required this.token,
    required this.userId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatService _chatService;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _creatorName;
  String? _error;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(
      token: widget.token,
      currentUserId: widget.currentUserId,
    );
    _loadUserName();
    _syncMessages();
    _markExistingMessagesAsRead();
    _setupMessageListener();
  }
  void _markExistingMessagesAsRead() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('senderId', isEqualTo: widget.userId)
          .where('receiverId', isEqualTo: widget.currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _creatorName = prefs.getString('selectedUserName'));
  }
  void _setupMessageListener() {
    FirebaseFirestore.instance
        .collection('messages')
        .where('senderId', isEqualTo: widget.userId)
        .where('receiverId', isEqualTo: widget.currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          doc.doc.reference.update({'isRead': false});
        }
      }
    });
  }

  Future<void> _syncMessages() async {
    try {
      await _chatService.fetchMessages(widget.userId);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    try {
      await _chatService.sendMessage(_controller.text, widget.userId);
      _controller.clear();
      _scrollToBottom();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('hh:mm a').format(timestamp);
  }

  Widget _buildMessage(Message message) {
    final isMe = message.senderId == widget.currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 250.w,
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? ColorApp.green_color : Colors.grey[300],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
            topLeft: isMe ? Radius.circular(16) : Radius.circular(0),
            topRight: isMe ? Radius.circular(0) : Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4), // مسافة صغيرة بين النص والوقت
            Text(
              _formatTimestamp(message.createdAt),
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<Message>> _getMessagesStream() {
    return FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Message(
      id: doc.id,
      text: doc['message'],
      senderId: doc['senderId'],
      receiverId: doc['receiverId'],
      createdAt: doc.data().containsKey('timestamp') && doc['timestamp'] != null
          ? (doc['timestamp'] as Timestamp).toDate()
          : DateTime.now(),

      isRead: doc.data().containsKey('isRead') ? doc['isRead'] : false,

    ))
        .where((msg) =>
    (msg.senderId == widget.currentUserId &&
        msg.receiverId == widget.userId) ||
        (msg.senderId == widget.userId &&
            msg.receiverId == widget.currentUserId))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(_creatorName ?? 'Chat',style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: ColorApp.green_color,
      ),
      body: Column(
        children: [
          if (_error != null)
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(child: Text('No messages yet'));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessage(messages[index]),
                );
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: ColorApp.green_color),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}


class Chat {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}


class ChatsListPage extends StatefulWidget {
  final String token;

  const ChatsListPage({required this.token, Key? key}) : super(key: key);

  @override
  _ChatsListPageState createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  List<Map<String, dynamic>> chats = [];
  String selectedUserName = '';

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }
  Stream<int> fetchUnreadCount(int receiverId) {
    return Stream<int?>.fromFuture(fetchCurrentUserId(widget.token)).asyncExpand((currentUserId) {
      if (currentUserId == null) {
        return Stream.value(0);
      }

      return FirebaseFirestore.instance
          .collection('messages')
          .where('senderId', isEqualTo: receiverId)
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.size);
    });
  }

  void markMessagesAsRead(int senderId) async {
    int? currentUserId = await fetchCurrentUserId(widget.token);
    if (currentUserId == null) return;

    var querySnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in querySnapshot.docs) {
      doc.reference.update({'isRead': true});
    }
  }

  Future<void> fetchMessages() async {
    try {
      Dio dio = Dio();
      Response response = await dio.get(
        'https://harajalmamlaka.com/api/old_chats',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          chats = List<Map<String, dynamic>>.from(response.data);
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text( AppLocalizations.of(context)!.translate('chats'), style: TextStyle(color: Colors.white)),
        backgroundColor: ColorApp.green_color,
      ),
      body: chats.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                  'https://harajalmamlaka.com/storage/${chat['avatar']}'),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(chat['name'] ?? 'No Name'),
                StreamBuilder<int>(
                  stream: fetchUnreadCount(chat['id']),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data! > 0) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${snapshot.data}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
            subtitle: StreamBuilder<String>(
              stream: fetchLastMessage(chat['id']),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? "لا توجد رسائل",
                  style: TextStyle(color: Colors.grey),
                );
              },
            ),
              onTap: () async {
                setState(() {
                  selectedUserName = chat['name'];
                });

                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('selectedUserName', selectedUserName);

                int? currentUserId = await fetchCurrentUserId(widget.token);
                if (currentUserId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        token: widget.token,
                        userId: chat['id'],
                        currentUserId: currentUserId,
                      ),
                    ),
                  ).then((_) {
                    // تحديث حالة الرسائل عند العودة من صفحة المحادثة
                    markMessagesAsRead(chat['id']);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل في جلب بيانات المستخدم')),
                  );
                }
              }

          );

        },
      ),
    );
  }

  /// جلب آخر رسالة بين المستخدم الحالي والمستخدم المستهدف من Firebase
  Stream<String> fetchLastMessage(int receiverId) {
    return Stream.fromFuture(fetchCurrentUserId(widget.token)).asyncExpand((currentUserId) {
      if (currentUserId == null) {
        return Stream.value("خطأ في جلب المستخدم");
      }

      return FirebaseFirestore.instance
          .collection('messages')
          .where(Filter.or(
        Filter.and(
            Filter('senderId', isEqualTo: currentUserId),
            Filter('receiverId', isEqualTo: receiverId)
        ),
        Filter.and(
            Filter('senderId', isEqualTo: receiverId),
            Filter('receiverId', isEqualTo: currentUserId)
        ),
      ))
          .orderBy('timestamp', descending: true) // Changed from 'createdAt'
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) return "لا توجد رسائل";
        return snapshot.docs.first.data()['message'] ?? "رسالة غير معروفة"; // Changed from 'text'
      });
    });
  }
  /// جلب `currentUserId` من الـ API
  Future<int?> fetchCurrentUserId(String token) async {
    try {
      Dio dio = Dio();
      Response response = await dio.get(
        'https://harajalmamlaka.com/api/profile',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        return response.data['data']['id'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user ID: $e');
      return null;
    }
  }
}

class MessageService {
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> getMessages(String token) async {
    try {
      Response response = await _dio.get(
        'https://harajalmamlaka.com/api/messages/2',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessageService _messageService = MessageService();
  final String token = '23|VdPjCOSIgBpN868ueaVc7sJ9DVr6m8dRNOIKJLjf0325109d';

  late Future<List<Map<String, dynamic>>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    _messagesFuture = _messageService.getMessages(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _messagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Map<String, dynamic>> messages = snapshot.data!;
            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                return ListTile(
                  title: Text(message['message']),
                  subtitle: Text('Sender: ${message['sender_id']} - Receiver: ${message['receiver_id']}'),
                  trailing: Text(message['created_at']),
                );
              },
            );
          } else {
            return Center(child: Text('No messages available'));
          }
        },
      ),
    );
  }
}


class ImageDisplayWidget extends StatefulWidget {
  @override
  _ImageDisplayWidgetState createState() => _ImageDisplayWidgetState();
}

class _ImageDisplayWidgetState extends State<ImageDisplayWidget> {
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    loadImageUrl();
  }
  Future<String?> getImageUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('image_url');
  }
  Future<void> loadImageUrl() async {
    String? storedUrl = await getImageUrl();
    setState(() {
      imageUrl = storedUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: CachedNetworkImage(
        imageUrl: (imageUrl != null && imageUrl!.isNotEmpty)
            ? imageUrl!
            : 'https://via.placeholder.com/120', // صورة بديلة إذا لم يوجد رابط مخزن
        width: 20.w,
        height: 150.h,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String? createdAt;

  @override
  void initState() {
    super.initState();
    loadCreatedAt();
  }

  Future<void> loadCreatedAt() async {
    String? storedCreatedAt = await getCreatedAt();
    setState(() {
      createdAt = storedCreatedAt;
    });
  }
  Future<String?> getCreatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('created_at') ?? '2000-01-01T00:00:00Z';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDateTime(createdAt ?? '2000-01-01T00:00:00Z'),
      style: TextStyle(
         fontSize: 12.sp,
      ),
    );
  }
}
