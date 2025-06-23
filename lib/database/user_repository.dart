
import 'package:my_project/database/base_repository.dart';
import 'package:my_project/models/user.dart';
import 'package:sqlite3/sqlite3.dart';

class UserRepository extends BaseRepository<User> {
  UserRepository(Database db) : super(db, User);

  @override
  User fromRow(Row row) {
    return User(
      row['id'],
      row['name'],
      row['age'],
    );
  }
}

