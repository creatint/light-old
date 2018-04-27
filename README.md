# Light

![Light logo](https://user-images.githubusercontent.com/17924777/39092072-762deace-4636-11e8-8acd-447a03c7556e.png)

Light目前只为Android平台做了适配，你可以自己移植到iOS。

Light contains platform-specific elements only for Android.<br>
You can transplant Light to iOS if you have a mac.

## Features
- [x] 支持ePub2、ePub3文件 ePub 2 and ePub 3 support. 
- [x] 支持utf-8编码  Utf-8 support. 
- [x] 支持latin-1编码 Latin-1 support. 
- [x] 支持扫描、导入本地文件 Scan and Import Local Files. 
- [x] 自定义字高 Custom Text Size. 
- [x] 自定义行高 Custom Line Height. 
- [x] 多主题 Multi Themes. 
- [ ] 日、夜间模式切换 Day mode / Night mode. 
- [ ] 搜索、关注、阅读贴吧 Search / Mark / Reading Tieba. 
- [ ] 剩余页数Reading Pages left. 
- [ ] 垂直、水平滚动Vertical or/and Horizontal scrolling. 
- [ ] 解析ePub文件封面 Parse epub cover image. 
- [ ] 添加、删除、搜索标签 Add / Delete / Search Mark. 
- [ ] 处理内、外链 Handle Internal and External Links. 
- [ ] 贴吧优化阅读 Tieba Optimize reading.
- [ ] 贴吧离线阅读 Tieba Offline Reading. 
- [ ] 在线搜索 Book Search Online. 
- [ ] Wifi导书 Import Book from Wifi. 
- [ ] 好友、聊天 Firend / Chat. 
- [ ] 书籍分享 Book Share. 
- [ ] 文字语音朗读 TTS - Text to Speech Support. 
- [ ] 用户设置 User Profile. 

## Screeshot
分页显示 Pagination | 本地导入 Local source mport
:-------------------------:|:-------------------------:
![分页显示](https://user-images.githubusercontent.com/17924777/39093416-24e27484-4652-11e8-9eaa-96b610508d80.gif) | ![本地导入](https://user-images.githubusercontent.com/17924777/39093132-18904792-464d-11e8-9bda-4f30abec0504.gif)

搜索贴吧 | 浏览帖子
:-------------------------:|:-------------------------:
![搜索贴吧](https://user-images.githubusercontent.com/17924777/39093389-d2d79c64-4651-11e8-9b19-07490ccbb44a.gif) | ![浏览帖子](https://user-images.githubusercontent.com/17924777/39093405-0108874c-4652-11e8-9e79-884a1f6961a9.gif)

## Usage
本项目基于Flutter。
- 你需要完成安装教程的阅读并安装Flutter：[flutter.io](https://flutter.io).
- 你也需要解决pubspec.yaml文件中的一些依赖

This project is built on Flutter.
- Follow the installation instructions on [flutter.io](https://flutter.io) to install Flutter.
- Some dependencies in pubspec.yaml need to be resolved in pubspec.yaml.

 name |  link
:-------------------------:|:-------------------------:
epub | https://github.com/creatint/dart-epub
html2md | https://github.com/creatint/dart-html2md
mimc | https://github.com/creatint/mimc-flutter

>example: 
 
- Lght可以像其他Flutter应用那样通过IntelliJ IDE或在Light目录下执行Flutter命令来运行：

- Light can be run like any other Flutter app, either through the IntelliJ UI or through running the following command from within the Light directory:
```
flutter packages get
flutter run
```


## Contact
Email: creatint@163.com

QQ: 565864175

QQ群: [![编程技术交流 (QQ群)](https://pub.idqqimg.com/wpa/images/group.png)](//shang.qq.com/wpa/qunwpa?idkey=b34e5d3956950dc053efdd7aef63ef75151c01cfff48a951c8fc53d6349b454a)


## License
Light使用GPL-3.0开源许可证，查看[证书](https://github.com/creatint/light/blob/master/LICENSE)。

Light is available under the GPL-3.0 license. See the [LICENSE](https://github.com/creatint/light/blob/master/LICENSE) file.