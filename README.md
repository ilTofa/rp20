Introduction
------------

[Radio Paradise](http://www.radioparadise.com) is a unique blend of many styles and genres of music, carefully selected and mixed by two real human beings — enhanced by a dazzling photo slideshow, tied in thematically with the songs that are playing. There's nothing else that's quite like it.

You'll hear modern and classic rock, world music, electronica, even a bit of classical and jazz — with no random computer-generated playlists, needless chatter, or commercials. The mix always includes a carefully-selected assortment of new songs & artists, many of which you won't hear anywhere else. Most selections are in English, but Radio Paradise always keeps an ear open for great music in other languages. 

The radio specialty is taking a diverse assortment of songs and making them flow together in a way that makes sense harmonically, rhythmically, and lyrically — an art that, to us, is the very essence of radio. If you don't care for what's playing at the moment, the PSD (Play Something Different) feature will select an alternative for you, then return you to the main playlist flow when it's done.

The Application
---------------

The application has been coded by myself, [Giacomo Tufano](http://www.ilTofa.com), and it's source is released with the MIT license. The project started initially as a personal (and unofficial) *"itch to scratch"* and currently it is the official iOS client for Radio Paradise, directly distributed (as a free application) on the [App Store](http://itunes.apple.com/app/id517818306). The app main website is @[ilTofa.com](http://www.iltofa.com/rphd/index.html). An OS X version is also open sourced and in the works in its github repository. Fixes, code and forks are warmly welcomed. Just ask me if you need help or hints.

The code
--------

The iOS streaming code is based on AVPlayer, that manage all the audio play (both "standard" and PSD).

UI
---

UI is based on .xib, not storyboards (code is born as iOS 4 compatible). While there are xibs for the main UI the object placement is completely made in code (in RPViewController+UI class category), the xib are there for the outlet connection (and for historical reason). 

The *real* layout is on RPiPadTestsViewController.xib, RPiPhone4TestController.xib and RPiPhone5TestController.xib, that are there only as mockup (are not tied to the target and not included in compilation). Here there are handlers for interface setup for play, stop and psd, the changes in layout triggered by the touches and the rotation management.

RPTVViewController is the handler for the AirPlay output to Apple TV. Init of the TV output controlelr is in the AppDelegate.

Main Controller
---------------

The main controller is RPViewController. Code is hopefully easy to follow. There are 3 AVPlayer objects to manage the main stream and the PSD stream (PSD needs two object to manage the "PSD to PSD transition"), state transitions for the streams are managed via KVO.

Metadata about the played song are taken directly from radio paradise (not from the stream metadata, because AVPlayer do not supports them for network streams), a NSTimer handles the task (in -[metatadaHandler:timer]). Another NSTimer manages the load of the images for the HD stream (in -[loadNewImage:timer]). PSD play is triggered and managed here. The "return" from the PSD is also timer-triggered.

The management of UI state and stream start is via KVO.

The main controllers also tries to manage the fading between the main stream and the PSD streams. Unfortunately volume controls (and therefore the fading) don't work on main stream. This is a know limitation of AVPlayer (cfr. [Apple's qa1716](http://developer.apple.com/library/ios/#qa/qa1716/_index.html) ). The fading work on the PSD songs.

The application logs heavily when DLog() (defined in RadioParadise-Prefix.pch) is set to have output. Be aware to not distribute the application with logging on (it's really verbose).

Tunemarks management
--------------------

is in the *SongsInTheCloud* group in the project. The saved songs are saved to a CoreData db synced via iCloud. It works reasonably well, with the usual *caveats* attached to the Core Data iCloud sync model. In the group there are also a bunch of categories needed for iOS 5 compatibility and to manage the songs db and a modified (for iOS 5 compatibility) CoreDataController (taken originally from Apple WWDC 2012 Core Data session).

Acknowledgements
----------------

This application uses code from:

[UIImage+RoundedCorner](https://gist.github.com/benilovj/2009030) by Trevor Harmon (slightly modified)

[Appirater](https://github.com/arashpayan/appirater/) by Arash Payan

[SDCloudUserDefaults](https://github.com/sdarlington/SDCloudUserDefaults) by Stephen Darlington

[STKeyChain](https://github.com/ldandersen/STUtils/blob/master/Security/STKeychain.m) by Buzz Andersen