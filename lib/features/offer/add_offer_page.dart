import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../core/themes/colors.dart';
import '../../core/themes/theme_provider.dart';
import '../lang/laguage_cubit.dart';
import '../lang/language_manager.dart';

class AddOfferPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const AddOfferPage({Key? key, required this.themeProvider}) : super(key: key);

  @override
  _AddOfferPageState createState() => _AddOfferPageState();
}

class _AddOfferPageState extends State<AddOfferPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  String? offerPrice;
  List<String> uploadedImages = [];
  String? offerTitle;
  String? offerDescription;
  LatLng? selectedLocation;
  String? locationName;
  late final ThemeProvider themeProvider;

  bool get isEnglish => Localizations.localeOf(context).languageCode == 'en';

  TextDirection get currentDirection =>
      isEnglish ? TextDirection.ltr : TextDirection.rtl;

  @override
  void initState() {
    super.initState();
    themeProvider = widget.themeProvider;
  }

  void pickImage(ImageSource source) async {
    final status = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();

    if (status.isGranted && storageStatus.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          uploadedImages.add(pickedFile.path);
        });
        print('تم اختيار صورة: ${pickedFile.path}');
      }
    } else {
      print('الرجاء منح الأذونات اللازمة');
    }
  }

  void pickMultipleImages(List<String> selectedImages) {
    setState(() {
      uploadedImages.addAll(selectedImages);
    });
  }

  Future<void> addOffer() async {
    print("Final Price Before Sending: $offerPrice");

    if (offerPrice == null || offerPrice!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red,content: Text('يرجى إدخال السعر')),
      );
      return;
    }
    if (offerDescription == null || offerDescription!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red,content: Text('يرجى إدخال الوصف')),
      );
      return;
    }
    if ((locationName?.trim()??'').isEmpty || locationName == "يرجى اختيار الموقع") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('يرجى تحديد عنوان العرض')),
      );
      return;
    }

    if (uploadedImages == null || uploadedImages!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red,content: Text('يرجى اضافه صور المنتج')),
      );
      return;
    }
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red,content: Text('يرجى اختيار الفئه الفرعيه')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (offerTitle == null || offerTitle!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red,content: Text('يرجى إدخال عنوان العرض')),
        );
        return;
      }

      final token = await _getToken();
      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red,content: Text('الرجاء تسجيل الدخول أولاً')),
        );
        return;
      }

      final url = Uri.parse('https://harajalmamlaka.com/api/products');
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token';

      // إضافة البيانات النصية
      request.fields['title'] = offerTitle ?? '';
      request.fields['description'] = offerDescription ?? '';
      request.fields['subcategory_id'] = selectedCategory ?? '';
      request.fields['location'] = locationName ?? '';
      request.fields['latitude'] = selectedLocation?.latitude.toString() ?? '';
      request.fields['longitude'] = selectedLocation?.longitude.toString() ?? '';

      // ✅ إضافة السعر إلى الطلب
      request.fields['price'] = (double.tryParse(offerPrice ?? '') ?? 0).toString();

      print("Price Sent to Server: ${request.fields['price']}");

      // إضافة الصور
      for (var imagePath in uploadedImages) {
        final file = File(imagePath);
        request.files.add(await http.MultipartFile.fromPath('images[]', file.path));
      }

      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        print('Response Status: ${response.statusCode}');
        print('Response Body: $responseBody');

        if (response.statusCode == 200) {
          // نجاح
        } else {
          ScaffoldMessenger.of(context).showSnackBar(

            SnackBar(backgroundColor: ColorApp.green_color,content: Text('Offer Added Successfully')),

          );
          Navigator.pop(context);
        }
      } catch (e) {
        print('Full Error: $e');
      }
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: themeProvider.isDarkMode
            ? ColorApp.dark_color
            : ColorApp.white_color,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white, // تغيير لون سهم الرجوع إلى الأبيض
          ),
          actions:[ Padding(
            padding: EdgeInsets.only(top: 15.0.h, left: 5.w,right:5.w),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.translate('can'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )],
          backgroundColor: ColorApp.green_color,
          title: Text(
            AppLocalizations.of(context)!.translate('add'),
            style: TextStyle(

              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Directionality(
          textDirection: currentDirection,
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                AddImageSection(
                  uploadedImages: uploadedImages,
                  pickImages: pickMultipleImages,
                ),
                SizedBox(height: 10.h),
                LocationSection(
                  onLocationSelected: (LatLng location, String name) {
                    setState(() {
                      selectedLocation = location;
                      locationName = name;
                    });
                  },
                ),
                SizedBox(height: 1.h),
                OfferTitleSection(
                  onTitleChanged: (String title) {
                    setState(() {
                      offerTitle = title;
                    });
                  },
                  themeProvider: Provider.of<ThemeProvider>(context),
                ),
                SizedBox(height: 1.h),
                OfferPriceSection(
                  onPriceChanged: (String price) {
                    setState(() {
                      offerPrice = price.isNotEmpty ? price : null; // تأكد أنه ليس فارغًا
                    });
                    print("Updated offerPrice: $offerPrice"); // تحقق من التحديث
                  },
                  themeProvider: Provider.of<ThemeProvider>(context),

                ),

                OfferDescriptionSection(
                  onDescriptionChanged: (String description) {
                    setState(() {
                      offerDescription = description;
                    });
                    print("Description: $offerDescription"); // تحقق من القيم
                  },
                ),

                CategorySection(
                  onCategorySelected: (String categoryId) {
                    setState(() {
                      selectedCategory = categoryId; // يتم حفظ الـ ID كـ String
                    });
                  },
                ),
                SizedBox(height: 15.h),
                NextButtonSection(
                  onPressed: addOffer,
                ),
              ],
            ),
          ),
        ));
  }
}


