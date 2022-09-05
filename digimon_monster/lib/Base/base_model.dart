class BaseModel {
  String tableName() {
    return "TABLE_NAME";
  }

  Map<String, String> paramaDBMap() {
    return {};
  }

  Map<String, dynamic> toJsonMap() {
    return {};
  }
}
