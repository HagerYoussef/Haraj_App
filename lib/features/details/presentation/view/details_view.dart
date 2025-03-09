import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart'as flutter;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/themes/theme_provider.dart';
import '../../../auth/presentation/view/login_view.dart';
import '../../../home/presentation/view/home_view.dart';
import '../../../lang/language_manager.dart';
import 'widgets/custom_app_bar.dart';

class ProductDetailsPage extends StatefulWidget {
  static const routeName = 'Product Details';

  //final String productId2;
  int productId;


  ProductDetailsPage({super.key, required this.productId});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Map<String, dynamic>? productDetails;
  bool isLoading = true;
  bool isFavorite = false;
  int currentIndex = 0;
  List<Map<String, dynamic>> favoriteItems = [];

  TextEditingController topTextFieldController = TextEditingController();
  TextEditingController bottomTextFieldController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String timeAgo(String createdAt) {
    DateTime now = DateTime.now();
    DateTime createdTime = DateTime.parse(createdAt);
    Duration difference = now.difference(createdTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
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

  // In _toggleFavorite method
  void _toggleFavorite(String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = !isFavorite;
    });

    // Include product ID in productData
    Map<String, dynamic> productData = {
      'id': productDetails!['id'],
      'title': productDetails!['title'],
      'location': productDetails!['location'],
      'price': productDetails!['price'],
      'image': (productDetails!['media'] != null && productDetails!['media'].isNotEmpty)
          ? productDetails!['media'][0]['original_url']
          : 'https://via.placeholder.com/120', // صورة افتراضية إذا لم تكن هناك صورة متاحة

      'created_at': productDetails!['created_at'],
      'creator': {
        'avatar': productDetails!['creator']['avatar'],
        'name': productDetails!['creator']['name'],

        // Ensure this key exists
      },

    };
    print('dd');
print(productData);
    String key = 'favorite_items_$userEmail';

    if (isFavorite) {
      List<String> favoriteItems = prefs.getStringList(key) ?? [];
      favoriteItems.add(jsonEncode(productData));
      prefs.setStringList(key, favoriteItems);
    } else {
      List<String> favoriteItems = prefs.getStringList(key) ?? [];
      favoriteItems.removeWhere((item) {
        try {
          return jsonDecode(item)['id'] == productData['id'];
        } catch (e) {
          print("Error decoding item: $item");
          return false;
        }
      });
      prefs.setStringList(key, favoriteItems);
    }
  }
  Future<void> _loadFavoriteItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("توكن غير موجود");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://harajalmamlaka.com/api/products'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        // 🔍 طباعة البيانات كاملة
        print("📢 البيانات المسترجعة من API: $data");

        // 🔍 تحقق إذا كانت هناك قائمة داخل البيانات
        for (var key in data.keys) {
          if (data[key] is List) {
            print("✅ وجدنا قائمة تحت المفتاح: $key");
          }
        }

        if (data.containsKey('data') && data['data'] is List) {
          List<dynamic> products = data['data'];

          List<Map<String, dynamic>> items =
          products.map((item) => item as Map<String, dynamic>).toList();

          setState(() {
            favoriteItems = items;
          });

          await prefs.setString('favorite_items', jsonEncode(items));
          print("✅ تم حفظ البيانات في SharedPreferences");

        } else {
          print("⚠️ البيانات المسترجعة لا تحتوي على قائمة 'products'");
        }
      } else {
        print("❌ خطأ في تحميل البيانات: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ خطأ في الاتصال: $e");
    }
  }

// In _loadFavoriteStatus method
  void _loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('email');

    if (userEmail != null && productDetails != null) {
      String favoriteKey = 'favorite_items_$userEmail';
      List<String> favoriteItems = prefs.getStringList(favoriteKey) ?? [];
      int productId = productDetails!['id'];

      bool favoriteStatus = false;
      for (var item in favoriteItems) {
        try {
          Map<String, dynamic> decodedItem =
              jsonDecode(item) as Map<String, dynamic>;
          if (decodedItem['id'] == productId) {
            favoriteStatus = true;
            break;
          }
        } catch (e) {
          print("Error decoding item: $item");
        }
      }

      setState(() {
        isFavorite = favoriteStatus;
      });
    }
  }

