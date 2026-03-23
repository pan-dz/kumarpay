import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kumar_pay/domain/entities/user.dart';
import 'package:kumar_pay/domain/repositories/user_repository.dart';
import 'package:kumar_pay/domain/usecases/get_user_info.dart';

// 生成模拟类
@GenerateMocks([UserRepository])
import 'get_user_info_test.mocks.dart';

void main() {
  group('GetUserInfo用例测试', () {
    late MockUserRepository mockUserRepository;
    late GetUserInfo getUserInfo;
    late List<User> testUsers;

    setUp(() {
      mockUserRepository = MockUserRepository();
      getUserInfo = GetUserInfo(mockUserRepository);

      // 创建测试用户数据
      testUsers = [
        User(
          id: 1,
          name: '测试用户1',
          email: 'test1@example.com',
          phone: '13800138001',
          website: 'test1.com',
        ),
        User(
          id: 2,
          name: '测试用户2',
          email: 'test2@example.com',
          phone: '13800138002',
          website: 'test2.com',
        ),
      ];
    });

    test('调用仓库获取用户信息应该成功', () async {
      // 设置模拟仓库返回测试用户数据
      when(mockUserRepository.getUserInfo()).thenAnswer((_) async => testUsers);

      // 调用用例
      final result = await getUserInfo();

      // 验证结果
      expect(result, testUsers);
      expect(result.length, 2);
      expect(result[0].name, '测试用户1');
      expect(result[1].email, 'test2@example.com');

      // 验证仓库方法被调用
      verify(mockUserRepository.getUserInfo()).called(1);
    });

    test('仓库抛出异常时用例应该传播异常', () async {
      // 设置模拟仓库抛出异常
      const errorMessage = '网络连接失败';
      when(mockUserRepository.getUserInfo()).thenThrow(Exception(errorMessage));

      // 验证用例抛出相同异常
      expect(
        () => getUserInfo(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains(errorMessage),
          ),
        ),
      );

      // 验证仓库方法被调用
      verify(mockUserRepository.getUserInfo()).called(1);
    });

    test('仓库返回空列表时用例应该返回空列表', () async {
      // 设置模拟仓库返回空列表
      when(mockUserRepository.getUserInfo()).thenAnswer((_) async => []);

      // 调用用例
      final result = await getUserInfo();

      // 验证结果为空列表
      expect(result, isEmpty);
      expect(result.length, 0);

      // 验证仓库方法被调用
      verify(mockUserRepository.getUserInfo()).called(1);
    });

    test('多次调用用例应该多次调用仓库', () async {
      // 设置模拟仓库返回测试用户数据
      when(mockUserRepository.getUserInfo()).thenAnswer((_) async => testUsers);

      // 多次调用用例
      await getUserInfo();
      await getUserInfo();
      await getUserInfo();

      // 验证仓库方法被调用三次
      verify(mockUserRepository.getUserInfo()).called(3);
    });

    test('用例应该直接返回仓库结果而不做修改', () async {
      // 设置模拟仓库返回特定用户数据
      final specificUsers = [
        User(
          id: 99,
          name: '特定用户',
          email: 'specific@example.com',
          phone: '13900139000',
          website: 'specific.com',
        ),
      ];
      when(
        mockUserRepository.getUserInfo(),
      ).thenAnswer((_) async => specificUsers);

      // 调用用例
      final result = await getUserInfo();

      // 验证结果与仓库返回完全一致
      expect(result, same(specificUsers));
      expect(result[0].id, 99);
      expect(result[0].name, '特定用户');

      // 验证仓库方法被调用
      verify(mockUserRepository.getUserInfo()).called(1);
    });
  });
}
