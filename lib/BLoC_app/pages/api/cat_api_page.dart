import 'package:flutter/material.dart';
import 'cat_api_service.dart';
import 'package:note_clone/BLoC_app/pages/to_do_list_page.dart';
import 'package:note_clone/BLoC_app/pages/home_page.dart';

class CatPage extends StatefulWidget {
  const CatPage({super.key});

  @override
  State<CatPage> createState() => CatPageState();
}

class CatPageState extends State<CatPage> {
  late Future<List<Cat>> futureCats;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController originController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureCats = CatService.fetchCats();
  }

  void refreshData() {
    setState(() {
      futureCats = CatService.fetchCats();
    });
  }

  Future<void> pickAndUpload() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => isLoading = true);

    final uploaded = await _service.uploadImage(File(file.path));

    if (uploaded == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đây không phải ảnh mèo, vui lòng chọn ảnh khác"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  }

  Future<void> deleteCatItem(String id) async {
    await CatService.deleteCat(id);
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cat API")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: originController,
                  decoration: const InputDecoration(labelText: "Origin"),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: isLoading ? null : createCat,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Add Cat"),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<Cat>>(
              future: futureCats,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final cats = snapshot.data ?? [];

                if (cats.isEmpty) {
                  return const Center(child: Text("No cats found"));
                }

                return ListView.builder(
                  itemCount: cats.length,
                  itemBuilder: (context, index) {
                    final cat = cats[index];
                    return ListTile(
                      title: Text(cat.name),
                      subtitle: Text("Origin: ${cat.origin}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteCatItem(cat.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, size: 28),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              ),
            ),

            IconButton(
              icon: const Icon(Icons.checklist, size: 28),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ToDoListPage()),
              ),
            ),

            IconButton(
              icon: const Icon(Icons.pets, size: 28),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
