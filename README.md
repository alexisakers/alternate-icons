# AlternateIcons

[![Build Status](https://travis-ci.org/alexaubry/alternate-icons.svg?branch=master)](https://travis-ci.org/alexaubry/alternate-icons)
[![Requires macOS 10.10+](https://img.shields.io/badge/macOS-10.10+-9D88A2.svg)]()
[![Requires Swift 3.1](https://img.shields.io/badge/Swift-3.1-ee4f37.svg)]()
[![Contact : @leksantoine](https://img.shields.io/badge/Contact-%40leksantoine-6C7A89.svg)](https://twitter.com/aleksaubry)

AlternateIcons is a Swift script that allows you to use Xcode Asset Catalogs to add alternate app icons to your iOS app. It takes care of copying the icon assets to your app bundle and correctly updating the Info.plist. No more manual setup required!

## Installation

### From a Pre-built Bottle

You can download a pre-compiled bottle of the script for the version you want to install in the [Releases](https://github.com/alexaubry/alternate-icons/releases) section of this repository.

Once the archive is expanded, run the `install.sh` script to install the script on your system.

### From Source

You can build and install AlternateIcons from source using **Make**:

~~~bash
git clone https://github.com/alexaubry/alternate-icons.git
cd alternate-icons
make
make install
~~~

## Setting up your app

To set up AlternateIcons as an Xcode build phase, do the following:

1. Create a new Xcode asset catalog to store your icons, and **do not add it to your target**.

2. Add your primary and alternate app icons to this asset catalog, using the '*New iOS App Icon*' template.

    **NOTE**: The primary icon needs to be named `AppIcon`.

3. If you're currently using an asset catalog to store your primary icon, in the General section of your project target, select 'Do not use Asset Catalog' in the App Icon Source setting.

4. In the Build Phases section of your project target, add a new Run Script phase. The script should be:

    ~~~
    embed-alternate-icons
    ~~~

    You now need to specify the path to the Asset Catalog you've created at step *1* under "Input Files", e.g.:
    
    ~~~
    $(SRCROOT)/Icons.xcassets
    ~~~

    **NOTE**: This Run Script phase needs to be situated after all the 'Copy Bundle Resources' and 'Copy Files' phases.
    
5. Build your app.

*Et voilà*! All the icons have automatically been embedded into your app and are ready for use!

You can now change the icon in your code using: 

~~~swift
UIApplication.shared.setAlternateIconName("IconName", completionHandler: nil)
~~~

> &#128218; Documentation: https://developer.apple.com/documentation/uikit/uiapplication/2806818-setalternateiconname

## How it works

Every time you build your app, the script will perform the following steps:

1. Infer the location of build artefacts from the environment variables passed by Xcode
2. Parse the Asset Catalog to get the list of icons to embed
3. Copy the new icons in the app bundle
4. Delete any icon you've removed from the Asset Catalog
5. Update the `CFBundleIcon` section of the Info.plist in the app bundle (not in your source code, to avoid trouble with version control)

## Acknowledgements

AlternateIcons uses these open source libraries:

- [Unbox](https://github.com/JohnSundell/Unbox) by **@JohnSundell**
- [Files](https://github.com/JohnSundell/Files) by **@JohnSundell**