import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_detail_screen.dart';
import '../domain/entities/product.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  final List<ProductEntity> _suggestedProducts = [
    const ProductEntity(
      id: '1',
      name: 'iPhone 16 PRO',
      category: 'Телефоны',
      price: 840000,
      rating: 5.0,
      imageUrl: 'phone',
      description: 'The latest iPhone.',
    ),
    const ProductEntity(
      id: '2',
      name: 'MacBook Pro',
      category: 'Ноутбуки',
      price: 1200000,
      rating: 4.9,
      imageUrl: 'laptop',
      description: 'Power and portability.',
    ),
    const ProductEntity(
      id: '3',
      name: 'AirPods Pro',
      category: 'Аксессуары',
      price: 120000,
      rating: 4.8,
      imageUrl: 'headphones',
      description: 'Immersive sound.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add({
      'text': 'Здравствуйте! 👋 Я ваш AI-ассистент. Помогу подобрать идеальный товар для вас. Что вы ищете?',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });

    final userMessage = _messageController.text.toLowerCase();
    _messageController.clear();

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 500), () {
      String aiResponse = '';
      List<ProductEntity>? products;

      if (userMessage.contains('телефон') || userMessage.contains('iphone')) {
        aiResponse = 'Отличный выбор! У нас есть новейший iPhone 16 PRO. Это флагманский смартфон с потрясающей камерой и производительностью. Хотите посмотреть?';
        products = [_suggestedProducts[0]];
      } else if (userMessage.contains('ноутбук') || userMessage.contains('macbook')) {
        aiResponse = 'Для работы и творчества рекомендую MacBook Pro. Мощный процессор M3 и великолепный дисплей!';
        products = [_suggestedProducts[1]];
      } else if (userMessage.contains('наушники') || userMessage.contains('airpods')) {
        aiResponse = 'AirPods Pro - идеальный выбор! Активное шумоподавление и отличное качество звука.';
        products = [_suggestedProducts[2]];
      } else if (userMessage.contains('привет') || userMessage.contains('здравствуй')) {
        aiResponse = 'Привет! Рад помочь вам с выбором. Что вас интересует?';
      } else {
        aiResponse = 'Вот несколько популярных товаров, которые могут вам понравиться:';
        products = _suggestedProducts;
      }

      setState(() {
        _messages.add({
          'text': aiResponse,
          'isUser': false,
          'timestamp': DateTime.now(),
          'products': products,
        });
      });

      _scrollToBottom();
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF494F88), Color(0xFF7B82C8)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Ассистент',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Онлайн',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _buildQuickActions(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final products = message['products'] as List<ProductEntity>?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF494F88), Color(0xFF7B82C8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              if (!isUser) const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF494F88) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message['text'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isUser ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (products != null && products.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...products.map((product) => _buildProductCard(product)),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.phone_iphone,
                color: Colors.grey.shade400,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)}₸',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF494F88),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      'Телефоны',
      'Ноутбуки',
      'Наушники',
      'Одежда',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: actions.map((action) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  _messageController.text = action;
                  _sendMessage();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    action,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Напишите сообщение...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF494F88), Color(0xFF7B82C8)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
