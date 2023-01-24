// // class AuthController extends StateNotifier<AsyncValue<void>> {
// //   AuthController(this.ref) : super(const AsyncData(null));
// //   final Ref ref;

// //   Future<void> signInAnonymously() async {
// //     final authRepository = ref.read(authRepositoryProvider);
// //     state = const AsyncLoading();
// //     state = await AsyncValue.guard(authRepository.signInAnonymously);
// //   }
// // }
// // class ItemListController extends StateNotifier {
// //   final Ref ref;
// //   final String? _userId;

// //   ItemListController(this.ref, this._userId) : super(AsyncValue.loading()) {
// //     if (_userId != null) {
// //       retrieveItems();
// //     }

// //   }

// //   Future<void> retrieveItems({bool isRefreshing = false}) async {
// //     if (isRefreshing) state = AsyncValue.loading();
// //     try {
// //       final items = await ref
// //           .read(itemRepositoryProvider)
// //           .retrieveItems(userId: _userId!);
// //       if (mounted) {
// //         state = AsyncValue.data(items);
// //       }
// //     } on CustomException catch (e, st) {
// //       state = AsyncValue.error(e, st);
// //     }
// //   }

// // }

// // 1. add the necessary imports

// // 2. extend [AsyncNotifier]
// import 'dart:async';

// import 'package:flutter_chatapp/domain/item_model/item_model.dart';
// import 'package:flutter_chatapp/repository/item_repository.dart';
// import 'package:flutter_chatapp/use_case/auth_controller.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// import '../extensions/custom_exception.dart';

// // TODO: <List<Item>>
// // /とある関数が使えない場合　使えている箇所まで行って場所を特定する notifierとかの場合はあらかじめ指定しておかないと使えない
// // / <????> の重要性　意味について詳しくやっていきたいと思った
// final itemListExceptionProvider = StateProvider<CustomException?>((_) => null);

// final itemListControllerProvider =
//     AsyncNotifierProvider<ItemListController, List<Item>>(() {
//   return ItemListController();
// });

// class ItemListController extends AsyncNotifier<List<Item>> {
//   late final userId = ref.watch(authControllerProvider);
//   late final String? _userId = userId?.uid;

//   @override
//   FutureOr<List<Item>> build() {
//     if (_userId != null) {
//       state = const AsyncLoading();
//       retrieveItems();
//     }
//     //非同期処理の結果を格納する
//     //FIXME: 削除対象
//     List<Item> results = [];
//     // 結果を返す
//     return results;
//   }

//   Future<void> retrieveItems({bool isRefreshing = false}) async {
//     if (isRefreshing) state = const AsyncLoading();
//     try {
//       final items = await ref
//           .read(itemRepositoryProvider)
//           .retrieveItems(userId: _userId!);

//       //mountedの代わりの処理 値が存在しているかを確認する　ここが通らなければerrorが出る
//       if (state.hasValue) {
//         state = AsyncData(items);
//         print('debug: item has value');
//       }
//     } on CustomException catch (e, st) {
//       state = AsyncValue.error(e, st);
//     }
//   }

//   Future<void> addItem({required String name, bool obtained = false}) async {
//     try {
//       final item = Item(name: name, obtained: obtained);
//       final itemId = await ref
//           .read(itemRepositoryProvider)
//           .createItem(userId: _userId!, item: item);
//       state.whenData(
//           (items) => state = AsyncData(items..add(item.copyWith(id: itemId))));
//     } on CustomException catch (e) {
//       ref.read(itemListExceptionProvider.notifier).state = e;
//     }
//   }

//   Future<void> updateItem({required Item updatedItem}) async {
//     try {
//       await ref
//           .read(itemRepositoryProvider)
//           .updateItem(userId: _userId!, item: updatedItem);

//       state.whenData(
//         (items) {
//           for (final item in items) {
//             if (item.id == updatedItem.id) {
//               updatedItem;
//             } else {
//               item;
//             }
//           }
//         },
//       );
//     } on CustomException catch (e) {
//       ref.read(itemListExceptionProvider.notifier).state = e;
//     }
//   }

//   Future<void> deleteItem({required String itemId}) async {
//     try {
//       await ref
//           .read(itemRepositoryProvider)
//           .deleteItem(userId: _userId!, itemId: itemId);

//       state.whenData((items) => state =
//           AsyncValue.data(items..removeWhere((item) => item.id == itemId)));
//     } on CustomException catch (e) {
//       ref.read(itemListExceptionProvider.notifier).state = e;
//     }
//   }
// }
