import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/house_provider.dart';
import 'edit_house_screen.dart';
import 'room_list_screen.dart';

class HouseListScreen extends StatelessWidget {
  const HouseListScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    String houseId,
    String houseName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete House'),
        content: Text('Are you sure you want to delete "$houseName"?'),
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
        await Provider.of<HouseProvider>(
          context,
          listen: false,
        ).deleteHouse(houseId);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('House deleted successfully')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete house')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HouseProvider>(
      builder: (context, provider, child) {
        if (provider.houses.isEmpty && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => provider.fetchHouses(),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Customers House List')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditHouseScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add House'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // House list
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: provider.houses.length,
                        itemBuilder: (context, index) {
                          final house = provider.houses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.house),
                              title: Text(
                                house.nickname.isNotEmpty
                                    ? '${house.customerName} (“${house.nickname}”)'
                                    : house.customerName,
                              ),
                              subtitle: Text(house.address),
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
                                          builder: (context) =>
                                              EditHouseScreen(house: house),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _confirmDelete(
                                      context,
                                      house.id,
                                      house.customerName,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RoomListScreen(house: house),
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
      },
    );
  }
}
