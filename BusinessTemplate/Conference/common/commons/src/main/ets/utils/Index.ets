import { sceneMap } from '@kit.MapKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

export const spacing = (name: string) => {
  name = name.trim();
  if (name.length === 2) {
    name =
      name.toString().substring(0, 1) + '　' + name.toString().substring(1);
    return name;
  }
  return name;
}

// 去这里
export const openMap = (context: Context, lat: string, lng: string, name: string) => {

}