import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/house.dart';
import '../providers/house_provider.dart';

class EditHouseScreen extends StatefulWidget {
  final House? house; // if null-- add mode, otherwise edit
  const EditHouseScreen({super.key, this.house});

  @override
  State<EditHouseScreen> createState() => _EditHouseScreenState();
}

class _EditHouseScreenState extends State<EditHouseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerNameController;
  late TextEditingController _nicknameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _detailsController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final house = widget.house;
    _customerNameController = TextEditingController(
      text: house?.customerName ?? '',
    );
    _nicknameController = TextEditingController(text: house?.nickname ?? '');
    _addressController = TextEditingController(text: house?.address ?? '');
    _phoneController = TextEditingController(text: house?.phoneNumber ?? '');
    _detailsController = TextEditingController(text: house?.details ?? '');
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _nicknameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final provider = Provider.of<HouseProvider>(context, listen: false);
      if (widget.house == null) {
        // Add new house
        await provider.addHouse(
          customerName: _customerNameController.text.trim(),
          nickname: _nicknameController.text.trim(),
          address: _addressController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          details: _detailsController.text.trim(),
        );
      } else {
        // TODO: implement updateHouse
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Edit')));
        return;
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to save house. Check Firestore rules and connection.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.house == null ? 'Add House' : 'Edit House'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Customer name (required)
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter customer name'
                    : null,
              ),
              const SizedBox(height: 12),
              // Nickname (optional)
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // Address (required)
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter address'
                    : null,
              ),
              const SizedBox(height: 12),
              // Phone number (required)
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter phone number'
                    : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'Details (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(widget.house == null ? 'Create House' : 'Update'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
