List<List<T>> chunk<T>(List<T> list, int chunkSize) {
  final List<List<T>> chunks = [];
  final len = list.length;
  for (var i = 0; i < list.length; i += chunkSize) {
    int size = i + chunkSize;
    chunks.add(list.sublist(i, size > len ? len : size));
  }
  return chunks;
}
