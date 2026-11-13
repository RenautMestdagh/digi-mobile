import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../data/digi_client.dart';
import '../data/products.dart';
import '../l10n/app_localizations.dart';
import '../widgets/feedback.dart';
import '../widgets/product_card.dart';
import '../widgets/readable_width.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.client, required this.onSignedOut});

  final DigiClient client;
  final VoidCallback onSignedOut;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _refresh = GlobalKey<RefreshIndicatorState>();
  String? _language;
  List<Product>? _products;
  DigiException? _error;
  var _loggingOut = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Digi's site speaks the app's language, so a new language means loading the products again.
    final language = Localizations.localeOf(context).languageCode;
    if (language != _language) {
      _language = language;
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    try {
      final products = await widget.client.products(language: _language!);
      if (!mounted) return;
      setState(() {
        _products = products;
        _error = null;
      });
    } on SessionExpired {
      if (!mounted) return;
      showMessage(context, S.of(context).sessionExpired);
      widget.onSignedOut();
    } on DigiException catch (error) {
      if (!mounted) return;
      if (_products == null) {
        setState(() => _error = error);
      } else {
        showMessage(context, describe(context, error));
      }
    }
  }

  Future<void> _logOut() async {
    setState(() => _loggingOut = true);
    await widget.client.logOut();
    widget.onSignedOut();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final products = _products;
    final error = _error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DIGI Mobile'),
        actions: [
          IconButton(tooltip: s.logOut, icon: const Icon(Icons.logout), onPressed: _loggingOut ? null : _logOut),
        ],
      ),
      body: products == null && error == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              key: _refresh,
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  for (final child in [
                    if (error != null)
                      Problem(
                        icon: error is NetworkFailure ? Icons.cloud_off : Icons.error_outline,
                        message: describe(context, error),
                        onRetry: () => _refresh.currentState!.show(),
                      )
                    else if (products!.isEmpty)
                      Problem(icon: Icons.inbox_outlined, message: s.noProducts)
                    else
                      for (final product in products)
                        ProductCard(product: product, onRetry: () => _refresh.currentState!.show()),
                  ])
                    ReadableWidth(child: child),
                ],
              ),
            ),
    );
  }
}
