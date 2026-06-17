import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/room.dart';
import '../providers/room_provider.dart';

class EditRoomScreen extends StatefulWidget {
  final String houseId;
  final Room? room;
  const EditRoomScreen({super.key, required this.houseId, this.room});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  bool _isSaving = false;
  bool isUploadingImage = false;
  File? imageFile;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room?.name ?? '');
    _notesController = TextEditingController(text: widget.room?.notes ?? '');
    imageUrl = widget.room?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      if (await file.exists()) {
        setState(() {
          imageFile = file;
          imageUrl = null;
        });
      } else {
        print('⚠️ Picked file does not exist');
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName =
          'rooms/${widget.houseId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref(fileName);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      String? finalImageUrl = imageUrl;
      if (imageFile != null) {
        setState(() => isUploadingImage = true);
        finalImageUrl = await _uploadImage(imageFile!);
        setState(() => isUploadingImage = false);
      }
      if (finalImageUrl == null) {
        // Upload failed – show error and abort save (or you could continue without image)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image upload failed. Please try again.'),
          ),
        );
        setState(() => _isSaving = false);
        return;
      }

      final provider = Provider.of<RoomProvider>(context, listen: false);

      if (widget.room == null) {
        await provider.addRoom(
          houseId: widget.houseId,
          name: name,
          notes: notes,
          imageUrl: finalImageUrl,
        );
      } else {
        final updatedRoom = Room(
          id: widget.room!.id,
          houseId: widget.houseId,
          name: name,
          notes: notes,
          imageUrl: finalImageUrl,
        );
        await provider.updateRoom(updatedRoom);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save room')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room == null ? 'Add Room' : 'Edit Room'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Room Name *'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter room name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              // Image
              Row(
                children: [
                  Expanded(
                    child: imageFile != null
                        ? Image.file(imageFile!, height: 100, fit: BoxFit.cover)
                        : imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(
                            imageUrl!,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : const Text('No image'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Take Photo'),
                  ),
                ],
              ),
              if (isUploadingImage) const LinearProgressIndicator(),
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
                label: Text(widget.room == null ? 'Create Room' : 'Update'),
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
