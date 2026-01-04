let idCounter = 0;

@ObservedV2
export class PositionInfo {
  @Trace id: string = '';
  @Trace jobTitle: string = '';
  @Trace salary: string = '';
  @Trace companyName: string = '';
  @Trace companyId: string = '';
  @Trace experience: string = '';
  @Trace education: string = '';
  @Trace hrUserId: string = ''; // HR的用户ID，用于聊天
  @Trace hrName: string = '';
  @Trace hrTitle: string = '';
  @Trace location: string = '';
  @Trace latitude: number = 0;
  @Trace longitude: number = 0;
  @Trace avatar: string = '';
  @Trace isFavorite: boolean = false;
  @Trace isApplied: boolean = false;
  @Trace isCommunicated: boolean = false; // 是否已沟通
  @Trace communicatedTime: number = 0; // 沟通时间戳，用于记录最后一次沟通时间

  constructor(
    jobTitle: string,
    salary: string,
    companyName: string,
    experience: string,
    education: string,
    hrUserId: string,
    hrName: string,
    hrTitle: string,
    location: string,
    latitude: number,
    longitude: number,
    companyId: string = '',
    avatar: string = '',
    isFavorite: boolean = false,
    isApplied: boolean = false,
    isCommunicated: boolean = false,
    communicatedTime: number = 0
  ) {
    this.id = `position_${Date.now()}_${idCounter++}`;
    this.jobTitle = jobTitle;
    this.salary = salary;
    this.companyName = companyName;
    this.companyId = companyId;
    this.experience = experience;
    this.education = education;
    this.hrName = hrName;
    this.hrTitle = hrTitle;
    this.hrUserId = hrUserId || `hr_${hrName}_${Date.now()}`; // 如果没有提供，生成一个默认ID
    this.location = location;
    this.latitude = latitude;
    this.longitude = longitude;
    this.avatar = avatar;
    this.isFavorite = isFavorite;
    this.isApplied = isApplied;
    this.isCommunicated = isCommunicated;
    this.communicatedTime = communicatedTime;
  }

  /**
   * 获取该职位所属的公司完整信息
   * @returns 公司信息，如果未找到则返回 undefined
   */
  getCompanyInfo(): CompanyInfo | undefined {
    return getCompanyById(this.companyId);
  }
}

@ObservedV2
export class CompanyInfo {
  @Trace id: string = '';
  @Trace companyName: string = '';
  @Trace companySize: string = '';
  @Trace industry: string = '';
  @Trace nature: string = '';
  @Trace positions: PositionInfo[] = [];
  @Trace logo: string = '';
  @Trace isFavorite: boolean = false;

  constructor(
    companyName: string,
    companySize: string,
    industry: string,
    nature: string,
    positions: PositionInfo[] = [],
    logo: string = '',
    isFavorite: boolean = false
  ) {
    this.id = `company_${Date.now()}_${idCounter++}`;
    this.companyName = companyName;
    this.companySize = companySize;
    this.industry = industry;
    this.nature = nature;
    this.positions = positions;
    this.logo = logo;
    this.isFavorite = isFavorite;
  }
}

// 全局公司列表
let mockCompanyList: CompanyInfo[] = [];

