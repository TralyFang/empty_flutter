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


/// ChatGPT生成的代码，未经过验证，逻辑有点看不懂
class LRUCache<K, V> {
  final int _maxSize;
  final Map<K, _Node<K, V>> _cache = {};
  final _Node<K, V> _head = _Node<K, V>(null, null);
  late _Node<K, V> _tail;
  // 在构造函数中必须确保 _head 和 _tail 的连通性，
  // 这里我们将 _tail 设置为 _head 的下一个节点，并在添加新数据时将新节点插入到 _head 之后，保证了链表的正确性。
  LRUCache(this._maxSize) : assert(_maxSize > 0) {
    _head.next = _tail;
    _tail = _head;
  }

  // 用于往缓存中添加新的数据，如果数据已存在，则更新其对应的值，
  // 否则在缓存已满时删除最近最少使用的数据。，并将新数据添加到链表头部
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      final node = _cache[key]!;
      node.value = value;
      _moveToHead(node);
    } else {
      if (_cache.length >= _maxSize) {
        _removeTail();
      }
      final node = _Node<K, V>(key, value);
      _cache[key] = node;
      _moveToHead(node);

    }
  }

  // 用于获取指定键对应的值，并将其移动到链表头部。
  V? get(K key) {
    if (!_cache.containsKey(key)) {
      return null;
    }
    final node = _cache[key]!;
    _moveToHead(node);
    return node.value;
  }

  void _removeTail() {
    final removed = _tail;
    _tail = removed.previous!; // 挪到倒数第二位为最后一个了
    _tail.next = null; // 最后的下一个没有了
    _cache.remove(removed.key);
  }

  void _moveToHead(_Node<K, V> node) {
    if (node == _head) {
      return;
    }
    // 处理相连的关联数据
    node.previous?.next = node.next;
    node.next?.previous = node.previous;

    /// 这里的逻辑没有看懂
    // 这段代码的实现逻辑是将一个新节点插入到双向链表头部，
    // 需要修改新节点、原头节点、原头节点的后继节点的指针。
    // 这样可以使新节点成为新的头节点，并与原来的第一个节点相连，形成新的双向链表。
    // 处理自己的关联，使得当前节点在head之前，
    node.next = _head.next; // 先记录下关联，
    _head.next?.previous = node; // 预定第一个
    _head.next = node; //
    node.previous = _head;

  }
}

class _Node<K, V> {
  K? key;
  V? value;
  _Node<K, V>? previous;
  _Node<K, V>? next;

  _Node(this.key, this.value);
}

/*
* 双向链表的应用场景非常广泛，常用于以下情况：

1.实现LRU缓存算法：LRU（Least Recently Used）是一种常见的缓存算法，用于淘汰最近最少使用的缓存。在LRU算法中，需要记录每个缓存的访问时间，并按照访问时间排序。这个排序可以通过双向链表实现，每当访问一个缓存时，将其移到链表头部，最近访问的缓存就在链表头部，最少访问的缓存就在链表尾部。

2.实现队列：队列是一种先进先出（FIFO）的数据结构，可以用双向链表来实现。在双向链表中，队列的头部是链表的第一个节点，尾部是链表的最后一个节点。新元素加入队列时，添加到链表的尾部；元素出队时，从链表的头部移除。

3.实现浏览器历史记录：浏览器历史记录可以看作是一个从当前页面到之前页面的双向链表。在浏览器中，用户可以通过前进和后退按钮来遍历历史记录，而双向链表正好可以支持这种双向遍历。

4.实现编辑器的撤销和重做功能：编辑器中的撤销和重做功能需要保存编辑操作的历史记录，而这个历史记录可以通过双向链表来实现。每当用户进行编辑操作时，都将这个操作作为一个节点添加到链表中，支持撤销和重做时，就可以通过遍历链表来实现。
*
*/
