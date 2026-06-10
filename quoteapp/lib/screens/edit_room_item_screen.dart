import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room_item.dart';
import '../providers/room_item_provider.dart';

class EditRoomItemScreen extends StatefulWidget {
  final String roomId;
  final RoomItem? existingItem; // if null - add mode
  final String? itemType;

  const EditRoomItemScreen({
    super.key,
    required this.roomId,
    this.existingItem,
    this.itemType,
  });

  @override
  State<EditRoomItemScreen> createState() => _EditRoomItemScreenState();
}

class _EditRoomItemScreenState extends State<EditRoomItemScreen> {
  late String _type;
  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingItem;
    _type = existing?.type ?? widget.itemType ?? 'window';
    _nameController = TextEditingController(text: existing?.name ?? '');
    _widthController = TextEditingController(
      text: existing?.widthMm.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: existing?.heightMm.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final width = int.parse(_widthController.text.trim());
      final height = int.parse(_heightController.text.trim());
      final provider = Provider.of<RoomItemProvider>(context, listen: false);

      if (widget.existingItem == null) {
        // Add mode
        await provider.addItem(
          roomId: widget.roomId,
          type: _type,
          name: _type == 'window' ? _nameController.text.trim() : null,
          widthMm: width,
          heightMm: height,
        );
      } else {
        // Edit mode
        final updated = RoomItem(
          id: widget.existingItem!.id,
          roomId: widget.roomId,
          type: _type,
          name: _type == 'window' ? _nameController.text.trim() : null,
          widthMm: width,
          heightMm: height,
        );
        await provider.updateItem(updated);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWindow = _type == 'window';
    final isEditing = widget.existingItem != null;
    String title;
    if (isEditing) {
      title = isWindow ? 'Edit Window' : 'Edit Floor Space';
    } else {
      title = isWindow ? 'Add Window' : 'Add Floor Space';
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (isWindow)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Window Name (e.g., North window)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Please enter a name' : null,
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _widthController,
                decoration: const InputDecoration(
                  labelText: 'Width (mm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter width' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Height (mm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter height' : null,
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
                label: Text(isEditing ? 'Update' : 'Create'),
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
