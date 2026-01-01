class HiveTableConstant {
  // Private constructor
  HiveTableConstant._();

  // Database name
  static const String dbName = "bazar_db";

  // Tables -> Box : Index
  static const int roleTypeId = 0;
  static const String roleTable = "role_table";

  static const int userTypeId = 1;
  static const String userTable = "user_table";

  static const int shopTypeId = 2;
  static const String shopTable = "shop_table";

  static const int categoryTypeId = 3;
  static const String categoryTable = "category_table";

  static const int shopinfoTypeId = 4;
  static const String shopinfoTable = "shopinfo_table";
}