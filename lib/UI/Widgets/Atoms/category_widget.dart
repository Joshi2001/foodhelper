
import 'package:e_commerce/Models/public_model.dart';
import 'package:e_commerce/UI/Widgets/Atoms/asdfg.dart';
import 'package:flutter/material.dart';
class CategoryWidget extends StatelessWidget {
  final AppCategory category;

  const CategoryWidget({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubCategoryScreen(categoryId: category.id),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12), 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: category.image.isNotEmpty
                    ? Image.network(
                  category.image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(),
                )
                    : _imagePlaceholder(),
              ),
            ),
          ),

          const SizedBox(height: 8), 
          SizedBox(
            height: 35, 
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF263238), 
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Icon(
        Icons.local_grocery_store_outlined,
        color: Colors.grey.shade300,
        size: 30,
      ),
    );
  }
}
