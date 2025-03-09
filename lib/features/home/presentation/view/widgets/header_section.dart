import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../../core/themes/theme_provider.dart';
import '../../../../auth/presentation/view/login_view.dart';
import '../../../../auth/presentation/view/register_view.dart';
import '../../../../details/presentation/view/details_view.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../../../lang/laguage_cubit.dart';
import '../../../../lang/language_manager.dart';
import 'custom_app_bar.dart';
import 'custom_menu.dart';
import 'package:flutter/material.dart' as flutter;
// Helper Functions
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

// API Service
class ApiService {
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ??
        '23|VdPjCOSIgBpN868ueaVc7sJ9DVr6m8dRNOIKJLjf0325109d';
  }

  static Future<String> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('languageCode') ?? 'ar';
  }

// في ملف ApiService
  static Future<List<dynamic>> fetchCategories(String languageCode) async {
    final token = await getToken();
    if (token.isEmpty) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse(
          'https://harajalmamlaka.com/api/categories/$languageCode/index'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200)
      return json.decode(response.body)['data'] as List;
    throw Exception('Failed to load categories: ${response.statusCode}');
  }
  Future<Map<String, dynamic>> fetchProductDetails(int productId) async {
    final url = 'https://harajalmamlaka.com/api/products/$productId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('البيانات الكاملة: $data');
        return data; // ✅ رجّع البيانات بدل الطباعة فقط
      } else {
        throw Exception('فشل في تحميل البيانات');
      }
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }
  static Future<List<dynamic>> fetchSubcategories(int categoryId) async {
    final token = await getToken();
    if (token.isEmpty) throw Exception('Token not found');
    final response = await http.get(
      Uri.parse('https://harajalmamlaka.com/api/categories/$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200)
      return json.decode(response.body)['data']['subcategories'] ?? [];
    throw Exception('Failed to load subcategories: ${response.statusCode}');
  }


  static Future<Map<int, String>> fetchSubcategoryImages() async {
    final token = await getToken();
    if (token.isEmpty) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('https://harajalmamlaka.com/api/subcategories/en/index'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Map<int, String> imageMap = {};

      for (var subcategory in (data['data'] ?? [])) {
        int id = subcategory['id'];
        String imageUrl = (subcategory['media'] != null && subcategory['media'].isNotEmpty)
            ? subcategory['media'][0]['original_url']
            : (subcategory['image'] ?? "https://harajalmamlaka.com/storage/placeholder.png");

        imageMap[id] = imageUrl;
      }

      return imageMap;
    } else {
      throw Exception('Failed to load subcategory images: ${response.statusCode}');
    }
  }


  static Future<List<dynamic>> fetchProducts(int subcategoryId) async {
    final token = await getToken();
    if (token.isEmpty) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('https://harajalmamlaka.com/api/products'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> allProducts = json.decode(response.body)['data'];

      // تصفية المنتجات حسب `subcategory_id`
      final List<dynamic> filteredProducts = allProducts
          .where((product) => product['subcategory_id'] == subcategoryId)
          .toList();

      return filteredProducts;
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

}

// Reusable Widgets
class CategoryChip extends StatelessWidget {
  final String nameKey; // مفتاح الترجمة بدلًا من النص الثابت
  final Color color;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoryChip({
    super.key,
    required this.nameKey,
    required this.color,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        final translatedName = AppLocalizations.of(context)!.translate(nameKey);

        return GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              translatedName,
              style: TextStyle(
                fontSize: 16.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProductItemWidget extends StatelessWidget {
  Map<String, dynamic>? productDetails;
  final ThemeProvider themeProvider;

   ProductItemWidget(
      {super.key, required this.productDetails, required this.themeProvider});

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: flutter.TextDirection.ltr,
      child: InkWell(
        onTap: () async{

          Navigator.pushNamed(context, ProductDetailsPage.routeName,
            arguments: productDetails!['id']);},
        child: Container(
          padding: EdgeInsets.all(10.h),
          decoration: BoxDecoration(
            color:
                themeProvider.isDarkMode ? ColorApp.dark_color : Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: (productDetails!['media'] != null && productDetails!['media'].isNotEmpty)
                        ? productDetails!['media'][0]['original_url']
                        : 'https://via.placeholder.com/120',
                    width: 20.w,
                    height: 150.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      productDetails!['title'] ?? 'No Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: themeProvider.isDarkMode
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
                        '${productDetails!['price'] ?? 'N/A'} USD',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : ColorApp.green_color,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          _formatDateTime(productDetails?['updated_at'] ?? '2000-01-01T00:00:00Z'),

                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey,
                            fontSize: 12.sp,
                          ),
                        ),
                        Icon(Icons.access_time,
                            size: 14,
                            color: themeProvider.isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          (productDetails!['location'] ?? '').replaceFirst(' ', '\n'),
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey,
                            fontSize: 12.sp,
                          ),
                          textAlign: TextAlign.start,
                        ),

                        Icon(Icons.location_on_sharp,
                            size: 12.sp,
                            color: themeProvider.isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey),
                        Text(
                          productDetails!['creator']?['name']??'No Name',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : ColorApp.green_color,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            productDetails!['creator']?['avatar']??''
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
  }

  String getTimeDifference(String updatedAt) {
    if (updatedAt.isEmpty) return 'غير معروف';

    DateTime updatedTime = DateTime.parse(updatedAt);
    DateTime now = DateTime.now();
    Duration difference = now.difference(updatedTime);

    if (difference.inSeconds < 60) {
      return 'منذ ${difference.inSeconds} ثانية';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 30) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      int months = difference.inDays ~/ 30;
      return 'منذ $months شهر';
    }
  }
}

// Main Widget
class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  Future<List<dynamic>>? _categoriesFuture;


  Future<List<dynamic>>? _subcategoriesFuture;
  Future<List<dynamic>>? _productsFuture;
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  late bool isAdmin;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<dynamic> subcategories = [];
  Map<int, String> subcategoryImages = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
    context.read<LanguageCubit>().stream.listen((_) {
      _reloadCategories();
    });
    loadSubcategories();
  }
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ??
        '23|VdPjCOSIgBpN868ueaVc7sJ9DVr6m8dRNOIKJLjf0325109d';
  }

  static Future<List<dynamic>> fetchSubcategories(int categoryId) async {
    final token = await getToken();
    if (token.isEmpty) throw Exception('Token not found');
    final response = await http.get(
      Uri.parse('https://harajalmamlaka.com/api/categories/$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200)
      return json.decode(response.body)['data']['subcategories'] ?? [];
    throw Exception('Failed to load subcategories: ${response.statusCode}');
  }
  static Future<Map<int, String>> fetchSubcategoryImages() async {
    final token = await getToken();
    if (token.isEmpty) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('https://harajalmamlaka.com/api/subcategories/en/index'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Map<int, String> imageMap = {};

      for (var subcategory in (data['data'] ?? [])) {
        int id = subcategory['id'];
        String imageUrl = (subcategory['media'] != null && subcategory['media'].isNotEmpty)
            ? subcategory['media'][0]['original_url']
            : (subcategory['image'] ?? "https://harajalmamlaka.com/storage/placeholder.png");

        imageMap[id] = imageUrl;
      }

      return imageMap;
    } else {
      throw Exception('Failed to load subcategory images: ${response.statusCode}');
    }
  }

  void loadSubcategories() async {
    try {
      int categoryId = 1; // استبدل بالـ ID المناسب
      final fetchedSubcategories = await fetchSubcategories(categoryId);
      final fetchedImages = await fetchSubcategoryImages();

      setState(() {
        subcategories = fetchedSubcategories;
        subcategoryImages = fetchedImages;
      });
    } catch (e) {
      print("❌ Error fetching data: $e");
    }
  }
  void _reloadCategories() {
    final currentLanguage = context.read<LanguageCubit>().state.languageCode;
    setState(() {
      _categoriesFuture = ApiService.fetchCategories(currentLanguage);
    });
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    final currentLanguage = context.read<LanguageCubit>().state.languageCode;

    setState(() {
      isAdmin = prefs.getBool('isAdmin') ?? false;
      _categoriesFuture =
          ApiService.fetchCategories(currentLanguage).then((categories) {
        if (categories.isNotEmpty && _selectedCategoryId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedCategoryId = categories.last['id'];

                _subcategoriesFuture =
                    ApiService.fetchSubcategories(_selectedCategoryId!)
                        .then((subcategories) {
                  if (subcategories.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _selectedSubcategoryId = subcategories.first['id'];
                          _productsFuture =
                              ApiService.fetchProducts(_selectedSubcategoryId!);
                        });
                      }
                    });
                  }
                  return subcategories;
                });
              });
            }
          });
        }
        return categories;
      });
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<dynamic> _filterProducts(List<dynamic> products) {
    print("All products: $products"); // ✅ عرض جميع المنتجات قبل البحث
    print("Searching for: $_searchQuery");

    if (_searchQuery.isEmpty) return products;

    final filtered = products.where((product) {
      final productTitle = product['title']?.toString()?.toLowerCase() ??
          ''; // ✅ استخدم 'title' بدلاً من 'name'
      return productTitle.contains(_searchQuery.trim().toLowerCase());
    }).toList();

    print("Filtered products: $filtered"); // ✅ عرض المنتجات بعد الفلترة
    return filtered;
  }

  Widget _buildCategoryRow(List<dynamic> categories, ThemeProvider theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

    child: Row(
    mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ...categories.map((category) => Row(
          children: [
            SvgPicture.network(
              category['media'] != null && category['media'].isNotEmpty
                  ? category['media'][0]['original_url']
                  : "https://harajalmamlaka.com/storage/1/realestate.svg",
              width: 24,
              height: 24,
              placeholderBuilder: (context) => Icon(Icons.image, size: 24),
            ),
            SizedBox(width: 8),
            CategoryChip(
              nameKey: category['name'] ?? "No Name",
              color: theme.isDarkMode ? Colors.white : ColorApp.green_color,
              onTap: () => _handleCategoryTap(category['id']),
              isSelected: _selectedCategoryId == category['id'],
            ),
          ],
        )),
      ],
    ),


    );
  }

  void _handleCategoryTap(int categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _subcategoriesFuture = ApiService.fetchSubcategories(categoryId);
      _productsFuture = null;
    });
  }


  Widget _buildSubcategoryRow(List<dynamic> subcategories, ThemeProvider theme) {
    final currentLang = context.read<LanguageCubit>().state.languageCode;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isAdmin)
            Icon(Icons.add, color: theme.isDarkMode ? Colors.white : ColorApp.green_color),
          ...subcategories.map((subcategory) {
            int subcategoryId = subcategory['id'];
            String imageUrl = subcategoryImages[subcategoryId] ?? "https://harajalmamlaka.com/storage/placeholder.png";

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: GestureDetector(
                onTap: () => _handleSubcategoryTap(subcategoryId),
                child: Row(
                  children: [
                    Image.network(
                      imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image_not_supported);
                      },
                    ),
                    SizedBox(width: 8),
                    Text(
                      _getLocalizedName(subcategory, currentLang),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.isDarkMode ? Colors.white : ColorApp.green_color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getLocalizedName(
      Map<String, dynamic> subcategory, String languageCode) {
    return switch (languageCode) {
      'en' => subcategory['name_en'] ?? subcategory['name_ar'] ?? 'No Name',
      'ar' => subcategory['name_ar'] ?? subcategory['name_en'] ?? 'لا يوجد اسم',
      _ => subcategory['name_en'] ?? subcategory['name_ar'] ?? 'No Name',
    };
  }

  void _handleSubcategoryTap(int subcategoryId) {
    setState(() {
      _selectedSubcategoryId = subcategoryId;
      _productsFuture = ApiService.fetchProducts(subcategoryId);
    });
  }

  bool isMenuOpen = false;
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isRTL = Directionality.of(context) == flutter.TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorApp.green_color,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Icon(Icons.grid_view_outlined, color: ColorApp.white_color),
          )
        ],
        leading: IconButton(
          icon: Padding(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: Icon(Icons.menu, color: ColorApp.white_color),
          ),
          onPressed: () {
            setState(() {
              // تغيير حالة القائمة عند الضغط
              isMenuOpen = !isMenuOpen;
            });
          },
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color:Theme.of(context).brightness == Brightness.dark
                ? ColorApp.black_color
                : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xffD3D3D3)),
          ),
          child: Row(
            textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
            children: [
              const Icon(Icons.search, color: Colors.grey),
              Expanded(
                child: TextField(
                  textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isRTL ? 'ابحث في حراج' : 'Search in haraj',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: _updateSearchQuery,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: theme.isDarkMode ? Colors.grey[900] : ColorApp.grey_color,
            child: ListView(

              children: [
                FutureBuilder<List<dynamic>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) =>
                      _handleCategorySnapshot(snapshot, theme),
                ),
                if (_subcategoriesFuture != null)
                  FutureBuilder<List<dynamic>>(
                    future: _subcategoriesFuture,
                    builder: (context, snapshot) =>
                        _handleSubcategorySnapshot(snapshot, theme),
                  ),
                if (_productsFuture != null)
                  FutureBuilder<List<dynamic>>(
                    future: _productsFuture,
                    builder: (context, snapshot) =>
                        _handleProductSnapshot(snapshot, theme),
                  ),
              ],
            ),
          ),
          // عرض القائمة المخصصة فقط إذا كانت حالة isMenuOpen صحيحة
          if (isMenuOpen)
            CustomMenu(isMenuOpen: isMenuOpen),
        ],
      ),
    );
  }
  Widget _handleCategorySnapshot(
      AsyncSnapshot<List<dynamic>> snapshot, ThemeProvider theme) {
    if (snapshot.connectionState == ConnectionState.waiting)
      return _buildLoading();
    if (snapshot.hasError) return _buildError(snapshot.error.toString());
    if (!snapshot.hasData || snapshot.data!.isEmpty)
      return _buildMessage('No categories found');
    return Padding(
      padding: EdgeInsets.only(right: 15.w, top: 8.h),
      child: Directionality(
          textDirection: flutter.TextDirection.rtl,
          child: _buildCategoryRow(snapshot.data!, theme)),
    );
  }

  Widget _handleSubcategorySnapshot(
      AsyncSnapshot<List<dynamic>> snapshot, ThemeProvider theme) {
    if (snapshot.connectionState == ConnectionState.waiting)
      return _buildLoading();
    if (snapshot.hasError) return _buildError(snapshot.error.toString());
    if (!snapshot.hasData || snapshot.data!.isEmpty)
      return _buildMessage('No subcategories found');
    return Padding(
      padding: EdgeInsets.only(right: 15.w, top: 8.h),
      child: Directionality(
          textDirection: flutter.TextDirection.rtl,
          child: _buildSubcategoryRow(snapshot.data!, theme)),
    );
  }

  Widget _handleProductSnapshot(
      AsyncSnapshot<List<dynamic>> snapshot, ThemeProvider theme) {
    if (snapshot.connectionState == ConnectionState.waiting)
      return _buildLoading();
    if (snapshot.hasError) return _buildError(snapshot.error.toString());
    if (!snapshot.hasData || snapshot.data!.isEmpty)
      return _buildMessage('No products found');

    final filteredProducts = _filterProducts(snapshot.data!);

    return SingleChildScrollView(
      child: Column(
          children: filteredProducts
              .map((product) =>
                  ProductItemWidget(productDetails: product, themeProvider: theme))
              .toList()),
    );
  }

  Widget _buildLoading() => Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(child: CircularProgressIndicator()));

  Widget _buildError(String error) => Padding(
      padding: const EdgeInsets.all(16),
      child: Text('Error: $error', style: const TextStyle(color: Colors.red)));

  Widget _buildMessage(String message) => Center(child: Text(message));
}

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({Key? key}) : super(key: key);

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _arabicNameController = TextEditingController();
  final _englishNameController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // جلب التوكن من SharedPreferences
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _image != null) {
      final token = await _getToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token not found')),
        );
        return;
      }

      final url =
          Uri.parse('https://harajalmamlaka.com/api/categories?lang=ar');

      // إنشاء طلب POST مع الصورة
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name_ar'] = _arabicNameController.text
        ..fields['name_en'] = _englishNameController.text
        ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

      try {
        final response = await request.send();

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseBody =
              await response.stream.bytesToString(); // قراءة جسم الاستجابة
          print('Response Body: $responseBody'); // طباعة جسم الاستجابة

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category added successfully!')),
          );
          Navigator.pop(context); // إغلاق الصفحة بعد الإرسال
        } else {
          final responseBody =
              await response.stream.bytesToString(); // قراءة جسم الاستجابة
          print('Response Body: $responseBody'); // طباعة جسم الاستجابة

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to add category: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select an image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // حقل الاسم العربي
              TextFormField(
                controller: _arabicNameController,
                decoration: const InputDecoration(
                  labelText: 'Arabic Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Arabic name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // حقل الاسم الإنجليزي
              TextFormField(
                controller: _englishNameController,
                decoration: const InputDecoration(
                  labelText: 'English Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the English name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // زر اختيار الصورة
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image == null
                      ? const Center(
                          child: Text('Tap to add an image'),
                        )
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16.h),

              // زر الإرسال
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
