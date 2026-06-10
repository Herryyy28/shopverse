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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        // Mocking page count detection
        _pageCount = (_selectedFile!.size / 500000).ceil().clamp(1, 50);
      });
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
          const SizedBox(height: 4),
          Text(
            'PDF, Images, Docs (Max 20MB)',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('SELECT FILES', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
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
                    Text(
                      _selectedFile!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB • $_pageCount pages',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _selectedFile = null),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pages to print', style: TextStyle(fontWeight: FontWeight.w500)),
              Row(
                children: [
                  _circleAction(Icons.remove, () {
                    if (_pageCount > 1) setState(() => _pageCount--);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('$_pageCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  _circleAction(Icons.add, () => setState(() => _pageCount++)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleAction(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildServiceGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _printServices.length,
      itemBuilder: (context, i) {
        final isSelected = _selectedPrintType == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedPrintType = i),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? brandRed.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? brandRed : Colors.white,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _printServices[i]['icon'],
                  color: isSelected ? brandRed : Colors.black87,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  _printServices[i]['name'],
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                    color: isSelected ? brandRed : Colors.black,
                  ),
                ),
                Text(
                  '₹${_printServices[i]['price']}/${_printServices[i]['unit']}',
                  style: TextStyle(
                    color: isSelected ? brandRed.withValues(alpha: 0.7) : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildStationeryList() {
    final items = [
      {'n': 'Classmate Notebook', 'p': '60', 'u': '1 unit', 'img': 'https://m.media-amazon.com/images/I/71B9V28MvAL._SL1500_.jpg'},
      {'n': 'Reynolds Ball Pen', 'p': '10', 'u': '1 unit', 'img': 'https://m.media-amazon.com/images/I/61Nl-H6v+GL._SL1500_.jpg'},
      {'n': 'A4 Paper Rim', 'p': '350', 'u': '500 sheets', 'img': 'https://m.media-amazon.com/images/I/61X-NlX4X4L._SL1100_.jpg'},
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        itemBuilder: (context, i) => Container(
          width: 150,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.network(items[i]['img']!, fit: BoxFit.contain),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(items[i]['n']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(items[i]['u']!, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${items[i]['p']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: brandRed.withValues(alpha: 0.2)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.add, color: brandRed, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_pageCount Pages • ${_printServices[_selectedPrintType]['name']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '₹${_totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Simulate adding to cart and moving to checkout
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Print job added to cart!'),
                      backgroundColor: brandRed,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
