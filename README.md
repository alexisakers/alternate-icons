# AlternateIcons

[![Build Status](https://travis-ci.org/alexaubry/alternate-icons.svg?branch=master)](https://travis-ci.org/alexaubry/alternate-icons)
[![Requires macOS 10.10+](https://img.shields.io/badge/macOS-10.10+-9D88A2.svg)]()
[![Requires Swift 4.0](https://img.shields.io/badge/Swift-4.0-ee4f37.svg)]()
[![Requires Xcode 9](https://img.shields.io/badge/Xcode-9%20and%20later-blue.svg)]()

AlternateIcons is a Swift script that automates adding alternate app icons to your iOS app. Group your alternate icons inside an asset catalog, add a build phase and let the script set up your app. No more manual maintenance required!

## Installation

### From a Pre-built Archive

You can download a pre-compiled binary for the version you want to install in the [Releases](https://github.com/alexaubry/alternate-icons/releases) section of this repository.

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

1. Add your main icon to your main asset catalog.

2. Create a new Xcode asset catalog to store your icons, and **do not add it to your target**.

> **NOTE** In this example, we'll name the catalog "AlternateIcons"

3. Add your alternate app icons to this asset catalog, using the '*New iOS App Icon*' template.

4. In the Build Phases section of your project target, add a new Run Script phase. The script should be:

    ~~~
    embed-alternate-icons
    ~~~

    You now need to specify the path to the Asset Catalog you've created at step *2* under "Input Files", for example:
    
    ~~~
    $(SRCROOT)/AlternateIcons.xcassets
    ~~~

    **NOTE**: This Run Script phase needs to be the last build phase in your build.
    
5. Build your app.

*Et voilà*! All the icons have automatically been embedded into your app and are ready for use!

### Changing the icon

You can now change the icon in your code using: 

~~~swift
UIApplication.shared.setAlternateIconName(iconName) { error in
    // handle the result
}
~~~

Where `iconName` is the name of an icon set in your alternate icons asset catalog.

> &#128218; Read the documentation on [developer.apple.com](https://developer.apple.com/documentation/uikit/uiapplication/2806818-setalternateiconname)

## Demo

A demo project is included in the `Demo/` folder, to help you set up your app.

## How it works

Every time you build your app, the script will perform the following steps:

1. Infer the location of build artefacts from the environment variables passed by Xcode
2. Parse the Asset Catalog to build a list of icons to embed
3. Copy the alternate icon files in the app bundle
4. Update the `CFBundleIcon` and `CFBundleIcon~ipad` sections of the Info.plist with the list of alternate icon files

## Authors

Alexis Aubry, me@alexaubry.fr <[@_alexaubry](https://twitter.com/_alexaubry)>

## Acknowledgements

AlternateIcons uses these open source libraries:

- [Files](https://github.com/JohnSundell/Files) by **@JohnSundell**