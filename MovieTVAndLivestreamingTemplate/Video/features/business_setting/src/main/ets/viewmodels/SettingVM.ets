import { promptAction } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import {
  BaseViewModel,
  CommonConfirmDialog,
  FileUtils,
  Logger,
  RouterMap,
  RouterUtils,
  SystemBarOperation
} from 'lib_common';
import { AccountApi } from 'lib_account';
import { SettingItem } from '../types/Types';
import fs from '@ohos.file.fs';

const TAG = '[SettingViewModel]'

@ObservedV2
export class SettingViewModel extends BaseViewModel {
  @Trace isLoading: boolean = false;
  @Trace cacheSize: string = '10';
  @Trace location: string = '/storage/emulated/0/Download/Music/'
  @Trace teenagers: string = this.settingInfo.teenagersSwitch ? '已开启' : '未开启'
  @Trace oldPhone: string = ''; // 旧手机号
  @Trace newPhone: string = ''; // 新手机号
  @Trace newPassword: string = ''; // 旧手机号
  @Trace surePassword: string = ''; // 新手机号
  @Trace verifyCode: string = ''; // 验证码
  @Trace codeBtnDisabled: boolean = false; // “获取验证码”按钮是否禁用
  @Trace codeBtnText: string = '获取验证码'; // “获取验证码”按钮文字
  stack: NavPathStack = new NavPathStack();
  @Trace teenagersSettingItem = new SettingItem({
    label: '未成年模式',
    typeSwitch: true,
    switchV: this.settingInfo.teenagersSwitch,
    onClick: (isOn) => {
      this.settingInfo.teenagersSwitch = isOn as boolean;
      if (this.settingInfo.teenagersSwitch) {
        CommonConfirmDialog.show({
          primaryTitle: '温馨提示',
          content: '未成年模式下，仅可播放少儿频道内容',
          secBtnV: '确认开启',
          secBtnFg: $r('sys.color.warning'),
          confirm: () => {
            this.settingInfo.teenagersSwitch = true;
          },
          cancel: () => {
            this.settingInfo.teenagersSwitch = false;
            this.teenagersSettingItem.switchV = false
          }
        })
      }
    },
  });
  @Trace userSettingItem = new SettingItem({
    label: '用户协议',
    routerName: RouterMap.SETTING_H5,
    routerParams: 1,
  });
  @Trace privacySettingItem = new SettingItem({
    label: '隐私政策',
    routerName: RouterMap.SETTING_H5,
    routerParams: 2,
  });
  @Trace aboutSettingItem = new SettingItem({
    label: '关于我们',
    routerName: RouterMap.SETTING_ABOUT,
  })
  @Trace cacheSettingItem = new SettingItem({
    label: '清理缓存',
    extraLabel: this.getLocalCacheLabel(),
    onClick: () => {

      this.cacheSettingItem.extraLabel = this.getLocalCacheLabel();
      CommonConfirmDialog.show({
        primaryTitle: '清理缓存',
        content: '您确定要清除缓存吗？(该操作不会删除已缓的视频）',
        secBtnV: '确认',
        secBtnFg: $r('sys.color.warning'),
        confirm: () => {
          const cacheDir = getContext().cacheDir;

          fs.listFile(cacheDir).then((filenames) => {
            this.cacheSize = '0';
            this.cacheSettingItem.extraLabel = this.getLocalCacheLabel();
            for (let i = 0; i < filenames.length; i++) {
              let dirPath = cacheDir + '/' + filenames[i];

              let isDirectory: boolean = false;
              try {
                isDirectory = fs.statSync(dirPath).isDirectory();
              } catch (e) {
              }
              if (isDirectory) {
                fs.rmdirSync(dirPath);
              } else {
                fs.unlink(dirPath).then(() => {
                  Logger.info(TAG, 'fs.unlink success')
                }).catch((err: Error) => {
                  Logger.info(TAG, 'fs.unlink error： ' + JSON.stringify(err))
                })
              }
            }
          })
        }
      })
    }
  })
  @Trace pushSettingItem = new SettingItem({
    label: '通知开关',
    typeSwitch: true,
    switchV: this.settingInfo.pushSwitch,
    onClick: (isOn) => {
      this.settingInfo.pushSwitch = isOn as boolean;
      this.pushSettingItem.switchV = isOn as boolean;
    },
  });
  @Trace list1: SettingItem[] = [
    new SettingItem({
      label: '个人信息',
      routerName: RouterMap.SETTING_PERSONAL,
      onClick: () => {
        if (this.userInfoModel.isLogin) {
          RouterUtils.pushPathByName(RouterMap.SETTING_PERSONAL);
        } else {
          promptAction.showToast({ message: '请先登录' });
        }
      },
    }),
    new SettingItem({
      label: '账号与安全',
      routerName: RouterMap.SETTING_ACCOUNT_SECURITY,
      onClick: () => {
        if (this.userInfoModel.isLogin) {
          RouterUtils.pushPathByName(RouterMap.SETTING_ACCOUNT_SECURITY);
        } else {
          promptAction.showToast({ message: '请先登录' });
        }
      },
    }),

    new SettingItem({
      label: '隐私设置',
      routerName: RouterMap.SETTING_PRIVACY,
    }),
  ];
  @Trace list2: SettingItem[] = [
    new SettingItem({
      label: '通知设置',
      extraLabel: '去设置',
      routerName: RouterMap.NOTIFICATION_PAGE,
    }),
    this.teenagersSettingItem,
  ];
  @Trace list3: SettingItem[] = [

    this.aboutSettingItem,
    this.cacheSettingItem

  ];
  @Trace list6: SettingItem[] = [
    new SettingItem({
      label: '登录手机',
      subLabel: '该手机用于登陆手机号',
      extraLabel: this.getLoginPhoneNumber(),
      routerName: RouterMap.SETTING_PHONE,
    })];
  @Trace list7: SettingItem[] = [

    new SettingItem({
      label: '登录密码',
      routerName: RouterMap.LOGIN_PASSWORD,
    })
  ];
  @Trace list8: SettingItem[] = [

    new SettingItem({
      label: '注销账号',
      labelColor: '#e84026',
      onClick: () => {
        CommonConfirmDialog.show({
          primaryTitle: '温馨提示',
          content: '注销后数据不可恢复，是否注销账号',
          secBtnV: '注销',
          secBtnFg: $r('sys.color.warning'),
          confirm: () => {
            this.accountInstance.signOut().then(() => {
              this.isLoading = false;
              promptAction.showToast({ message: '已注销该账号' });
            })
          }
        })
      }
    })
  ];
  private accountInstance: AccountApi = new AccountApi();

