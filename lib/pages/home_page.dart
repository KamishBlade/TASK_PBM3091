import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List products = [];
  bool loading = true;

  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final descC = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await ApiService.getProducts(widget.token);
    setState(() {
      products = data;
      loading = false;
    });
  }

  void addProduct() async {
    final price = int.tryParse(priceC.text);
    if (price == null) return;

    final success = await ApiService.createProduct(
      widget.token,
      nameC.text,
      price,
      descC.text,
    );

    if (success) {
      nameC.clear();
      priceC.clear();
      descC.clear();
      loadData();
    }
  }

  void deleteProduct(int id) async {
    final success = await ApiService.deleteProduct(widget.token, id);

    if (success) {
      loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk dihapus")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Katalog Produk")),
      body: Column(
        children: [
          // FORM
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: nameC,
                  decoration: const InputDecoration(labelText: "Nama Produk"),
                ),
                TextField(
                  controller: priceC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Harga"),
                ),
                TextField(
                  controller: descC,
                  decoration: const InputDecoration(labelText: "Deskripsi"),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: addProduct,
                    child: const Text("Simpan Draft"),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // GRID
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, i) {
                      final item = products[i];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(item["name"] ?? "-",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text("Rp ${item["price"] ?? 0}"),
                              Expanded(
                                child: Text(item["description"] ?? "-"),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteProduct(item["id"]),
                              )
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