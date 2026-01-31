import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../presentation/blocs/seller/seller_bloc.dart';
import '../../presentation/blocs/seller/seller_state_event.dart';

class EditStoreScreen extends StatefulWidget {
  final String currentName;
  final String currentDescription;

  const EditStoreScreen({
    super.key,
    required this.currentName,
    required this.currentDescription,
  });

  @override
  State<EditStoreScreen> createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  File? _logo;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _descriptionController = TextEditingController(
      text: widget.currentDescription,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logo = File(pickedFile.path);
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      context.read<SellerBloc>().add(
        UpdateStore(
          name: _nameController.text,
          description: _descriptionController.text,
          logo: _logo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SellerBloc, SellerState>(
      listener: (context, state) {
        if (state is SellerLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Магазин обновлен успешно!')),
          );
          Navigator.pop(context);
        } else if (state is SellerError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Редактировать магазин',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        image: _logo != null
                            ? DecorationImage(
                                image: FileImage(_logo!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _logo == null
                          ? const Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Изменить логотип',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF494F88),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название магазина',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите название';
                    }
                    if (value.length < 3) {
                      return 'Минимум 3 символа';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Описание магазина',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите описание';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                BlocBuilder<SellerBloc, SellerState>(
                  builder: (context, state) {
                    if (state is SellerLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF494F88),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Сохранить изменения',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
