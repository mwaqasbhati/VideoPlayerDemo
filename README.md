# VideoPlayerDemo


## Screenshots

|             Video Listing         |         Video Detail          | AVPlayerView |
|---------------------------------|------------------------------|------------------------------|
|![Demo](https://github.com/mwaqasbhati/VideoPlayerDemo/blob/master/ScreenShots/VideoList.png)|![Demo](https://github.com/mwaqasbhati/VideoPlayerDemo/blob/master/ScreenShots/Detail.png)|![Demo](https://github.com/mwaqasbhati/VideoPlayerDemo/blob/master/ScreenShots/Player.png)|

## Requirements

- Xcode 11.2.1
- Swift 5.0
- Minimum iOS version 13.2


## Architecture at a Glance

I have used MVVM desigsn pattern in this project. I have made a network manager which will get video play list from local/remote store. currently we are getting it from local storage.
I have created a custom AVPlayerQueue with custom layouts which can run the player as embedded or in a full screen. I have used Combine framework for observing properties.

## Framework Used

- Combine
- AVFoundation
- AVKit
- UIKit
- Foundation

## Custom AVPlayerView Functionality

- Play/Pause.
- Full Screen.
- More Play List items in full Screen.
- show/hide of verlay using tap.
- Timer of the video.

## Build

To build using xcodebuild without code signing
```
xcodebuild clean build -workspace "VideoStreamingDemo.xcodeproj" -scheme "VideoStreamingDemo" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

## Discussions

I have used MVVM design pattern in this project. MVVM follows a very clean architecture. It isolates each module from others. So changing or fixing bugs are very easy as you only have to update a specific module. Also for having modular approach MVVM creates a very good environment for unit testing. As each module is independent from others, it maintains low coupling very well. So, dividing work among co-developers are pretty simple.

## Author

mwaqasbhati, m.waqas.bhati@hotmail.com

## License

VideoPlayerDemo is available under the MIT license. See the LICENSE file for more info.
