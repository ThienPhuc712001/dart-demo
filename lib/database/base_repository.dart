  
import 'package:my_project/database_annotations.dart';
import 'package:my_project/database/repository.dart';
import 'package:sqlite3/sqlite3.dart';
import 'dart:mirrors';

abstract class BaseRepository<T> implements Repository<T> {
  final Database db;
  final Type entityType;

  BaseRepository(this.db, this.entityType);

  // Annotation helper functions
  bool hasAnnotation<A>(Type classType) {
    final classMirror = reflectClass(classType);
    return classMirror.metadata.any((metadata) => metadata.reflectee is A);
  }

  String? getTableName(Type classType) {
    final classMirror = reflectClass(classType);
    for (var metadata in classMirror.metadata) {
      if (metadata.reflectee is Entity) {
        return (metadata.reflectee as Entity).tableName;
      }
    }
    return null;
  }

  List<VariableMirror> getColumns(Type classType) {
    final classMirror = reflectClass(classType);
    List<VariableMirror> columns = [];
    classMirror.declarations.forEach((symbol, declaration) {
      if (declaration is VariableMirror) {
        for (var metadata in declaration.metadata) {
          if (metadata.reflectee is Column) {
            columns.add(declaration);
            break;
          }
        }
      }
    });
    return columns;
  }

  String? getIdFieldName(Type classType) {
    final classMirror = reflectClass(classType);
    for (var declaration in classMirror.declarations.values) {
      if (declaration is VariableMirror) {
        for (var metadata in declaration.metadata) {
          if (metadata.reflectee is Id) {
            return MirrorSystem.getName(declaration.simpleName);
          }
        }
      }
    }
    return null;
  }

  // Abstract method to convert a row to an entity
  T fromRow(Row row);

  @override
  Future<T?> findById(int id) async {
    final tableName = getTableName(entityType);
    final idFieldName = getIdFieldName(entityType);

    if (tableName == null || idFieldName == null) {
      throw Exception(\'Entity ${entityType} is not properly annotated.\');
    }

    final results = db.select(
        \'SELECT * FROM $tableName WHERE $idFieldName = ?\',
        [id]);

    if (results.isNotEmpty) {
      return fromRow(results.first);
    } else {
      return null;
    }
  }

  @override
  Future<List<T>> findAll() async {
    final tableName = getTableName(entityType);

    if (tableName == null) {
      throw Exception(\'Entity ${entityType} is not properly annotated.\');
    }

    final results = db.select(\'SELECT * FROM $tableName\');

    return results.map((row) => fromRow(row)).toList();
  }

  @override
  Future<int> save(T entity) async {
    final tableName = getTableName(entityType);
    final idFieldName = getIdFieldName(entityType);
    final columns = getColumns(entityType);

    if (tableName == null || idFieldName == null) {
      throw Exception(\'Entity ${entityType} is not properly annotated.\');
    }

    // Lấy danh sách tên cột (không bao gồm id)
    final columnNames = columns.where((col) => MirrorSystem.getName(col.simpleName) != idFieldName).map((col) => (col.metadata.firstWhere((metadata) => metadata.reflectee is Column).reflectee as Column).columnName).toList();
    // Lấy danh sách tham số (dấu ?)
    final params = List.generate(columnNames.length, (index) => \'?\').join(\', \');

    // Tạo câu lệnh INSERT
    String sql = \'INSERT INTO $tableName (${columnNames.join(\', \')}) VALUES ($params)\';

    // Lấy giá trị của các trường
    List values = [];
    InstanceMirror instanceMirror = reflect(entity);
    for(var col in columns){
       String name = MirrorSystem.getName(col.simpleName);
       if(name != idFieldName){
         values.add(instanceMirror.getField(col.simpleName).reflectee);
       }
    }

    try {
      db.execute(sql, values);
      final id = db.lastInsertRowId;
      return id;

    } catch (e) {
      print(\'Error inserting entity: $e\');
      return 0;
    }
  }

  @override
  Future<int> update(T entity) async {
    final tableName = getTableName(entityType);
    final idFieldName = getIdFieldName(entityType);
    final columns = getColumns(entityType);

    if (tableName == null || idFieldName == null) {
      throw Exception(\'Entity ${entityType} is not properly annotated.\');
    }

    // Lấy danh sách tên cột và giá trị để cập nhật
    List<String> setClauses = [];
    List values = [];
    InstanceMirror instanceMirror = reflect(entity);

    for (var col in columns) {
      String name = MirrorSystem.getName(col.simpleName);
      if (name != idFieldName) {
        String columnName = (col.metadata.firstWhere((metadata) => metadata.reflectee is Column).reflectee as Column).columnName;
        setClauses.add(\'$columnName = ?\');
        values.add(instanceMirror.getField(col.simpleName).reflectee);
      }
    }

    // Lấy giá trị ID
    VariableMirror idField = columns.firstWhere((element) => MirrorSystem.getName(element.simpleName) == idFieldName);
    dynamic idValue = instanceMirror.getField(idField.simpleName).reflectee;

    // Tạo câu lệnh UPDATE
    String sql = \'UPDATE $tableName SET ${setClauses.join(\', \')} WHERE $idFieldName = ?\';
    values.add(idValue);

    try {
        db.execute(sql, values);
        return 1; // Trả về 1 nếu thành công
    } catch (e) {
      print(\'Error updating entity: $e\');
      return 0; // Trả về 0 nếu thất bại
    }
  }

  @override
  Future<int> delete(int id) async {
    final tableName = getTableName(entityType);
    final idFieldName = getIdFieldName(entityType);

    if (tableName == null || idFieldName == null) {
      throw Exception(\'Entity ${entityType} is not properly annotated.\');
    }

    try {
      db.execute(\'DELETE FROM $tableName WHERE $idFieldName = ?\', [id]);
      return 1; // Trả về 1 nếu thành công
    } catch (e) {
      print(\'Error deleting entity: $e\');
      return 0; // Trả về 0 nếu thất bại
    }
  }
}

