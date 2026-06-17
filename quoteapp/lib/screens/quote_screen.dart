import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/house.dart';
import '../models/room.dart';
import '../models/room_item.dart';
import '../models/product.dart';
import '../providers/room_provider.dart';
import '../providers/room_item_provider.dart';
import '../providers/product_provider.dart';

class QuoteScreen extends StatefulWidget {
  final House house;
  const QuoteScreen({super.key, required this.house});

  @override
  State<QuoteScreen> createState() => QuoteScreenState();
}

class QuoteScreenState extends State<QuoteScreen> {
  List<Room> rooms = [];
  Map<String, List<RoomItem>> itemsByRoom = {};
  Map<String, Product> productMap = {};
  bool isLoading = true;
  String? error;

  // Selection state
  Map<String, bool> selectedItemIds = {};
  Map<String, bool> selectedRoomIds = {};

  static const double labourCostPerRoom = 200.0;
  final GlobalKey _shareButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadQuoteData();
    });
  }

  Future<void> loadQuoteData() async {
    try {
      // Fetch products first (or use cached data)
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      if (productProvider.products.isEmpty) {
        await productProvider.fetchProducts();
      }
      productMap = {for (var p in productProvider.products) p.id: p};

      // Fetch rooms and items
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      await roomProvider.fetchRooms(widget.house.id);
      final fetchedRooms = List<Room>.from(roomProvider.rooms);
      rooms = fetchedRooms;

      final itemProvider = Provider.of<RoomItemProvider>(
        context,
        listen: false,
      );
      final Map<String, List<RoomItem>> itemsMap = {};
      for (var room in fetchedRooms) {
        await itemProvider.fetchItems(room.id);
        itemsMap[room.id] = List<RoomItem>.from(itemProvider.items);
      }
      itemsByRoom = itemsMap;

      // All items selected
      for (var items in itemsMap.values) {
        for (var item in items) {
          selectedItemIds[item.id] = true;
        }
      }
      // All rooms selected
      for (var room in fetchedRooms) {
        selectedRoomIds[room.id] = true;
      }
    } catch (e) {
      error = 'Failed to load quote data: $e';
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  double calculateArea(int widthMm, int heightMm) {
    return (widthMm * heightMm) / 1_000_000;
  }

  double calculateWindowsCostForRoom(List<RoomItem> items) {
    double total = 0;
    for (var item in items) {
      if (item.type == 'window' && (selectedItemIds[item.id] ?? false)) {
        final product = productMap[item.productId];
        if (product != null) {
          double area = calculateArea(item.widthMm, item.heightMm);
          total += area * product.pricePerSqm;
        }
      }
    }
    return total;
  }

  double calculateFloorsCostForRoom(List<RoomItem> items) {
    double total = 0;
    for (var item in items) {
      if (item.type == 'floor' && (selectedItemIds[item.id] ?? false)) {
        final product = productMap[item.productId];
        if (product != null) {
          double area = calculateArea(item.widthMm, item.heightMm);
          total += area * product.pricePerSqm;
        }
      }
    }
    return total;
  }

  double calculateRoomTotal(List<RoomItem> items) {
    return calculateWindowsCostForRoom(items) +
        calculateFloorsCostForRoom(items);
  }

  void toggleItemSelection(String itemId) {
    setState(() {
      selectedItemIds[itemId] = !(selectedItemIds[itemId] ?? false);
    });
  }

  void toggleRoomSelection(String roomId) {
    setState(() {
      selectedRoomIds[roomId] = !(selectedRoomIds[roomId] ?? false);
    });
  }

  String _buildQuoteText() {
    final buffer = StringBuffer();
    buffer.writeln('QUOTE FOR ${widget.house.customerName.toUpperCase()}');
    buffer.writeln('=' * 40);
    buffer.writeln();

    int totalSelectedItems = 0;

    for (final room in rooms) {
      final allItems = itemsByRoom[room.id] ?? [];
      // selected items
      final selectedItems = allItems
          .where((item) => selectedItemIds[item.id] ?? false)
          .toList();
      if (selectedItems.isEmpty) continue;

      totalSelectedItems += selectedItems.length;

      final windowsCost = calculateWindowsCostForRoom(allItems);
      final floorsCost = calculateFloorsCostForRoom(allItems);
      final roomTotal = windowsCost + floorsCost;

      buffer.writeln('${room.name}');
      buffer.writeln('-' * 30);

      // List selected items
      for (final item in selectedItems) {
        final isWindow = item.type == 'window';
        final itemName = isWindow ? (item.name ?? 'Window') : 'Floor Space';
        final product = item.productId != null
            ? productMap[item.productId]
            : null;
        final productName = product != null
            ? ' (${product.name})'
            : ' (no product)';
        buffer.writeln('  --> $itemName$productName');
        if (product != null) {
          buffer.writeln(
            '    Price/psm: ${product.pricePerSqm.toStringAsFixed(2)} AUD',
          );
          final area = calculateArea(item.widthMm, item.heightMm);
          final cost = area * product.pricePerSqm;
          buffer.writeln('    Cost: ${cost.toStringAsFixed(2)} AUD');
        }
        if (item.selectedColour != null && item.selectedColour!.isNotEmpty) {
          buffer.writeln('    Colour: ${item.selectedColour}');
        }
      }

      buffer.writeln();
      buffer.writeln('  Windows cost:   ${windowsCost.toStringAsFixed(2)} AUD');
      buffer.writeln(
        '  Floor spaces cost: ${floorsCost.toStringAsFixed(2)} AUD',
      );
      buffer.writeln('  Room total:     ${roomTotal.toStringAsFixed(2)} AUD');
      buffer.writeln();
    }

    // If no items selected
    if (totalSelectedItems == 0) {
      buffer.writeln('No items selected for this quote.');
      buffer.writeln('Please select at least one window or floor space.');
      return buffer.toString();
    }

    // Calculate totals
    final selectedRoomsCount = rooms
        .where((room) => selectedRoomIds[room.id] ?? false)
        .length;
    final labourTotal = selectedRoomsCount * labourCostPerRoom;
    final roomsSubtotal = rooms.fold<double>(0, (sum, room) {
      final items = itemsByRoom[room.id] ?? [];
      return sum + calculateRoomTotal(items);
    });
    final houseTotal = roomsSubtotal + labourTotal;

    buffer.writeln('=' * 40);
    buffer.writeln('SUMMARY');
    buffer.writeln('-' * 30);
    buffer.writeln('Subtotal (rooms): ${roomsSubtotal.toStringAsFixed(2)} AUD');
    buffer.writeln(
      'Labour (${selectedRoomsCount} room${selectedRoomsCount != 1 ? 's' : ''}): ${labourTotal.toStringAsFixed(2)} AUD',
    );
    buffer.writeln('-' * 30);
    buffer.writeln('HOUSE TOTAL: ${houseTotal.toStringAsFixed(2)} AUD');
    buffer.writeln('=' * 40);
    buffer.writeln();

    return buffer.toString();
  }

  Future<void> _shareQuote() async {
    final quoteText = _buildQuoteText();

    final RenderBox? box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    Rect rect = Rect.zero;
    if (box != null) {
      final position = box.localToGlobal(Offset.zero);
      final size = box.size;
      rect = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
    }

    try {
      await Share.share(
        quoteText,
        subject: 'Quote for ${widget.house.customerName}',
        sharePositionOrigin: rect,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quote shared successfully')),
        );
      }
    } catch (e) {
      print('Share error: $e');
      try {
        await Clipboard.setData(ClipboardData(text: quoteText));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quote copied to clipboard (share failed)'),
            ),
          );
        }
      } catch (clipError) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Labour total
    final selectedRoomsCount = rooms
        .where((room) => selectedRoomIds[room.id] ?? false)
        .length;
    final labourTotal = selectedRoomsCount * labourCostPerRoom;

    // Subtotal in all rooms
    final roomsSubtotal = rooms.fold<double>(0, (sum, room) {
      final items = itemsByRoom[room.id] ?? [];
      return sum + calculateRoomTotal(items);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Quote for ${widget.house.customerName}'),
        actions: [
          IconButton(
            key: _shareButtonKey,
            icon: const Icon(Icons.share),
            onPressed: _shareQuote,
            tooltip: 'Share Quote',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : rooms.isEmpty
          ? const Center(child: Text('No rooms found. Add rooms first.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...rooms.map((room) {
                    final items = itemsByRoom[room.id] ?? [];
                    final roomSelected = selectedRoomIds[room.id] ?? false;
                    final windowsCost = calculateWindowsCostForRoom(items);
                    final floorsCost = calculateFloorsCostForRoom(items);
                    final roomTotal = windowsCost + floorsCost;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: roomSelected,
                                  onChanged: (_) =>
                                      toggleRoomSelection(room.id),
                                ),
                                Expanded(
                                  child: Text(
                                    room.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...items.map((item) {
                              final isWindow = item.type == 'window';
                              final product = item.productId != null
                                  ? productMap[item.productId]
                                  : null;
                              final productInfo = product != null
                                  ? '\n${product.name}\n${product.pricePerSqm.toStringAsFixed(2)} AUD/psm'
                                  : ' (no product)';
                              return CheckboxListTile(
                                value: selectedItemIds[item.id] ?? false,
                                onChanged: (_) => toggleItemSelection(item.id),
                                title: Text(
                                  isWindow
                                      ? (item.name ?? 'Window')
                                      : 'Floor Space',
                                ),
                                subtitle: Text(
                                  '${item.widthMm}mm x ${item.heightMm}mm$productInfo',
                                ),
                              );
                            }),
                            const Divider(),
                            buildDetailRow('Windows', windowsCost),
                            buildDetailRow('Floor spaces', floorsCost),
                            const Divider(),
                            buildDetailRow(
                              'Room Total',
                              roomTotal,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  // House total
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          buildDetailRow('Subtotal (rooms)', roomsSubtotal),
                          buildDetailRow(
                            'Labour (${selectedRoomsCount} room${selectedRoomsCount != 1 ? 's' : ''} × 200 AUD)',
                            labourTotal,
                          ),
                          const Divider(),
                          buildDetailRow(
                            'HOUSE TOTAL',
                            roomsSubtotal + labourTotal,
                            isBold: true,
                            fontSize: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildDetailRow(
    String label,
    double value, {
    bool isBold = false,
    double fontSize = 16,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} AUD',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
