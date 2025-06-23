
import 'package:my_project/database_annotations.dart';

@Entity('users')
class User {
  @Id()
  @Column('id', 'INTEGER')
  int id;

  @Column('name', 'TEXT')
  String name;

  @Column('age', 'INTEGER', isNullable: true)
  int? age;

  User(this.id, this.name, this.age);
}