// In your StatefulWidget
  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _fetchComments();
    _loadFavoriteItems();
    if (productDetails != null && productDetails!['created_at'] != null) {
      saveCreatedAt(productDetails!['created_at']);
    }
  }

  void _saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userName); // تخزين الاسم
  }

  List<Map<String, dynamic>> comments = [];
  bool isLoadingComments = true;

  Future<void> _fetchComments() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .doc(
              widget.productId.toString()) // تأكد أن المنتج الصحيح يتم استهدافه
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        comments = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoadingComments = false;
      });
    } catch (e) {
      print("Error fetching comments: $e");
      setState(() {
        isLoadingComments = false;
      });
    }
  }

  // جلب تفاصيل المنتج
  Future<void> _fetchProductDetails() async {
    if (widget.productId != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token') ??
          '23|VdPjCOSIgBpN868ueaVc7sJ9DVr6m8dRNOIKJLjf0325109d';

      if (token != null) {
        final response = await http.get(
          Uri.parse('https://harajalmamlaka.com/api/products'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          setState(() {
            final responseData = json.decode(response.body);
            final List<dynamic> products = responseData['data'];

            productDetails = products.firstWhere(
              (product) => product['id'] == widget.productId,
              orElse: () => null,
            );

            if (productDetails != null) {
              _loadFavoriteStatus(); // جلب حالة التفضيل بعد تحميل تفاصيل المنتج
            }

            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Failed to load product details');
        }
      } else {
        print('No token found');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is int) {
      widget.productId = arguments;
      _fetchProductDetails();
      _fetchComments();
      _loadFavoriteStatus(); // جلب حالة التفضيل بعد تحميل تفاصيل المنتج
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
  Future<void> saveImageUrl(String imageUrl) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('image_url', imageUrl);
  }
  Future<String?> getImageUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('image_url');
  }


  _sendComment() async {
    if (_commentController.text.isEmpty) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('email') ?? '';
    String? username = userEmail?.split('@').first;

    await _firestore
        .collection('products')
        .doc(widget.productId.toString()) // تأكد أن الـ ID هنا صحيح
        .collection('comments')
        .add({
      'text': _commentController.text,
      'user': username,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
    _fetchComments(); // تحديث التعليقات بعد الإرسال
  }
  Future<void> saveCreatedAt(String createdAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('created_at', createdAt);
    print("تم تخزين created_at: $createdAt");
  }
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
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : ColorApp.dark_color;
    final backgroundColor = isDarkMode ? ColorApp.dark_color : ColorApp.white_color;
    final String token;

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false, // إيقاف الرفع التلقائي للكيبورد
          backgroundColor: backgroundColor,
          appBar: CustomAppBar(),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : productDetails != null
              ? SingleChildScrollView(
            reverse: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0.h),
                  child: Text(
                    '${productDetails!['title'] ?? 'No title'}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorApp.green_color,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                  Text(

                  _formatDateTime(productDetails!['created_at']),
                  style: TextStyle(color: textColor, fontSize: 12.sp),
                )

// دالة لتحويل الوقت

                      ,Icon(Icons.access_time, size: 14.sp, color: ColorApp.green_color),
                      SizedBox(width: 30),
                      Text(
                        '${productDetails!['location']??'No Loc'}',
                        style: TextStyle(color: textColor, fontSize: 12.sp),
                      ),
                      Icon(Icons.location_on_sharp, size: 14.sp, color: ColorApp.green_color),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${productDetails!['creator']['name']??'No Name'}',
                        style: TextStyle(fontSize: 14.sp, color: ColorApp.green_color),
                      ),
                      SizedBox(width: 1.w),
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          productDetails!['creator']['avatar']??'',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0.h),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${productDetails!['description'] ?? 'No description'}',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),
                if (productDetails!['media'] != null && productDetails!['media'].isNotEmpty)
                  Column(
                    children: List.generate(productDetails!['media'].length, (index) {
                      String imageUrl = productDetails!['media'][index]['original_url'];
                      saveImageUrl(imageUrl).then((_) {
                        print("تم حفظ الرابط بنجاح: $imageUrl");
                      });
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: GestureDetector(
                          onTap: () {

                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CachedNetworkImage(
                                    imageUrl: productDetails!['media'][index]['original_url'],
                                    width: double.infinity,
                                    height: 500.h,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => const Icon(Icons.error, size: 50),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: productDetails!['media'][index]['original_url'],
                              width: double.infinity,
                              height: 150.h,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Icon(Icons.error, size: 50),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('products')
                      .doc(widget.productId.toString())
                      .collection('comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final comments = snapshot.data!.docs;

                    return Column(
                      children: List.generate(comments.length, (index) {
                        final comment = comments[index];

                        return ListTile(
                          title: Text(comment['text']),
                          subtitle: Text(comment['user']),
                          trailing: Text(
                            comment['timestamp'] != null
                                ? (comment['timestamp'] as Timestamp).toDate().toLocal().toString()
                                : '',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }),
                    );
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          )
              : const Center(child: Text('Product details not available')),
            bottomNavigationBar: Directionality(
              textDirection: flutter.TextDirection.ltr,
              child: BottomNavigationBar(
                elevation: 0,

                currentIndex: currentIndex,
                onTap: (index) async {
                  if (index == 0) {
                    try {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String? userEmail = prefs.getString('email') ?? '';
                      await prefs.setString('selectedUserName', productDetails!['creator']['name']);
                      await prefs.setString('creator_email', productDetails!['creator']['email']);

                      String? token = prefs.getString('token') ??
                          '23|VdPjCOSIgBpN868ueaVc7sJ9DVr6m8dRNOIKJLjf0325109d';

                      String? creatorEmail = prefs.getString('creator_email') ?? '';
                      final newUserRef = FirebaseFirestore.instance
                          .collection('chats')
                          .doc(creatorEmail)
                          .collection('users')
                          .doc(userEmail);

                      await newUserRef.set({
                        'email': userEmail,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      int? currentUserId = await fetchCurrentUserId(token);
print('token$token');
                      Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => ChatPage(
                                 token: token, // ضعي التوكن هنا
                                 userId: productDetails!['user_id'],
                                 currentUserId:currentUserId!,
                               ),
                               // builder: (context) => ChatPagee(),
                             ));
                          //
                          // ChatScreen(
                          //   creatorName: productDetails!['creator']['name'],
                          //   creatorEmail: productDetails!['creator']['email'],
                          // ),
                    } catch (error) {
                      print('Error: $error');
                    }
                  } else {
                    setState(() => currentIndex = index);
                  }
                },
                selectedItemColor: ColorApp.green_color,
                unselectedItemColor: ColorApp.green_color,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.email_sharp, color: ColorApp.green_color),
                    label: AppLocalizations.of(context)!.translate('message'),
                  ),
                  BottomNavigationBarItem(
                    icon: InkWell(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String? userEmail = prefs.getString('email') ?? '';
                        if (userEmail.isNotEmpty) {
                          _toggleFavorite(userEmail);
                        } else {
                          _showVerificationModal();
                        }
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border_sharp,
                        color: isFavorite ? Colors.red : ColorApp.green_color,
                      ),
                    ),
                    label: AppLocalizations.of(context)!.translate('fav'),
                  ),
                
                ],
              ),
            )


        ),

        Positioned(
        bottom: max(MediaQuery.of(context).viewInsets.bottom, 0), left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.only(top: 8.0.h,bottom: 60.h,left: 10.w),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(color: ColorApp.green_color),
                      decoration: InputDecoration(
                        labelText:  AppLocalizations.of(context)!.translate('enter'),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: ColorApp.green_color, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: ColorApp.green_color),
                  onPressed: _sendComment,
                ),
              ],
            ),
          ),
        ),
      ],
    );

  }


}

