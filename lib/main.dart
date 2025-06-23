
import 'package:my_project/database/database_helper.dart';
import 'package:my_project/database/user_repository.dart';
import 'package:my_project/database/product_repository.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/models/product.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

void main() async {
  await initializeDatabase();

  final String databasePath = await getDatabasesPath();
  final String path = join(databasePath, 'my_database.db');
  final db = sqlite3.open(path);

  // Example Usage
  final userRepository = UserRepository(db);
  final productRepository = ProductRepository(db);

  // Create
  final newUser = User(0, 'John Doe', 30);
  final newUserId = await userRepository.save(newUser);
  print('New User ID: $newUserId');

  final newProduct = Product(0, 'Awesome Widget', 99.99);
  final newProductId = await productRepository.save(newProduct);
  print('New Product ID: $newProductId');

  // Read
  final retrievedUser = await userRepository.findById(1);
  print('Retrieved User: ${retrievedUser?.name}');

  // Update
  if (retrievedUser != null) {
    final updatedUser = User(retrievedUser.id, 'Jane Doe', 32);
    await userRepository.update(updatedUser);
    print('User Updated');
  }

  // Delete
  await userRepository.delete(1);
  print('User Deleted');

  db.dispose();
}

