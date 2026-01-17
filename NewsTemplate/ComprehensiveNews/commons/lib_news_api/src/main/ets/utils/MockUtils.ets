import mockAdapter from '../common/MockAdapter';
import { ArticleServiceMock } from '../httpsmock/ArticleServiceMock';
import { AuthorServiceMock } from '../httpsmock/AuthorServiceMock';
import { BaseNewsServiceMock } from '../httpsmock/BaseNewsServiceMock';
import { CommentServiceMock } from '../httpsmock/CommentServiceMock';
import { HomeServiceMock } from '../httpsmock/HomeServiceMock';
import { MessageServiceMock } from '../httpsmock/MessageServiceMock';
import { MineServiceMock } from '../httpsmock/MineServiceMock';
import { PostServiceMock } from '../httpsmock/PostServiceMock';
import { VideoServiceMock } from '../httpsmock/VideoServiceMock';

// todo: 全局配置，是否启用mock，默认启用
const enableMock: boolean = true;

if (enableMock) {
  const mockApis = [
    new ArticleServiceMock(),
    new AuthorServiceMock(),
    new BaseNewsServiceMock(),
    new CommentServiceMock(),
    new HomeServiceMock(),
    new MessageServiceMock(),
    new MineServiceMock(),
    new PostServiceMock(),
    new VideoServiceMock(),
  ];
  mockApis.forEach((api) => {
    api.start(mockAdapter);
  });
}