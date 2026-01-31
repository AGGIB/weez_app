import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection_container.dart' as di;
import '../../data/repositories/file_repository.dart';
import '../../domain/repositories/seller_repository.dart'; // New import
import '../../domain/entities/product.dart';
import '../../presentation/blocs/product/product_bloc.dart';
import '../../presentation/blocs/product/product_event.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';

// Helper for formatting price (Thousands separator)
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ' ';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newValueText = newValue.text.replaceAll(separator, '');

    if (int.tryParse(newValueText) == null) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < newValueText.length; i++) {
      if (i > 0 && (newValueText.length - i) % 3 == 0) {
        buffer.write(separator);
      }
      buffer.write(newValueText[i]);
    }

    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class AddProductWizardScreen extends StatefulWidget {
  const AddProductWizardScreen({super.key});

  @override
  State<AddProductWizardScreen> createState() => _AddProductWizardScreenState();
}

class _AddProductWizardScreenState extends State<AddProductWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Data
  String _selectedCategory = '';
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  // We no longer use a simple text controller for delivery, but a dynamic list
  List<Map<String, String>> _deliveryOptions = [];

  List<File> _selectedImages = [];
  bool _isUploading = false;
  final FileRepository _fileRepository = di.sl<FileRepository>();
  final SellerRepository _sellerRepository = di.sl<SellerRepository>(); // New
  final _keywordsController = TextEditingController();
  bool _isGeneratingAi = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Electronics', 'icon': Icons.devices},
    {'name': 'Clothing', 'icon': Icons.checkroom},
    {'name': 'Shoes', 'icon': Icons.do_not_step},
    {'name': 'Accessories', 'icon': Icons.watch},
    {'name': 'Home', 'icon': Icons.home},
    {'name': 'Books', 'icon': Icons.book},
    {'name': 'Beauty', 'icon': Icons.brush},
    {'name': 'Toys', 'icon': Icons.toys},
    {'name': 'Sports', 'icon': Icons.sports_basketball},
  ];

  void _addDeliveryOption() {
    showDialog(
      context: context,
      builder: (ctx) {
        String title = '';
        String price = '';
        String time = '';
        return AlertDialog(
          title: Text(
            "Добавить вариант доставки",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: "Название (напр. Курьер)",
                ),
                onChanged: (v) => title = v,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Стоимость (напр. 1000 или Бесплатно)",
                ),
                onChanged: (v) => price = v,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Срок (напр. 1-2 дня)",
                ),
                onChanged: (v) => time = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty) {
                  setState(() {
                    _deliveryOptions.add({
                      'title': title,
                      'price': price,
                      'time': time,
                    });
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Добавить"),
            ),
          ],
        );
      },
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      if (_validateCurrentStep()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep++);
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_selectedCategory.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Выберите категорию')));
        return false;
      }
    } else if (_currentStep == 1) {
      if (_nameController.text.isEmpty || _descController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заполните название и описание')),
        );
        return false;
      }
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Добавьте хотя бы одно фото')),
        );
        return false;
      }
    } else if (_currentStep == 2) {
      if (_priceController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Укажите цену')));
        return false;
      }
    }
    return true;
  }

  double _parsePrice(String text) {
    return double.tryParse(text.replaceAll(' ', '')) ?? 0.0;
  }

  Future<void> _submitProduct() async {
    setState(() => _isUploading = true);

    try {
      List<String> uploadedUrls = [];

      for (var image in _selectedImages) {
        final result = await _fileRepository.uploadImage(image);
        result.fold(
          (failure) => throw Exception(failure.message),
          (url) => uploadedUrls.add(url),
        );
      }

      final authState = context.read<AuthBloc>().state;
      String? sellerId;
      if (authState is AuthAuthenticated) {
        sellerId = authState.user.id;
      }

      final product = ProductEntity(
        id: '',
        name: _nameController.text,
        description: _descController.text,
        price: _parsePrice(_priceController.text),
        imageUrl: uploadedUrls.first,
        imageUrls: uploadedUrls,
        category: _selectedCategory,
        rating: 0,
        isFavorite: false,
        sellerId: sellerId,
        discountPrice: _parsePrice(_discountController.text),
        deliveryInfo: json.encode(_deliveryOptions), // Save as JSON
      );

      if (mounted) {
        context.read<ProductBloc>().add(CreateProduct(product));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Товар успешно создан!')));
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }

  void _clearForm() {
    _selectedImages.clear();
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _discountController.clear();
    _deliveryOptions.clear(); // Clear list
    _selectedCategory = '';
    setState(() {
      _currentStep = 0;
      _isUploading = false;
    });
    _pageController.jumpToPage(0);
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  Future<void> _generateAiDescription() async {
    if (_nameController.text.isEmpty || _selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите название и категорию')),
      );
      return;
    }

    setState(() => _isGeneratingAi = true);

    final keywords = _keywordsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final result = await _sellerRepository.generateProductDescription(
      _nameController.text,
      _selectedCategory,
      keywords,
    );

    if (mounted) {
      setState(() => _isGeneratingAi = false);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка AI: ${failure.message}')),
          );
        },
        (text) {
          _descController.text = text;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Описание сгенерировано! ✨')),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Создание товара',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _prevStep,
              )
            : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Row(
              children: List.generate(_totalSteps, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? const Color(0xFF494F88)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCategoryStep(),
                _buildInfoStep(),
                _buildAttributesStep(),
                _buildPreviewStep(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isUploading
              ? null
              : (_currentStep == _totalSteps - 1 ? _submitProduct : _nextStep),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF494F88),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isUploading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  _currentStep == _totalSteps - 1 ? 'Опубликовать' : 'Далее',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  // ... (Keep existing methods and update where needed)
  Widget _buildCategoryStep() {
    // (Same as before)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Выберите категорию",
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat['name'];
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['name']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF494F88).withOpacity(0.1)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF494F88)
                          : Colors.grey.shade200,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat['icon'],
                        size: 32,
                        color: isSelected
                            ? const Color(0xFF494F88)
                            : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF494F88)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Основная информация",
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Icon(Icons.add_a_photo, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                ..._selectedImages.map(
                  (file) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            file,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedImages.remove(file)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildTextField(_nameController, "Название товара"),
          const SizedBox(height: 16),
          _buildTextField(
            _keywordsController,
            "Ключевые слова (через запятую)",
            hint: "легкие, летние, хлопок",
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Описание",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                onPressed: _isGeneratingAi ? null : _generateAiDescription,
                icon: _isGeneratingAi
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: Colors.orange,
                      ),
                label: Text(
                  "Сгенерировать AI",
                  style: GoogleFonts.inter(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(
            _descController,
            "Введите описание или сгенерируйте...",
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Цена и условия",
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            _priceController,
            "Цена (₸)",
            isNumber: true,
            isPrice: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            _discountController,
            "Цена со скидкой (опционально)",
            isNumber: true,
            isPrice: true,
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Варианты доставки",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              IconButton(
                onPressed: _addDeliveryOption,
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF494F88),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          if (_deliveryOptions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Нет вариантов доставки",
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
          ..._deliveryOptions.map(
            (opt) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  opt['title']!,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${opt['price']} • ${opt['time']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _deliveryOptions.remove(opt)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Предпросмотр",
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Mockup Product Page
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                ),
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                  child: _selectedImages.isEmpty
                      ? Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        )
                      : PageView.builder(
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Image.file(
                              _selectedImages[index],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _nameController.text,
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "${_priceController.text} ₸",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF494F88),
                            ),
                          ),
                        ],
                      ),
                      if (_discountController.text.isNotEmpty)
                        Text(
                          "Цена со скидкой: ${_discountController.text} ₸",
                          style: GoogleFonts.inter(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedCategory,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Описание",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _descController.text,
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),

                      if (_deliveryOptions.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          "Доставка",
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._deliveryOptions.map(
                          (opt) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_shipping_outlined,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${opt['title']} - ${opt['price']} (${opt['time']})",
                                    style: GoogleFonts.inter(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    bool isPrice = false,
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      inputFormatters: isPrice ? [ThousandsSeparatorInputFormatter()] : [],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
