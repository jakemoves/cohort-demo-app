# Cohort Framework
Cohort is an audio, video, and augmented reality cueing framework. It helps you run interesting events with groups of people.

## Integrating Cohort with an Xcode project
1. [Set up your project to use CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html). Cohort is not currently available as a Pod, but all its dependencies are. Cohort is currently built using **TheAmazingAudioEngine 1.5**, **EventSource 1.0** and **AFNetworking 2.0**.
2. Clone the Cohort repo into a subfolder within your Xcode project folder. (This is 50MB because it currently includes unit tests, which require video and sound files to test with.)
3. Drag Cohort.xcodeproj into the root of your main Xcode workspace. (Doing this with Cohort.xcworkspace **will not work**)
4. Drill down in your Xcode file list to Cohort.xcodeproj/Products, and drag libCohort.a into the Linked Frameworks and Libraries list of your app target. This is now located in the General tab (not Build Phases as it used to be in older versions of Xcode).
5. In the Build Settings tab of your app target, find the Header Search Paths entry. You'll need to add the path for the Cohort framework. (I)f you ran git clone in your main project folder, this will be "cohort/Cohort").
6. In the Capabilities tab, add Audio as a Background Mode. (Note that your App Store reviewer will need an idiot-proof way to test that your app makes use of audio playback while in the background — plan ahead.)

You should now be able to use Cohort in your app.

## Using Cohort in your app
In your App Delegate, create a CHSession. This will handle all networking and A/V playback across all your views.

You'll need to spin up an instance of the Cohort Server app to handle your networking. It's a basic Server Sent Events (SSE) server written in node. We use Heroku for easy hosting and deployment. This component is outside the scope of this document. However, you'll need to add the following to your Info.plist:

```
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>cohort-server.herokuapp.com</key>
        <dict>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <false/>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSTemporaryExceptionMinimumTLSVersion</key>
            <string>TLSv1.1</string>
        </dict>
    </dict>
</dict>
```

Tell your CHSession to start listening for cues: 
```
[_session listenForCuesWithURL:[NSURL URLWithString:@"http://SERVER-URL.herokuapp.com/listen"] withCompletionHandler:^(BOOL success, NSError *error) {
    if(!success){
        NSLog(@"%@", error);
    }
}];
```

Now, a JSON POST request sent to http://SERVER-URL/broadcast (i.e., {"action": "sound-1-go"} ) should be forwarded to your app.

## Cueing with Cohort
- Cohort's stable branch currently supports only sound cues
- Cohort organizes cues into episodes. An event is made up of one or more episodes.

## Unit Testing Notes
There is [an issue](http://forum.theamazingaudioengine.com/discussion/926/xctest-problem-you-may-only-use-one-taae-instance-at-a-time) with The Amazing Audio Engine that causes problems with unit testing. To run the unit tests, search that pod for "You may only use one TAAE instance at a time" and comment out that line.

