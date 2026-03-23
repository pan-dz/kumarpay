///
/// 用户视图模型 - Presentation层
///
/// 在MVVM(Model-View-ViewModel)架构中，ViewModel(ViewModel)是连接View和Model的桥梁。
/// 它负责处理UI逻辑、状态管理和用户交互，同时保持与业务逻辑的解耦。
///
/// 设计决策：
/// 1. 使用Riverpod进行状态管理，提供响应式UI更新
/// 2. 定义不可变状态类(UserState)，确保状态一致性
/// 3. 将业务逻辑委托给用例(GetUserInfo)，保持ViewModel的简洁
/// 4. 提供清晰的加载、成功和错误状态
///
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_user_info.dart';
import '../../../core/di/providers.dart';

///
/// 用户状态类
///
/// 定义用户页面的所有可能状态，包括数据、加载状态和错误信息
///
class UserState {
  /// 用户列表数据
  final List<User> users;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息，null表示无错误
  final String? error;

  ///
  /// 用户状态构造函数
  ///
  /// @param users 用户列表，默认为空列表
  /// @param isLoading 加载状态，默认为false
  /// @param error 错误信息，默认为null
  ///
  UserState({this.users = const [], this.isLoading = false, this.error});

  ///
  /// 创建新状态，同时保留未更改的字段
  ///
  /// 这种模式使得状态更新更加安全和可预测
  ///
  /// @param users 新的用户列表，可选
  /// @param isLoading 新的加载状态，可选
  /// @param error 新的错误信息，可选
  /// @return UserState 新的状态实例
  ///
  UserState copyWith({List<User>? users, bool? isLoading, String? error}) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  ///
  /// 创建初始状态
  ///
  /// @return UserState 初始状态实例
  ///
  factory UserState.initial() => UserState();
}

///
/// 用户视图模型类
///
/// 继承自StateNotifier，负责管理用户状态和处理用户交互
///
class UserViewModel extends StateNotifier<UserState> {
  /// 获取用户信息用例依赖
  final GetUserInfo getUserInfo;

  ///
  /// 构造函数，接收获取用户信息用例作为依赖
  ///
  /// 初始状态为UserState.initial()
  ///
  /// @param getUserInfo 获取用户信息用例
  ///
  UserViewModel(this.getUserInfo) : super(UserState.initial());

  ///
  /// 加载用户列表
  ///
  /// 执行以下步骤：
  /// 1. 设置加载状态，清除之前的错误
  /// 2. 调用用例获取用户数据
  /// 3. 更新状态为成功或失败
  ///
  /// 这种方法确保UI始终反映当前的数据获取状态
  ///
  Future<void> loadUsers() async {
    // 设置加载状态，清除之前的错误
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 调用用例获取用户数据
      final users = await getUserInfo();

      // 更新状态为成功
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      // 更新状态为失败
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

///
/// 用户视图模型提供者
///
/// 使用Riverpod提供UserViewModel实例，确保依赖注入正确
///
final userViewModelProvider = StateNotifierProvider<UserViewModel, UserState>((
  ref,
) {
  // 从提供者中获取用例实例
  final useCase = ref.read(getUserInfoProvider);

  // 创建并返回ViewModel实例
  return UserViewModel(useCase);
});
