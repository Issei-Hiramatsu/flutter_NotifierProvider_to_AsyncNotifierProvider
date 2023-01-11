import 'dart:async';

import 'package:flutter_chatapp/repository/item_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/item_model/item_model.dart';
import '../extensions/custom_exception.dart';
import '../view/auth_and_todoPage.dart';

final itemListExceptionProvider = StateProvider<CustomException?>((_) => null);

// final itemListControllerProvider = SAsyncNotifierProvider(
// (ref) {
//   final user = ref.watch(authControllerProvider.notifier).state;
//   return ItemListController(ref, user?.uid);
// },
// );
final itemListControllerProvider = AsyncNotifierProvider(
     ref.watch(authControllerProvider.notifier);
);

class ItemListController extends AsyncNotifier {
  final Ref _read;
  final String? _userId;

  ItemListController(this._read, this._userId) : super(AsyncValue.loading()) {
    if (_userId != null) {
      retrieveItems();
    }
  }

  Future<void> retrieveItems({bool isRefreshing = false}) async {
    if (isRefreshing) state = AsyncValue.loading();
    try {
      final items = await _read
          .read(itemRepositoryProvider)
          .retrieveItems(userId: _userId!);
      if (mounted) {
        state = AsyncValue.data(items);
      }
    } on CustomException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem({required String name, bool obtained = false}) async {
    try {
      final item = Item(name: name, obtained: obtained);
      final itemId = await _read
          .read(itemRepositoryProvider)
          .createItem(userId: _userId!, item: item);

      state.whenData((items) =>
          state = AsyncValue.data(items..add(item.copyWith(id: itemId))));
    } on CustomException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateItem({required Item updatedItem}) async {
    try {
      await _read
          .read(itemRepositoryProvider)
          .updateItem(userId: _userId!, item: updatedItem);

      state.whenData((items) {
        for (final item in items) {
          if (item.id == updatedItem.id) {
            updatedItem;
          } else {
            item;
          }
        }
      });
    } on CustomException catch (e) {
      _read.read(itemListExceptionProvider.notifier).state = e;
    }
  }

  Future<void> deleteItem({required String itemId}) async {
    try {
      await _read
          .read(itemRepositoryProvider)
          .deleteItem(userId: _userId!, itemId: itemId);

      //state((items) => state = AsyncValue.data(items));
      state;
    } on CustomException catch (e) {
      _read.read(itemListExceptionProvider.notifier).state = e;
    }
  }
}

