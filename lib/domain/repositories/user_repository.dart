///
/// 用户仓库接口 - Domain层
///
/// 在Clean Architecture中，仓库(Repository)接口定义了如何访问数据，但不关心数据来源。
/// 它是Domain层和Data层之间的桥梁，实现了依赖反转原则。
///
/// 设计决策：
/// 1. 定义抽象接口，不包含具体实现，符合依赖反转原则
/// 2. 返回Domain实体(User)，而不是数据模型(UserModel)
/// 3. 使用Future处理异步操作，适应移动应用的网络环境
/// 4. 接口简单明了，只包含必要的方法
///
import '../entities/user.dart';

abstract class UserRepository {
  ///
  /// 获取用户信息列表
  ///
  /// 这个方法抽象了数据获取过程，调用者不需要知道数据来自网络、数据库还是缓存
  ///
  /// @return Future<List<User>> 用户信息列表的Future对象
  ///
  Future<List<User>> getUserInfo();
}
