
import 'dart:async';
import 'dart:io';

import 'package:e_commerce/Models/category_model.dart';
import 'package:e_commerce/Services/api/apiservice.dart';
import 'package:flutter/material.dart';

class SubCategoriesProvider extends ChangeNotifier {
  final ApiService apiService;
  
  List<SubCategory> subCategories = [];
  bool isLoading = false;
  String? errorMessage;

  SubCategoriesProvider({required this.apiService});

  Future<void> fetchSubCategories(String category) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      subCategories = await apiService.getSubCategories(category);
      errorMessage = null;
    } catch (e) {
      errorMessage = _handleError(e);
      subCategories = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your connection.';
    } else if (error is TimeoutException) {
      return 'Request timeout. Please try again.';
    } else if (error is FormatException) {
      return 'Invalid response format. Please try again.';
    } else {
      return error.toString().replaceFirst('Exception: ', '');
    }
  }
}
