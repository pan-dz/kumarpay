import '../../domain/entities/user.dart';

class MockUserDataSource {
  Future<List<User>> getUsers() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    return [
      User(
        id: 1,
        name: '张三',
        email: 'zhangsan@example.com',
        phone: '13800138001',
        website: 'zhangsan.com',
      ),
      User(
        id: 2,
        name: '李四',
        email: 'lisi@example.com',
        phone: '13800138002',
        website: 'lisi.com',
      ),
      User(
        id: 3,
        name: '王五',
        email: 'wangwu@example.com',
        phone: '13800138003',
        website: 'wangwu.com',
      ),
      User(
        id: 4,
        name: '赵六',
        email: 'zhaoliu@example.com',
        phone: '13800138004',
        website: 'zhaoliu.com',
      ),
      User(
        id: 5,
        name: '钱七',
        email: 'qianqi@example.com',
        phone: '13800138005',
        website: 'qianqi.com',
      ),
    ];
  }
}