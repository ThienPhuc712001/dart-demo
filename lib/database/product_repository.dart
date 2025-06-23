
import 'package:my_project/database/base_repository.dart';
import 'package:my_project/models/product.dart';
import 'package:sqlite3/sqlite3.dart';

class ProductRepository extends BaseRepository<Product> {
  ProductRepository(Database db) : super(db, Product);

  @override
  Product fromRow(Row row) {
    return Product(
      row['product_id'],
      row['product_name'],
      row['price'],
    );
  }
}

