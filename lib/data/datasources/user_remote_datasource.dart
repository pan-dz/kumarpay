///
/// 用户远程数据源 - Data层
///
/// 在Clean Architecture中，数据源(DataSource)负责从具体的数据源(如网络API、数据库等)获取原始数据。
/// 它们是Data层的最外层，直接与外部系统交互。
///
/// 设计决策：
/// 1. 专注于数据获取，不包含业务逻辑
/// 2. 返回数据模型(UserModel)，而不是Domain实体
/// 3. 处理网络请求和响应转换
/// 4. 将特定异常转换为应用异常
///
import '../models/user_model.dart';
import '../../app/config/api.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/exceptions.dart';

///
/// 用户远程数据源类
///
/// 负责从远程API获取用户数据
///
class UserRemoteDataSource {
  /// Dio客户端依赖，用于执行HTTP请求
  final DioClient dioClient;

  ///
  /// 构造函数，接收Dio客户端作为依赖
  ///
  /// 这种依赖注入方式使得数据源可以与不同的网络实现一起工作，
  /// 便于测试和灵活配置
  ///
  UserRemoteDataSource(this.dioClient);

  ///
  /// 从远程API获取用户列表
  ///
  /// 这个方法执行以下步骤：
  /// 1. 使用Dio客户端发送GET请求到用户API端点
  /// 2. 将响应数据转换为UserModel对象列表
  /// 3. 处理可能的异常，将其转换为应用异常
  ///
  /// @return Future<List<UserModel>> 用户模型列表的Future对象
  /// @throws AppException 当API请求失败时抛出应用异常
  /// @throws UnknownException 当发生未知错误时抛出未知异常
  ///
  Future<List<UserModel>> getUsers() async {
    try {
      // 发送GET请求获取用户数据
      final response = await dioClient.get(Api.user);

      // 将响应数据列表转换为UserModel对象列表
      return (response.data as List).map((e) => UserModel.fromJson(e)).toList();
    } on AppException {
      // 如果已经是应用异常，直接重新抛出
      rethrow;
    } catch (e) {
      // 将其他异常转换为未知异常
      throw UnknownException('获取用户列表失败: $e');
    }
  }
}
