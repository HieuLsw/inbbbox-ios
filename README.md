# Inbbbox

![](https://www.bitrise.io/app/57ab32541a792428.svg?token=l69JVSj-LJqSlXjEwk9-fQ&branch=Inbbbox-v2)
[![codebeat badge](https://codebeat.co/badges/b554db34-7c30-4e41-8b32-9ec8fc3742d9)](https://codebeat.co/a/netguru/projects/inbbbox-ios-master)

With Inbbbox you can discover excellent visual works from Dribbble, the global directory for digital design.
If you want to grab a copy for yourself just go straight to [App Store](https://itunes.apple.com/app/inbbbox/id1101252506). However, if you are interested in the core of Inbbbox, check out [Configuration](#configuration) section. Note that Dribbble account is necessary for using the app.

We at Netguru strongly believe in open-source software. Inbbbox isn’t our only project repo where you can find the app’s full source code. Explore other [open source projects](https://www.netguru.co/opensource) created by our team.

## Configuration

### Tools & requirements

* Xcode 8.3 with iOS 9.3 SDK
* Carthage 0.11 or newer
* CocoaPods 1.1.1 or newer
* RVM (recommended)
* Bundler

### Instructions

1. Clone repo at `https://github.com/netguru/inbbbox-ios.git`
2. Within Terminal navigate to `inbbbox-ios` directory
3. Type `bundle install`
4. Type `carthage bootstrap`
5. Type `bundle exec pod install`

    You will see `CocoaPods-Keys has detected a keys mismatch for your setup. What is the key for ClientID`. Fear not! This is how Inbbbox authenticates with Dribbble API to fetch all data! Go to `https://dribbble.com/account/applications/` to create your own application. After that you should have `ClientID`, `ClientSecret` and `ClientAccessToken`. After providing `ClientID` you will be asked for other keys. We are using `cocoapods-keys` to store them securely.

    As an alternative way of storing keys, you can add them to `.env` file to root directory of project. All required keys can be found in `.env.required` file, so all you need to do is to copy them to `.env` file and provide your values.

    During pod installation, `cocoapods-keys` will actually search for keys in `.env` file in the first place. Optional keys can be found in `.env.optional`, but are not required for project setup.

6. You are good to go! Just open `Inbbbox.xcworkspace`. In case of any problems don't hesitate to contact with us!

## Contribution

You're more than welcome to contribute. Just try to follow our [coding style guide](https://github.com/netguru/swift-style-guide) or report an issue in case of any problems, questions or improvement proposals.

## Authors

* [Designers Team](https://dribbble.com/netguru)

    * [Bartosz Bąk](https://dribbble.com/bartoszbak)
    * [Bartosz Białek](https://dribbble.com/bkbl)
    * [Mateusz Czajka](https://dribbble.com/czajkovsky)
    * [Łukasz Łanecki](https://dribbble.com/LukaszLanecki)
    * [Michał Parulski](https://dribbble.com/Shuma87)
    * [Magdalena Sitarek](https://www.linkedin.com/in/magdalenasitarek)
    * [Dawid Woźniak](https://dribbble.com/dawidw)

* [Developers Team](https://github.com/netguru/inbbbox-ios/graphs/contributors)

    * [Piotr Bruź](https://github.com/pbruz)
    * [Patryk Kaczmarek](https://github.com/PatrykKaczmarek)
    * [Adrian Kashivskyy](https://github.com/akashivskyy)
    * [Lukasz Pikor](https://github.com/pikor)
    * [Aleksander Popko](https://github.com/APbjj)
    * [Marcin Siemaszko](https://github.com/Siemian)
    * [Radosław Szeja](https://github.com/rad3ks)
    * [Kamil Tomaszewski](https://github.com/kamil-tomaszewski)
    * [Łukasz Wolańczyk](https://github.com/lukwol)
    * [Robert Abramczyk](https://github.com/Malibris)
    * [Tomasz Walenciak](https://github.com/twalenciak)
    * [Błażej Wdowikowski](https://github.com/bwdowikowski)

Copyright © 2016 [Netguru](http://netguru.co).

Licensed under the [GPLv3 License](LICENSE.txt).
