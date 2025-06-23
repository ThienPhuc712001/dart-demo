
import 'package:my_project/database_annotations.dart';

@Entity('products')
class Product {
  @Id()
  @Column('product_id', 'INTEGER')
  int productId;

  @Column('product_name', 'TEXT')
  String productName;

  @Column('price', 'REAL')
  double price;

  Product(this.productId, this.productName, this.price);
}

