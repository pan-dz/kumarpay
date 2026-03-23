///
/// 用户仓库实现 - Data层
///
/// 在Clean Architecture中，仓库实现(Repository Implementation)负责协调不同的数据源，
/// 实现Domain层定义的仓库接口。它是Data层和Domain层之间的桥梁。
///
/// 设计决策：
/// 1. 实现Domain层的UserRepository接口，确保契约履行
/// 2. 组合多个数据源(远程和本地)，实现数据获取策略
/// 3. 处理数据转换，将数据模型转换为Domain实体
/// 4. 实现回退机制，当远程数据源失败时使用本地数据源
///
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../datasources/user_local_datasource.dart';

///
/// 用户仓库实现类
///
/// 实现UserRepository接口，提供用户数据的获取逻辑
///
class UserRepositoryImpl implements UserRepository {
  /// 远程数据源，用于从网络获取数据
  final UserRemoteDataSource remoteDataSource;

  /// 本地数据源，用于从本地存储获取数据
  final UserLocalDataSource localDataSource;

  ///
  /// 构造函数，接收远程和本地数据源作为依赖
  ///
  /// 这种依赖注入方式使得仓库可以与不同的数据源实现一起工作，
  /// 便于测试和灵活配置
  ///
  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  ///
  /// 获取用户信息列表
  ///
  /// 实现以下数据获取策略：
  /// 1. 首先尝试从远程数据源获取最新数据
  /// 2. 如果远程数据源失败，回退到本地数据源
  /// 3. 将数据模型转换为Domain实体
  ///
  /// 这种实现提供了良好的用户体验，即使在网络不可用的情况下也能显示数据
  ///
  /// @return Future<List<User>> 用户实体列表的Future对象
  ///
  @override
  Future<List<User>> getUserInfo() async {
    try {
      // 尝试从远程数据源获取数据
      final remoteUsers = await remoteDataSource.getUsers();
      return remoteUsers;
    } catch (e) {
      // 远程数据源失败时，回退到本地数据源
      return localDataSource.getUsers();
    }
  }
}
