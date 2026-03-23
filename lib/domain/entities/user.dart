///
/// 用户实体类 - Domain层
///
/// 在Clean Architecture中，实体(Entity)是业务规则的核心，代表企业范围内的业务对象。
/// 实体不应该被框架或外部因素影响，它们应该是最内层的、最纯粹的代码。
///
/// 设计决策：
/// 1. 使用不可变属性(final)，确保实体一旦创建就不能被修改，这有助于防止意外修改
/// 2. 使用required参数，确保创建实体时必须提供所有必要信息
/// 3. 不包含任何业务逻辑，只作为数据容器
/// 4. 不依赖任何框架或外部库，保持纯粹性
///
class User {
  /// 用户唯一标识符
  final int id;

  /// 用户姓名
  final String name;

  /// 用户电子邮箱
  final String email;

  /// 用户电话号码
  final String phone;

  /// 用户个人网站
  final String website;

  ///
  /// 用户实体构造函数
  ///
  /// 所有参数都是必需的，确保创建完整的用户实体
  ///
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.website,
  });
}
