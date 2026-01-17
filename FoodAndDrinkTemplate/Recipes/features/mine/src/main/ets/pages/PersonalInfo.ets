import { MinePageVM } from '../viewModels/MinePageVM';
import { buildTitleBar } from 'commonlib';
import { LengthMetrics } from '@kit.ArkUI';
import { PersonalInfo, PersonalInfoView, DataType } from 'collect_personal_info';

@Builder
export function PersonalInfoBuilder() {
  PersonalView();
}

@ComponentV2
struct PersonalView {
  vm: MinePageVM = MinePageVM.instance;

  aboutToAppear(): void {
    this.vm.personalInfo.nickName = this.vm.userInfo.nickname ? this.vm.userInfo.nickname : '华为用户';
    this.vm.personalInfo.avatar = this.vm.formatAvatar(this.vm.userInfo.avatar)
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        PersonalInfoView({
          switchInfo: this.vm.switchInfo,
          personalInfo: this.vm.personalInfo,
          apiInfo: this.vm.apiInfo,
          onChange: (type: DataType, data: PersonalInfo) => {
            this.vm.userInfo.nickname = data.nickName as string;
            this.vm.userInfo.avatar = data.avatar as string;
          }
        })
      }
      .height('100%')
      .backgroundColor('#F1F3F5')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .padding({ top: 12, left: 16, right: 16 });
    }
    .title(buildTitleBar('个人信息'), { paddingStart: LengthMetrics.vp(16) });
  }
}