class ChatScreen extends StatefulWidget {
  final String creatorName;
  final String creatorEmail;

  const ChatScreen({
    Key? key,
    required this.creatorName,
    required this.creatorEmail,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? currentUserEmail;
  String? creatorName;
  String? chatRoomId;

  @override
  void initState() {
    super.initState();
    getStoredEmail();
  }

  /// جلب البريد الإلكتروني واسم المبدع من SharedPreferences
  Future<void> getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserEmail = prefs.getString('email');
      creatorName = prefs
          .getString('creator_name'); // جلب creator_name من SharedPreferences
      print("Current user email: $currentUserEmail");
      print("Creator name: $creatorName");
      if (currentUserEmail != null && widget.creatorEmail.isNotEmpty) {
        chatRoomId = getChatRoomId(currentUserEmail!, widget.creatorEmail);
        print("Chat Room ID: $chatRoomId");
        prefs.setString('room_id', chatRoomId!);
        // حفظ القائمة في SharedPreferences
        List<String> chatRoomIds = [];

        prefs.setStringList('chat_room_ids', chatRoomIds);

        print("lkzjxgchdxghc");
      } else {
        print("Error: User email or creator email is null");
      }
    });
  }

  /// إنشاء معرف غرفة محادثة فريد بناءً على البريدين
  String getChatRoomId(String email1, String email2) {
    List<String> emails = [email1, email2];
    emails.sort(); // الترتيب يضمن نفس المعرف لكل محادثة
    return emails.join("_");
  }

  /// جلب التوكن المخزن
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // جلب التوكن من SharedPreferences
  }

  /// إرسال رسالة إلى الغرفة الخاصة
  void sendMessage() async {
    String creatorEmail = widget.creatorEmail; // البريد الإلكتروني للمنشئ
    String? token = await getToken();
    String? participantEmail = currentUserEmail; // بريد المستخدم الحالي

    if (token == null || participantEmail == null || participantEmail.isEmpty) {
      print("خطأ: المستخدم غير مسجل الدخول أو بريد المشارك غير موجود");
      return;
    }

    if (_messageController.text.isNotEmpty) {
      try {
        print("المسار: chats/$creatorEmail/users/$participantEmail/messages");
        print("creatorEmail: $creatorEmail");
        print("participantEmail: $participantEmail");

        // إرسال الرسالة إلى Firestore تحت مجموعة المشارك في وثيقة المنشئ
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(creatorEmail)
            .collection('users')
            .doc(participantEmail)
            .collection('messages')
            .add({
          'chatRoomId': chatRoomId!, // إضافة chatRoomId هنا
          'text': _messageController.text,
          'timestamp': FieldValue.serverTimestamp(),
          'senderToken': token,
          'senderEmail': participantEmail,
          'creatorEmail': creatorEmail,
          'isRead': false,
          // الرسالة غير مقروءة
        });

        // مسح نص الرسالة وإعادة بناء الواجهة
        setState(() {
          // مسح محتوى الرسالة
          _messageController.clear();
        });
        print("تم إرسال الرسالة بنجاح");
      } catch (e) {
        print("التفاصيل الكاملة للخطأ: $e");
      }
    } else {
      print("الرسالة لا يمكن أن تكون فارغة");
    }
  }

  /// ✅ تعديل `getChatMessages` بحيث ترجع Stream مباشرةً
  Stream<QuerySnapshot> getChatMessages() {
    if (chatRoomId == null) {
      print("Error: chatRoomId is null");
      return Stream.empty();
    }

    print("Fetching messages for chatRoomId: $chatRoomId");

    return FirebaseFirestore.instance
        .collectionGroup(
            'messages') // ابحث في جميع الـ subcollections المسماة 'messages'
        .where('chatRoomId',
            isEqualTo: chatRoomId) // الفلترة حسب الـ chatRoomId
        .orderBy('timestamp', descending: true) // الترتيب حسب الوقت
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? ColorApp.dark_color : ColorApp.white_color,
      appBar: AppBar(
        backgroundColor: ColorApp.green_color,
        title: Text(
          widget.creatorName,
          style: TextStyle(color: Colors.white),
        ), // اسم صاحب المنتج
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getChatMessages(),
              builder: (context, snapshot) {
                print("Messages snapshot: ${snapshot.data?.docs}");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet"));
                }
                return ListView(
                  reverse: true, // لجعل أحدث رسالة تظهر في الأسفل
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    bool isCreatorMessage =
                        data['senderEmail'] == widget.creatorEmail;

                    // فقط عرض الرسائل إذا كان المرسل هو الكريتور أو المرسل له نفس البريد الإلكتروني
                    if (isCreatorMessage ||
                        data['senderEmail'] == currentUserEmail) {
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12), // إضافة هوامش
                        title: Align(
                          alignment: data['senderEmail'] == currentUserEmail
                              ? Alignment.centerRight
                              : Alignment.centerLeft, // تحديد اتجاه الرسالة
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            // إضافة padding داخل الرسالة
                            decoration: BoxDecoration(
                              color: data['senderEmail'] == currentUserEmail
                                  ? ColorApp.green_color
                                  : Colors.white,
                              // تغيير اللون بناءً على الرسالة
                              borderRadius: BorderRadius.circular(12),
                              // حواف منحنية للرسالة
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  // إضافة ظل للرسالة
                                  blurRadius: 5,
                                  offset: Offset(0, 3), // ظل طفيف للأسفل
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  data['senderEmail'] == currentUserEmail
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              // ترتيب النص داخل الرسالة
                              children: [
                                Text(
                                  data['text'],
                                  style: TextStyle(
                                    color:
                                        data['senderEmail'] == currentUserEmail
                                            ? Colors.white
                                            : Colors.black, // تغيير لون النص
                                    fontSize: 16, // تحديد حجم الخط
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  data['senderEmail'] ?? "",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    // جعل البريد الإلكتروني باللون الرمادي
                                    fontSize:
                                        12, // تصغير الخط الخاص بالبريد الإلكتروني
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return SizedBox(); // لا تعرض الرسالة إذا لم تكن من المرسل أو الكريتور
                    }
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: ColorApp.green_color),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