function initMockData() {
  if (mockCompanyList.length > 0) {
    return;
  }

  // 先创建公司（不带职位）
  const companyA = new CompanyInfo('A软件技术有限公司', '1000-9999人', '互联网', '私企', []);
  const companyB = new CompanyInfo('B软件技术有限公司', '20-99人', '互联网', '私企', []);
  const companyC = new CompanyInfo('C软件技术有限公司', '100-499人', '人工智能', '国企', []);
  const companyD = new CompanyInfo('D软件技术有限公司', '1000-9999人', '计算机软件', '私企', []);

  // 为每个公司创建职位，并关联公司ID
  companyA.positions = [
    new PositionInfo('测试工程师', '15-20K', 'A软件技术有限公司', '3-5年', '本科', 'user_six', '张女士', 'HR',
      '软件大道',
      31.9897, 118.7969, companyA.id),
    new PositionInfo('前端工程师', '18-25K', 'A软件技术有限公司', '3-5年', '本科', 'user_six', '张女士', 'HR',
      '软件大道', 31.9910,
      118.7980, companyA.id),
    new PositionInfo('产品经理', '20-30K', 'A软件技术有限公司', '5-10年', '本科', 'user_six', '张女士', 'HR',
      '软件大道', 31.9885,
      118.7955, companyA.id)
  ];

  companyB.positions = [
    new PositionInfo('Java工程师', '20-35K', 'B软件技术有限公司', '3-5年', '本科', 'user_three', '赵女士', 'HR',
      '高新区', 32.0500,
      118.7800, companyB.id),
    new PositionInfo('测试工程师', '15-20K', 'B软件技术有限公司', '3-5年', '本科', 'user_three', '赵女士', 'HR',
      '高新区', 32.0520,
      118.7820, companyB.id)
  ];

  companyC.positions = [
    new PositionInfo('C＃', '18-28K', 'C软件技术有限公司', '3-5年', '本科', 'user_four', '刘先生', 'HR', '金融街',
      32.0400,
      118.7600, companyC.id),
    new PositionInfo('C/C++', '35-50K', 'C软件技术有限公司', '5-10年', '硕士', 'user_four', '刘先生', 'HR', '金融街',
      32.0420,
      118.7620, companyC.id),
    new PositionInfo('开发工程实习生', '3-5K', 'C软件技术有限公司', '1-3年', '本科', 'user_four', '刘先生', 'HR',
      '金融街', 32.0380,
      118.7580, companyC.id)
  ];

  companyD.positions = [
    new PositionInfo('开发工程师', '22-30K', 'D软件技术有限公司', '3-5年', '本科', 'user_five', '孙女士', 'HR',
      '秣周东路',
      31.874986, 118.837794, companyD.id),
    new PositionInfo('运维工程师', '18-25K', 'D软件技术有限公司', '3-5年', '本科', 'user_five', '孙女士', 'HR',
      '秣周东路',
      31.874986, 118.837794, companyD.id)
  ];

  mockCompanyList = [companyA, companyB, companyC, companyD];
}

export function getMockCompanyList(): CompanyInfo[] {
  initMockData();
  return mockCompanyList;
}

export function getMockPositionList(): PositionInfo[] {
  initMockData();
  const allPositions: PositionInfo[] = [];
  mockCompanyList.forEach(company => {
    allPositions.push(...company.positions);
  });
  return allPositions;
}

export function getPositionById(id: string): PositionInfo | undefined {
  const allPositions = getMockPositionList();
  return allPositions.find(position => position.id === id);
}

export function getCompanyById(id: string): CompanyInfo | undefined {
  const allCompanies = getMockCompanyList();
  return allCompanies.find(company => company.id === id);
}

/**
 * 职位与距离的组合类型
 */
interface PositionWithDistance {
  position: PositionInfo;
  distance: number;
}

/**
 * 计算两个坐标点之间的距离（单位：公里）
 * 使用 Haversine 公式
 */
export function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371; // 地球半径（公里）
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c;
  return distance;
}

/**
 * 根据当前位置筛选附近的职位
 * @param latitude 当前纬度
 * @param longitude 当前经度
 * @param maxDistance 最大距离（公里），默认10公里
 * @returns 附近的职位列表，按距离排序
 */
export function filterNearbyPositions(
  latitude: number,
  longitude: number,
  maxDistance: number = 10
): PositionInfo[] {
  const allPositions = getMockPositionList();

  // 计算每个职位的距离并筛选
  const nearbyPositions = allPositions
    .map((position): PositionWithDistance => {
      return {
        position: position,
        distance: calculateDistance(latitude, longitude, position.latitude, position.longitude)
      };
    })
    .filter((item: PositionWithDistance) => item.distance <= maxDistance)
    .sort((a: PositionWithDistance, b: PositionWithDistance) => a.distance - b.distance)
    .map((item: PositionWithDistance) => item.position);

  return nearbyPositions;
}

