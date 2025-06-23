
abstract class Repository<T> {
  Future<T?> findById(int id);
  Future<List<T>> findAll();
  Future<int> save(T entity);
  Future<int> update(T entity);
  Future<int> delete(int id);
}

