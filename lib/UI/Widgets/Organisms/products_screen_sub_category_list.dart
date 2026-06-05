// import 'package:flutter/material.dart';
// import '../../../app_colors.dart';

// const subCategory = [
//   "Milk",
//   "Bread & Pav",
//   "Butter & Cheese",
//   "Paneer & Curd",
//   "Eggs",
//   "Oats",
//   "Flakes & Cereals",
//   "Vermicelli",
//   "Peanut Butter",
//   "Condensed Milk"
// ];

// class SubCategoryList extends StatefulWidget {
//   final Function(int)? onCategorySelected;

//   const SubCategoryList({
//     super.key,
//     this.onCategorySelected,
//   });

//   @override
//   State<SubCategoryList> createState() => _SubCategoryListState();
// }

// class _SubCategoryListState extends State<SubCategoryList> {
//   int selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const BouncingScrollPhysics(),
//       itemBuilder: (BuildContext context, int index) {
//         if (index == subCategory.length) {
//           return const SizedBox(height: 50);
//         }

//         bool isSelected = index == selectedIndex;

//         return GestureDetector(
//           onTap: () {
//             setState(() {
//               selectedIndex = index;
//             });
//             // Call callback if provided
//             widget.onCategorySelected?.call(index);
//           },
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             margin: const EdgeInsets.symmetric(vertical: 10),
//             decoration: BoxDecoration(
//               border: isSelected
//                   ? const Border(
//                 right: BorderSide(
//                   color: AppColors.primaryOrangeColor,
//                   width: 4,
//                 ),
//               )
//                   : null,
//             ),
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundColor: isSelected
//                       ? AppColors.primaryOrangeColor.withOpacity(0.15)
//                       : AppColors.greyWhiteColor,
//                   child: Image.asset(
//                     "Assets/SubCategories/${index + 1}.png",
//                     height: 45,
//                     fit: BoxFit.fitWidth,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subCategory[index],
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                     color: isSelected
//                         ? AppColors.primaryOrangeColor
//                         : Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//       itemCount: subCategory.length + 1,
//     );
//   }
// }


// import 'package:e_commerce/Models/category_model.dart';
// import 'package:e_commerce/Services/api/apiservice.dart';
// import 'package:flutter/material.dart';
// import 'package:e_commerce/app_colors.dart';

// class SubCategoryList extends StatefulWidget {
//   final String categoryName;
//   final Function(String)? onSubCategorySelected;
//   final ApiService apiService;

//   const SubCategoryList({
//     super.key,
//     required this.categoryName,
//     required this.apiService,
//     this.onSubCategorySelected,
//   });

//   @override
//   State<SubCategoryList> createState() => _SubCategoryListState();
// }

// class _SubCategoryListState extends State<SubCategoryList> {
//   late Future<List<SubCategory>> subCategories;
//   int selectedIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     subCategories = widget.apiService.getSubCategories(widget.categoryName);
//   }

//   @override
//   void didUpdateWidget(SubCategoryList oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.categoryName != widget.categoryName) {
//       setState(() {
//         selectedIndex = 0;
//         subCategories = widget.apiService.getSubCategories(widget.categoryName);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<SubCategory>>(
//       future: subCategories,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(
//               color: AppColors.primaryOrangeColor,
//             ),
//           );
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline, size: 48, color: Colors.red),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Failed to load subcategories',
//                   style: Theme.of(context).textTheme.bodyMedium,
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           );
//         }

//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Center(
//             child: Text(
//               'No subcategories available',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           );
//         }

//         final subCats = snapshot.data!;

//         return ListView.builder(
//           shrinkWrap: true,
//           physics: const BouncingScrollPhysics(),
//           itemCount: subCats.length + 1,
//           itemBuilder: (BuildContext context, int index) {
//             if (index == subCats.length) {
//               return const SizedBox(height: 50);
//             }
//             bool isSelected = index == selectedIndex;
//             final subCategory = subCats[index];
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedIndex = index;
//                 });
//                 widget.onSubCategorySelected?.call(subCategory.name);
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//                 decoration: BoxDecoration(
//                   border: isSelected
//                       ? const Border(
//                           right: BorderSide(
//                             color: AppColors.primaryOrangeColor,
//                             width: 4,
//                           ),
//                         )
//                       : null,
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircleAvatar(
//                       radius: 20,
//                       backgroundColor: isSelected
//                           ? AppColors.primaryOrangeColor.withOpacity(0.15)
//                           : AppColors.greyWhiteColor,
//                       child: subCategory.image != null
//                           ? Image.network(
//                               subCategory.image!,
//                               height: 45,
//                               fit: BoxFit.fitWidth,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Icon(
//                                   Icons.image_not_supported,
//                                   color: AppColors.primaryOrangeColor,
//                                 );
//                               },
//                             )
//                           : Icon(
//                               Icons.category,
//                               color: AppColors.primaryOrangeColor,
//                             ),
//                     ),
//                     const SizedBox(height: 8),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       child: Text(
//                         subCategory.name,
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight:
//                               isSelected ? FontWeight.bold : FontWeight.normal,
//                           color: isSelected
//                               ? AppColors.primaryOrangeColor
//                               : Colors.black87,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:e_commerce/Models/category_model.dart';
import 'package:e_commerce/Services/api/apiservice.dart';
import 'package:e_commerce/app_colors.dart';

class SubCategoryList extends StatefulWidget {
  final String categoryName;
  final Function(String)? onSubCategorySelected;
  final ApiService apiService;

  const SubCategoryList({
    super.key,
    required this.categoryName,
    required this.apiService,
    this.onSubCategorySelected,
  });

  @override
  State<SubCategoryList> createState() => _SubCategoryListState();
}

class _SubCategoryListState extends State<SubCategoryList> {
  late Future<List<SubCategory>> subCategories;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    subCategories = widget.apiService.getSubCategories(widget.categoryName);
  }

  @override
  void didUpdateWidget(SubCategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryName != widget.categoryName) {
      setState(() {
        selectedIndex = 0;
        subCategories =
            widget.apiService.getSubCategories(widget.categoryName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SubCategory>>(
      future: subCategories,
      builder: (context, snapshot) {
        // 🔹 Loader while fetching data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: double.infinity,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              color: AppColors.primaryOrangeColor,
            ),
          );
        }

        // 🔹 Error state
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load subcategories',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // 🔹 No data state
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No subcategories available',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        final subCats = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: subCats.length,
          itemBuilder: (BuildContext context, int index) {
            bool isSelected = index == selectedIndex;
            final subCategory = subCats[index];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                widget.onSubCategorySelected?.call(subCategory.name);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  border: isSelected
                      ? const Border(
                          right: BorderSide(
                            color: AppColors.primaryOrangeColor,
                            width: 4,
                          ),
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isSelected
                          ? AppColors.primaryOrangeColor.withOpacity(0.15)
                          : AppColors.greyWhiteColor,
                      child: subCategory.image != null
                          ? Image.network(
                              subCategory.image!,
                              height: 45,
                              fit: BoxFit.fitWidth,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.primaryOrangeColor,
                                );
                              },
                            )
                          : Icon(
                              Icons.category,
                              color: AppColors.primaryOrangeColor,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        subCategory.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primaryOrangeColor
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
