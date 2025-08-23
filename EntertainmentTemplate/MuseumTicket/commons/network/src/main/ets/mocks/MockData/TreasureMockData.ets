import { TreasureItem, BaseResponse } from '../../types/ResponseTypes';
import { CLOUD_STORAGE_URL } from '../Constants';


export const treasureInfoResp: BaseResponse<TreasureItem[]> = {
  code: 0,
  data: [
    {
      treasureId: 1,
      name: '偷水果的人',
      title: '顶级摄影师怪诞的超写实艺术\n《偷水果的人》',
      cover: CLOUD_STORAGE_URL + 'treasure_cover1.png?token=5fe434c0-2ed9-437e-9d0c-39262037656f',
      bg: CLOUD_STORAGE_URL + 'treasure_bg1.png?token=67bf23d7-bed6-499f-b14a-7d2ffd5db058',
      introduction: '油画（an oil painting；a painting in oils）是以用快干性的植物油' +
        '（亚麻仁油、罂粟油、核桃油等）调和颜料，在画布（亚麻布）、纸板或木板上进行制作的一个画种。' +
        '作画时使用的稀释剂为挥发性的松节油和干性的亚麻仁油等。画面所附着的颜料有较强的硬度，当画面干燥后，' +
        '能长期保持光泽。凭借颜料的遮盖力和透明性能较充分地表现描绘对象，色彩丰富，立体质感强。油画是西洋画的主要画种之一。',
      age: '19世纪西方艺术',
    },
    {
      treasureId: 2,
      name: '佛教壁画',
      title: '中国传统文化\n魅力佛教壁画',
      cover: CLOUD_STORAGE_URL + 'treasure_cover2.png?token=ab094635-a564-4d7d-a542-71ca79cbcc43',
      bg: CLOUD_STORAGE_URL + 'treasure_bg2.png?token=2c56d149-1eb2-46ec-a4b3-3deb97bb49dc',
      introduction: '始绘于前秦，延续至元代，跨越千年。内容以佛教故事为主，融合多元文化，画风从古朴到绚丽，技艺精湛，色彩斑斓，是世界艺术宝库中的璀璨明珠。',
      age: '古代佛教文化',
    },
    {
      treasureId: 3,
      name: '敦煌壁画',
      title: '中原与西域的文化碰撞\n丝绸之路的文化积淀',
      cover: CLOUD_STORAGE_URL + 'treasure_bg3.jpg?token=84ce497d-df17-4bea-8f93-6c728e9f43be',
      bg: CLOUD_STORAGE_URL + 'treasure_bg3.jpg?token=84ce497d-df17-4bea-8f93-6c728e9f43be',
      introduction: '敦煌壁画，千年佛国丹青，以斑斓色彩绘就天上人间。飞天飘袂，菩萨低眉，经变画里演绎盛唐气象；线条如行云，赋彩似流霞，中西交融间尽显丝路华章，乃东方艺术之绝唱。',
      age: '横跨千年的艺术珍品',
    },
  ],
};