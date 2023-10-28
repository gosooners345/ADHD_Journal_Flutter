
extension ListUpdate on List<dynamic> {
  void update(dynamic object, int index) {
    removeAt(index);
    insert(index, object);
  }
}
