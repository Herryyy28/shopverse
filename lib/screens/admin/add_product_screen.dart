import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:shopverse/models/product.dart';
import 'package:shopverse/providers/product_provider.dart';
import 'package:shopverse/providers/category_provider.dart';
import 'package:shopverse/services/firebase_service.dart';
import 'package:shopverse/utils/app_colors.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _oldPriceController;
  late TextEditingController _unitController;
  
  String _selectedCategory = 'Grocery';
  bool _isVeg = true;
  PlatformFile? _imageFile;
  bool _isUploading = false;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _oldPriceController = TextEditingController(text: widget.product?.oldPrice.toString() ?? '');
    _unitController = TextEditingController(text: widget.product?.unit ?? '');
    _selectedCategory = widget.product?.category ?? 'Grocery';
    _isVeg = widget.product?.isVeg ?? true;
    _existingImageUrl = widget.product?.imageUrl;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _imageFile = result.files.first);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Upload to Firebase Storage if new image picked
      String imageUrl = _existingImageUrl ?? '';
      if (_imageFile != null) {
        imageUrl = await FirebaseService.uploadImage(_imageFile);
      }

      // 2. Create Product Object
      final newProduct = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descController.text,
        price: double.parse(_priceController.text),
        oldPrice: double.tryParse(_oldPriceController.text) ?? 0,
        imageUrl: imageUrl,
        category: _selectedCategory,
        unit: _unitController.text,
        isVeg: _isVeg,
      );

      // 3. Save to Firestore & Provider
      if (!mounted) return;
      final productProv = Provider.of<ProductProvider>(context, listen: false);
      if (widget.product == null) {
        await productProv.addProduct(newProduct);
      } else {
        await productProv.updateProduct(newProduct);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.product == null ? 'Product added successfully!' : 'Product updated successfully!'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProv = Provider.of<CategoryProvider>(context);
    
    return StreamBuilder<List<CategoryItem>>(
      stream: categoryProv.categoriesStream,
      builder: (context, snapshot) {
        final categories = snapshot.data ?? categoryProv.categories;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: const Icon(Icons.check_circle, color: Colors.green, size: 50), // Simplified preview
                            )
                          : _existingImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(_existingImageUrl!, fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Select Product Image', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Enter description' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Price (₹)', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter price' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _oldPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'MRP (₹)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: categories.any((c) => c.name == _selectedCategory) ? _selectedCategory : (categories.isNotEmpty ? categories.first.name : null),
                    items: categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Unit (e.g. 500 ml, 1 kg)', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Enter unit' : null,
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Is Vegetarian?'),
                    value: _isVeg,
                    activeThumbColor: Colors.green,
                    onChanged: (v) => setState(() => _isVeg = v),
                  ),

                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isUploading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SAVE PRODUCT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
