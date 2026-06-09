import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/house_provider.dart';
import 'edit_house_screen.dart';

class HouseListScreen extends StatelessWidget {
  const HouseListScreen({super.key});

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
          body: provider.isLoading
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
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditHouseScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
