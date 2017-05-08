PhotoViewer 看圖小幫手
======================
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/kkdai/PhotoViewer/master/LICENSE)


看圖小幫手，是一個實驗性質的App．主要是把[我愛批踢踢](https://github.com/kkdai/iloveptt)，[我愛卡提諾](https://github.com/kkdai/iloveck101)與[臉書相簿小幫手](https://github.com/kkdai/goFBPages) 整合進iOS的App，透過[Gomobile](https://godoc.org/golang.org/x/mobile/cmd/gomobile)

主要的核心模組為[PhotoMgr](https://github.com/kkdai/photomgr) 是由Go撰寫的．其他相關的功能也都會寫在核心模組上．


如何編譯
---------------

- Clone this project `git clone https://github.com/kkdai/PhotoViewer.git`
- move to project folder `cd PhotoViewer`
- Install related pods `pod install`
- Build and Run it.


主要功能
--------------

`看圖小幫手`主要是幫助你方便(離線)看圖，提供了離線緩存的功能． 並且能夠方便瀏覽各個常有圖片的網站．功能列表如下:

- 管理並且瀏覽本地端緩存圖片
- 新增相簿圖片到App的資料夾中
- 瀏覽並且緩存PTT 版面圖片 (版面為**Beauty**)
- 瀏覽並且緩存CK101 版面與圖片 (版面為**熱議正妹**)

截圖
--------------


### 瀏覽與管理相片的介面

![](images/viewer.png)


### 瀏覽Ptt 與下載的介面

![](images/ptt.png)



### 瀏覽CK101 與下載的介面

![](images/ck101.png)



使用方式，透過[上頁]與[下頁]的切換．看到喜歡的文章點選下去，會自動把圖片下載到手機裡面．可以透過瀏覽介面來看．


未來規劃
---------------

由於我主要在忙我的[project 52](https://github.com/kkdai/project52) 這個專案會不定期更新，未來規劃請看[PhotoMgr](https://github.com/kkdai/photomgr)


廣告
---------------

如果你喜歡這個App，請考慮以下方式贊助我

- 按下一個"github Star"

感謝...


Project52
---------------

It is one of my [project 52](https://github.com/kkdai/project52).


License
---------------

This package is licensed under MIT license. See LICENSE for details.
