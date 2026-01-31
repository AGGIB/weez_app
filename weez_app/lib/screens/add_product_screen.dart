import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection_container.dart' as di;
import '../../data/repositories/file_repository.dart';
import '../../domain/entities/product.dart';
import '../../presentation/blocs/product/product_bloc.dart';
import '../../presentation/blocs/product/product_event.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Electronics'; // Default
  File? _imageFile;
  bool _isUploading = false;
  final FileRepository _fileRepository = di.sl<FileRepository>();

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Shoes',
    'Accessories',
    'Home',
    'Books',
    'Beauty',
    'Toys',
    'Sports',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, выберите изображение товара'),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    // 1. Upload Image
    final uploadResult = await _fileRepository.uploadImage(_imageFile!);

    uploadResult.fold(
      (failure) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки фото: ${failure.message}')),
        );
      },
      (imageUrl) {
        // 2. Create Product
        final authState = context.read<AuthBloc>().state;
        String? sellerId;
        if (authState is AuthAuthenticated) {
          sellerId = authState.user.id;
        }

        final product = ProductEntity(
          id: '', // Server generates ID
          name: _nameController.text,
          description: _descController.text,
          price: double.tryParse(_priceController.text) ?? 0.0,
          imageUrl: imageUrl,
          category: _selectedCategory,
          rating: 0,
          isFavorite: false,
          sellerId: sellerId,
        );

        context.read<ProductBloc>().add(CreateProduct(product));

        setState(() => _isUploading = false);

        // Show success and clear or navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Товар успешно добавлен!')),
        );
        _clearForm();
      },
    );
  }

  void _clearForm() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    setState(() {
      _imageFile = null;
      _selectedCategory = 'Electronics';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Добавить товар',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Добавить фото',
                              style: GoogleFonts.inter(color: Colors.grey),
                            ),
                          ],
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 24),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Название товара',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Введите название' : null,
              ),

              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Цена (₸)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) => value!.isEmpty ? 'Введите цену' : null,
              ),

              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Категория',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Введите описание' : null,
              ),

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isUploading ? null : _submitProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF494F88),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Опубликовать товар',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
