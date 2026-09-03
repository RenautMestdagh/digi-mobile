import 'package:digi_mobile/src/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/scraping_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Product>?> scrapedData = Future.value(null);
  bool _isLoading = true; // Track loading state
  String? _errorMessage; // Track error messages

  @override
  void initState() {
    super.initState();
    _fetchData(); // Call _fetchData when the widget loads
  }

  // Fetch data when the screen loads or refreshed
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true; // Set loading state to true
      _errorMessage = null; // Clear any previous error messages
    });

    try {
      // Fetch CSRF token and session
      await AuthService.fetchCsrfToken();
      await AuthService.getSession();

      // Check if the widget is still mounted
      if (!mounted) return;

      // Fetch scraped data
      final products = await ScrapingService.scrapeProducts();
      List<Product> productData = [];
      
      if (products != null) {
        final results = await Future.wait(
            products.map((product) => ScrapingService.scrapeProduct(product))
        );
        for (var result in results) {
          if (result != null) {
            productData.add(result);
          }
        }
      }

      // Check if the widget is still mounted
      if (!mounted) return;

      // Update the state with the fetched data
      setState(() {
        scrapedData = Future.value(productData);
        _isLoading = false;
      });

      // If data is null, sign out the user
      if (products == null) {
        signOut();
      }
    } catch (e) {
      // Handle errors during data fetching
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data. Please try again.'; // Set error message
      });

      // Log the error for debugging
      print('Error fetching data: $e');
    }
  }

  void signOut() async {
    await AuthService.signout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(233, 237, 239, 1.0),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            right: 30,
            child: IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.red),
              onPressed: () {
                signOut();
              },
            ),
          ),
          Positioned(
            top: 60,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Rounded corners for logo
              child: Image.asset(
                'assets/logo.png',
                height: 100, // Bigger logo
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 175),
            child: RefreshIndicator(
              onRefresh: _fetchData, // Pull-to-refresh functionality
              child: FutureBuilder<List<Product>?>(
                future: scrapedData,
                builder: (context, snapshot) {
                  if (_isLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (_errorMessage != null) {
                    return Center(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'An unexpected error occurred.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                    List<Product> products = snapshot.data!;
                    return Column(
                      children: [
                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withAlpha(0), // Top fade
                                  Colors.white,
                                  Colors.white,
                                  Colors.white.withAlpha(0), // Bottom fade
                                ],
                                stops: [0.0, 0.025, 0.975, 1.0],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.dstIn,
                            child: ListView(
                              children: products.map((product) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                                  child: ProductCard(product: product),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(
                      child: Text(
                        'No data available.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
