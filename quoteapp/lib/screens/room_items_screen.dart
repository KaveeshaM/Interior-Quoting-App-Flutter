import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room.dart';
import '../models/room_item.dart';
import '../providers/room_item_provider.dart';
import 'edit_room_item_screen.dart';

class RoomItemsScreen extends StatefulWidget {
  final Room room;
  const RoomItemsScreen({super.key, required this.room});

  @override
  State<RoomItemsScreen> createState() => _RoomItemsScreenState();
}

class _RoomItemsScreenState extends State<RoomItemsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoomItemProvider>(
        context,
        listen: false,
      ).fetchItems(widget.room.id);
    });
  }

  Future<void> _deleteItem(RoomItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Delete this ${item.type}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await Provider.of<RoomItemProvider>(
          context,
          listen: false,
        ).deleteItem(item.id, widget.room.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deleted')));
      } catch (e) {
        // todo
      }
    }
  }

  void _editItem(RoomItem item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditRoomItemScreen(roomId: widget.room.id, existingItem: item),
      ),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Updated')));
    }
  }

  void _addItem(String type) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditRoomItemScreen(roomId: widget.room.id, itemType: type),
      ),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            type == 'window' ? 'Window added' : 'Floor space added',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoomItemProvider>(context);
    final items = provider.items;
    final windowCount = items.where((f) => f.type == 'window').length;
    final floorCount = items.where((f) => f.type == 'floor').length;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.room.name} - Items')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addItem('window'),
                  icon: const Icon(Icons.window),
                  label: const Text('Add Window'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: () => _addItem('floor'),
                  icon: const Icon(Icons.square_foot),
                  label: const Text('Add Floor space'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                ? const Center(
                    child: Text(
                      'No windows or floor spaces.\nUse buttons above to add.',
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final f = items[index];
                      final isWindow = f.type == 'window';
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Icon(
                            isWindow ? Icons.window : Icons.square_foot,
                          ),
                          title: Text(
                            isWindow ? (f.name ?? 'Window') : 'Floor Space',
                          ),
                          subtitle: Text('${f.widthMm}mm x ${f.heightMm}mm'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _editItem(f),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteItem(f),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
