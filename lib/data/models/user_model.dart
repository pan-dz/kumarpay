///
/// 用户数据模型 - Data层
///
/// 在Clean Architecture中，数据模型(Data Model)负责将外部数据源的数据转换为应用内部可用的格式。
/// 它们通常包含序列化/反序列化逻辑，以及与API响应格式的映射。
///
/// 设计决策：
/// 1. 继承自Domain实体(User)，实现"is-a"关系，确保类型兼容性
/// 2. 使用json_annotation库实现自动序列化/反序列化
/// 3. 保持与API响应格式一致的字段名
/// 4. 不包含业务逻辑，只负责数据转换
///
import '../../domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';

/// 指示代码生成器生成序列化代码
part 'user_model.g.dart';

///
/// 用户数据模型类
///
/// 使用@JsonSerializable注解标记，以便json_serializable包自动生成序列化代码
///
@JsonSerializable()
class UserModel extends User {
  ///
  /// 用户模型构造函数
  ///
  /// 使用super关键字将参数传递给父类(User)构造函数
  ///
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.website,
  });

  ///
  /// 从JSON创建用户模型实例
  ///
  /// 这个方法由json_serializable代码生成器实现，用于将API响应转换为UserModel对象
  ///
  /// @param json 包含用户数据的JSON映射
  /// @return UserModel 用户模型实例
  ///
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  ///
  /// 将用户模型转换为JSON
  ///
  /// 这个方法由json_serializable代码生成器实现，用于将UserModel对象转换为JSON格式
  ///
  /// @return Map<String, dynamic> 用户数据的JSON映射
  ///
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