/**
 * 获取所有沟通过的职位
 * @returns 沟通过的职位列表
 */
export function getCommunicatedPositions(): PositionInfo[] {
  const allPositions = getMockPositionList();
  return allPositions.filter(position => position.isCommunicated);
}

/**
 * 获取所有已投递的职位
 * @returns 已投递的职位列表
 */
export function getAppliedPositions(): PositionInfo[] {
  const allPositions = getMockPositionList();
  return allPositions.filter(position => position.isApplied);
}

/**
 * 获取所有已收藏的职位
 * @returns 已收藏的职位列表
 */
export function getFavoritePositions(): PositionInfo[] {
  const allPositions = getMockPositionList();
  return allPositions.filter(position => position.isFavorite);
}

/**
 * 获取所有已收藏的公司
 * @returns 已收藏的公司列表
 */
export function getFavoriteCompanies(): CompanyInfo[] {
  const allCompanies = getMockCompanyList();
  return allCompanies.filter(company => company.isFavorite);
}

/**
 * 切换职位的收藏状态
 * @param positionId 职位ID
 * @returns 切换后的收藏状态
 */
export function togglePositionFavorite(positionId: string): boolean {
  const position = getPositionById(positionId);
  if (position) {
    position.isFavorite = !position.isFavorite;
    return position.isFavorite;
  }
  return false;
}

/**
 * 切换公司的收藏状态
 * @param companyId 公司ID
 * @returns 切换后的收藏状态
 */
export function toggleCompanyFavorite(companyId: string): boolean {
  const company = getCompanyById(companyId);
  if (company) {
    company.isFavorite = !company.isFavorite;
    return company.isFavorite;
  }
  return false;
}

/**
 * 获取收藏总数（职位+公司）
 * @returns 收藏总数
 */
export function getTotalFavoriteCount(): number {
  const favoritePositionsCount = getFavoritePositions().length;
  const favoriteCompaniesCount = getFavoriteCompanies().length;
  return favoritePositionsCount + favoriteCompaniesCount;
}

/**
 * 根据 HR 用户ID 获取最近一次沟通的职位
 * 如果该 HR 有已沟通的职位，返回沟通时间最新的职位
 * 否则返回该 HR 所在公司的第一个职位
 * @param hrUserId HR 用户ID
 * @returns 职位信息，如果未找到则返回 undefined
 */
export function getPositionByHR(hrUserId: string): PositionInfo | undefined {
  const allPositions = getMockPositionList();

  // 找到该 HR 的所有职位
  const hrPositions = allPositions.filter(position => position.hrUserId === hrUserId);

  if (hrPositions.length === 0) {
    return undefined;
  }

  // 查找已沟通的职位，按沟通时间降序排序
  const communicatedPositions = hrPositions
    .filter(position => position.isCommunicated && position.communicatedTime > 0)
    .sort((a, b) => b.communicatedTime - a.communicatedTime);

  // 如果有已沟通的职位，返回最新的；否则返回该 HR 所在公司的第一个职位
  return communicatedPositions.length > 0 ? communicatedPositions[0] : hrPositions[0];
}

/**
 * 更新职位的沟通状态和沟通时间
 * @param positionId 职位ID
 * @returns 是否更新成功
 */
export function updatePositionCommunicatedStatus(positionId: string): boolean {
  const position = getPositionById(positionId);
  if (position) {
    position.isCommunicated = true;
    position.communicatedTime = Date.now();
    return true;
  }
  return false;
}

/**
 * 重置所有职位和公司的状态
 * 包括：收藏、投递、沟通状态
 */
export function resetAllPositionStatus(): void {
  const allPositions = getMockPositionList();
  const allCompanies = getMockCompanyList();

  // 重置所有职位的状态
  allPositions.forEach(position => {
    position.isFavorite = false;
    position.isApplied = false;
    position.isCommunicated = false;
    position.communicatedTime = 0;
  });

  // 重置所有公司的收藏状态
  allCompanies.forEach(company => {
    company.isFavorite = false;
  });
}

@ObservedV2
export class CalendarId {
  @Trace ids: Array<string> = [];
}


