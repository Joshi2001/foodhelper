// Create a new file: UI/Widgets/Organisms/location_picker.dart
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Services/Providers/home_provider.dart';

class LocationPicker extends StatelessWidget {
  const LocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Provider.of<Home>(context);
    
    return GestureDetector(
      onTap: () {
        _showLocationOptions(context, home);
      },
      child: Row(
        children: [
          if (home.isLoadingLocation)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (home.locationError.isNotEmpty)
            const Icon(Icons.location_off, color: Colors.red, size: 18)
          else
            const Icon(Icons.location_on, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              home.currentAddress,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1A3D7C),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF1A3D7C),
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showLocationOptions(BuildContext context, Home home) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.my_location, color: Colors.blue),
                title: const Text('Use Current Location'),
                onTap: () async {
                  Navigator.pop(context);
                  await home.fetchCurrentLocation();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_location, color: Colors.green),
                title: const Text('Enter Address Manually'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddressInputDialog(context, home);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAddressInputDialog(BuildContext context, Home home) {
    final TextEditingController addressController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Your Address'),
          content: TextField(
            controller: addressController,
            decoration: const InputDecoration(
              hintText: 'e.g., SCO-12, A-Block, VIP Rd, Zirakpur',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (addressController.text.isNotEmpty) {
                  home.updateAddress(addressController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}