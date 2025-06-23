
class Entity {
  final String tableName;
  const Entity(this.tableName);
}

class Column {
  final String columnName;
  final String dataType;
  final bool isNullable;
  const Column(this.columnName, this.dataType, {this.isNullable = false});
}

class Id {
  const Id();
}

