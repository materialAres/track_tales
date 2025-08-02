import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';

class ISBNScannerScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onBookFound;

  const ISBNScannerScreen({
    super.key,
    required this.onBookFound,
  });

  @override
  State<ISBNScannerScreen> createState() => _ISBNScannerScreenState();
}

class _ISBNScannerScreenState extends State<ISBNScannerScreen> {
  late MobileScannerController controller;
  late Dio dio;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      formats: [BarcodeFormat.ean13, BarcodeFormat.ean8], // ISBN formats
    );
    dio = Dio();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final isbn = barcode.rawValue;

    if (isbn == null || isbn.isEmpty) return;

    setState(() {
      isProcessing = true;
    });

    try {
      // Fetch book data from Google Books API
      final bookData = await _fetchBookData(isbn);
      if (bookData != null) {
        // Close scanner and return book data
        if (mounted) {
          Navigator.of(context).pop();
          widget.onBookFound(bookData);
        }
      } else {
        _showErrorMessage('Book not found for ISBN: $isbn');
      }
    } catch (e) {
      _showErrorMessage('Error fetching book data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchBookData(String isbn) async {
    try {
      final url = 'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn';
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        final items = data['items'] as List?;

        if (items != null && items.isNotEmpty) {
          return items.first as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching book data: $e');
      return null;
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan ISBN'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: controller,
            onDetect: _onBarcodeDetected,
          ),

          // Overlay with scanning area
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
            child: Column(
              children: [
                Expanded(flex: 1, child: Container()),

                // Scanning area
                Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(), // Transparent scanning area
                ),

                Expanded(flex: 1, child: Container()),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Position the ISBN barcode within the frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      if (isProcessing)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Processing...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}