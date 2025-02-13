import 'package:flutter/material.dart';
import 'package:sql_helper_dasar/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter SQLite Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _items = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _items = data.map((item) {
        item['imageUrl'] ??= ''; // Pastikan imageUrl tidak null
        return item;
      }).toList();
      _isLoading = false;
    });
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingItem = _items.firstWhere((element) => element['id'] == id);
      _titleController.text = existingItem['title'];
      _descriptionController.text = existingItem['description'];
      _noteController.text = existingItem['note'];
      _imageUrlController.text = existingItem['imageUrl'];
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _noteController.clear();
      _imageUrlController.clear();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Note',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            TextField(
              controller: _imageUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Image URL',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await SQLHelper.createItem(
                      _titleController.text,
                      _descriptionController.text,
                      _noteController.text,
                      _imageUrlController.text);
                } else {
                  await SQLHelper.updateItem(
                      id,
                      _titleController.text,
                      _descriptionController.text,
                      _noteController.text,
                      _imageUrlController.text);
                }
                Navigator.of(context).pop();
                _refreshItems();
              },
              child: Text(id == null ? 'Add Item' : 'Update Item'),
            )
          ],
        ),
      ),
    );
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQLite CRUD Example')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) => Card(
                color: Colors.purple[900],
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: _items[index]['imageUrl'] != null &&
                          _items[index]['imageUrl'].isNotEmpty
                      ? Image.network(
                          _items[index]['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image,
                                  color: Colors.white),
                        )
                      : const Icon(Icons.image, color: Colors.white),
                  title: Text(
                    _items[index]['title'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_items[index]['description'],
                          style: const TextStyle(color: Colors.white70)),
                      Text('Note: ${_items[index]['note']}',
                          style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.white70)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => _showForm(_items[index]['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () => _deleteItem(_items[index]['id']),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(height: 50.0),
      ),
    );
  }
}