class OfferPriceSection extends StatefulWidget {
  final Function(String) onPriceChanged;
  final ThemeProvider themeProvider;

  const OfferPriceSection({
    required this.onPriceChanged,
    required this.themeProvider,
  });

  @override
  State<OfferPriceSection> createState() => _OfferPriceSectionState();
}

class _OfferPriceSectionState extends State<OfferPriceSection> {
  @override
  Widget build(BuildContext context) {
    final bool isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final TextDirection currentDirection =
    isEnglish ? TextDirection.ltr : TextDirection.rtl;

    return Container(
      width: double.infinity,
      color: widget.themeProvider.isDarkMode
          ? ColorApp.black_color
          : ColorApp.grey_color,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            Align(
              alignment: isEnglish ? Alignment.topLeft : Alignment.topRight,
              child: Text(
                AppLocalizations.of(context)!.translate('price'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 50.h,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.translate('price_example'),
                  contentPadding: EdgeInsetsDirectional.only(
                    start: 5.w,
                  ),
                  // ✅ تصحيح اتجاه النص

                ),
                onChanged: (value) {
                  widget.onPriceChanged(value); // ✅ تحديث القيمة في الأب
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AddImageSection extends StatefulWidget {
  final Function(List<String>) pickImages;
  final List<String> uploadedImages;

  AddImageSection({required this.pickImages, required this.uploadedImages});

  @override
  _AddImageSectionState createState() => _AddImageSectionState();
}

class _AddImageSectionState extends State<AddImageSection> {
  void pickImagesWithPermissions(BuildContext context) async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();

    if (cameraStatus.isGranted && storageStatus.isGranted) {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? pickedFiles = await picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        widget.pickImages(pickedFiles.map((file) => file.path).toList());
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء منح الأذونات اللازمة')),
      );
    }
  }

  void removeImage(String path) {
    setState(() {
      widget.uploadedImages.remove(path);
    });
    widget.pickImages(widget.uploadedImages);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider =
    Provider.of<ThemeProvider>(context); // إضافة هذا السطر

    return Padding(
      padding: EdgeInsets.only(top: 16.h, right: 8.w, left: 8.w),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.topStart,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.translate('add2'),
                        style: TextStyle(color: ColorApp.green_color),
                        textAlign: TextAlign.center,
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.photo_library,
                                color: ColorApp.green_color),
                            title: Text("الاستوديو"),
                            onTap: () {
                              Navigator.pop(context);
                              pickImagesWithPermissions(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.cancel, color: Colors.red),
                            title: Text(
                                AppLocalizations.of(context)!.translate('can')),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? ColorApp.black_color
                      : ColorApp.grey_color,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                width: 120,
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      color: ColorApp.green_color,
                      size: 40,
                    ),
                    Text(
                      AppLocalizations.of(context)!.translate('add2'),
                      style: TextStyle(color: ColorApp.green_color),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          widget.uploadedImages.isEmpty
              ? Container()
              : Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.uploadedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(
                                File(widget.uploadedImages[index])),
                            fit: BoxFit.cover,
                          ),
                          borderRadius:
                          BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      Positioned(
                        top: -10,
                        right: -12,
                        child: IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            removeImage(widget.uploadedImages[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LocationSection extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;

  LocationSection({required this.onLocationSelected});

  @override
  _LocationSectionState createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection>
    with WidgetsBindingObserver {
  // Add mixin here

  late GoogleMapController _mapController;
  LatLng _selectedLocation = LatLng(21.4225, 39.8262);
  bool _locationSelected = false;
  String _locationName = "يرجى اختيار الموقع";
  Marker? _marker;

  @override
  void didChangeLocales(List<Locale>? locales) {
    setState(() {}); // إعادة بناء الواجهة عند تغيير اللغة
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionStatus();
    _loadSavedLocation();
    _initializeMarker();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Clean up the observer
    super.dispose();
  }

  void _initializeMarker() {
    _marker = Marker(
      markerId: MarkerId('selected_location'),
      position: _selectedLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
  }

  Future<void> _checkPermissionStatus() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _marker = Marker(
          markerId: MarkerId('selected_location'),
          position: _selectedLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
      });

      await _getLocationName(position.latitude, position.longitude);
    } catch (e) {
      print("خطأ في الحصول على الموقع الحالي: $e");
    }
  }

  Future<void> _getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String name = _getBestLocationName(place);

        print("Fetched Location Name: $name"); // تأكد من أن الاسم ليس فارغًا

        setState(() {
          _locationName = name;
          _locationSelected = true;
        });

        widget.onLocationSelected(_selectedLocation, _locationName);
      }
    } catch (e) {
      print("خطأ في تحويل الإحداثيات: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('فشل في تحديد اسم الموقع')));
    }
  }

  String _getBestLocationName(Placemark place) {
    return place.locality ??
        place.subAdministrativeArea ??
        place.administrativeArea ??
        "موقع غير معروف";
  }

  Future<void> _saveLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLocation', _locationName);
    print("Saved Location Name: $_locationName"); // تأكد من أنه يتم حفظ الاسم
  }

  Future<void> _loadSavedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('selectedLocation');

    print("Loaded Location Name: $savedName"); // تحقق مما يتم تحميله

    if (savedName != null && savedName.isNotEmpty) {
      setState(() {
        _locationName = savedName;
        _locationSelected = true;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      await _getCurrentLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الإذن مطلوب لاستخدام الخريطة')));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng latLng) async {
    setState(() {
      _selectedLocation = latLng;
      _locationSelected = true;
      _marker = Marker(
        markerId: MarkerId('selected_location'),
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    });

    await _getLocationName(latLng.latitude, latLng.longitude);
  }

  bool _isRTL(BuildContext context) {
    return Directionality.of(context).index == TextDirection.rtl.index;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider =
    Provider.of<ThemeProvider>(context); // إضافة هذا السطر

    return Container(
      width: double.infinity,
      color:
      themeProvider.isDarkMode ? ColorApp.black_color : ColorApp.grey_color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: _isRTL(context)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Align(
              alignment: _isRTL(context)
                  ? Alignment.topRight
                  : Alignment.topLeft,
              child: Text(
                AppLocalizations.of(context)!.translate('loc'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (await Permission.location.isGranted) {
                  showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setState) {
                        return Dialog(
                          child: Column(
                            children: [
                              AppBar(
                                title: Text('اختر موقعك'),
                                actions: [
                                  IconButton(
                                    icon: Icon(Icons.check),
                                    onPressed: () async {
                                      if (_locationSelected) {
                                        await _saveLocation();
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Expanded(
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: _selectedLocation,
                                    zoom: 14,
                                  ),
                                  onMapCreated: _onMapCreated,
                                  onTap: _onTap,
                                  markers: _marker != null ? {_marker!} : {},
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  await _requestLocationPermission();
                }
              },

              child:  Align(
                alignment: _isRTL(context)
                    ? Alignment.topRight
                    : Alignment.topLeft,
                child:Text(
                  _locationName,
                  style: TextStyle(
                    color: ColorApp.green_color,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ) ],
        ),
      ),
    );
  }
}

class OfferTitleSection extends StatelessWidget {
  final Function(String) onTitleChanged;
  final ThemeProvider themeProvider;

  const OfferTitleSection({
    required this.onTitleChanged,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final TextDirection currentDirection =
    isEnglish ? TextDirection.ltr : TextDirection.rtl;

    return Container(
      width: double.infinity,
      color:
      themeProvider.isDarkMode ? ColorApp.black_color : ColorApp.grey_color,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            Align(
              alignment: isEnglish ? Alignment.topLeft : Alignment.topRight,
              child: Text(
                AppLocalizations.of(context)!.translate('sub'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 50.h,
              child: TextFormField(
                onChanged: onTitleChanged,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.translate('ex'),
                  hintStyle: TextStyle(
                    textBaseline: TextBaseline.alphabetic,
                  ),
                  hintTextDirection: Directionality.of(context), // تحديد الاتجاه تلقائيًا
                  contentPadding: EdgeInsetsDirectional.only(
                    start: 5.w, // سيتم تطبيقه على الجانب "البداية" حسب الاتجاه
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            )],
        ),
      ),
    );
  }
}


class OfferDescriptionSection extends StatelessWidget {
  final Function(String) onDescriptionChanged;
  final String? offerDescription; // إضافة متغير لحفظ النص الأولي

  OfferDescriptionSection({
    required this.onDescriptionChanged,
    this.offerDescription, // اجعلها اختيارية
  });

  bool _isRTL(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: double.infinity,
      color: themeProvider.isDarkMode ? ColorApp.black_color : ColorApp.grey_color,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: _isRTL(context) ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.translate('offer'),
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10.h), // مسافة صغيرة بين العنوان وحقل الإدخال
          TextFormField(

            initialValue: offerDescription,
            textDirection: _isRTL(context) ? TextDirection.rtl : TextDirection.ltr,
            textAlign: _isRTL(context) ? TextAlign.right : TextAlign.left,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.translate('description_example'),
            ),
            onChanged: onDescriptionChanged,
          ),
        ],
      ),
    );
  }
}

class CategorySection extends StatefulWidget {
  final Function(String) onCategorySelected;

  CategorySection({required this.onCategorySelected});

  @override
  _CategorySectionState createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  Future<List<dynamic>>? _categoriesFuture;
  Map<int, List<dynamic>> subcategoriesCache = {};
  String displayedCategory = '';

  @override
  void initState() {
    final currentLanguage = context.read<LanguageCubit>().state.languageCode;

    super.initState();
    _categoriesFuture = fetchCategories(currentLanguage);
  }

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ??
        '130|TUHrXzvL11mrXtR73rrhCG2CTaosPrxzOpyvq8dK75862981';
  }
  bool _isRTL(BuildContext context) {
    return Directionality.of(context).index == TextDirection.rtl.index;
  }
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

  Future<List<dynamic>> fetchSubcategories(int categoryId) async {
    final url =
    Uri.parse('https://harajalmamlaka.com/api/categories/$categoryId');
    final token = await getToken();

    if (token.isEmpty) {
      throw Exception('Token not found');
    }

    try {
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categoryData = data['data'];
        final List<dynamic> subcategories = categoryData['subcategories'] ?? [];
        return subcategories;
      } else {
        throw Exception('Failed to load subcategories: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider =
    Provider.of<ThemeProvider>(context); // إضافة هذا السطر

    return Expanded(
      child: Container(
        width: double.infinity,
        color: themeProvider.isDarkMode
            ? ColorApp.black_color
            : ColorApp.grey_color,
        child: Padding(
          padding: EdgeInsets.all(12.h),
          child: SingleChildScrollView(
            child: ExpansionTile(
              title: Column(
                children: [
                  Align(
                      alignment:  _isRTL(context)
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: Text(AppLocalizations.of(context)!.translate('sec'))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayedCategory,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              children: [
                FutureBuilder(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('لا توجد أقسام.'));
                    } else {
                      final categories = snapshot.data as List<dynamic>;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final categoryName =
                              category['name'] ?? 'قسم غير مُسمى';
                          final categoryId =
                              int.tryParse(category['id'].toString()) ?? 0;
                          return ExpansionTile(
                            title: GestureDetector(
                              onTap: () {
                                setState(() {
                                  displayedCategory = '$categoryName';
                                });
                              },
                              child: Text(
                                categoryName,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                            children: [
                              FutureBuilder(
                                future: fetchSubcategories(categoryId),
                                builder: (context, subSnapshot) {
                                  if (subSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else if (subSnapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            'خطأ أثناء تحميل الأقسام الفرعية: ${subSnapshot.error}'));
                                  } else {
                                    final subcategories =
                                    subSnapshot.data as List<dynamic>;
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: subcategories.length,
                                      itemBuilder: (context, subIndex) {
                                        final subcat = subcategories[subIndex];
                                        final bool isEnglish =
                                            Localizations.localeOf(context)
                                                .languageCode ==
                                                'en';

                                        final subcatName = isEnglish
                                            ? subcat['name_en'] ??
                                            'Untitled Subcategory'
                                            : subcat['name_ar'] ??
                                            'قسم فرعي غير مُسمى';
                                        return ListTile(
                                          title: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                displayedCategory =
                                                '$categoryName > $subcatName';
                                              });
                                              widget.onCategorySelected(subcat[
                                              'id']
                                                  .toString()); // يتم إرسال الـ ID كـ String
                                              print(
                                                  'تم اختيار الفئة الفرعية: ${subcat['id']}'); // هنا يتم طباعة الـ ID
                                            },
                                            child: Text(
                                              subcatName,
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NextButtonSection extends StatelessWidget {
  final VoidCallback onPressed;

  NextButtonSection({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          color: ColorApp.green_color,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Center(
          child: TextButton(
            onPressed: onPressed,
            child: Text(
              AppLocalizations.of(context)!.translate('add'),
              style: TextStyle(color: ColorApp.white_color),
            ),
          ),
        ),
      ),
    );
  }
}