import 'package:kumar_pay/store/models/active/active_req_model.dart';
import 'package:kumar_pay/store/models/active/active_res_model.dart';
import 'package:kumar_pay/store/request/active/active_api.dart';

class ActiveActions {
  final ActiveStoreApi activeStore;
  ActiveActions(this.activeStore);

  /// 新手奖励
  Future<INewbieGuidesResModel> newbieGuidesApi() async {
    return activeStore.newbieGuidesRequest();
  }

  /// 新手奖励 - 领取奖励
  Future<IInviteFriendsRewardResModel> newbieRewardApi() async {
    return activeStore.newbieRewardRequest();
  }

  /// 邀请好友
  Future<IInviteFriendsResModel> inviteFriendsApi() async {
    return activeStore.inviteFriendsRequest();
  }

  /// 邀请好友 - 领取奖励
  Future<IInviteFriendsRewardResModel> inviteFriendsRewardApi({
    required String activityCode,
  }) async {
    return activeStore.inviteFriendsRewardRequest(activityCode: activityCode);
  }

  /// 邀请好友 - 完成任务
  Future<IInviteFriendsRewardResModel> activityCodeDoneApi({
    required String activityCode,
  }) async {
    return activeStore.activityCodeDoneRequest(activityCode: activityCode);
  }

  /// 团队信息
  Future<ITeamInfoResModel> getTeamInfoApi() async {
    return activeStore.getTeamInfoRequest();
  }

  /// 团队每日数据
  Future<ITeamDailyDataResModel> getTeamDailyDataApi({required int day}) async {
    return activeStore.getTeamDailyDataRequest(day: day);
  }

  /// 我的团队列表
  Future<IMyTeamListResModel> myTeamListApi(IMyTeamListReqModel request) async {
    return activeStore.myTeamListRequest(request);
  }
}
