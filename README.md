# AlternateIcons

AlternateIcons is an Xcode build script that enables using Asset Catalogs to add alternate app icons to your iOS app. It takes care of copying the icon assets to your app bundle and correctly updating the Info.plist. No more manual setup required!

## Installation

You can build and install AlternateIcons with **Make**:

~~~bash
git clone https://github.com/alexaubry/alternate-icons.git
cd alternate-icons
make install
~~~

**NOTE**: AlternateIcons requires Swift 3.1 and is only compatible with macOS Yosemite (10.10) and above.

## Setting up your app

To set up AlternateIcons as an Xcode build phase, do the following:

1. Create a new Xcode asset catalog to hold your icons, and **do not add it to your target**.

2. Add your primary and alternate app icons to this asset catalog, using the '*New iOS App Icon*' template.

    **NOTE**: The primary icon needs to be named `AppIcon`.

3. In the General section of your project target, select 'Do not use Asset Catalog' in the App Icon Source setting. If you don't see this option and you have a 'Use Asset Catalog' button, you can skip this step *3*.

4. In the Build Phases section of your project target, add a new Run Script phase. The script should be:

    ~~~
    embed-alternate-icons
    ~~~

    You now need to add the path to the Asset Catalog you've created at step *1* under "Input Files", e.g.:
    
    ~~~
    $(SRCROOT)/Icons.xcassets
    ~~~

    **NOTE**: This Run Script phase needs to be situated after all the 'Copy Bundle Resources' and 'Copy Files' phases.
    
5. Build your app.

TADA! You've embedded alternate icons into your app!

You can now change the icon in your app using: 

~~~swift
UIApplication.shared.setAlternateIconName("%AlternateIcon%", completionHandler: nil)
~~~

Replace `"%AlternateIcon%"` by the name of the icon's set in the Asset Catalog created at step *1*.

## How it works

Every time you build your app, the script will perform the following steps:

1. Infer the location of build artefacts from build environment variables passed by Xcode
2. Parse the Asset Catalog to get the list of icons to embed
3. Delete any icon you've removed from the Asset Catalog
4. Update the `CFBundleIcon` section of the Info.plist in the app bundle (not in your source code, to avoid trouble with version control)
5. Copy the new icons in the app bundle

## Acknowledgements

AlternateIcons uses these open source libraries:

- [Unbox](https://github.com/JohnSundell/Unbox) by **@JohnSundell**
- [Files](https://github.com/JohnSundell/Files) by **@JohnSundell**