import 'package:digi_mobile/src/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/scraping_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, dynamic>?> scrapedData = Future.value(null);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch data when the screen loads or refreshed
  Future<void> _fetchData() async {
    scrapedData = ScrapingService.scrapeOverview();
    setState(() {});
    AuthService.getSession();
  }

  // Convert KB to MB or GB
  String formatData(int? dataKB) {
    if (dataKB == null) return '0.0 MB';

    double value = dataKB.toDouble();
    const units = ['KB', 'MB', 'GB'];

    int unitIndex = 0;
    while (value >= 1000 && unitIndex < units.length - 1) {
      value /= 1000;
      unitIndex++;
    }

    return '${value.toStringAsFixed(2)} ${units[unitIndex]}';
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
                AuthService.signout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 60,
            left: MediaQuery.of(context).size.width / 2 - 75,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Rounded corners for logo
              child: Image.asset(
                'assets/logo.png',
                height: 150, // Bigger logo
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 250),
            child: RefreshIndicator(
              onRefresh: _fetchData, // Pull-to-refresh functionality
              child: FutureBuilder<Map<String, dynamic>?>(
                future: scrapedData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading data',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data != null && snapshot.data!['products'] != null) {
                    List<List<dynamic>> data = snapshot.data!['products'];
                    String? usageInfo = snapshot.data!['usageInfo'];
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
                              children: data.map((item) {
                                String type = item[0];
                                String phoneNumber = item[1];
                                int usedKB = item[2];
                                int availableKB = item[3];
                                double usagePercentage = usedKB / (usedKB + availableKB);

                                return Padding(
                                  padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                                  child: Container(
                                    padding: EdgeInsets.all(24),
                                    margin: EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  type,
                                                  style: TextStyle(
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blueGrey[900],
                                                  ),
                                                ),
                                                Text(
                                                  phoneNumber,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.blueGrey[900],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Transform.scale(
                                              scale: 0.75,
                                              child: CircularProgressIndicator(
                                                value: usagePercentage,
                                                strokeWidth: 7.5,
                                                strokeCap: StrokeCap.round,
                                                backgroundColor: Color.fromRGBO(218, 218, 218, 1.0),
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  usagePercentage >= 0.9
                                                      ? Colors.red
                                                      : usagePercentage >= 0.7
                                                      ? Colors.orange
                                                      : Colors.green,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 45),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  'Current Usage',
                                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                                ),
                                                Text(
                                                  formatData(usedKB),
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  'Data Limit',
                                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                                ),
                                                Text(
                                                  formatData(availableKB),
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        if (usageInfo != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              usageInfo,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromRGBO(110, 110, 110, 1.0),
                                fontStyle: FontStyle.italic,
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
