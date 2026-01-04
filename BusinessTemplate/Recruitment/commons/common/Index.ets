export { GlobalContext } from './src/main/ets/basic/GlobalContext';

export { BaseViewModel } from './src/main/ets/basic/BaseViewModel';

export { Constants, TValueType, MOCK_ACCOUNT_LIST } from './src/main/ets/constant/Constants'

export { PreferenceConstant } from './src/main/ets/constant/PreferenceConstant'

export { RouterMap } from './src/main/ets/constant/RouterMap'

export { UserInfo, PopInfoResult, TabItem, JobApplicationData } from './src/main/ets/model/UserInfo';

export { DisplayModel } from './src/main/ets/model/DisplayModel';

export { BreakpointModel } from './src/main/ets/model/BreakpointModel';

export { BarVM } from './src/main/ets/model/BarVM'

export { AiBarHeight, StatusBarHeight, TempBarHeight } from './src/main/ets/model/AvoidArea'

export { AppStorageKeys } from './src/main/ets/constant/AppStorageKeys'

export { WindowUtils } from './src/main/ets/util/WindowUtils';

export { getInterviewTime } from './src/main/ets/util/DateUtil';

export { BreakpointUtils } from './src/main/ets/util/BreakpointUtils';

export { DeviceUtils } from './src/main/ets/util/DeviceUtils';

export { PreferenceUtil } from './src/main/ets/util/PreferenceUtil';

export { CacheUtil } from './src/main/ets/util/CacheUtil';

export { PermissionUtil } from './src/main/ets/util/PermissionUtil';

export { getString, getMedia, getColor } from './src/main/ets/util/ResManager';

export { CommonHeader } from './src/main/ets/ui/CommonHeader';

export { ProtocolWebView } from './src/main/ets/ui/ProtocolWebView';

export { SecureRandomUtil } from './src/main/ets/util/SecureRandomUtil';

export { PositionInfo,
  getMockPositionList,
  CompanyInfo,
  getMockCompanyList,
  getPositionById,
  getCompanyById,
  calculateDistance,
  filterNearbyPositions,
  getCommunicatedPositions,
  getAppliedPositions,
  getFavoritePositions,
  getFavoriteCompanies,
  togglePositionFavorite,
  toggleCompanyFavorite,
  getTotalFavoriteCount,
  getPositionByHR,
  CalendarId,
  updatePositionCommunicatedStatus,
  resetAllPositionStatus } from './src/main/ets/model/PositionModel'

export { PositionCard } from './src/main/ets/component/PositionCard'

export { CompanyCard } from './src/main/ets/component/CompanyCard'

export { InterviewCard } from './src/main/ets/component/InterviewCard'

export { WindowPopManager } from './src/main/ets/ui/window/WindowPopManager';

export { WindowParam } from './src/main/ets/ui/window/interface/WindowParam';

export { KickedDialogModel } from './src/main/ets/model/KickedDialogModel';

export { AccountDialogModel, MockAccountSingleModel } from './src/main/ets/model/AccountDialogModel';

export { KickedDialog } from './src/main/ets/ui/KickedDialog';

export { dialogMockAccountBuilder } from './src/main/ets/ui/MockAccountDialog';

export { CMPromptAction } from './src/main/ets/util/CMPromptAction';

export { OHDialog } from './src/main/ets/dialog/OHDialog';

export { OHDialogModel } from './src/main/ets/dialog/OHDialogModel';
