import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/house.dart';
import '../providers/room_provider.dart';
import 'edit_room_screen.dart';
import 'room_items_screen.dart';
import 'quote_screen.dart';

class RoomListScreen extends StatefulWidget {
  final House house;
  const RoomListScreen({super.key, required this.house});

  @override
  State<RoomListScreen> createState() => RoomListScreenState();
}

class RoomListScreenState extends State<RoomListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoomProvider>(
        context,
        listen: false,
      ).fetchRooms(widget.house.id);
    });
  }

  Future<void> confirmDelete(String roomId, String roomName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text('Delete "$roomName"?'),
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
        await Provider.of<RoomProvider>(
          context,
          listen: false,
        ).deleteRoom(roomId, widget.house.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Room deleted')));
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete room')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Rooms in ${widget.house.customerName}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditRoomScreen(houseId: widget.house.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.library_add),
                  label: const Text('Add Room'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuoteScreen(house: widget.house),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt),
                  label: const Text('Get Quote'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: roomProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : roomProvider.rooms.isEmpty
                ? const Center(child: Text('No rooms yet.\nTap + to add one.'))
                : ListView.builder(
                    itemCount: roomProvider.rooms.length,
                    itemBuilder: (context, index) {
                      final room = roomProvider.rooms[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.meeting_room),
                          title: Text(room.name),
                          subtitle: Text(
                            'Notes: ${room.notes != null ? '\n${room.notes}' : ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditRoomScreen(
                                        houseId: widget.house.id,
                                        room: room,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    confirmDelete(room.id, room.name),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RoomItemsScreen(room: room),
                              ),
                            );
                          },
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
