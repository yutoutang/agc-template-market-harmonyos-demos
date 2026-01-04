import { promptAction } from '@kit.ArkUI';
import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { getMockPositionList, PositionInfo, filterNearbyPositions, CompanyInfo } from 'common';

@ObservedV2
export class PositionPageVM {
  @Trace selectedTab: number = 0;
  @Trace selectedFilter: number = 0;
  @Trace selectedCount: number = 0;
  @Trace positionList: PositionInfo[] = getMockPositionList();
  @Trace selectedCity: string = '城市';
  @Trace currentLocation?: geoLocationManager.Location;

  initPositionList() {
    this.positionList = getMockPositionList()
  }

  // 请求定位权限
  async requestLocationPermission(): Promise<boolean> {
    const permissions: Array<Permissions> = [
      'ohos.permission.APPROXIMATELY_LOCATION',
      'ohos.permission.LOCATION'
    ];

    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const context = getContext(this) as common.UIAbilityContext;

      // 检查权限状态
      const grantStatus = await atManager.checkAccessToken(context.applicationInfo.accessTokenId, permissions[0]);

      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return true;
      }

      // 请求权限
      const result: PermissionRequestResult = await atManager.requestPermissionsFromUser(context, permissions);

      if (result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return true;
      } else {
        promptAction.showToast({
          message: '需要定位权限才能查看附近职位',
          duration: 2000
        });
        return false;
      }
    } catch (err) {
      promptAction.showToast({
        message: '请求权限失败',
        duration: 2000
      });
      return false;
    }
  }

  // 获取当前位置
  async getCurrentLocation() {
    // 先请求权限
    const hasPermission = await this.requestLocationPermission();
    if (!hasPermission) {
      return;
    }

    const request: geoLocationManager.SingleLocationRequest = {
      'locatingPriority': geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
      'locatingTimeoutMs': 10000
    };

    try {
      const result = await geoLocationManager.getCurrentLocation(request);
      this.currentLocation = result;

      // 根据经纬度筛选附近的职位
      this.filterNearbyPositionsByLocation(result.latitude, result.longitude);
      this.getCurrentCityByLocation(result.latitude, result.longitude)
    } catch (error) {
      promptAction.showToast({
        message: '获取位置失败',
        duration: 2000
      });
    }
  }

  getCurrentCityByLocation(latitude: number, longitude: number,) {
    let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest = { latitude, longitude, maxItems: 1 };
    try {
      geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest, (err, data) => {

        if (data) {

          this.selectedCity = data[0].locality!
        }
      });
    } catch (err) {

    }
  }

  // 筛选附近的职位
  filterNearbyPositionsByLocation(latitude: number, longitude: number, maxDistance: number = 10) {
    const nearbyPositions = filterNearbyPositions(latitude, longitude, maxDistance);

    if (nearbyPositions.length > 0) {
      this.positionList = nearbyPositions;
      promptAction.showToast({
        message: `找到 ${nearbyPositions.length} 个附近职位`,
        duration: 2000
      });
    } else {
      promptAction.showToast({
        message: `附近${maxDistance}公里内暂无职位`,
        duration: 2000
      });
      // 如果没有找到，恢复显示所有职位
      this.positionList = getMockPositionList();
    }
  }

  // 应用筛选条件
  applyFilter(selectedItems: string[]) {
    this.selectedCount = selectedItems.length;
    if (selectedItems.length === 0) {
      this.positionList = getMockPositionList();
      return;
    }
    const filterMap = this.parseFilterItems(selectedItems);
    const filteredPositions = this.filterPositions(filterMap);
    this.positionList = filteredPositions;
    promptAction.showToast({
      message: `找到 ${filteredPositions.length} 个符合条件的职位`,
      duration: 2000
    });
  }

  // 解析筛选条件
  private parseFilterItems(selectedItems: string[]): Map<string, string[]> {
    const filterMap = new Map<string, string[]>();

    selectedItems.forEach(item => {
      const parts = item.split('_');
      const categoryName = parts[0];
      const value = parts.slice(1).join('_');

      if (!filterMap.has(categoryName)) {
        filterMap.set(categoryName, []);
      }
      filterMap.get(categoryName)?.push(value);
    });

    return filterMap;
  }

  // 过滤职位列表
  private filterPositions(filterMap: Map<string, string[]>): PositionInfo[] {
    const allPositions = getMockPositionList();
    return allPositions.filter(position => this.matchesAllFilters(position, filterMap));
  }

  // 检查职位是否匹配所有筛选条件
  private matchesAllFilters(position: PositionInfo, filterMap: Map<string, string[]>): boolean {
    const company: CompanyInfo = position.getCompanyInfo()!;

    return this.matchesSalaryFilter(position.salary, filterMap) &&
    this.matchesIndustryFilter(company, filterMap) &&
    this.matchesNatureFilter(company, filterMap) &&
    this.matchesSizeFilter(company, filterMap) &&
    this.matchesJobTypeFilter(position.jobTitle, filterMap) &&
    this.matchesEducationFilter(position.education, filterMap);
  }

  // 匹配薪资筛选
  private matchesSalaryFilter(salary: string, filterMap: Map<string, string[]>): boolean {
    if (!filterMap.has('薪资区间')) {
      return true;
    }

    const salaryFilters = filterMap.get('薪资区间')!;
    return salaryFilters.includes('全部') || this.matchSalary(salary, salaryFilters);
  }

  // 匹配行业筛选
  private matchesIndustryFilter(company: CompanyInfo, filterMap: Map<string, string[]>): boolean {
    if (!filterMap.has('行业类型') || !company) {
      return true;
    }

    const industryFilters = filterMap.get('行业类型')!;
    return industryFilters.includes('全部') || industryFilters.includes(company.industry);
  }

  // 匹配公司性质筛选
  private matchesNatureFilter(company: CompanyInfo, filterMap: Map<string, string[]>): boolean {
    if (!filterMap.has('公司性质') || !company) {
      return true;
    }

    const natureFilters = filterMap.get('公司性质')!;
    return natureFilters.includes('全部') || natureFilters.includes(company.nature);
  }

  // 匹配公司规模筛选
  private matchesSizeFilter(company: CompanyInfo, filterMap: Map<string, string[]>): boolean {
    if (!filterMap.has('公司规模') || !company) {
      return true;
    }

    const sizeFilters = filterMap.get('公司规模')!;
    return sizeFilters.includes('全部') || sizeFilters.includes(company.companySize);
  }

  // 匹配职位类型筛选
  private matchesJobTypeFilter(jobTitle: string, filterMap: Map<string, string[]>): boolean {
    if (!filterMap.has('职位类型')) {
      return true;
    }

    const jobTypeFilters = filterMap.get('职位类型')!;
    return jobTypeFilters.includes('全部') || this.matchJobType(jobTitle, jobTypeFilters);
  }

  // 匹配学历筛选
  private matchesEducationFilter(education: string, filterMap: Map<string, string[]>): boolean {
    if (!filterMap.has('学历')) {
      return true;
    }

    const educationFilters = filterMap.get('学历')!;
    return educationFilters.includes('全部') || educationFilters.includes(education);
  }

  // 匹配薪资区间
  private matchSalary(salary: string, filters: string[]): boolean {
    // 提取薪资数字，例如 "15-20K" -> 15, 20

    const salaryMatch = salary.match(/(\d+)-(\d+)K/);
    if (!salaryMatch) {
      return false;
    }

    const minSalary = parseInt(salaryMatch[1]);
    const maxSalary = parseInt(salaryMatch[2]);
    const avgSalary = (minSalary + maxSalary) / 2;

    return filters.some(filter => {
      if (filter === '3K以下') {
        return avgSalary < 3;
      }
      if (filter === '3-5K') {
        return avgSalary >= 3 && avgSalary <= 5;
      }
      if (filter === '5-7K') {
        return avgSalary >= 5 && avgSalary <= 7;
      }
      if (filter === '7-9K') {
        return avgSalary >= 7 && avgSalary <= 9;
      }
      if (filter === '9-12K') {
        return avgSalary >= 9 && avgSalary <= 12;
      }
      if (filter === '12K以上') {
        return avgSalary > 12;
      }
      if (filter.indexOf('D') !== -1) {
        const filterArray = filter.split('D')[1].match(/(\d+)K-(\d+)K/);
        return (minSalary >= parseInt(filterArray![1]) && minSalary <= parseInt(filterArray![2])) ||
          (maxSalary >= parseInt(filterArray![1]) && maxSalary <= parseInt(filterArray![2]));
      }
      return false;
    });
  }

  // 匹配职位类型
  private matchJobType(jobTitle: string, filters: string[]): boolean {
    return filters.some(filter => {
      // 简单的关键词匹配
      return jobTitle.includes(filter) || filter.includes(jobTitle);
    });
  }
}