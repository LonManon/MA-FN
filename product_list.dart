import 'dart:convert';
import 'package:test1/for_FN-sb/cart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;
import 'detail.dart';
import 'sendDataToAPIServer.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  dynamic cartCount = 10;
  Future<List>? _myFuture;

  @override
  void initState() {
    super.initState();
    // Load data once
    _myFuture = _getProduct();
  }

  Future<List> _getProduct() async {
    var url = Uri.parse("http://127.0.0.1:5000/products");
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data;
        } else {
          return []; // Return an empty list if no data is present
        }
      } else {
        throw Exception("Failed to load products. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to load products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product List"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            // child: IconButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => CreateProductScreen(),
            //       ),
            //     );
            //   },
            //   icon: Icon(Icons.add_box),
            // ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 16.0, right: 20, left: 20),
          //   child: InkWell(
          //     child: badges.Badge(
          //       badgeContent: Text(
          //         "${cartCount!}",
          //         style: TextStyle(fontSize: 10, color: Colors.yellow),
          //       ),
          //       badgeAnimation: const badges.BadgeAnimation.scale(
          //         loopAnimation: false,
          //         curve: Curves.fastOutSlowIn,
          //         colorChangeAnimationCurve: Curves.easeInCubic,
          //       ),
          //       badgeStyle: badges.BadgeStyle(
          //         shape: badges.BadgeShape.square,
          //         badgeColor: Colors.purple,
          //         padding: EdgeInsets.all(3),
          //         borderRadius: BorderRadius.circular(10),
          //         borderSide: BorderSide(color: Colors.white, width: 1),
          //         elevation: 0,
          //       ),
          //       // child: Icon(Icons.shopping_cart),
          //     ),
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => CartScreen(user_id: 1),
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
      body: FutureBuilder<List>(
        future: _myFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(
              child: Text("No products available"),
            );
          }
          if (snapshot.hasData) {
            var product = snapshot.data!;
            return GridView.builder(
              itemCount: product.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                      data: product[index]['id']),
                                ),
                              );
                            },
                            child: Image.network(
                              product[index]['image'],
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product[index]['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "${product[index]['price'].toString()} \$",
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () {
                                  print("Favorite");
                                },
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.deepOrangeAccent,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    cartCount++;
                                  });
                                },
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Text("No widget to build");
        },
      ),
    );
  }
}
