///
/// 依赖注入提供者 - Core层
///
/// 在Clean Architecture中，依赖注入(Dependency Injection)是实现松耦合的关键技术。
/// 它允许我们在不修改代码的情况下替换实现，便于测试和维护。
///
/// 设计决策：
/// 1. 使用Riverpod的Provider进行依赖注入，提供类型安全和状态管理
/// 2. 按照依赖顺序定义提供者，确保依赖关系正确
/// 3. 遵循依赖反转原则，依赖抽象而非具体实现
/// 4. 每个提供者只负责创建一个对象，保持单一职责
///
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/datasources/user_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_user_info.dart';
import '../../domain/usecases/login.dart';
import '../../core/network/dio_client.dart';

///
/// Dio客户端提供者
///
/// 提供HTTP客户端实例，用于网络请求
///
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

///
/// 用户远程数据源提供者
///
/// 提供用户远程数据源实例，用于从API获取用户数据
/// 依赖于dioClientProvider，确保HTTP客户端可用
///
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>(
  (ref) => UserRemoteDataSource(ref.read(dioClientProvider)),
);

///
/// 用户本地数据源提供者
///
/// 提供用户本地数据源实例，用于从本地存储获取用户数据
/// 不依赖于其他提供者，是独立的本地数据源
///
final userLocalDataSourceProvider = Provider<UserLocalDataSource>(
  (ref) => UserLocalDataSource(),
);

///
/// 用户仓库实现提供者
///
/// 提供用户仓库实现实例，负责协调数据源
/// 依赖于远程和本地数据源提供者，实现数据获取策略
///
final userRepositoryImplProvider = Provider<UserRepositoryImpl>(
  (ref) => UserRepositoryImpl(
    remoteDataSource: ref.read(userRemoteDataSourceProvider),
    localDataSource: ref.read(userLocalDataSourceProvider),
  ),
);

///
/// 用户仓库接口提供者
///
/// 提供用户仓库接口实例，隐藏具体实现
/// 这种方式允许我们在不修改调用代码的情况下替换实现
///
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => ref.read(userRepositoryImplProvider),
);

///
/// 获取用户信息用例提供者
///
/// 提供获取用户信息用例实例，封装业务逻辑
/// 依赖于用户仓库提供者，实现业务规则
///
final getUserInfoProvider = Provider<GetUserInfo>(
  (ref) => GetUserInfo(ref.read(userRepositoryProvider)),
);

///
/// 认证远程数据源提供者
///
/// 提供认证远程数据源实例，用于从API执行认证操作
/// 依赖于dioClientProvider，确保HTTP客户端可用
///
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.read(dioClientProvider)),
);

///
/// 认证仓库实现提供者
///
/// 提供认证仓库实现实例，负责协调认证数据源
/// 依赖于远程数据源提供者
///
final authRepositoryImplProvider = Provider<AuthRepositoryImpl>(
  (ref) => AuthRepositoryImpl(authImpl: ref.read(authRemoteDataSourceProvider)),
);

///
/// 认证仓库接口提供者
///
/// 提供认证仓库接口实例，隐藏具体实现
///
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ref.read(authRepositoryImplProvider),
);

///
/// 登录用例提供者
///
/// 提供登录用例实例，封装登录业务逻辑
/// 依赖于认证仓库提供者
///
final loginProvider = Provider<Login>(
  (ref) => Login(ref.read(authRepositoryProvider)),
);
