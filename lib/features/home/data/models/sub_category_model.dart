class SubCategory {
  final int id;
  final String nameEn;
  final String nameAr;

  SubCategory({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      nameEn: json['name_en'],
      nameAr: json['name_ar'],
    );
  }
}
