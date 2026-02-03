import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<ToggleFavorite>(_onToggleFavorite);
    on<LoadFavorites>(_onLoadFavorites);
    on<CreateProduct>(_onCreateProduct);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final productsResult = await productRepository.getProducts(
      category: event.category,
      storeId: event.storeId,
      search: event.search,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
    );
    final categoriesResult = await productRepository.getCategories();

    productsResult.fold((failure) => emit(ProductError(failure.message)), (
      products,
    ) {
      categoriesResult.fold(
        (failure) => emit(ProductError(failure.message)),
        (categories) => emit(
          ProductLoaded(
            products: products,
            categories: categories,
            selectedCategory: event.category ?? 'Все товары',
          ),
        ),
      );
    });
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    // Keep showing current state or switch to loading specific search state?
    // For simplicity, let's use loading
    emit(ProductLoading());
    final result = await productRepository.searchProducts(event.query);

    // We also need categories for context on the home screen
    final categoriesResult = await productRepository.getCategories();

    result.fold((failure) => emit(ProductError(failure.message)), (products) {
      categoriesResult.fold(
        (failure) => emit(ProductError(failure.message)),
        (categories) => emit(
          ProductLoaded(
            products: products,
            categories: categories,
            selectedCategory: 'Все товары', // Reset filter or keep?
          ),
        ),
      );
    });
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<ProductState> emit,
  ) async {
    final result = await productRepository.toggleFavorite(event.productId);
    result.fold((failure) => emit(ProductError(failure.message)), (_) {
      // Reload products or update list manually
      // Ideally we should update the list in place to avoid full reload flicker
      // But for mock repo simplicity, let's just trigger reload with current state params if possible
      // But we don't store current filters in the bloc property easily without caching
      // Let's just emit current state if possible or reload
      // Simplest: Request reload of current category from scratch
      if (state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        add(LoadProducts(category: currentState.selectedCategory));
      } else if (state is ProductFavoritesLoaded) {
        add(LoadFavorites());
      } else {
        add(const LoadProducts());
      }
    });
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await productRepository.getFavorites();
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (favorites) => emit(ProductFavoritesLoaded(favorites)),
    );
  }

  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    final result = await productRepository.createProduct(event.product);
    result.fold((failure) => emit(ProductError(failure.message)), (product) {
      add(const LoadProducts());
    });
  }
}
