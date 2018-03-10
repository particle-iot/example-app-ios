# iOS-app-particle-setup

Barebones Swift iOS app showcasing basic ParticleSetup / Particle-SDK cocoapods usage / getting started.
Tools versioning used: macOS 10.13.3, XCode 9.2, Cocoapods 1.4, Particle-SDK pod 0.7, ParticleSetup pod 0.8

### How was it created?

1. Open XCode. File->New->Project->Single View App->Your project name
1. Create Podfile with your target name and Particle pods reference (see file)
1. Close XCode Project
1. Open shell window and navigate to the project folder
1. Run `pod install` (make sure your have latest [Cocoapods](https://guides.cocoapods.org/using/getting-started.html#installation)  installed), pods will be installed and new XCode workspace file will be createdand
1. in XCode open the new <your project name>.xcworkspace
1. Add bridging header - see file `Particle-Bridging-Header.h`  for reference.
1. Go to project settings->build settings->Objective-C bridging header->type in `./<your project name folder>/Particle-Bridging-Header.h`
1. Create the source code and storyboard for your app (see `ViewController.swift` and `Main.storyboard` for reference)
1. Build and run - works on simulator and device (no need to do any modifications to Keychain settings)

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










