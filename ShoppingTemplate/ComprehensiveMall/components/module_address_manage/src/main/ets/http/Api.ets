import textProcessing, { EntityType } from '@hms.ai.nlp.textProcessing';
import site from '@hms.core.map.site';
import i18n from '@ohos.i18n';
import util from '@ohos.util';

import { AddressDTO } from '../model/AddressDTO';
import { ParsedAddressDTO } from '../model/ParsedAddressDTO';

export class Api {
  private static addressListMock: AddressDTO[] = [
    {
      id: util.generateRandomUUID(false),
      name: '张三',
      phone: '12345678901',
      countryCode: 'CN',
      country: '中国',
      province: '江苏省',
      city: '南京市',
      district: '雨花台区',
      street: '铁心桥街道',
      detail: '软件大道101号',
      isDefault: true,
      createdAt: new Date().getTime(),
      updatedAt: new Date().getTime(),
      latitude:31.99,
      longitude:118.78
    },
  ];

  private static withDelay<T>(
    callback: () => T | Promise<T>,
    delay = 300,
  ): Promise<T> {
    return new Promise((resolve, reject) => {
      setTimeout(async () => {
        try {
          const result: T = await callback();
          resolve(result);
        } catch (error) {
          reject(error);
        }
      }, delay);
    });
  }

  public static async listAddresses(): Promise<AddressDTO[]> {
    return Api.withDelay(() => {
      const list: AddressDTO[] = JSON.parse(
        JSON.stringify(Api.addressListMock),
      );
      list.sort((a, b) => {
        if (a.isDefault && !b.isDefault) {
          return -1;
        }
        if (!a.isDefault && b.isDefault) {
          return 1;
        }
        return b.updatedAt - a.updatedAt;
      });
      return list;
    });
  }

  public static async createAddress(address: AddressDTO): Promise<void> {
    return Api.withDelay(() => {
      const time: number = new Date().getTime();
      address.createdAt = time;
      address.updatedAt = time;
      address.id = util.generateRandomUUID(false);
      if (address.isDefault) {
        Api.addressListMock.forEach((item) => (item.isDefault = false));
      }
      Api.addressListMock.push(address);
    });
  }

  public static async updateAddress(address: AddressDTO): Promise<void> {
    return Api.withDelay(() => {
      address.updatedAt = new Date().getTime();
      const index = Api.addressListMock.findIndex(
        (item) => item.id === address.id,
      );
      if (index === -1) {
        throw new Error();
      }
      if (address.isDefault) {
        Api.addressListMock.forEach((item) => (item.isDefault = false));
      }
      Api.addressListMock[index] = address;
    });
  }

  public static async deleteAddress(id: string): Promise<void> {
    return Api.withDelay(() => {
      const index = Api.addressListMock.findIndex((item) => item.id === id);
      if (index === -1) {
        throw new Error();
      }
      Api.addressListMock.splice(index, 1);
    });
  }

