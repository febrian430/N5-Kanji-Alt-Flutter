import 'dart:core';

extension IndexedIterable<E> on Iterable<E> {
  void forEachIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    forEach((e) => f(e, i++));
  }
}