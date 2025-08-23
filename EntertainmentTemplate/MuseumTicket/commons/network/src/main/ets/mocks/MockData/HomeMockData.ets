import { BaseResponse, GetRecommendListResp, GetIntroduceResp,
  ParkTextResp } from '../../types/ResponseTypes';
import { CLOUD_STORAGE_URL } from '../Constants';

export const recommendListResp: BaseResponse<GetRecommendListResp> = {
  code: 0,
  data: [{
    id: '1',
    name: '下河文明巡回展',
    img: CLOUD_STORAGE_URL + 'IMG_382.png?token=fc448f58-9dd5-44c4-8eb4-fac91dc6590a',
    detail: '身临其境2800年下河历史',
    price: 39,

  }, {
    id: '2',
    name: '线条艺术展',
    img: CLOUD_STORAGE_URL + 'IMG_383.png?token=82cc3a9e-ab60-468c-94c4-5dbcde3bae10',
    detail: '东京艺术家倾情力作',
    price: 59,
  }],
};





export const introduceTextResp: BaseResponse<GetIntroduceResp> = {
  code: 0,
  data: {
    museumName: '博物馆',
    address: '江苏省南京市秦淮区',
    tel: '025-00001111',
    openTime: '每周二至周日9:00—18:00（17:00停止入馆），\n' +
      '周一闭馆（逢国家法定节假日除外）。',
    bus: '5路，34路，36路，55路中山门站',
    subway: '2号线明故宫站，1号口出向东300米',
    introduction: '博物馆位于江苏省南京市秦淮区，为总馆分支机构，是一座综合性历史艺术类博物馆，' +
      '是南京市市立博物馆，国家重点博物馆之一，是江苏省、南京市爱国主义教育基地。她的前身是建国初期成' +
      '立的南京市文物保管委员会，1978年博物馆正式挂牌。博物馆担负着南京地区的地下遗址和古墓葬的考古发掘调' +
      '查，文物的保护、藏品的征集与保管，以丰富的文物、文献资料及研究成果为基础，展示南京在中国各个历史发' +
      '展阶段的发展的轨迹，重点展示南京古都历史文化的成就。\n' +
      '博物馆所处的朝天宫是江南地区建筑等级最高，面积最大，保存最完整的古建筑群。朝天宫之名，' +
      '系明洪武十七年(1385)太祖朱元璋下诏亲赐，取"朝拜上天"之意。现存建筑为清同治五年（1866）重建，占地面积约四万平方米。',
  },
};

export const parkingTextResp: BaseResponse<ParkTextResp[]> = {
  code: 0,
  data: [
    {
      title:'停车场地址：',
      content:'小型车辆（含小型燃油车、新能源车）停放在南停车场（地下）指定划线、立体停车位；大型车辆（含大客车）停放于西南门内和南主馆西的指定划线车位内。'
    },
    {
      title:'电话：',
      content:'01234567'
    },
    {
      title:'开放时间：',
      content:'参观日9：00至18：00'
    },
    {
      title:'收费标准：',
      content:'小型燃油车3元/小时（半小时内免费），新能源车1元/小时（1小时内免费），大客车5元/次，已开通支付宝，使用现金支付的可向停车场入口收费处索要相关发票。'
    }
  ],
};