  @Computed
  get signOutBtnLabel() {
    if (this.isLoading) {
      return '正在退出登录...'
    }
    return '退出账号'
  }

  isPhoneNumberValid(phoneNumber: string): boolean {
    if (!phoneNumber) {
      return false;
    }
    // 正则表达式：以1开头，第二位是3-9，后面跟9位数字
    const phoneRegex = /^1[3-9]\d{9}$/;
    return phoneRegex.test(phoneNumber);
  }

  // 在 SettingViewModel 类中添加
  changeLoginPhone(oldPhone: string, newPhone: string, verifyCode: string) {
    if (this.userInfoModel.authorPhone !== oldPhone) {
      promptAction.showToast({ message: '旧手机号不正确' });
      return
    }

    if (!newPhone) {
      promptAction.showToast({ message: '新手机号不能为空' });
      return
    }
    if (!this.isPhoneNumberValid(newPhone)) {
      promptAction.showToast({ message: '新手机号格式不正确' });
      return;
    }
    // 验证验证码（这里应该是调用实际的验证接口）
    if (!verifyCode) {
      promptAction.showToast({ message: '验证码不能为空' });
      return
    }
    // 更新手机号
    this.userInfoModel.authorPhone = newPhone;
    promptAction.showToast({ message: '手机号更换成功' });
    RouterUtils.popToName(RouterMap.SETTING_PAGE);
  }

  setColorMode(isDark: boolean) {
    const mode =
      isDark ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK : ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    getContext().getApplicationContext().setColorMode(mode);
    SystemBarOperation.setWindowSystemBarProp({
      statusBarContentColor: isDark ? '#ffffff' : '#ff090909'
    })
  }

  getCache() {
    FileUtils.getCache().then((resp: number) => {
      this.cacheSize = (resp / 1024 / 1024).toFixed(2);
      this.cacheSettingItem.extraLabel = this.getLocalCacheLabel();
    })
  }

  getLocalCacheLabel() {
    return `${this.cacheSize}M`;
  }

  // 添加获取手机号的方法
  getLoginPhoneNumber() {
    // 假设用户信息中包含手机号，根据实际数据结构调整
    if (this.userInfoModel && this.userInfoModel.authorPhone) {
      // 如果有手机号则显示，否则显示'未设置'
      const authorPhone = this.userInfoModel.authorPhone;
      this.oldPhone = authorPhone
      return `${authorPhone.slice(0, 3)}****${authorPhone.slice(-4)}` || '未设置';
    }
    return '未登录';
  }

  outBtnClick() {
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: '是否退出账号',
      secBtnV: '退出',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        this.accountInstance.signOut().then(() => {
          this.isLoading = false;
          promptAction.showToast({ message: '已退出该账号' });
        })
      },
    })
  }

  onSignOutBtnClick() {
    this.accountInstance.signOut().then(() => {
      promptAction.showToast({ message: '已退出登录' })
    }).finally(() => {
      this.isLoading = false;
    })
  }

  getLocationLabel() {
    return `${this.location}M`;
  }

  getTeenagersLabel() {
    return `${this.settingInfo.teenagersSwitch ? '已开启' : '未开启'}`;
  }

  onChangeTeenagersSwitch(password: string) {
    // 校验密码是否输入
    if (password.length === 0) {
      promptAction.showToast({ message: '请输入密码' });
      return
    }
    if (password !== this.settingInfo.teenagersPassword) {
      promptAction.showToast({ message: '密码错误' });
      return
    }
    this.settingInfo.teenagersSwitch = !this.settingInfo.teenagersSwitch;
    this.teenagersSettingItem.extraLabel = this.settingInfo.teenagersSwitch ? '已开启' : '未开启';
    //关闭页面
    RouterUtils.pop();
  }
}