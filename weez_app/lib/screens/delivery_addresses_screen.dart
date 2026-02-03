import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../injection_container.dart' as di;
import '../domain/repositories/auth_repository.dart';

class DeliveryAddressesScreen extends StatefulWidget {
  const DeliveryAddressesScreen({super.key});

  @override
  State<DeliveryAddressesScreen> createState() =>
      _DeliveryAddressesScreenState();
}

class _DeliveryAddressesScreenState extends State<DeliveryAddressesScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;
  final _authRepository = di.sl<AuthRepository>();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    final result = await _authRepository.getAddresses();
    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (addresses) {
        setState(() {
          _addresses = addresses;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _deleteAddress(int id) async {
    final result = await _authRepository.deleteAddress(id);
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => _loadAddresses(),
    );
  }

  void _showAddAddressDialog() {
    final titleController = TextEditingController();
    final addrController = TextEditingController();
    bool isDefault = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Добавить адрес'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Название (напр. Дом)',
                ),
              ),
              TextField(
                controller: addrController,
                decoration: const InputDecoration(labelText: 'Адрес'),
              ),
              CheckboxListTile(
                title: const Text('По умолчанию'),
                value: isDefault,
                onChanged: (val) =>
                    setDialogState(() => isDefault = val ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await _authRepository.addAddress(
                  titleController.text,
                  addrController.text,
                  isDefault,
                );
                result.fold(
                  (failure) => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(failure.message))),
                  (_) {
                    Navigator.pop(context);
                    _loadAddresses();
                  },
                );
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Адреса доставки',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? const Center(child: Text('У вас пока нет сохраненных адресов'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final addr = _addresses[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      addr['title'] ?? 'Адрес',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(addr['address'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (addr['is_default'] == true)
                          const Icon(Icons.check_circle, color: Colors.green),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteAddress(addr['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAddressDialog,
        backgroundColor: const Color(0xFF494F88),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
