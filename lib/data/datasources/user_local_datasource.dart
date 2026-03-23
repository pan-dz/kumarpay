import '../../domain/entities/user.dart';
import '../../core/exceptions/app_exception.dart';

/// 本地数据源
/// 
/// 职责：
/// - 从本地存储获取用户数据
/// - 提供离线数据访问能力
/// - 作为远程数据源的备用方案
/// 
/// 设计决策：
/// - 返回Domain层User实体，保持架构一致性
/// - 抛出统一的AppException异常，便于上层处理
/// - 简单实现，仅用于演示，实际项目中可使用SharedPreferences等
class UserLocalDataSource {
  /// 获取用户信息
  /// 
  /// 返回本地存储的用户列表
  /// 
  /// 抛出：
  /// - [AppException] 当本地数据访问失败时
  Future<List<User>> getUsers() async {
    // 模拟从本地存储获取用户数据
    // 实际项目中可使用SharedPreferences、Hive、SQLite等
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      User(id: 1, name: '本地用户1', email: 'local1@example.com', phone: '13800138001', website: 'local1.com'),
      User(id: 2, name: '本地用户2', email: 'local2@example.com', phone: '13800138002', website: 'local2.com'),
    ];
  }
}