import { bundleManager, common, Want } from '@kit.AbilityKit';
import { Logger } from 'module_ui_base';
import { MapOptionType } from '../commons/Enums';
import { mapOptionsDialogBuilder, MapOptionsDialogParam } from '../components/MapOptionDialog';
import { MapMarkerLocation } from '../commons/Types';
import { PopViewUtil } from './PopViewUtil';
import { WindowUtil } from './WindowUtil';

const TAG: string = '[MapUtil]';

export class MapUtil {
  public static handleClickGuide(location: MapMarkerLocation) {
    PopViewUtil.openDialog(
      wrapBuilder(mapOptionsDialogBuilder),
      { alignment: DialogAlignment.Bottom },
      {
        handleMapOptionClick: (type) => {
          switch (type) {
            case MapOptionType.HUAWEI:
              MapUtil.jumpToMapApp(location);
              break;
            case MapOptionType.CANCEL:
              PopViewUtil.closeDialog();
              break;
            default:
              break;
          }
        },
      } as MapOptionsDialogParam,
    );
  }

  public static async jumpToMapApp(location: MapMarkerLocation) {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION;
    try {
      const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleFlags);
      if (bundleInfo.name) {
        let petalMapWant: Want = {
          bundleName: 'com.huawei.hmos.maps.app',
          uri: 'maps://routes',
          parameters: {
            linkSource: bundleInfo.name,
            destinationLatitude: location.latitude,
            destinationLongitude: location.longitude,
          },
        };
        let context = WindowUtil.context as common.UIAbilityContext | undefined;
        if (context) {
          context.startAbility(petalMapWant);
        }
      }
    } catch (err) {
      Logger.error(TAG, 'jump to map app failed. error:', JSON.stringify(err.message));
    }
  }
}

