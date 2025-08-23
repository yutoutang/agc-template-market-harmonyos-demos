import { storageStatistics } from '@kit.CoreFileKit';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import fs from '@ohos.file.fs';
import { RouterModule, } from 'lib_foundation';
import { AppStorageBank, IUserInfo, UserInfo } from 'module_base'
import { userInfoData } from '../constants';

@ObservedV2
export class SettingPageVM {
  private static _instance: SettingPageVM;
  @Trace public size: number = 0
  @Trace isLogin: boolean = false
  @Trace userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;

  @Monitor('userInfo.id')
  onChange(monitor: IMonitor) {
    const id = monitor.value()?.now as number;
    this.checkLogin(id)
  }

  checkLogin(id: number) {
    if (id === 0) {
      this.isLogin = false
    } else {
      this.isLogin = true
    }
  }

  init() {
    this.checkLogin(this.userInfo.id)
  }

  public static get instance() {
    if (!SettingPageVM._instance) {
      SettingPageVM._instance = new SettingPageVM();
    }
    return SettingPageVM._instance;
  }

  public async logout() {
    AppStorageBank.updateUserInfo(userInfoData as IUserInfo)
    RouterModule.pop()
  }

  public async getCacheSize() {
    const bundleStats = await storageStatistics.getCurrentBundleStats()
    this.size = bundleStats.cacheSize //单位默认是B
  }

  // 3.清除缓存数据
  async clearCache() {
    AlertDialog.show(
      {
        title: '温馨提示',
        message: '缓存清除后不可恢复！',
        autoCancel: true,
        alignment: DialogAlignment.Bottom,
        gridCount: 4,
        offset: { dx: 0, dy: -20 },
        primaryButton: {
          value: '取消',
          action: () => {
          }
        },
        secondaryButton: {
          enabled: true,
          defaultFocus: true,
          style: DialogButtonStyle.HIGHLIGHT,
          value: '确定',
          action: () => {
            //用户点击确定后执行删除缓存逻辑
            let cacheDir = getContext(this).cacheDir;
            let fileList = fs.listFileSync(cacheDir) //获取缓存总目录下所有文件信息
            //循环依次判断如果待删除的缓存文件存在就执行删除操作
            fileList.forEach((item: string) => {
              let dirPath = cacheDir + '/' + item;
              // 判断是否为文件夹
              let isDirectory: boolean = false;
              try {
                isDirectory = fs.statSync(dirPath).isDirectory();
              } catch (e) {
                console.error(JSON.stringify(e));
              }
              if (isDirectory) {
                fs.rmdirSync(dirPath);
              } else {
                fs.unlink(dirPath).then(() => {
                  console.info('remove file succeed');
                }).catch((err: Error) => {
                  console.error('remove file failed with error message: ' + err.message);
                });
              }
            })
            promptAction.showToast({ message: '清除成功！' })
            this.getCacheSize()
          }
        }
      }
    )
  }
}
