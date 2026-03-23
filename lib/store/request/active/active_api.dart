import 'package:kumar_pay/app/config/api.dart';
import 'package:kumar_pay/core/error/exceptions.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/store/models/active/active_req_model.dart';
import 'package:kumar_pay/store/models/active/active_res_model.dart';

class ActiveStoreApi {
  final DioClient dioClient;
  ActiveStoreApi(this.dioClient);

  /// 新手奖励
  Future<INewbieGuidesResModel> newbieGuidesRequest() async {
    try {
      final response = await dioClient.get(Api.newbieGuides);
      return INewbieGuidesResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: newbieGuidesRequest');
    }
  }

  /// 新手奖励 - 领取奖励
  Future<IInviteFriendsRewardResModel> newbieRewardRequest() async {
    try {
      final response = await dioClient.post(Api.newbieReward);
      return IInviteFriendsRewardResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: newbieRewardRequest');
    }
  }

  /// 邀请好友
  Future<IInviteFriendsResModel> inviteFriendsRequest() async {
    try {
      final response = await dioClient.get(Api.inviteFriends);
      return IInviteFriendsResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: inviteFriendsRequest');
    }
  }

  /// 邀请好友 - 领取奖励
  Future<IInviteFriendsRewardResModel> inviteFriendsRewardRequest({
    required String activityCode,
  }) async {
    try {
      final response = await dioClient.post(
        Api.inviteFriendsReward,
        // data: {'activityCode': activityCode},
      );
      return IInviteFriendsRewardResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: inviteFriendsRewardRequest');
    }
  }

  /// 邀请好友 - 完成任务
  Future<IInviteFriendsRewardResModel> activityCodeDoneRequest({
    required String activityCode,
  }) async {
    try {
      final response = await dioClient.get(
        '${Api.activityCodeDone}$activityCode',
      );
      return IInviteFriendsRewardResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: activityCodeDoneRequest');
    }
  }

  /// 团队信息
  Future<ITeamInfoResModel> getTeamInfoRequest() async {
    try {
      final response = await dioClient.get(Api.getTeamInfo);
      return ITeamInfoResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getTeamInfoRequest');
    }
  }

  /// 团队每日数据
  Future<ITeamDailyDataResModel> getTeamDailyDataRequest({
    required int day,
  }) async {
    try {
      final response = await dioClient.get('${Api.getTeamDailyData}/$day');
      return ITeamDailyDataResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getTeamDailyDataRequest');
    }
  }

  /// 我的团队列表
  Future<IMyTeamListResModel> myTeamListRequest(
    IMyTeamListReqModel request,
  ) async {
    try {
      final response = await dioClient.get(
        Api.myTeamList,
        queryParameters: request.toQueryParameters(),
      );
      return IMyTeamListResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: myTeamListRequest');
    }
  }
}
