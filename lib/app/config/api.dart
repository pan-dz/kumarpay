import 'package:flutter/foundation.dart';

const _env = String.fromEnvironment(
  'APP_ENV',
  defaultValue: kReleaseMode ? 'prod' : 'dev',
);
const _isTestEnv = _env == 'test' || _env == 'sit' || _env == 'dev';

const baseUrl = _isTestEnv
    ? 'https://backend.11kumar.click' // 测试环境
    : 'https://api.kumarpay-in.com'; // 生产环境
// const baseUrl = 'https://api.kumarpay-in.com';
const prefix = '/xxapi';

const apkDownloadUrl = _isTestEnv
    ? 'https://down.kumarpay-in.com/test/kumarpay-test.apk'
    : 'https://down.kumarpay-in.com/down/kumarpay.apk';

class Api {
  static const user = 'https://jsonplaceholder.typicode.com/users';
  static const post = 'https://jsonplaceholder.typicode.com/posts';
  static const comment = 'https://jsonplaceholder.typicode.com/comments';

  // 登陆注册
  static const login = '$baseUrl$prefix/login'; // 登陆
  static const register = '$baseUrl$prefix/register'; // 注册
  static const checkSmsNew = '$baseUrl$prefix/checkSmsNew'; // 校验验证码
  static const getSendToken = '$baseUrl$prefix/getsendtken'; // 获取发送验证码的token
  static const sendLoginSms = '$baseUrl$prefix/sendLoginSms'; // 发送登陆验证码
  static const accountPoolList = '$baseUrl$prefix/accountPool/list'; // 获取帐号池列表
  static const getCustomerByUserName =
      '$baseUrl$prefix/accountPool/getCustomerByUserName'; // 按用户名获取客服

  // 修改密码
  static const resetPwd = '$baseUrl$prefix/resetpassword'; // 重置密码
  static const sendSmsCode = '$baseUrl$prefix/sendsms'; // 发送验证码

  // 首页
  static const getAdjustId = '$baseUrl$prefix/adId'; // 获取 Adjust ID
  static const getHomeConfig = '$baseUrl$prefix/config'; // 首页配置信息
  static const waitconfirm =
      '$baseUrl$prefix/buyitoken/waitconfirm'; // 获取待确认订单列表
  static const unReadCount = '$baseUrl$prefix/unReadCount'; // 获取未读信息
  static const getSellInfo =
      '$baseUrl$prefix/userinfoAndAvailableCt'; // 获取Sell信息
  static const getCustomerService =
      '$baseUrl$prefix/accountPool/getCustomerService'; // 获取客服链接

  // 购买、售出
  static const buyOrderList =
      '$baseUrl$prefix/buyitoken/waitpayerpaymentslip'; // 购买订单列表
  static const getBuyUpiList =
      '$baseUrl$prefix/availablect?payment_method=0'; // 获取购买UPI列表
  static const buyIToken =
      '$baseUrl$prefix/buyitoken/pickuppaymentslip'; // 购买-获取付款单
  static const paymentslipDetail =
      '$baseUrl$prefix/buyitoken/paymentslipdetail'; // 付款单详情
  static const getUsdtList =
      'https://api.trongrid.io/v1/accounts/'; // 获取 USDT 列表
  static const getBuyUsdtList = '$baseUrl$prefix/buyUsdt/list'; // 获取usdt购买记录

  // upi
  static const upiList = '$baseUrl$prefix/collectiontoollist'; // UPI列表
  static const upiDetail = '$baseUrl$prefix/upidetail/'; // UPI详情
  static const monitorflowOne = '$baseUrl$prefix/monitorflow/one'; // 监控第一步
  static const monitorflowTwo = '$baseUrl$prefix/monitorflow/two'; // 监控第二步
  static const monitorflowThree = '$baseUrl$prefix/monitorflow/three'; // 监控第三步
  static const monitorflowCheck = '$baseUrl$prefix/monitorflow/check'; // 监控检查
  static const getCheckResult =
      '$baseUrl$prefix/monitorflow/two/getpreloginresult'; // 获取监控结果
  static const addUpi = '$baseUrl$prefix/collectiontool'; // 绑定UPI
  static const updateUpiStatus =
      '$baseUrl$prefix/collectiontoolStatus'; // 更新UPI状态
  static const getUpiDetails =
      '$baseUrl$prefix/collectiontool?id='; // 获取UPI详情信息
  static const stopSell = '$baseUrl$prefix/collectiontool/stopsell'; // 停止出售UPI
  static const startSell =
      '$baseUrl$prefix/collectiontool/startsell'; // 开启出售UPI

  // 我的
  static const userinfo = '$baseUrl$prefix/userinfo'; // 用户信息
  static const minSellIToken = '$baseUrl$prefix/minSellIToken'; // 最小出售IToken
  static const todayProfit = '$baseUrl$prefix/todayProfit'; // 团队今日利润
  static const customerservice = '$baseUrl$prefix/customerservice'; // 客服列表
  static const buyHistory = '$baseUrl$prefix/buyitoken/history'; // 购买历史
  static const buyUsdtNotify =
      '$baseUrl$prefix/buyUsdt/notify'; // USDT购买通知（后端使用这个接口查询usdt账单）

  static const processpaymentslips =
      '$baseUrl$prefix/buyitoken/processpaymentslips'; // 取消购买

  static const confirmPaid =
      '$baseUrl$prefix/buyitoken/processpaymentslips'; // 确认已付款
  static const sellHistory = '$baseUrl$prefix/sell/history'; // 售出历史
  static const transferTokenHistory =
      '$baseUrl$prefix/transferToken'; // token转交记录

  // 活动
  static const getTeamInfo = '$baseUrl$prefix/teaminfo'; // 三级代理 - 团队信息
  static const getTeamDailyData =
      '$baseUrl$prefix/teamDailyData'; // 三级代理 - 团队每日数据
  static const inviteFriends = '$baseUrl$prefix/oldRptNew/init'; // 三级代理 - 邀请好友
  static const inviteFriendsReward =
      '$baseUrl$prefix/inviteFriends/reward'; // 三级代理 - 领取奖励
  static const myTeamList = '$baseUrl$prefix/myTeam'; // 三级代理 - 我的团队

  static const newbieGuides = '$baseUrl$prefix/bguide/guides'; // 新手奖励 - 任务列表
  static const newbieReward = '$baseUrl$prefix/bguide/reward'; // 新手奖励 - 领取奖励
  static const activityCodeDone =
      '$baseUrl$prefix/bguide/activityCodeDone/'; // 完成新人任务

  // static const newbieTgChannel = '$baseUrl$prefix/bguide/activityCodeDone/newbie_tg_channel'; // 新手奖励 - 完成 TG 频道任务
  // static const newbieTgChannel = '$baseUrl$prefix/bguide/activityCodeDone/newbie_tg_customer'; // 新手奖励 - 完成 TG 频道任务
  // bguide/activityCodeDone/newbie_watch_video
}
