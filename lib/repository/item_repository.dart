import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chatapp/extensions/firestore_extension.dart';
import 'package:flutter_chatapp/extensions/custom_exception.dart';
import 'package:flutter_chatapp/repository/general_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/item_model/item_model.dart';

final itemRepositoryProvider =
    Provider<ItemRepository>((ref) => ItemRepository(ref));

abstract class BaseItemRepository {
  Future<List<Item>> retrieveItems({required String userId});
  Future<String> createItem({required String userId, required Item item});
  Future<void> updateItem({required String userId, required Item item});
  Future<void> deleteItem({required String userId, required String itemId});
}

class ItemRepository implements BaseItemRepository {
  final Ref _read;

  const ItemRepository(this._read);

  @override
  Future<List<Item>> retrieveItems({required String userId}) async {
    try {
      final snap =
          await _read.read(firebaseFirestoreProvider).userListRef(userId).get();
      return snap.docs.map((doc) => Item.fromDocument(doc)).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<String> createItem(
      {required String userId, required Item item}) async {
    try {
      final docRef = await _read
          .read(firebaseFirestoreProvider)
          .userListRef(userId)
          .add(item.toDocument());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> updateItem({required String userId, required Item item}) async {
    try {
      await _read
          .read(firebaseFirestoreProvider)
          .userListRef(userId)
          .doc(item.id)
          .update(item.toDocument());
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> deleteItem(
      {required String userId, required String itemId}) async {
    try {
      await _read
          .read(firebaseFirestoreProvider)
          .userListRef(userId)
          .doc(itemId)
          .delete();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }
}
