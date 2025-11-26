import 'package:flutter/material.dart';
import 'package:note_clone/core/cat_api.dart';
import 'package:note_clone/BLoC_app/pages/home_page.dart';
import 'package:note_clone/BLoC_app/pages/to_do_list_page.dart';

class CatApiPage extends StatefulWidget {
  const CatApiPage({super.key});

  @override
  State<CatApiPage> createState() => _CatApiPageState();
}

class _CatApiPageState extends State<CatApiPage> {
  late Future<List<CatBreed>> futureBreeds;

  @override
  void initState() {
    super.initState();
    futureBreeds = CatApi.fetchCatBreeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ảnh mèo")),
      body: FutureBuilder<List<CatBreed>>(
        future: futureBreeds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}"));
          }

          if (snapshot.hasData) {
            final breeds = snapshot.data!;

            return ListView.builder(
              itemCount: breeds.length,
              itemBuilder: (context, index) {
                final breed = breeds[index];

                return FutureBuilder<List<String>>(
                  future: CatApi.fetchCatImages(limit: 1),
                  builder: (context, imgSnapshot) {
                    Widget child;
                    if (imgSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      child = const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (imgSnapshot.hasError ||
                        imgSnapshot.data!.isEmpty) {
                      child = Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.pets,
                          size: 80,
                          color: Colors.grey,
                        ),
                      );
                    } else {
                      child = Image.network(
                        imgSnapshot.data!.first,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(breed.name),
                            content: Text(
                              "Nguồn gốc: ${breed.origin ?? "Không có"}\nTính cách: ${breed.temperament ?? "Không có"}",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Đóng"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: child,
                      ),
                    );
                  },
                );
              },
            );
          }

          return const Center(child: Text("Không có dữ liệu."));
        },
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.checklist, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ToDoListPage()),
                );
              },
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