  public static async parseAddressByText(
    text: string,
  ): Promise<ParsedAddressDTO> {
    const config: textProcessing.EntityConfig = {
      entityTypes: [EntityType.NAME, EntityType.PHONE_NO, EntityType.LOCATION],
    };
    return Api.withDelay(async () => {
      // 通过自然语言理解能力对文本进行实体抽取
      const entities: textProcessing.Entity[] = await textProcessing.getEntity(
        text,
        config,
      );
      const parsedAddress: ParsedAddressDTO = new ParsedAddressDTO();
      const formatInterNational: i18n.PhoneNumberFormat =
        new i18n.PhoneNumberFormat('CN', { type: 'INTERNATIONAL' });
      const formatNational: i18n.PhoneNumberFormat = new i18n.PhoneNumberFormat(
        'CN',
        { type: 'NATIONAL' },
      );
      // 文本中可能包含多个同类实体，当某个实体成功解析后，后续将跳过对该类型实体的解析
      let hasPhone: boolean = false;
      let hasName: boolean = false;
      let hasRegion: boolean = false;
      let hasDetail: boolean = false;
      // 遍历实体集，正式进入解析流程
      for (let entity of entities) {
        if (entity.type === EntityType.PHONE_NO && !hasPhone) {
          /**
           * 先将手机号格式化为 InterNational 格式，如果其以 `+86 `开头，则更换格式
           * 为 National，最终移除空格以得到国内常用手机号风格。
           *
           * InterNational: (+86 xxx 0000 1111) (+1 xxx 000 1111)
           * National:      (xxx 0000 1111)     (xxx 000 1111)
           */
          const phone: string = formatInterNational.format(entity.text);
          if (phone && formatInterNational.isValidNumber(phone)) {
            if (phone.startsWith('+86 ')) {
              parsedAddress.phone = formatNational
                .format(phone)
                .replace(/\s+/g, '');
            } else {
              parsedAddress.phone = phone;
            }
          }
          hasPhone = Boolean(parsedAddress.phone);
        } else if (entity.type === EntityType.NAME && !hasName) {
          parsedAddress.name = entity.text;
          hasName = Boolean(parsedAddress.name);
        } else if (entity.type === EntityType.LOCATION) {
          if (hasRegion && hasDetail) {
            continue;
          }
          // 抽取源内容中的区划信息与详细地址
          let lastRegionEndIndex = -1;
          const subDistrict: string = Api.findJsonValueByKey(
            entity.jsonObject,
            'subDistrict',
          );
          const road: string = Api.findJsonValueByKey(
            entity.jsonObject,
            'road',
          );
          const regionFields: string[] = [
            Api.findJsonValueByKey(entity.jsonObject, 'country'),
            Api.findJsonValueByKey(entity.jsonObject, 'province'),
            Api.findJsonValueByKey(entity.jsonObject, 'city'),
            Api.findJsonValueByKey(entity.jsonObject, 'county'),
            Api.findJsonValueByKey(entity.jsonObject, 'district'), // 类似澳门半岛等地区会使用 district 字段
            subDistrict ? subDistrict : road,
          ].filter(Boolean);
          for (let regionPart of regionFields) {
            const index = entity.text.indexOf(
              regionPart,
              lastRegionEndIndex + 1,
            );
            if (index !== -1) {
              lastRegionEndIndex = index + regionPart.length - 1;
            }
          }
          if (lastRegionEndIndex === -1 || hasRegion) {
            // 本次放弃进一步处理区划信息，但仍可以尝试存储详细地址
            if (!hasDetail && entity.text) {
              parsedAddress.detail = entity.text;
              hasDetail = true;
            }
            continue;
          }
          const region: string = entity.text
            .slice(0, lastRegionEndIndex + 1)
            .trim();
          let detail: string = entity.text.slice(lastRegionEndIndex + 1).trim();
          /**
           * 通过地点搜索能力，对地址实体进行错误修正、地址补全、名称规范
           *
           * 注：根据搜索规则约定，sites[0] 是与搜索关键字最契合的地点
           */
          const result: site.SearchByTextResult = await site.searchByText({
            query: region,
          });
          if (result.sites && result.sites.length > 0) {
            const address: site.AddressComponent =
              result.sites[0].addressComponent;
            parsedAddress.countryCode = address.countryCode ?? '';
            parsedAddress.country = address.countryName ?? '';
            parsedAddress.province = address.adminLevel1 ?? '';
            parsedAddress.city = address.adminLevel2 ?? '';
            parsedAddress.district = address.adminLevel3 ?? '';
            parsedAddress.street = address.adminLevel4 ?? '';
            // 如果 subDistrict 不存在，却解析出了街道，说明街道信息可能来自 road 字段
            if (!subDistrict && parsedAddress.street && road) {
              // 如果街道信息没有完全包含 road 所有字符，说明 road 字段大概率不代表街道，仅仅是算法就近寻找到的街道
              if (!parsedAddress.street.includes(road)) {
                parsedAddress.street = '';
                detail = road + parsedAddress.detail;
              }
            }
            // 如果 subDistrict 存在且解析出了街道，优先使用 subDistrict，除非解析对其进行了拼写补全
            if (subDistrict && parsedAddress.street) {
              if (!parsedAddress.street.includes(subDistrict)) {
                parsedAddress.street = subDistrict;
              }
            }
            // 如果 subDistrict 存在却没解析出街道，将其拼接到详细地址
            if (subDistrict && !parsedAddress.street) {
              detail = subDistrict + detail;
            }
            parsedAddress.detail = detail ? detail : parsedAddress.detail;
            if (parsedAddress.hasCompleteLocation()) {
              hasRegion = true;
            } else {
              parsedAddress.clearAddress();
            }
          }
        }
      }
      return parsedAddress;
    });
  }

  private static findJsonValueByKey(jsonStr: string, key: string): string {
    const regex: RegExp = new RegExp(
      `"${key}"\\s*:\\s*\\{\\s*"value"\\s*:\\s*"(.*?)"`,
      'i',
    );
    const match: RegExpMatchArray | null = jsonStr.match(regex);
    return match ? match[1] : '';
  }
}
