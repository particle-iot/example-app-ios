//
//  ViewController.swift
//  SparkSetupExample-Swift
//
//  Created by Ido on 4/7/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SparkSetupMainControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Function will be called when setup finishes
    func sparkSetupViewController(controller: SparkSetupMainController!, didFinishWithResult result: SparkSetupMainControllerResult, device: SparkDevice!) {
        
        switch result
        {
            case .Success:
                print("Setup completed successfully")
            case .Failure:
                print("Setup failed")
            case .UserCancel :
                print("User cancelled setup")
            case .LoggedIn :
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
        // Do customization for Spark Setup wizard UI
        let c = SparkSetupCustomization.sharedInstance()
        c.brandImage = UIImage(named: "brand-logo-head")
        c.brandName = "Acme"
        c.brandImageBackgroundColor = UIColor(red: 0.88, green: 0.96, blue: 0.96, alpha: 0.9)
//        c.appName = "Acme Setup"
//        c.deviceImage = UIImage(named: "anvil")
        c.deviceName = "Connected Anvil"
        c.instructionalVideoFilename = "rr.mp4"

        c.normalTextFontName = "Skater Girls Rock"
        c.boldTextFontName = "CheriLiney"
        c.fontSizeOffset = 1;
    }
    
    @IBAction func startButtonTapped(sender: UIButton)
    {
        // Comment out this line to revert to default "Unbranded" Spark Setup app
//        self.customizeSetup()
        
        

        // lines required for invoking the Spark Setup wizard
        if let vc = SparkSetupMainController()
        {
            
            // check organization setup mode
            let c = SparkSetupCustomization.sharedInstance()
            c.allowSkipAuthentication = true
            
            vc.delegate = self
            vc.modalPresentationStyle = .FormSheet  // use that for iPad
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func runSDKFuncs(sender: AnyObject) {
        self.example()
    }
    
    func example()
    {
        let loginGroup : dispatch_group_t = dispatch_group_create()
        let deviceGroup : dispatch_group_t = dispatch_group_create()
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        let deviceName = "turtle_gerbil"
        let functionName = "testFunc"
        let variableName = "testVar"
        var myPhoton : SparkDevice? = nil
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // logging in
            dispatch_group_enter(loginGroup);
            dispatch_group_enter(deviceGroup);
            if SparkCloud.sharedInstance().loggedInUsername == nil
            {
                let keys = SparksetupexampleswiftKeys()
                SparkCloud.sharedInstance().loginWithUser(keys.particleUsername(), password: keys.particlePassword()) { (error:NSError?) -> Void in
                    if let _=error
                    {
                        print("Wrong credentials or no internet connectivity, please try again")
                    }
                    else
                    {
                        print("Logged in with user "+keys.particleUsername())
                        dispatch_group_leave(loginGroup)
                    }
                }
            } else {
                print("Already logged in with user "+SparkCloud.sharedInstance().loggedInUsername!)
                dispatch_group_leave(loginGroup)
            }
        }
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // logging in
            dispatch_group_wait(loginGroup, DISPATCH_TIME_FOREVER)
            
            // get specific device by name:
            SparkCloud.sharedInstance().getDevices { (sparkDevices:[AnyObject]?, error:NSError?) -> Void in
                if let _=error
                {
                    print("Check your internet connectivity")
                }
                else
                {
                    if let devices = sparkDevices as? [SparkDevice]
                    {
                        for device in devices
                        {
                            if device.name == deviceName
                            {
                                print("found a device with name "+deviceName+" in your account")
                                myPhoton = device
                                dispatch_group_leave(deviceGroup)
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
        
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // logging in
            dispatch_group_wait(deviceGroup, DISPATCH_TIME_FOREVER)
            dispatch_group_enter(deviceGroup);

            print("subscribing to event...");
            var gotFirstEvent : Bool = false
            myPhoton!.subscribeToEventsWithPrefix("test", handler: { (event: SparkEvent?, error:NSError?) -> Void in
                if (!gotFirstEvent) {
                    print("Got first event: "+event!.event)
                    gotFirstEvent = true
                    dispatch_group_leave(deviceGroup)
                } else {
                    print("Got event: "+event!.event)
                }
            });
        }
        
        
        // calling a function
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // logging in
            dispatch_group_wait(deviceGroup, DISPATCH_TIME_FOREVER) // 5
            dispatch_group_enter(deviceGroup);
            
            let funcArgs = ["D7",1]
            myPhoton!.callFunction(functionName, withArguments: funcArgs) { (resultCode : NSNumber?, error : NSError?) -> Void in
                if (error == nil) {
                    print("Successfully called function "+functionName+" on device "+deviceName)
                    dispatch_group_leave(deviceGroup)
                } else {
                    print("Failed to call function "+functionName+" on device "+deviceName)
                }
            }
        }
        
        
        // reading a variable
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // logging in
            dispatch_group_wait(deviceGroup, DISPATCH_TIME_FOREVER) // 5
            dispatch_group_enter(deviceGroup);
            
            myPhoton!.getVariable(variableName, completion: { (result:AnyObject?, error:NSError?) -> Void in
                if let _=error
                {
                    print("Failed reading variable "+variableName+" from device")
                }
                else
                {
                    if let res = result as? Int
                    {
                        print("Variable "+variableName+" value is \(res)")
                        dispatch_group_leave(deviceGroup)
                    }
                }
            })
        }
        
        
        // get device variables and functions
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // logging in
            dispatch_group_wait(deviceGroup, DISPATCH_TIME_FOREVER) // 5
            dispatch_group_enter(deviceGroup);
            
            let myDeviceVariables : Dictionary? = myPhoton!.variables as Dictionary<String,String>
            print("MyDevice first Variable is called \(myDeviceVariables!.keys.first) and is from type \(myDeviceVariables?.values.first)")
            
            let myDeviceFunction = myPhoton!.functions
            print("MyDevice first function is called \(myDeviceFunction.first)")
            dispatch_group_leave(deviceGroup)
        }
        
        // logout
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // logging in
            dispatch_group_wait(deviceGroup, DISPATCH_TIME_FOREVER) // 5
            
            SparkCloud.sharedInstance().logout()
            print("logged out")
        }
        
        /*
        
        // get a device instance by ID
        var myOtherDevice : SparkDevice? = nil
        SparkCloud.sharedInstance().getDevice("53fa73265066544b16208184", completion: { (device:SparkDevice?, error:NSError?) -> Void in
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

