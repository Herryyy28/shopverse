import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class PrintScreen extends StatefulWidget {
  const PrintScreen({super.key});

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  PlatformFile? _selectedFile;
  int _pageCount = 1;
  int _selectedPrintType = 0; // 0: B&W, 1: Color
  final Color brandRed = const Color(0xFFFF3232);

  final List<Map<String, dynamic>> _printServices = [
    {'name': 'Black & White', 'icon': Icons.print_outlined, 'price': 3, 'unit': 'page'},
    {'name': 'Color Print', 'icon': Icons.color_lens_outlined, 'price': 10, 'unit': 'page'},
    {'name': 'Lamination', 'icon': Icons.layers_outlined, 'price': 25, 'unit': 'doc'},
    {'name': 'Spiral Binding', 'icon': Icons.menu_book_outlined, 'price': 60, 'unit': 'doc'},
  ];

  Future<void> _pickFile() async {
    try {
      // Use the static pickFiles method directly as per file_picker 8.x+ / 11.x API
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          // Mocking page count detection: 1 page per 500KB, min 1, max 50
          _pageCount = (_selectedFile!.size / 500000).ceil().clamp(1, 50);
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick file. Please try again.')),
        );
      }
    }
  }

  // Fallback if .platform is indeed missing (some versions use static directly)
  Future<void> _pickFileFallback() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _pageCount = (_selectedFile!.size / 500000).ceil().clamp(1, 50);
        });
      }
    } catch (e) {
      debugPrint("Fallback error: $e");
    }
  }

  double get _totalPrice {
    if (_selectedFile == null) return 0;
    double pricePerPage = _printServices[_selectedPrintType]['price'].toDouble();
    return pricePerPage * _pageCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Print Store',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUploadCard(),
            if (_selectedFile != null) _buildFileDetails(),
            _buildSectionHeader('PRINT SERVICES'),
            _buildServiceGrid(),
            _buildSectionHeader('QUICK STATIONERY'),
            _buildStationeryList(),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: _selectedFile != null ? _buildCheckoutBar() : null,
    );
  }

  Widget _buildUploadCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brandRed.withValues(alpha: 0.1), width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: brandRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_upload_outlined, color: brandRed, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload documents to print',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: brandRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: const Text('SELECT FILES'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.description, color: Colors.blue, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedFile!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB • $_pageCount pages',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selectedFile = null)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pages to print'),
              Row(
                children: [
                  IconButton(onPressed: () => setState(() => _pageCount = (_pageCount > 1) ? _pageCount - 1 : 1), icon: const Icon(Icons.remove_circle_outline)),
                  Text('$_pageCount', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => setState(() => _pageCount++), icon: const Icon(Icons.add_circle_outline)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5, mainAxisSpacing: 12, crossAxisSpacing: 12),
      itemCount: _printServices.length,
      itemBuilder: (context, i) {
        final isSelected = _selectedPrintType == i;
        return InkWell(
          onTap: () => setState(() => _selectedPrintType = i),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? brandRed.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? brandRed : Colors.transparent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_printServices[i]['icon'], color: isSelected ? brandRed : Colors.black),
                const Spacer(),
                Text(_printServices[i]['name'], style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                Text('₹${_printServices[i]['price']}/${_printServices[i]['unit']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)));

  Widget _buildStationeryList() => const SizedBox.shrink(); // Simplified for now

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_pageCount Pages • ${_printServices[_selectedPrintType]['name']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text('₹${_totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart'))),
            style: ElevatedButton.styleFrom(backgroundColor: brandRed, foregroundColor: Colors.white),
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}
