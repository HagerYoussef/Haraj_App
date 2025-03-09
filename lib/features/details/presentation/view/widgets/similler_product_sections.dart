// import 'package:flutter/material.dart';
//
// import '../../../../../core/themes/colors.dart';
// import '../details_view.dart';
//
// class SimilarProductsSection extends StatelessWidget {
//   final List<Map<String, dynamic>> similarProducts;
//
//   const SimilarProductsSection({Key? key, required this.similarProducts}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300, width: 1),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Align(
//             alignment: Alignment.topRight,
//             child: Text(
//               'العروض المشابهة',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: ColorApp.black_color,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//               childAspectRatio: 1,
//             ),
//             itemCount: similarProducts.length,
//             itemBuilder: (context, index) {
//               final product = similarProducts[index];
//               return GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ProductDetailsPage(
//                         // productId: product['id'],
//                       ),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   color: Colors.red,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       product['image'],
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
