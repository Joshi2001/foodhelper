import 'dart:convert';
import 'package:e_commerce/UI/Widgets/address/service_area_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAddress extends StatefulWidget {
  final Function(Map<String, dynamic>)? onAddressSelected;

  const AddAddress({
    super.key,
    this.onAddressSelected,
  });

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  String? address;
  String? extractedCity;
  String? extractedPincode;
  String? extractedArea;
  double? selectedLat;
  double? selectedLng;
  bool? _isServiceable;

  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> _areaSuggestions = [];
  bool _showSuggestions = false;
  bool _isLoadingAreas = false;

  Map<String, dynamic>? _selectedSuggestion;

  List<Map<String, dynamic>> _savedAddresses = [];

  // Currently selected/active address (for highlight)
  int? _activeAddressIndex;

  // Edit mode — agar koi index hai to hum edit kar rahe hain
  int? _editingIndex;

  String _selectedAddressType = 'Home';
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _detailedAddressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  static const _primaryRed = Color(0xFFE24B4A);
  static const _redLight = Color(0xFFFEF2F2);
  static const _redDark = Color(0xFFA32D2D);
  static const _greenLight = Color(0xFFEAF3DE);
  static const _greenDark = Color(0xFF3B6D11);
  static const _greenMid = Color(0xFF27500A);

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchTextChanged);
    _searchFocusNode.addListener(_onFocusChange);
    _loadSavedAddresses();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServiceAreasOnce();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchTextChanged);
    _searchFocusNode.removeListener(_onFocusChange);
    searchController.dispose();
    _searchFocusNode.dispose();
    _houseController.dispose();
    _floorController.dispose();
    _buildingController.dispose();
    _landmarkController.dispose();
    _detailedAddressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  // DATA METHODS
  // ─────────────────────────────────────────

  Future<void> _loadSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getStringList('saved_addresses');
    if (addressesJson != null) {
      setState(() {
        _savedAddresses = addressesJson
            .map((e) => jsonDecode(e) as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> _persistAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addresses = _savedAddresses.map((a) => jsonEncode(a)).toList();
    await prefs.setStringList('saved_addresses', addresses);
  }

  /// CREATE / UPDATE
  Future<void> _saveCurrentAddress() async {
    if (_selectedSuggestion == null) {
      _showSnack('Please select a location first', _primaryRed);
      return;
    }
    if (_phoneController.text.trim().length != 10) {
  _showSnack('Please enter valid 10 digit phone number', _primaryRed);
  return;
}
    if (_nameController.text.trim().isEmpty) {
      _showSnack('Please enter your full name', _primaryRed);
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showSnack('Please enter your phone number', _primaryRed);
      return;
    }
    if (_houseController.text.trim().isEmpty) {
      _showSnack('Please enter your house / flat number', _primaryRed);
      return;
    }
    if (_detailedAddressController.text.trim().isEmpty) {
      _showSnack('Please enter your detailed address', _primaryRed);
      return;
    }

    final fullAddressData = {
      'type': _selectedAddressType,
      'fullName': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'area': extractedArea ?? '',
      'city': extractedCity ?? '',
      'pincode': extractedPincode ?? '',
      'latitude': selectedLat ?? 0,
      'longitude': selectedLng ?? 0,
      'house': _houseController.text.trim(),
      'floor': _floorController.text.trim(),
      'building': _buildingController.text.trim(),
      'landmark': _landmarkController.text.trim(),
      'address': _detailedAddressController.text.trim(),
      'fullAddress': _formatFullAddress(),
    };

    if (_editingIndex != null) {
      // UPDATE existing
      setState(() {
        _savedAddresses[_editingIndex!] = fullAddressData;
        _editingIndex = null;
      });
      await _persistAddresses();
      await _loadSavedAddresses();
      _resetForm();
      _showSnack('Address updated successfully!', _greenDark);
    } else {
      // CREATE — same type hogi to replace karo
      final existingIndex = _savedAddresses.indexWhere(
        (a) => a['type'] == _selectedAddressType,
      );
      if (existingIndex != -1) {
        setState(() => _savedAddresses[existingIndex] = fullAddressData);
      } else {
        setState(() => _savedAddresses.add(fullAddressData));
      }
      await _persistAddresses();
      await _loadSavedAddresses();
      _showSnack('Address saved successfully!', _greenDark);
      _navigateToCartWithAddress(fullAddressData);
    }
  }

  /// EDIT — form mein data bhar do
  void _startEditing(int index) {
    final addr = _savedAddresses[index];
    setState(() {
      _editingIndex = index;
      _selectedAddressType = addr['type'] ?? 'Home';
      _nameController.text = addr['fullName'] ?? '';
      _phoneController.text = addr['phone'] ?? '';
      _houseController.text = addr['house'] ?? '';
      _floorController.text = addr['floor'] ?? '';
      _buildingController.text = addr['building'] ?? '';
      _landmarkController.text = addr['landmark'] ?? '';
      _detailedAddressController.text = addr['address'] ?? '';
      // Restore location suggestion
      extractedArea = addr['area'];
      extractedCity = addr['city'];
      extractedPincode = addr['pincode'];
      selectedLat = (addr['latitude'] as num?)?.toDouble();
      selectedLng = (addr['longitude'] as num?)?.toDouble();
      _selectedSuggestion = {
        'name': addr['area'] ?? '',
        'area': addr['area'],
        'city': addr['city'],
        'pincode': addr['pincode'],
        'latitude': selectedLat,
        'longitude': selectedLng,
      };
      searchController.text = '${addr['area'] ?? ''}, ${addr['city'] ?? ''}';
    });
    // Scroll to top
    Scrollable.ensureVisible(context);
  }

  void _cancelEditing() {
    setState(() => _editingIndex = null);
    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _selectedSuggestion = null;
      extractedArea = null;
      extractedCity = null;
      extractedPincode = null;
      selectedLat = null;
      selectedLng = null;
      _selectedAddressType = 'Home';
    });
    searchController.clear();
    _nameController.clear();
    _phoneController.clear();
    _houseController.clear();
    _floorController.clear();
    _buildingController.clear();
    _landmarkController.clear();
    _detailedAddressController.clear();
  }

  /// DELETE with confirm dialog
  Future<void> _deleteAddress(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete address?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text(
          'Are you sure you want to delete this ${_savedAddresses[index]['type']} address?',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: _primaryRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        if (_activeAddressIndex == index) _activeAddressIndex = null;
        if (_editingIndex == index) {
          _editingIndex = null;
          _resetForm();
        }
        _savedAddresses.removeAt(index);
        // Re-adjust active index if needed
        if (_activeAddressIndex != null &&
            _activeAddressIndex! >= _savedAddresses.length) {
          _activeAddressIndex = null;
        }
      });
      await _persistAddresses();
      _showSnack('Address deleted', Colors.grey.shade700);
    }
  }

  /// SELECT existing address → cart pe navigate
  void _selectExistingAddress(int index) {
    setState(() => _activeAddressIndex = index);
    final addressData = Map<String, dynamic>.from(_savedAddresses[index]);
    _navigateToCartWithAddress(addressData);
  }

  void _navigateToCartWithAddress(Map<String, dynamic> addressData) {
    // Transform address to format expected by OrderProvider
    final transformedAddress = {
      'fullName': addressData['fullName'] ?? '',
      'phone': addressData['phone'] ?? '',
      'name': addressData['fullName'] ?? '',
      'receiverName': addressData['fullName'] ?? '',
      'receiverPhone': addressData['phone'] ?? '',
      'street': _formatStreetAddress(addressData),
      'addressLine': _formatStreetAddress(addressData),
      'address': _formatStreetAddress(addressData),
      'city': addressData['city'] ?? '',
      'state': addressData['city'] ?? '',
      'pincode': addressData['pincode'] ?? '',
      'area': addressData['area'] ?? '',
      'areaName': addressData['area'] ?? '',
      'house': addressData['house'] ?? '',
      'floor': addressData['floor'] ?? '',
      'building': addressData['building'] ?? '',
      'landmark': addressData['landmark'] ?? '',
    };
    
    debugPrint("=================================");
    debugPrint("📤 TRANSFORMED ADDRESS FOR ORDER:");
    debugPrint("   fullName: ${transformedAddress['fullName']}");
    debugPrint("   phone: ${transformedAddress['phone']}");
    debugPrint("   address: ${transformedAddress['address']}");
    debugPrint("   city: ${transformedAddress['city']}");
    debugPrint("   pincode: ${transformedAddress['pincode']}");
    debugPrint("=================================");
    
    if (widget.onAddressSelected != null) {
      widget.onAddressSelected!(transformedAddress);
    }
    Navigator.pop(context, transformedAddress);
  }
  
  String _formatStreetAddress(Map<String, dynamic> addressData) {
    return [
      addressData['house'] ?? '',
      addressData['floor'] ?? '',
      addressData['building'] ?? '',
      addressData['landmark'] ?? '',
      addressData['address'] ?? '',
      addressData['area'] ?? '',
    ].where((e) => e.isNotEmpty).join(', ');
  }
  
  String _formatFullAddress() {
    return [
      _nameController.text.trim(),
      _phoneController.text.trim(),
      _houseController.text.trim(),
      _floorController.text.trim(),
      _buildingController.text.trim(),
      _landmarkController.text.trim(),
      _detailedAddressController.text.trim(),
      extractedArea ?? '',
      extractedCity ?? '',
      extractedPincode ?? '',
    ].where((e) => e.isNotEmpty).join(', ');
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─────────────────────────────────────────
  // SEARCH METHODS
  // ─────────────────────────────────────────

  Future<void> _loadServiceAreasOnce() async {
    final provider = Provider.of<ServiceAreaProvider>(context, listen: false);
    if (provider.serviceCities.isEmpty && !_isLoadingAreas) {
      setState(() => _isLoadingAreas = true);
      await provider.fetchServiceAreas();
      if (mounted) setState(() => _isLoadingAreas = false);
    }
  }

  void _onFocusChange() {
    if (_searchFocusNode.hasFocus) {
      if (searchController.text.isEmpty) {
        _loadPopularAreas();
      } else {
        setState(() => _showSuggestions = _areaSuggestions.isNotEmpty);
      }
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _showSuggestions = false);
      });
    }
  }

  void _onSearchTextChanged() {
    final query = searchController.text;
    if (query.isEmpty) {
      _loadPopularAreas();
      return;
    }
    _filterAreaSuggestions(query);
  }

  void _loadPopularAreas() {
    final serviceProvider = Provider.of<ServiceAreaProvider>(context, listen: false);
    final suggestions = <Map<String, dynamic>>[];

    for (final city in serviceProvider.serviceCities) {
      suggestions.add({
        'type': 'city',
        'name': city.city,
        'area': city.city,
        'city': city.city,
        'pincode': city.areas.isNotEmpty ? city.areas.first.pincode : '',
        'latitude': city.latitude ?? 28.6139,
        'longitude': city.longitude ?? 77.2090,
      });
      int areaCount = 0;
      for (final area in city.areas) {
        if (area.active && areaCount < 2) {
          suggestions.add({
            'type': 'area',
            'name': '${area.name}, ${city.city}',
            'area': area.name,
            'city': city.city,
            'pincode': area.pincode,
            'latitude': area.latitude ?? city.latitude ?? 28.6139,
            'longitude': area.longitude ?? city.longitude ?? 77.2090,
          });
          areaCount++;
        }
      }
    }

    setState(() {
      _areaSuggestions = suggestions.take(8).toList();
      _showSuggestions = _searchFocusNode.hasFocus && _areaSuggestions.isNotEmpty;
    });
  }

  void _filterAreaSuggestions(String query) {
    final serviceProvider = Provider.of<ServiceAreaProvider>(context, listen: false);
    final suggestions = <Map<String, dynamic>>[];
    final lq = query.toLowerCase();

    for (final city in serviceProvider.serviceCities) {
      if (city.city.toLowerCase().contains(lq)) {
        suggestions.add({
          'type': 'city',
          'name': city.city,
          'area': city.city,
          'city': city.city,
          'pincode': city.areas.isNotEmpty ? city.areas.first.pincode : '',
          'latitude': city.latitude ?? 28.6139,
          'longitude': city.longitude ?? 77.2090,
        });
      }
      for (final area in city.areas) {
        if (area.active && area.name.toLowerCase().contains(lq)) {
          suggestions.add({
            'type': 'area',
            'name': '${area.name}, ${city.city}',
            'area': area.name,
            'city': city.city,
            'pincode': area.pincode,
            'latitude': area.latitude ?? city.latitude ?? 28.6139,
            'longitude': area.longitude ?? city.longitude ?? 77.2090,
          });
        }
      }
    }

    setState(() {
      _areaSuggestions = suggestions.take(10).toList();
      _showSuggestions = _searchFocusNode.hasFocus && _areaSuggestions.isNotEmpty;
    });
  }

  void _selectSuggestion(Map<String, dynamic> suggestion) {
    setState(() {
      _selectedSuggestion = suggestion;
      searchController.text = suggestion['name'];
      _showSuggestions = false;
      address = suggestion['name'];
      extractedCity = suggestion['city'];
      extractedPincode = suggestion['pincode'];
      extractedArea = suggestion['area'];
      selectedLat = suggestion['latitude'];
      selectedLng = suggestion['longitude'];
      _isServiceable = true;
    });
  }

  // ─────────────────────────────────────────
  // UI WIDGETS
  // ─────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildAddressTypeSelector() {
    final types = [
      {'label': 'Home', 'icon': Icons.home_rounded},
      {'label': 'Office', 'icon': Icons.work_rounded},
      {'label': 'Other', 'icon': Icons.location_on_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Save as'),
        Row(
          children: types.map((t) {
            final label = t['label'] as String;
            final icon = t['icon'] as IconData;
            final isSelected = _selectedAddressType == label;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedAddressType = label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? _redLight : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _primaryRed : Colors.grey.shade200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon,
                          size: 22,
                          color: isSelected ? _primaryRed : Colors.grey.shade500),
                      const SizedBox(height: 5),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? _redDark : Colors.grey.shade600,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
  required TextEditingController controller,
  required String hint,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primaryRed, width: 1.5),
      ),
    ),
  );
}
  Widget _buildAddressForm() {
    final isEditing = _editingIndex != null;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEditing ? const Color(0xFFFFF8E1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEditing ? const Color(0xFFFFCC02) : Colors.grey.shade100,
          width: isEditing ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isEditing ? Icons.edit_rounded : Icons.edit_location_alt_rounded,
                color: isEditing ? const Color(0xFFBA7517) : _primaryRed,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isEditing ? 'Edit address' : 'Delivery details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isEditing ? const Color(0xFFBA7517) : Colors.black,
                ),
              ),
              if (isEditing) ...[
                const Spacer(),
                GestureDetector(
                  onTap: _cancelEditing,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          
          // Name and Phone fields
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _nameController,
                  hint: 'Full name *',
                ),
              ),
              const SizedBox(width: 10),
             Expanded(
  child: _buildTextField(
    controller: _phoneController,
    hint: 'Phone number *',
    keyboardType: TextInputType.phone,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(10),
    ],
  ),
),
            ],
          ),
          const SizedBox(height: 10),
          
          // House/Flat and Floor
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _houseController,
                  hint: 'House / Flat no. *',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  controller: _floorController,
                  hint: 'Floor (optional)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          _buildTextField(
            controller: _buildingController,
            hint: 'Building / Society name',
          ),
          const SizedBox(height: 10),
          
          _buildTextField(
            controller: _landmarkController,
            hint: 'Landmark (optional)',
          ),
          const SizedBox(height: 10),
          
          _buildTextField(
            controller: _detailedAddressController,
            hint: 'Street, road, or further details... *',
            maxLines: 2,
          ),

          if (_selectedSuggestion != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _greenLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, color: _greenDark, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          extractedArea ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _greenDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pincode: ${extractedPincode ?? ''} · ${extractedCity ?? ''} · Serviceable',
                          style: const TextStyle(fontSize: 11, color: _greenMid),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final bool canSave = _selectedSuggestion != null;
    final bool isEditing = _editingIndex != null;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canSave ? _saveCurrentAddress : null,
        icon: Icon(
          isEditing ? Icons.check_rounded : Icons.save_rounded,
          size: 18,
          color: canSave ? Colors.white : Colors.grey.shade400,
        ),
        label: Text(
          isEditing ? 'Update address' : 'Save & proceed to cart',
          style: TextStyle(
            color: canSave ? Colors.white : Colors.grey.shade400,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: canSave
              ? (isEditing ? const Color(0xFFBA7517) : _primaryRed)
              : Colors.grey.shade200,
          disabledBackgroundColor: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedAddressesSection() {
    if (_savedAddresses.isEmpty) return const SizedBox.shrink();

    final typeConfig = {
      'Home': {
        'icon': Icons.home_rounded,
        'bg': const Color(0xFFE6F1FB),
        'fg': const Color(0xFF185FA5),
      },
      'Office': {
        'icon': Icons.work_rounded,
        'bg': const Color(0xFFFAEEDA),
        'fg': const Color(0xFF854F0B),
      },
      'Other': {
        'icon': Icons.location_on_rounded,
        'bg': const Color(0xFFEEEDFE),
        'fg': const Color(0xFF534AB7),
      },
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionLabel('Saved addresses'),
        ...List.generate(_savedAddresses.length, (index) {
          final addr = _savedAddresses[index];
          final type = addr['type'] as String? ?? 'Home';
          final cfg = typeConfig[type] ?? typeConfig['Other']!;
          final isActive = _activeAddressIndex == index;
          final isBeingEdited = _editingIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? _primaryRed
                    : isBeingEdited
                        ? const Color(0xFFFFCC02)
                        : Colors.grey.shade100,
                width: (isActive || isBeingEdited) ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: cfg['bg'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(cfg['icon'] as IconData,
                        size: 20, color: cfg['fg'] as Color),
                  ),
                  title: Row(
                    children: [
                      Text(type,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _redLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Selected',
                            style: TextStyle(
                                fontSize: 10,
                                color: _primaryRed,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${addr['fullName'] ?? ''} • ${addr['phone'] ?? ''}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        addr['fullAddress'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button
                      IconButton(
                        onPressed: () => _startEditing(index),
                        icon: Icon(Icons.edit_outlined,
                            size: 18, color: const Color(0xFFBA7517)),
                        tooltip: 'Edit',
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                      // Delete button
                      IconButton(
                        onPressed: () => _deleteAddress(index),
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: _primaryRed),
                        tooltip: 'Delete',
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  onTap: () => _selectExistingAddress(index),
                ),

                // "Use this address" bottom strip
                if (!isActive)
                  InkWell(
                    onTap: () => _selectExistingAddress(index),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(13),
                          bottomRight: Radius.circular(13),
                        ),
                        border: Border(top: BorderSide(color: Colors.grey.shade100)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_checkout_rounded,
                              size: 14, color: _primaryRed),
                          SizedBox(width: 6),
                          Text(
                            'Use this address',
                            style: TextStyle(
                              fontSize: 12,
                              color: _primaryRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB5D4F4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF185FA5), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Only serviceable areas are shown. Search your city or area above to add a new address.',
              style: TextStyle(fontSize: 12, color: Color(0xFF0C447C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      focusNode: _searchFocusNode,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search for area, city...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close_rounded, color: Colors.grey.shade400),
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    _selectedSuggestion = null;
                    address = null;
                    _isServiceable = null;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryRed, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSuggestionDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 280),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: _areaSuggestions.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade100, indent: 56),
        itemBuilder: (context, index) {
          final s = _areaSuggestions[index];
          final isCity = s['type'] == 'city';
          return ListTile(
            dense: true,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCity ? const Color(0xFFE6F1FB) : const Color(0xFFEAF3DE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCity ? Icons.location_city_rounded : Icons.location_on_rounded,
                color: isCity ? const Color(0xFF185FA5) : const Color(0xFF3B6D11),
                size: 18,
              ),
            ),
            title: Text(s['name'],
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: s['pincode'] != null && s['pincode'].toString().isNotEmpty
                ? Text('Pincode: ${s['pincode']}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500))
                : null,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3DE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('✓ Serviceable',
                  style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF3B6D11),
                      fontWeight: FontWeight.w600)),
            ),
            onTap: () => _selectSuggestion(s),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_left_rounded,
                  color: Colors.black, size: 22),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Select your location',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey.shade100, height: 1),
          ),
        ),
        body: _isLoadingAreas
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: _primaryRed),
                    const SizedBox(height: 16),
                    Text('Loading service areas...',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchField(),

                    if (_showSuggestions) _buildSuggestionDropdown(),

                    const SizedBox(height: 24),

                    _buildAddressTypeSelector(),
                    
                    const SizedBox(height: 16),

                    _buildAddressForm(),

                    _buildSaveButton(),

                    _buildSavedAddressesSection(),

                    if (_selectedSuggestion == null && _savedAddresses.isEmpty)
                      _buildInfoBanner(),
                  ],
                ),
              ),
      ),
    );
  }
}

// import 'package:e_commerce/UI/Widgets/address/add_address_detalis.dart';
// import 'package:e_commerce/UI/Widgets/address/service_area_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:free_map/free_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart' as geo;
// import 'package:provider/provider.dart';

// class AddAddress extends StatefulWidget {
//   final Function(Map<String, dynamic>)? onAddressSelected;

//   const AddAddress({
//     super.key,
//     this.onAddressSelected,
//   });

//   @override
//   State<AddAddress> createState() => _AddAddressState();
// }

// class _AddAddressState extends State<AddAddress> {
//   final MapController _mapController = MapController();
//   final LatLng _defaultLatLng = const LatLng(28.6139, 77.2090);

//   LatLng? selectedLatLng;
//   String? address;
//   String? extractedCity;
//   String? extractedPincode;
//   String? extractedArea;
//   bool _isCheckingServiceability = false;
//   String? _serviceabilityMessage;
//   bool? _isServiceable;

//   final TextEditingController searchController = TextEditingController();
//   final FocusNode _searchFocusNode = FocusNode();
  
//   List<Map<String, dynamic>> _areaSuggestions = [];
//   bool _showSuggestions = false;
//   bool _isLoadingSuggestions = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadServiceAreas();
//       _getCurrentLocation();
//     });
    
//     searchController.addListener(_onSearchTextChanged);
//     _searchFocusNode.addListener(_onFocusChange);
//   }

//   @override
//   void dispose() {
//     searchController.removeListener(_onSearchTextChanged);
//     _searchFocusNode.removeListener(_onFocusChange);
//     searchController.dispose();
//     _searchFocusNode.dispose();
//     super.dispose();
//   }

//  void _onFocusChange() {
//   setState(() {
//     if (_searchFocusNode.hasFocus) {
//       // When focused, show suggestions even if empty
//       if (_areaSuggestions.isEmpty && searchController.text.isEmpty) {
//         _loadPopularAreas(); // Load popular/default areas
//       } else {
//         _showSuggestions = _areaSuggestions.isNotEmpty;
//       }
//     } else {
//       _showSuggestions = false;
//     }
//   });
// }
// Future<void> _loadPopularAreas() async {
//   setState(() {
//     _isLoadingSuggestions = true;
//   });
  
//   final serviceProvider = Provider.of<ServiceAreaProvider>(context, listen: false);
//   final suggestions = <Map<String, dynamic>>[];
  
//   // Load first few active serviceable areas as suggestions
//   for (final city in serviceProvider.serviceCities) {
//     // Add the city
//     suggestions.add({
//       'type': 'city',
//       'name': city.city,
//       'area': city.city,
//       'city': city.city,
//       'pincode': city.areas.isNotEmpty ? city.areas.first.pincode : '',
//       'latitude': city.latitude ?? 28.6139,
//       'longitude': city.longitude ?? 77.2090,
//     });
    
//     // Add first 2 active areas from each city
//     int areaCount = 0;
//     for (final area in city.areas) {
//       if (area.active && areaCount < 2) {
//         suggestions.add({
//           'type': 'area',
//           'name': '${area.name}, ${city.city}',
//           'area': area.name,
//           'city': city.city,
//           'pincode': area.pincode,
//           'latitude': area.latitude ?? city.latitude ?? 28.6139,
//           'longitude': area.longitude ?? city.longitude ?? 77.2090,
//         });
//         areaCount++;
//       }
//     }
//   }
  
//   setState(() {
//     _areaSuggestions = suggestions.take(8).toList();
//     _showSuggestions = true;
//     _isLoadingSuggestions = false;
//   });
// }
//  void _onSearchTextChanged() {
//   final query = searchController.text;
//   if (query.isEmpty) {
//     setState(() {
//       _showSuggestions = _searchFocusNode.hasFocus; // Keep showing if focused
//       if (_areaSuggestions.isEmpty && _searchFocusNode.hasFocus) {
//         _loadPopularAreas(); // Load popular areas when cleared
//       }
//     });
//     return;
//   }
  
//   _loadAreaSuggestions(query);
// }

//   Future<void> _loadAreaSuggestions(String query) async {
//     setState(() {
//       _isLoadingSuggestions = true;
//     });
    
//     final serviceProvider = Provider.of<ServiceAreaProvider>(context, listen: false);
//     final suggestions = <Map<String, dynamic>>[];
    
//     // Search through service areas
//     for (final city in serviceProvider.serviceCities) {
//       // Check if city name matches
//       if (city.city.toLowerCase().contains(query.toLowerCase())) {
//         suggestions.add({
//           'type': 'city',
//           'name': city.city,
//           'area': city.city,
//           'city': city.city,
//           'pincode': city.areas.isNotEmpty ? city.areas.first.pincode : '',
//           'latitude': city.latitude ?? 28.6139, // Default to Delhi if not set
//           'longitude': city.longitude ?? 77.2090,
//         });
//       }
      
//       // Check areas within the city
//       for (final area in city.areas) {
//         if (area.active && area.name.toLowerCase().contains(query.toLowerCase())) {
//           suggestions.add({
//             'type': 'area',
//             'name': '${area.name}, ${city.city}',
//             'area': area.name,
//             'city': city.city,
//             'pincode': area.pincode,
//             'latitude': area.latitude ?? city.latitude ?? 28.6139,
//             'longitude': area.longitude ?? city.longitude ?? 77.2090,
//           });
//         }
//       }
//     }
    
//     setState(() {
//       _areaSuggestions = suggestions.take(10).toList();
//       _showSuggestions = _searchFocusNode.hasFocus && _areaSuggestions.isNotEmpty;
//       _isLoadingSuggestions = false;
//     });
//   }

//   Future<void> _loadServiceAreas() async {
//     final provider = Provider.of<ServiceAreaProvider>(context, listen: false);
//     if (provider.serviceCities.isEmpty) {
//       await provider.fetchServiceAreas();
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     if (!await Geolocator.isLocationServiceEnabled()) return;

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//     if (permission == LocationPermission.deniedForever) return;

//     final Position pos = await Geolocator.getCurrentPosition();
//     final LatLng latLng = LatLng(pos.latitude, pos.longitude);
//     await _updateLocation(latLng);
//   }

//   Future<void> _selectAreaSuggestion(Map<String, dynamic> suggestion) async {
//     // Clear search and hide suggestions
//     searchController.text = suggestion['name'];
//     setState(() {
//       _showSuggestions = false;
//       _isCheckingServiceability = true;
//     });
    
//     // Move to the selected area's coordinates
//     final latLng = LatLng(
//       suggestion['latitude'] as double,
//       suggestion['longitude'] as double,
//     );
    
//     // Update location with the selected area
//     await _updateLocation(latLng, suggestedArea: suggestion);
//   }

//   Future<void> _updateLocation(LatLng latLng, {Map<String, dynamic>? suggestedArea}) async {
//     setState(() {
//       _isCheckingServiceability = true;
//       _serviceabilityMessage = null;
//       _isServiceable = null;
//       extractedCity = null;
//       extractedPincode = null;
//       extractedArea = null;
//     });

//     try {
//       String city = '';
//       String areaName = '';
//       String pincode = '';
//       String formattedAddress = '';
      
//       // If we have a suggested area, use its data
//       if (suggestedArea != null) {
//         city = suggestedArea['city'];
//         areaName = suggestedArea['area'];
//         pincode = suggestedArea['pincode'];
//         formattedAddress = suggestedArea['name'];
        
//         debugPrint('=== Using Suggested Area ===');
//         debugPrint('City: $city');
//         debugPrint('Area: $areaName');
//         debugPrint('Pincode: $pincode');
//         debugPrint('Full Address: $formattedAddress');
//       } else {
//         // Get address from coordinates
//         final placemarks = await geo.placemarkFromCoordinates(
//           latLng.latitude,
//           latLng.longitude,
//         );

//         final placemark = placemarks.isNotEmpty ? placemarks.first : null;
        
//         final String locality = placemark?.locality ?? '';
//         final String subLocality = placemark?.subLocality ?? '';
//         final String administrativeArea = placemark?.administrativeArea ?? '';
//         final String subAdministrativeArea = placemark?.subAdministrativeArea ?? '';
//         final String thoroughfare = placemark?.thoroughfare ?? '';
//         final String name = placemark?.name ?? '';
        
//         city = locality.isNotEmpty ? locality : administrativeArea;
//         if (city.isEmpty && subAdministrativeArea.isNotEmpty) {
//           city = subAdministrativeArea;
//         }
        
//         areaName = subLocality.isNotEmpty ? subLocality : thoroughfare;
//         if (areaName.isEmpty && name.isNotEmpty) {
//           areaName = name;
//         }
        
//         pincode = placemark?.postalCode ?? '';
        
//         formattedAddress = [
//           name,
//           thoroughfare,
//           subLocality,
//           locality,
//           subAdministrativeArea,
//           administrativeArea,
//         ].where((e) => e.isNotEmpty).join(', ');
        
//         debugPrint('=== Address Details ===');
//         debugPrint('City: $city');
//         debugPrint('Area: $areaName');
//         debugPrint('Pincode: $pincode');
//         debugPrint('Full Address: $formattedAddress');
//       }
      
//       final serviceProvider = Provider.of<ServiceAreaProvider>(context, listen: false);
//       final isServiceable = serviceProvider.isLocationServiceableByAddress(
//         address: formattedAddress.toLowerCase(),
//         city: city,
//         areaName: areaName,
//         pincode: pincode,
//       );
      
//       final matchingArea = serviceProvider.getMatchingServiceArea(
//         address: formattedAddress.toLowerCase(),
//         city: city,
//         areaName: areaName,
//         pincode: pincode,
//       );
      
//       if (!mounted) return;

//       setState(() {
//         selectedLatLng = latLng;
//         address = formattedAddress;
//         extractedCity = city;
//         extractedPincode = pincode;
//         extractedArea = areaName;
//         _isServiceable = isServiceable;
        
//         if (isServiceable && matchingArea != null) {
//           _serviceabilityMessage = "✓ Service available in ${matchingArea['city']} - ${matchingArea['area']}";
//         } else if (isServiceable && city.isNotEmpty) {
//           _serviceabilityMessage = "✓ Service available in $city";
//         } else if (isServiceable) {
//           _serviceabilityMessage = "✓ Service available at this location";
//         } else {
//           final serviceableCities = serviceProvider.getServiceableCities().join(', ');
//           _serviceabilityMessage = "✗ Delivery not available. Serviceable: $serviceableCities";
//         }
//         _isCheckingServiceability = false;
        
//         // Clear search if not from suggestion
//         if (suggestedArea == null) {
//           searchController.clear();
//         }
//       });

//       _mapController.move(latLng, 16);
//     } catch (e) {
//       debugPrint('Error in _updateLocation: $e');
//       if (!mounted) return;
//       setState(() {
//         selectedLatLng = latLng;
//         address = "Location selected";
//         _isCheckingServiceability = false;
//         _isServiceable = false;
//         _serviceabilityMessage = "✗ Unable to verify serviceability";
//       });
//       _mapController.move(latLng, 16);
//     }
//   }

//   Future<void> _searchLocation(String query) async {
//     if (query.isEmpty) return;

//     setState(() {
//       _isCheckingServiceability = true;
//       _showSuggestions = false;
//     });

//     try {
//       final List<geo.Location> locations = await geo.locationFromAddress(query);

//       if (locations.isNotEmpty) {
//         final loc = locations.first;
//         await _updateLocation(LatLng(loc.latitude, loc.longitude));
//       } else {
//         setState(() {
//           _isCheckingServiceability = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Location not found")),
//         );
//       }
//     } catch (_) {
//       setState(() {
//         _isCheckingServiceability = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Location not found")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize: const Size(double.infinity, 60),
//         child: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 1,
//           leading: IconButton(
//             icon: const Icon(Icons.chevron_left, color: Colors.black),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: const Text(
//             "Select Your Location",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//               color: Colors.black,
//             ),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             // Search field with suggestions
//             Focus(
//               focusNode: _searchFocusNode,
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: searchController,
//                     onSubmitted: _searchLocation,
//                     decoration: InputDecoration(
//                       hintText: "Search for area, street...",
//                       prefixIcon: const Icon(Icons.search),
//                       suffixIcon: searchController.text.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(Icons.close),
//                               onPressed: () {
//                                 searchController.clear();
//                                 setState(() {
//                                   _areaSuggestions = [];
//                                   _showSuggestions = false;
//                                 });
//                               },
//                             )
//                           : null,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
                  
//                   // Suggestions dropdown
//                   if (_showSuggestions)
//                     Container(
//                       margin: const EdgeInsets.only(top: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.3),
//                             spreadRadius: 1,
//                             blurRadius: 5,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       constraints: const BoxConstraints(maxHeight: 300),
//                       child: _isLoadingSuggestions
//                           ? const Center(
//                               child: Padding(
//                                 padding: EdgeInsets.all(20),
//                                 child: CircularProgressIndicator(),
//                               ),
//                             )
//                           : ListView.builder(
//                               shrinkWrap: true,
//                               itemCount: _areaSuggestions.length,
//                               itemBuilder: (context, index) {
//                                 final suggestion = _areaSuggestions[index];
//                                 return ListTile(
//                                   leading: Icon(
//                                     suggestion['type'] == 'city' 
//                                         ? Icons.location_city 
//                                         : Icons.location_on,
//                                     color: Colors.red,
//                                     size: 20,
//                                   ),
//                                   title: Text(
//                                     suggestion['name'],
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   subtitle: suggestion['type'] == 'area'
//                                       ? Text(
//                                           'Pincode: ${suggestion['pincode']}',
//                                           style: const TextStyle(fontSize: 12),
//                                         )
//                                       : null,
//                                   onTap: () => _selectAreaSuggestion(suggestion),
//                                 );
//                               },
//                             ),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
//             Expanded(
//               child: Stack(
//                 children: [
//                   FmMap(
//                     mapController: _mapController,
//                     mapOptions: MapOptions(
//                       initialCenter: _defaultLatLng,
//                       initialZoom: 15,
//                       onTap: (_, point) => _updateLocation(point),
//                     ),
//                     markers: [
//                       Marker(
//                         point: selectedLatLng ?? _defaultLatLng,
//                         child: const Icon(
//                           Icons.location_on,
//                           size: 40,
//                           color: Colors.red,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Positioned(
//                     bottom: 20,
//                     right: 20,
//                     child: FloatingActionButton(
//                       backgroundColor: Colors.white,
//                       onPressed: _getCurrentLocation,
//                       child: const Icon(Icons.my_location, color: Colors.red),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (_isCheckingServiceability)
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Row(
//                   children: [
//                     SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                     SizedBox(width: 8),
//                     Text("Checking service availability..."),
//                   ],
//                 ),
//               ),
            
//             if (_serviceabilityMessage != null && !_isCheckingServiceability)
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: _isServiceable == true ? Colors.green[50] : Colors.red[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: _isServiceable == true ? Colors.green : Colors.red,
//                     width: 1,
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       _isServiceable == true ? Icons.check_circle : Icons.error,
//                       color: _isServiceable == true ? Colors.green : Colors.red,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         _serviceabilityMessage!,
//                         style: TextStyle(
//                           color: _isServiceable == true ? Colors.green[800] : Colors.red[800],
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
            
//             const SizedBox(height: 8),
            
//             Text(
//               address ?? "Fetching location...",
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 12),
            
//             GestureDetector(
//               onTap: () async {
//                 if (selectedLatLng == null || address == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Please select a location first")),
//                   );
//                   return;
//                 }
                
//                 final serviceProvider = Provider.of<ServiceAreaProvider>(context, listen: false);
//                 final isServiceable = serviceProvider.isLocationServiceableByAddress(
//                   address: address,
//                   city: extractedCity,
//                   areaName: extractedArea,
//                   pincode: extractedPincode,
//                 );
                
//                 if (!isServiceable) {
//                   showDialog(
//                     context: context,
//                     builder: (ctx) => AlertDialog(
//                       title: const Text("Delivery Not Available"),
//                       content: Text(
//                         "Sorry, we don't deliver to ${extractedCity?.isNotEmpty == true ? extractedCity! : 'this location'} yet.\n\n"
//                         "Serviceable cities: ${serviceProvider.getServiceableCities().join(', ')}",
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(ctx),
//                           child: const Text("OK"),
//                         ),
//                       ],
//                     ),
//                   );
//                   return;
//                 }
                
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => AddAddressScreen(
//                       preSelectedLocation: address,
//                       preSelectedLatLng: {
//                         'lat': selectedLatLng!.latitude,
//                         'lng': selectedLatLng!.longitude,
//                       },
//                       onAddressSelected: (addressData) {
//                         addressData['city'] = extractedCity;
//                         addressData['pincode'] = extractedPincode;
//                         addressData['area'] = extractedArea;
//                         if (widget.onAddressSelected != null) {
//                           widget.onAddressSelected!(addressData);
//                         }
//                       },
//                     ),
//                   ),
//                 );

//                 if (result != null && result is Map<String, dynamic>) {
//                   result['city'] = extractedCity;
//                   result['pincode'] = extractedPincode;
//                   result['area'] = extractedArea;
                  
//                   if (widget.onAddressSelected != null) {
//                     widget.onAddressSelected!(result);
//                   } else {
//                     Navigator.pop(context, result);
//                   }
//                 }
//               },
//               child: Container(
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: _isServiceable == true ? Colors.red : Colors.grey,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   _isServiceable == true ? "CONFIRM LOCATION & CONTINUE" : "SERVICE NOT AVAILABLE",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
