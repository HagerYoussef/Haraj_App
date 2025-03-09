import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../details/presentation/view/details_view.dart';
import '../../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int displayIndex;

  const ProductCard({
    Key? key,
    required this.product,
    required this.displayIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {

      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: displayIndex % 2 == 0 ? ColorApp.grey_color : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: product.images.isNotEmpty
                    ? product.images[0]
                    : 'https://via.placeholder.com/120',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 15),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Title
                  Text(
                    product.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: ColorApp.green_color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Product Price
                  Text(
                    '${product.price} USD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: ColorApp.green_color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Product Location
                  Text(
                    product.location,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Time and Creator Info
                  Row(
                    children: [
                      // Time
                      Text(
                        'قبل 10 دقائق',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Creator Name
                      Text(
                        product.creator.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorApp.green_color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Creator Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          product.creator.avatar,
                        ),
                        onBackgroundImageError: (_, __) => const Icon(
                          Icons.person,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
