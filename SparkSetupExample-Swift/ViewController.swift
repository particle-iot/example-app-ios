//
//  ViewController.swift
//  ParticleSetupExample-Swift
//
//  Created by Ido on 4/7/15.
//  Copyright (c) 2015 Particle. All rights reserved.
//

import UIKit


class ViewController: UIViewController, ParticleSetupMainControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func particleSetupViewController(_ controller: ParticleSetupMainController!, didFinishWith result: ParticleSetupMainControllerResult, device: ParticleDevice!) {
        
        switch result
        {
            case .success:
                print("Setup completed successfully")
            case .failureConfigure:
                fallthrough
            case .failureCannotDisconnectFromDevice:
                fallthrough
            case .failureLostConnectionToDevice:
                fallthrough
            case .failureClaiming:
                print("Setup failed")
            case .userCancel :
                print("User cancelled setup")
            case .loggedIn :
                print("User is logged in")
            default:
                print("Uknown setup error")
            
        }
        
        if device != nil
        {
            device.getVariable("test", completion: { (value, err) -> Void in

            })
        }
    }
    
    
    func customizeSetup()
    {
        // Do customization for Particle Setup wizard UI
        let c = ParticleSetupCustomization.sharedInstance()
        c?.brandImage = UIImage(named: "brand-logo-head")
        c?.brandName = "Acme"
        c?.brandImageBackgroundColor = UIColor(red: 0.88, green: 0.96, blue: 0.96, alpha: 0.9)
//        c.appName = "Acme Setup"
//        c.deviceImage = UIImage(named: "anvil")
        c?.deviceName = "Connected Anvil"
        c?.instructionalVideoFilename = "rr.mp4"

        c?.normalTextFontName = "Skater Girls Rock"
        c?.boldTextFontName = "CheriLiney"
        c?.fontSizeOffset = 1;
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton)
    {
        // Comment out this line to revert to default "Unbranded" Particle Setup app
//        self.customizeSetup()
        
        

        // lines required for invoking the Particle Setup wizard
        if let vc = ParticleSetupMainController()
        {
            
            // check organization setup mode
            let c = ParticleSetupCustomization.sharedInstance()
            c?.allowSkipAuthentication = true
            
            vc.delegate = self
            vc.modalPresentationStyle = .formSheet  // use that for iPad
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func runSDKFuncs(_ sender: Any) {
        self.example()
    }
    
    func example()
    {
        let loginGroup : DispatchGroup = DispatchGroup()
        let deviceGroup : DispatchGroup = DispatchGroup()
        let priority = DispatchQueue.GlobalQueuePriority.default
        let deviceName = "turtle_gerbil" // change to your particular device name
        let functionName = "testFunc"
        let variableName = "testVar"
        var myPhoton : ParticleDevice? = nil
        var myEventId : Any?
        
        DispatchQueue.global(priority: priority).async {
            // logging in
            loginGroup.enter();
            deviceGroup.enter();
            if ParticleCloud.sharedInstance().isAuthenticated {
                print("logging out of old session")
                ParticleCloud.sharedInstance().logout()
            }
            
            let keys = SparksetupexampleswiftKeys()
//            ParticleCloud.sharedInstance().loginWithUser(keys.particleUsername(), password: keys.particlePassword()) { (error:NSError?) -> Void in
            ParticleCloud.sharedInstance().injectSessionAccessToken("ec05695c1b224a262f1a1e92d5fc2de912cebbe1")
            if false {
//                if let _=error
//                {
                    print("Wrong credentials or no internet connectivity, please try again")
                }
                else
                {
                    print("Logged in with user "+keys.particleUsername())
                    loginGroup.leave()
                }
//            }
        }
        
        DispatchQueue.global(priority: priority).async {
            // logging in
            loginGroup.wait(timeout: DispatchTime.distantFuture)
            
            // get specific device by name:
            ParticleCloud.sharedInstance().getDevices { (particleDevices:[ParticleDevice]?, error:Error?) -> Void in
                if let _=error
                {
                    print("Check your internet connectivity")
                }
                else
                {
                    if let devices = particleDevices
                    {
                        for device in devices
                        {
                            if device.name == deviceName
                            {
                                print("found a device with name "+deviceName+" in your account")
                                myPhoton = device
                                deviceGroup.leave()
                            }
                            
                        }
                        if (myPhoton == nil)
                        {
                            print("device with name "+deviceName+" was not found in your account")
                        }
                    }
                }
            }
        }
        
        
        DispatchQueue.global(priority: priority).async {
            // logging in
            deviceGroup.wait(timeout: DispatchTime.distantFuture)
            deviceGroup.enter();

            print("subscribing to event...");
            var gotFirstEvent : Bool = false
            myEventId = myPhoton!.subscribeToEvents(withPrefix: "test", handler: { (event: ParticleEvent?, error:Error?) -> Void in
                if (!gotFirstEvent) {
                    print("Got first event: "+event!.event)
                    gotFirstEvent = true
                    deviceGroup.leave()
                } else {
                    print("Got event: "+event!.event)
                }
            });
        }
        
        
        // calling a function
        DispatchQueue.global(priority: priority).async {
            // logging in
            deviceGroup.wait(timeout: DispatchTime.distantFuture) // 5
            deviceGroup.enter();
            
            let funcArgs = ["D7",1] as [Any]
            myPhoton!.callFunction(functionName, withArguments: funcArgs) { (resultCode : NSNumber?, error : Error?) -> Void in
                if (error == nil) {
                    print("Successfully called function "+functionName+" on device "+deviceName)
                    deviceGroup.leave()
                } else {
                    print("Failed to call function "+functionName+" on device "+deviceName)
                }
            }
        }
        
        
        // reading a variable
        DispatchQueue.global(priority: priority).async {
            // logging in
            deviceGroup.wait(timeout: DispatchTime.distantFuture) // 5
            deviceGroup.enter();
            
            myPhoton!.getVariable(variableName, completion: { (result:Any?, error:Error?) -> Void in
                if let _=error
                {
                    print("Failed reading variable "+variableName+" from device")
                }
                else
                {
                    if let res = result as? Int
                    {
                        print("Variable "+variableName+" value is \(res)")
                        deviceGroup.leave()
                    }
                }
            })
        }
        
        
        // get device variables and functions
        DispatchQueue.global(priority: priority).async {
            // logging in
            deviceGroup.wait(timeout: DispatchTime.distantFuture) // 5
            deviceGroup.enter();
            
            let myDeviceVariables : Dictionary? = myPhoton!.variables as Dictionary<String,String>
            print("MyDevice first Variable is called \(myDeviceVariables!.keys.first) and is from type \(myDeviceVariables?.values.first)")
            
            let myDeviceFunction = myPhoton!.functions
            print("MyDevice first function is called \(myDeviceFunction.first)")
            deviceGroup.leave()
        }
        
        // logout
        DispatchQueue.global(priority: priority).async {
            // logging in
            deviceGroup.wait(timeout: DispatchTime.distantFuture) // 5
            
            if let eId = myEventId {
                myPhoton!.unsubscribeFromEvent(withID: eId)
            }
            ParticleCloud.sharedInstance().logout()
            
            print("logged out")
        }
        
        /*
        
        // get a device instance by ID
        var myOtherDevice : ParticleDevice? = nil
        ParticleCloud.sharedInstance().getDevice("53fa73265066544b16208184", completion: { (device:ParticleDevice?, error:NSError?) -> Void in
            if let d = device {
                myOtherDevice = d
            }
        })

        // rename a device
        myPhoton!.name = "myNewDeviceName"
            // or:
        myPhoton!.rename("myNewDeviceName", completion: { (error:NSError?) -> Void in
            if (error == nil) {
                print("Device successfully renamed")
            }
            
        })

        */

        

    }

    
    
}

