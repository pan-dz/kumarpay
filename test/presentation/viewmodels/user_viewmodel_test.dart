import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kumar_pay/domain/entities/user.dart';
import 'package:kumar_pay/domain/usecases/get_user_info.dart';
import 'package:kumar_pay/presentation/viewmodels/user_viewmodel.dart';

// 生成模拟类
@GenerateMocks([GetUserInfo])
import 'user_viewmodel_test.mocks.dart';

void main() {
  group('UserViewModel测试', () {
    late MockGetUserInfo mockGetUserInfo;
    late UserViewModel userViewModel;
    late List<User> testUsers;

    setUp(() {
      mockGetUserInfo = MockGetUserInfo();
      userViewModel = UserViewModel(mockGetUserInfo);

      // 创建测试用户数据
      testUsers = [
        User(
          id: 1,
          name: '张三',
          email: 'zhangsan@example.com',
          phone: '13800138000',
          website: 'zhangsan.com',
        ),
        User(
          id: 2,
          name: '李四',
          email: 'lisi@example.com',
          phone: '13800138001',
          website: 'lisi.com',
        ),
      ];
    });

    test('初始状态应该是正确的', () {
      // 验证初始状态
      expect(userViewModel.state.users.isEmpty, true);
      expect(userViewModel.state.isLoading, false);
      expect(userViewModel.state.error, null);
    });

    test('加载用户成功时应该更新状态', () async {
      // 设置模拟用例返回测试用户数据
      when(mockGetUserInfo()).thenAnswer((_) async => testUsers);

      // 调用加载用户方法
      await userViewModel.loadUsers();

      // 验证状态更新
      expect(userViewModel.state.users, testUsers);
      expect(userViewModel.state.isLoading, false);
      expect(userViewModel.state.error, null);

      // 验证用例被调用
      verify(mockGetUserInfo()).called(1);
    });

    test('加载用户失败时应该更新错误状态', () async {
      // 设置模拟用例抛出异常
      const errorMessage = '网络错误';
      when(mockGetUserInfo()).thenThrow(Exception(errorMessage));

      // 调用加载用户方法
      await userViewModel.loadUsers();

      // 验证状态更新
      expect(userViewModel.state.users.isEmpty, true);
      expect(userViewModel.state.isLoading, false);
      expect(userViewModel.state.error, contains(errorMessage));

      // 验证用例被调用
      verify(mockGetUserInfo()).called(1);
    });

    test('加载过程中应该设置加载状态', () async {
      // 设置模拟用例延迟返回
      when(mockGetUserInfo()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return testUsers;
      });

      // 开始加载但不等待完成
      final loadFuture = userViewModel.loadUsers();

      // 验证加载状态
      expect(userViewModel.state.isLoading, true);
      expect(userViewModel.state.error, null);

      // 等待加载完成
      await loadFuture;

      // 验证最终状态
      expect(userViewModel.state.isLoading, false);
      expect(userViewModel.state.users, testUsers);
    });

    test('多次加载应该覆盖之前的状态', () async {
      // 第一次加载
      when(mockGetUserInfo()).thenAnswer((_) async => testUsers);
      await userViewModel.loadUsers();

      // 验证第一次加载结果
      expect(userViewModel.state.users, testUsers);

      // 第二次加载空列表
      when(mockGetUserInfo()).thenAnswer((_) async => []);
      await userViewModel.loadUsers();

      // 验证第二次加载结果覆盖了第一次
      expect(userViewModel.state.users.isEmpty, true);
      expect(userViewModel.state.isLoading, false);
      expect(userViewModel.state.error, null);

      // 验证用例被调用两次
      verify(mockGetUserInfo()).called(2);
    });
  });
}
