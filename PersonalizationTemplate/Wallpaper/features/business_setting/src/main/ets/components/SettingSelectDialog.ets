import { SelectDialog } from '@kit.ArkUI';
import { CommonConstants, GridRowColSetting, PopViewUtils } from 'lib_common';
import { SettingItem } from '../types/Types';

@Builder
export function SettingSelectDialog(v: SettingItem) {
  Column() {
    Column() {
      SelectDialog({
        title: v.selectTitle,
        selectedIndex: v.selectV,
        confirm: {
          action: () => {
            PopViewUtils.closePopView();
          },
          value: '取消'
        },
        radioContent: v.selectOptions?.map(item => {
          return {
            action: () => {
              if (v.onSelect) {
                v.onSelect(item);
                PopViewUtils.closePopView();
              }
            },
            title: item.label
          } as SheetInfo;
        })
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('app.float.xxl_radius'))
    .constraintSize({ maxWidth: GridRowColSetting.DIALOG_MAX_WIDTH })
  }
  .width(CommonConstants.FULL_PERCENT)
  .padding({
    right: CommonConstants.PADDING_PAGE,
    left: CommonConstants.PADDING_PAGE,
  })
}