/// A fixed-capacity ring buffer that evicts the oldest element when full.
///
/// Memory stays bounded regardless of how long the toolkit runs.
class RingBuffer<T> extends Iterable<T> {
  RingBuffer(this.capacity)
      : assert(capacity > 0, 'capacity must be positive'),
        _buffer = List<T?>.filled(capacity, null);

  final int capacity;
  final List<T?> _buffer;
  int _start = 0;
  int _length = 0;

  void add(T value) {
    if (_length < capacity) {
      _buffer[(_start + _length) % capacity] = value;
      _length++;
    } else {
      _buffer[_start] = value;
      _start = (_start + 1) % capacity;
    }
  }

  void clear() {
    for (int i = 0; i < capacity; i++) {
      _buffer[i] = null;
    }
    _start = 0;
    _length = 0;
  }

  @override
  bool get isEmpty => _length == 0;

  bool get isFull => _length == capacity;

  @override
  int get length => _length;

  T operator [](int index) {
    if (index < 0 || index >= _length) {
      throw RangeError.index(index, this, 'index', null, _length);
    }
    return _buffer[(_start + index) % capacity] as T;
  }

  @override
  List<T> toList({bool growable = true}) {
    final List<T> result = <T>[for (int i = 0; i < _length; i++) this[i]];
    return growable ? result : List<T>.unmodifiable(result);
  }

  @override
  Iterator<T> get iterator => _RingBufferIterator<T>(this);
}

class _RingBufferIterator<T> implements Iterator<T> {
  _RingBufferIterator(this._buffer);

  final RingBuffer<T> _buffer;
  int _index = -1;

  @override
  T get current => _buffer[_index];

  @override
  bool moveNext() {
    if (_index + 1 >= _buffer.length) return false;
    _index++;
    return true;
  }
}
