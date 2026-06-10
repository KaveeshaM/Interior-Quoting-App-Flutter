import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/house.dart';
import '../models/room.dart';
import '../models/room_item.dart';
import '../providers/room_provider.dart';
import '../providers/room_item_provider.dart';

class QuoteScreen extends StatefulWidget {
  final House house;
  const QuoteScreen({super.key, required this.house});

  @override
  State<QuoteScreen> createState() => QuoteScreenState();
}

class QuoteScreenState extends State<QuoteScreen> {
  List<Room> rooms = [];
  Map<String, List<RoomItem>> itemsByRoom = {};
  bool isLoading = true;
  String? error;

  // Selection state
  Map<String, bool> selectedItemIds = {}; // itemId -- selected
  Map<String, bool> selectedRoomIds = {}; // roomId - selected

  static const double windowCostPerM2 = 50.0;
  static const double floorCostPerM2 = 100.0;
  static const double labourCostPerRoom = 200.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadQuoteData();
    });
  }

  Future<void> loadQuoteData() async {
    try {
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
        double area = calculateArea(item.widthMm, item.heightMm);
        total += area * windowCostPerM2;
      }
    }
    return total;
  }

  double calculateFloorsCostForRoom(List<RoomItem> items) {
    double total = 0;
    for (var item in items) {
      if (item.type == 'floor' && (selectedItemIds[item.id] ?? false)) {
        double area = calculateArea(item.widthMm, item.heightMm);
        total += area * floorCostPerM2;
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
      appBar: AppBar(title: Text('Quote for ${widget.house.customerName}')),
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
                              return CheckboxListTile(
                                value: selectedItemIds[item.id] ?? false,
                                onChanged: (_) => toggleItemSelection(item.id),
                                title: Text(
                                  isWindow
                                      ? (item.name ?? 'Window')
                                      : 'Floor Space',
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
