<p align="center">
  <img src="https://user-images.githubusercontent.com/11541888/58876201-a370b100-86cd-11e9-962b-b46e823d1b54.png" alt="appdb icon" title="appdb" height=130>
</p>

# appdb
A fully-featured iOS client for [appdb.to](https://appdb.to) written in Swift 5.

## Screenshots
<p align="center">
  <img src="https://user-images.githubusercontent.com/11541888/58879836-df5c4400-86d6-11e9-9fcc-95cb8239d7f3.png" alt="appdb icon" title="appdb" style="width=100%">
</p>

## Dependencies
* [Alamofire](https://github.com/Alamofire/Alamofire) - Elegant HTTP Networking in Swift
* [AlamofireImage](https://github.com/Alamofire/AlamofireImage) - Image component library for Alamofire
* [AlamofireNetworkActivityIndicator](https://github.com/Alamofire/AlamofireNetworkActivityIndicator) - Controls the visibility of the network activity indicator using Alamofire
* [BulletinBoard](https://github.com/alexaubry/BulletinBoard) - General-purpose contextual cards for iOS
* [Cartography](https://github.com/robb/Cartography) - A declarative Auto Layout DSL for Swift
* [Cosmos](https://github.com/evgenyneu/Cosmos) - A star rating control for iOS/tvOS written in Swift
* [DeepDiff](https://github.com/onmyway133/DeepDiff) - Amazingly incredible extraordinary lightning fast diffing in Swift
* [Kanna](https://github.com/tid-kijyun/Kanna) - XML/HTML parser for Swift
* [Localize-Swift](https://github.com/marmelroy/Localize-Swift) - Swift friendly localization and i18n with in-app language switching
* [ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper) - Simple JSON Object mapping written in Swift
* [SwiftTheme](https://github.com/wxxsw/SwiftTheme) - Powerful theme/skin manager for iOS 8+
* [Static](https://github.com/venmo/Static) - Simple static table views for iOS in Swift
* [SwiftMessages](https://github.com/SwiftKickMobile/SwiftMessages) - A very flexible message bar for iOS written in Swift
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) - The better way to deal with JSON data in Swift
* [swifter](https://github.com/httpswift/swifter) - Tiny http server engine written in Swift programming language
* [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) - Effortless ZIP Handling in Swift

## URL Schemes available
* `appdb-ios://?tab=featured`
* `appdb-ios://?tab=search`
* `appdb-ios://?tab=downloads`
* `appdb-ios://?tab=settings`
* `appdb-ios://?tab=updates`
* `appdb-ios://?tab=news`
* `appdb-ios://?tab=system_status`
* `appdb-ios://?tab=device_status`
* `appdb-ios://?trackid=1900000538&type=[ios, cydia, books]`
* `appdb-ios://?q=facebook&type=[ios, cydia, books]`
* `appdb-ios://?url=https://appdb.to`
* `appdb-ios://?news_id=308`
* `appdb-ios://?action=authorize&code=xxx`

## Download
You can download the latest .ipa from [here](https://github.com/n3d1117/appdb/releases).

## Build manually
Alernatively, you can build the project manually. 
Make sure you have [Carthage](https://github.com/Carthage/Carthage) installed. Run the following commands:
```
$ git clone https://github.com/n3d1117/appdb.git
$ cd appdb/
$ carthage update --platform iOS
$ open appdb.xcodeproj
```
Note: this project references the StartApp SDK. You will need to download it from [here](https://portal.startapp.com/#/pub/resource-center), unzip it and import `StartApp.framework` inside the project's `Frameworks` folder. Make sure to select `Copy items if needed` when copying the file.

## License
MIT License. See [LICENSE](LICENSE) file for further information.
