# iOS Example App

Barebones Swift iOS app showcasing basic ParticleSetup / Particle-SDK cocoapods usage / getting started.

Built using XCode 9.4.1 (Swift 4)

### How to run the example?

1. Clone this repo
1. Open shell window and navigate to project folder
1. Run `pod install`
1. Open `ios-app-particle-setup.xcworkspace` and run the project on selected device or simulator

### How was it created?

1. Open XCode. File->New->Project->Single View App->Your project name
1. Create Podfile with your target name and Particle pods reference (see file)
1. Close XCode Project
1. Open shell window and navigate to the project folder
1. Run `pod install` (make sure your have latest [Cocoapods](https://guides.cocoapods.org/using/getting-started.html#installation)  installed), pods will be installed and new XCode workspace file will be created.
1. in XCode open the new `<your project name>.xcworkspace`
1. Add bridging header - see file `Particle-Bridging-Header.h` for reference.
1. Go to project settings->build settings->Objective-C bridging header->type in `./<your project name folder>/Particle-Bridging-Header.h` (or wherever file is located).
1. Create the source code and storyboard for your app (see `ViewController.swift` and `Main.storyboard` for reference)
1. Build and run - works on simulator and device (no need to do any modifications to Keychain settings)
1. Click "Start setup" on the phone and onboard a new Photon to your account.

### Code

ViewController invoking Particle setup must adhere to the `ParticleSetupMainControllerDelegate` protocol and implement (at least) the funcion `func particleSetupViewController(_ controller: ParticleSetupMainController!, didFinishWith result: ParticleSetupMainControllerResult, device: ParticleDevice!)`.

To invoke setup:

```
if let setupController = ParticleSetupMainController()
{
    setupController.delegate = self //as! UIViewController & ParticleSetupMainControllerDelegate
    self.present(setupController, animated: true, completion: nil)
}
```

To reference the Particle cloud use: `ParticleCloud.sharedInstance()`,
to reference a device use: `var device : ParticleDevice` or use a returned device instance from a cloud function like:

```
if device != nil
{
    device.getVariable("test", completion: { (value, err) -> Void in
        print(value)
    })
}
```

For questions - refer to Particle mobile knowledgebase/community here: https://community.particle.io/c/mobile

Good luck!
