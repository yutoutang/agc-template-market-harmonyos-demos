import { getFormattedResp } from '../Utils';
import { GetBannerImgRequest } from '../../types/RequestTypes';
import { CLOUD_STORAGE_URL } from '../Constants';
import { CloudUrl } from '../../types/ResponseTypes';

const url1 = CLOUD_STORAGE_URL + 'IMG_379.png?token=429c87bf-e9eb-474b-b079-e94ea238c668';

const url2 = CLOUD_STORAGE_URL + 'IMG_002.png?token=fd98d196-dca0-4bbc-b8e4-dfcb4a84593e';

const url3 = CLOUD_STORAGE_URL + 'IMG_380.png?token=7448f9bd-194d-4728-a4e2-567138dfda07';


const activeCover = CLOUD_STORAGE_URL + 'active_cover.png?token=c8e7c859-8dd0-4d83-b3e1-23ba9f9611b5';
const sheetBg = CLOUD_STORAGE_URL + 'sheet_bg.png?token=559988b0-2b60-4fcc-a3af-45d946ad467b';
const introductionBg = CLOUD_STORAGE_URL + 'Introduction_bg.png?token=9cbaed7c-9d80-42ae-9416-d5a19c6d5f8e';

export class BannerDatasetMock {
  public static getBannerSource(data: GetBannerImgRequest) {
    if (data.pageType === 1) {
      return getFormattedResp([url1, url2]);
    } else {
      return getFormattedResp(url3);
    }
  }

  public static getCloudUrl() {
    const res: CloudUrl = {
      sheetBg,
      activeCover,
      introductionBg,
    };
    return getFormattedResp(res);
  }
}