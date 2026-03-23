///
/// 获取用户信息用例 - Domain层
///
/// 在Clean Architecture中，用例(Use Case)包含特定于应用程序的业务规则。
/// 它们协调实体和仓库接口之间的交互，实现具体的业务逻辑。
///
/// 设计决策：
/// 1. 每个用例只做一件事，符合单一职责原则
/// 2. 依赖抽象(Repository接口)，而不是具体实现
/// 3. 简单的call方法，便于在ViewModel中使用
/// 4. 不包含任何UI相关的代码
///
import '../repositories/user_repository.dart';
import '../entities/user.dart';

class GetUserInfo {
  /// 用户仓库接口依赖
  final UserRepository userRepository;

  ///
  /// 构造函数，接收用户仓库接口作为依赖
  ///
  /// 这种依赖注入方式使得用例可以与不同的仓库实现一起工作，
  /// 便于测试和灵活配置
  ///
  GetUserInfo(this.userRepository);

  ///
  /// 执行获取用户信息的业务逻辑
  ///
  /// 这个方法封装了获取用户信息的完整业务流程，
  /// 包括可能的错误处理、数据转换等
  ///
  /// @return Future<List<User>> 用户信息列表的Future对象
  ///
  Future<List<User>> call() async {
    return userRepository.getUserInfo();
  }
}
