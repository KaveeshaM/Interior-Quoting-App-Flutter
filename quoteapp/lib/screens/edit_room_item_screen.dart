import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room_item.dart';
import '../providers/room_item_provider.dart';
import '../models/product.dart';
import '../screens/select_product_screen.dart';
import '../providers/product_provider.dart';

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
  String? _selectedProductId;
  String? _selectedColour;
  Product? _selectedProduct;

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
    _selectedProductId = widget.existingItem?.productId;
    _selectedColour = widget.existingItem?.selectedColour;

    if (_selectedProductId != null && _selectedProductId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSelectedProduct();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedProduct() async {
    if (_selectedProductId != null && _selectedProductId!.isNotEmpty) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final product = await provider.fetchProductById(_selectedProductId!);
      if (mounted && product != null) {
        setState(() {
          _selectedProduct = product;
        });
      }
    }
  }

  void _selectProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectProductScreen(
          currentProductId: _selectedProductId ?? '',
          currentColour: _selectedColour,
          category: _type,
          onProductSelected: (product, colour) {
            if (_type == 'window') {
              final int width = int.tryParse(_widthController.text.trim()) ?? 0;
              final error = validateWindowProduct(width, product);
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error), backgroundColor: Colors.red),
                );
                return;
              }
            }
            setState(() {
              _selectedProductId = product.id;
              _selectedColour = colour;
              _selectedProduct = product;
            });
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final width = int.parse(_widthController.text.trim());
      final height = int.parse(_heightController.text.trim());
      final provider = Provider.of<RoomItemProvider>(context, listen: false);

      if (_type == 'window' && _selectedProduct != null) {
        final error = validateWindowProduct(width, _selectedProduct!);
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
          setState(() => _isSaving = false);
          return;
        }
      }

      if (widget.existingItem == null) {
        // Add
        await provider.addItem(
          roomId: widget.roomId,
          type: _type,
          name: _type == 'window' ? _nameController.text.trim() : null,
          widthMm: width,
          heightMm: height,
          productId: _selectedProductId,
        );
      } else {
        // Edit
        final updated = RoomItem(
          id: widget.existingItem!.id,
          roomId: widget.roomId,
          type: _type,
          name: _type == 'window' ? _nameController.text.trim() : null,
          widthMm: width,
          heightMm: height,
          productId: _selectedProductId,
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

  String? validateWindowProduct(int windowWidthMm, Product product) {
    if (product.minWidth == null && product.maxWidth == null) return null;

    // maxPanels == null or 1
    final int maxPanels = product.maxPanels ?? 1;

    // fit within range
    if (windowWidthMm >= (product.minWidth ?? 0) &&
        windowWidthMm <= (product.maxWidth ?? double.infinity)) {
      return null;
    }
    // oversize panel – not allowed
    if (maxPanels == 1) {
      return 'Width exceeds maximum width for this product.';
    }

    // Multi-panel
    for (int n = 1; n <= maxPanels; n++) {
      double panelWidth = windowWidthMm / n;
      if (panelWidth >= (product.minWidth ?? 0) &&
          panelWidth <= (product.maxWidth ?? double.infinity)) {
        return null;
      }
    }

    if (product.minWidth != null &&
        product.maxWidth != null &&
        product.minWidth == product.maxWidth) {
      return 'This product requires panels of exactly ${product.minWidth}mm. ';
    }

    return 'Width does not fit within product.';
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedProductId != null
                          ? 'Product selected'
                          : 'No product selected',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectProduct,
                    child: const Text('Select Product'),
                  ),
                ],
              ),
              if (_selectedProduct != null) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedProduct!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Price: ${_selectedProduct!.pricePerSqm.toStringAsFixed(2)} AUD/m²',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
