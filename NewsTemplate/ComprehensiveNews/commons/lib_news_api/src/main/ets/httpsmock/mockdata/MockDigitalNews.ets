import { DigitalNewsResponse, DigitalNewsSource } from '../../params/response/DigitalNewsResponse';

export class MockDigitalNews {
  static list: DigitalNewsResponse[] = [
    {
      id: 1,
      newsImg: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Fdigital_1.png',
      newsName: '第01版：头版',
      position: '10,56,510,56,510,379,10,379,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||521,56,691,56,691,269,521,269,,https://www.example.com,,article_digital_2,,全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点||10,391,510,391,510,875,10,875,,https://www.example.com,,article_digital_3,,人工智能推动增长，绿色经济成未来焦点||521,281,691,281,691,1026,521,1026,,https://www.example.com,,article_digital_4,,人工智能：经济增长的新引擎||10,895,510,895,510,1026,10,1026,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源',
      width: '700',
      height: '1036',
      paperId: 1,
      paperTime: '2025-06-28',
    },
    {
      id: 2,
      newsImg: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Fdigital_2.png',
      newsName: '第02版：要闻',
      position: '10,56,690,56,690,252,10,252,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||10,265,464,265,464,729,10,729,,https://www.example.com,,article_digital_2,,全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点||476,264,690,264,690,729,476,729,,https://www.example.com,,article_digital_4,,人工智能：经济增长的新引擎||10,752,380,752,380,861,10,861,,https://www.example.com,,article_digital_3,,人工智能推动增长，绿色经济成未来焦点||392,752,692,752,692,1024,392,1024,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||10,869,380,869,380,1024,10,1024,,https://www.example.com,,article_digital_5,,绿色经济：未来的增长方向',
      width: '700',
      height: '1036',
      paperId: 1,
      paperTime: '2025-06-28',
    },
    {
      id: 3,
      newsImg: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Fdigital_3.png',
      newsName: '第03版：国内',
      position: '10,56,510,56,510,379,10,379,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||521,56,691,56,691,269,521,269,,https://www.example.com,,article_digital_2,,全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点||10,391,510,391,510,875,10,875,,https://www.example.com,,article_digital_3,,人工智能推动增长，绿色经济成未来焦点||521,281,691,281,691,1026,521,1026,,https://www.example.com,,article_digital_4,,人工智能：经济增长的新引擎||10,895,510,895,510,1026,10,1026,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源',
      width: '700',
      height: '1036',
      paperId: 1,
      paperTime: '2025-06-28',
    },
    {
      id: 4,
      newsImg: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Fdigital_4.png',
      newsName: '第04版：天下',
      position: '10,56,690,56,690,252,10,252,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||10,265,464,265,464,729,10,729,,https://www.example.com,,article_digital_2,,全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点||476,264,690,264,690,729,476,729,,https://www.example.com,,article_digital_4,,人工智能：经济增长的新引擎||10,752,380,752,380,861,10,861,,https://www.example.com,,article_digital_3,,人工智能推动增长，绿色经济成未来焦点||392,752,692,752,692,1024,392,1024,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||10,869,380,869,380,1024,10,1024,,https://www.example.com,,article_digital_5,,绿色经济：未来的增长方向',
      width: '700',
      height: '1036',
      paperId: 1,
      paperTime: '2025-06-28',
    },
    {
      id: 5,
      newsImg: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Fdigital_5.png',
      newsName: '第05版：视线',
      position: '10,56,510,56,510,379,10,379,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||521,56,691,56,691,269,521,269,,https://www.example.com,,article_digital_2,,全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点||10,391,510,391,510,875,10,875,,https://www.example.com,,article_digital_3,,人工智能推动增长，绿色经济成未来焦点||521,281,691,281,691,1026,521,1026,,https://www.example.com,,article_digital_4,,人工智能：经济增长的新引擎||10,895,510,895,510,1026,10,1026,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源',
      width: '700',
      height: '1036',
      paperId: 1,
      paperTime: '2025-06-28',
    },
    {
      id: 6,
      newsImg: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/ComprehensiveNews%2Fdigital_6.png',
      newsName: '第06版：资讯',
      position: '10,56,690,56,690,252,10,252,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||10,265,464,265,464,729,10,729,,https://www.example.com,,article_digital_2,,全球经济复苏新动力：人工智能推动增长，绿色经济成未来焦点||476,264,690,264,690,729,476,729,,https://www.example.com,,article_digital_4,,人工智能：经济增长的新引擎||10,752,380,752,380,861,10,861,,https://www.example.com,,article_digital_3,,人工智能推动增长，绿色经济成未来焦点||392,752,692,752,692,1024,392,1024,,https://www.example.com,,article_digital_1,,人工智能助力教育公平：偏远地区学生迎来优质教育资源||10,869,380,869,380,1024,10,1024,,https://www.example.com,,article_digital_5,,绿色经济：未来的增长方向',
      width: '700',
      height: '1036',
      paperId: 1,
      paperTime: '2025-06-28',
    },
  ];
  static sources: DigitalNewsSource[] = [
    {
      id: '1',
      name: '人民日报',
    },
    {
      id: '2',
      name: '光明日报',
    },
    {
      id: '3',
      name: '经济日报',
    },
    {
      id: '4',
      name: '南方日报',
    },
    {
      id: '5',
      name: '广州日报',
    },
    {
      id: '6',
      name: '新华社',
    },
    {
      id: '7',
      name: '扬子晚报',
    },
    {
      id: '8',
      name: '法治日报',
    },
    {
      id: '9',
      name: '钱江晚报',
    },
    {
      id: '10',
      name: '南方都市报',
    },
    {
      id: '11',
      name: '解放日报',
    },
    {
      id: '12',
      name: '文汇报',
    },
    {
      id: '13',
      name: '大众日报',
    },
    {
      id: '14',
      name: '湖北日报',
    },
    {
      id: '15',
      name: '新华日报',
    },
  ];
}
