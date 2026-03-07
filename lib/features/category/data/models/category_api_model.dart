import 'package:bazar/features/category/domain/entities/category_entity.dart';

class CategoryApiModel {
  final String? id;
  final String? categoryId;
  final String categoryName;


  CategoryApiModel({
    this.id,
    this.categoryId,
    required this.categoryName,
  });

  //toJSON
  Map<String,dynamic> toJson(){
    return {
      "categoryName" : categoryName
    };
  }


//fromJSON
  factory CategoryApiModel.fromJson(Map<String,dynamic> json){
    return CategoryApiModel(
      id: json['_id'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String,
    );
  }
  //toEntity
 CategoryEntity toEntity(){
    return CategoryEntity(
    categoryId: categoryId ?? id,
    categoryName: categoryName,
);
  }

  //fromEntity
  factory CategoryApiModel.fromEntity(CategoryEntity entity){
    return CategoryApiModel(categoryName: entity.categoryName);
  }

  //toEntityList
  static List<CategoryEntity> toEntityList(List<CategoryApiModel> models){
    return models.map((model) => model.toEntity()).toList();
  } 

  //fromEntityList
  static List<CategoryApiModel> fromEntityList(List<CategoryEntity> entities) {
    return entities.map((entity) => CategoryApiModel.fromEntity(entity)).toList();
  }
}