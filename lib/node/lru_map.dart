/*
* LRU缓存算法是一种用于缓存淘汰的策略，它的全称是Least Recently Used，即最近最少使用。
*
* 它的基本思路是，当缓存空间已满时，优先淘汰最近最少使用的缓存数据，以腾出空间存储新的数据。
* 那么在使用双向链表实现LRU缓存算法时，可以将链表的头部看做是最近使用的节点，尾部看做是最久未使用的节点。
*
* 当有新的数据需要缓存时，
* 先在链表中查找是否已经存在，
* 如果存在，则将该节点移动到链表头部；
* 如果不存在，则将新节点添加到链表头部。
* 当链表空间已满时，则将链表尾部的节点删除。
* */
class LRUMap<K, V> {
  _Link? _head;
  _Link? _tail;

  // 原来是依赖next，previous来确保时序性。跟map的非有序化无关。
  final entries = <K, _Link>{};

  int _currentSize = 0;
  /// [maxSize]: Total allowed size in bytes (7MB by default).
  final int maxSize;
  /// [maxEntrySize]: Allowed size per entry in bytes (500KB by default).
  final int maxEntrySize;
  /// 由外面提供计算单体的大小
  final int Function(V resp) computeSizeCallback;

  LRUMap({this.maxSize = 7340032, this.maxEntrySize = 512000, required this.computeSizeCallback}) {
    assert(maxEntrySize != maxSize);
    assert(maxEntrySize * 5 <= maxSize);
  }

  V? operator [](String key) {
    final entry = entries[key];
    if (entry == null) return null;

    _moveToHead(entry);
    return entry.value;
  }

  void operator []=(K key, V resp) {
    final entrySize = _computeSize(resp);
    // Entry too heavy, skip it
    if (entrySize > maxEntrySize) return;

    final entry = _Link(key, resp, entrySize);
    // 不用判断是否存在，直接覆盖，并移到头部
    entries[key] = entry;
    _currentSize += entry.size;
    _moveToHead(entry);

    while (_currentSize > maxSize) {
      assert(_tail != null);
      remove(_tail!.key);
    }
  }

  void clear() {
    entries.clear();

    _head = null;
    _tail = null;
    _currentSize = 0;
  }

  V? remove(String key) {
    final entry = entries[key];
    if (entry == null) return null;

    _currentSize -= entry.size;
    entries.remove(key);

    // 移除了对象，需要重新设置关联，确保链路的完整性
    // 因为是重末尾移除的，所以不需要考虑中间的情况
    if (entry == _tail) {
      _tail = entry.next;
      _tail?.previous = null;
    }
    if (entry == _head) {
      _head = entry.previous;
      _head?.next = null;
    }

    return entry.value;
  }

  // 只处理相连的 所以计算的复杂度0(1)
  void _moveToHead(_Link link) {

    // head L L T L L tail
    // T 为目标移动对象


    // 已经在头部了
    if (link == _head) return;

    // 让当前对象的下一级顶上末尾
    if (link == _tail) {
      _tail = link.next;
    }

    // 对当前对象的前后链接进行重连
    if (link.previous != null) {
      link.previous!.next = link.next;
    }
    if (link.next != null) {
      link.next!.previous = link.previous;
    }

    // 对当前对象重新定义
    _head?.next = link; // 之前没有下一级设置最新下一级
    link.previous = _head; // 之前的头部设置为当前对象的前一级
    _head = link; // 当前对象霸占头部
    _tail ??= link; // 如果尾部为空那就用当前对象
    link.next = null; // 当前对象在不下一级

  }

  int _computeSize(V resp) {
    return computeSizeCallback.call(resp);
  }
}

class _Link<K, V> implements MapEntry<K, V> {
  _Link? next;
  _Link? previous;

  final int size;

  @override
  final K key;

  @override
  final V value;

  _Link(this.key, this.value, this.size);
}
/*
* 双向链表的应用场景非常广泛，常用于以下情况：

1.实现LRU缓存算法：LRU（Least Recently Used）是一种常见的缓存算法，用于淘汰最近最少使用的缓存。在LRU算法中，需要记录每个缓存的访问时间，并按照访问时间排序。这个排序可以通过双向链表实现，每当访问一个缓存时，将其移到链表头部，最近访问的缓存就在链表头部，最少访问的缓存就在链表尾部。

2.实现队列：队列是一种先进先出（FIFO）的数据结构，可以用双向链表来实现。在双向链表中，队列的头部是链表的第一个节点，尾部是链表的最后一个节点。新元素加入队列时，添加到链表的尾部；元素出队时，从链表的头部移除。

3.实现浏览器历史记录：浏览器历史记录可以看作是一个从当前页面到之前页面的双向链表。在浏览器中，用户可以通过前进和后退按钮来遍历历史记录，而双向链表正好可以支持这种双向遍历。

4.实现编辑器的撤销和重做功能：编辑器中的撤销和重做功能需要保存编辑操作的历史记录，而这个历史记录可以通过双向链表来实现。每当用户进行编辑操作时，都将这个操作作为一个节点添加到链表中，支持撤销和重做时，就可以通过遍历链表来实现。
*
*/