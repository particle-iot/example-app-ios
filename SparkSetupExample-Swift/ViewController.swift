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
    
    func sparkSetupViewController(controller: SparkSetupMainController!, didFinishWithResult result: SparkSetupMainControllerResult, device: SparkDevice!) {
        
        switch result
        {
        case .Success: println("Setup completed successfully")
        case .Failure: println("Setup failed")
        case .UserCancel : println("User cancelled setup")
        }
        
        if device != nil
        {
            device.getVariable("test", completion: { (value, err) -> Void in

            })
        }
    }
    
    
//    
//    -(void)checkFontNames
//    {
//        for (NSString* family in [UIFont familyNames])
//        {
//            NSLog(@"%@", family);
//    
//            for (NSString* name in [UIFont fontNamesForFamilyName: family])
//            {
//                NSLog(@"  %@", name);
//            }
//        }
//    }

    
    func checkFontNames()
    {
        for family in UIFont.familyNames()
        {
            print("\(family)\n")
            for name in UIFont.fontNamesForFamilyName(family as! String)
            {
                print("   \(name)\n")
            }
            
        }
    }
    
    
    func customizeSetup()
    {
        self.checkFontNames()
        let c = SparkSetupCustomization.sharedInstance()
        c.brandImage = UIImage(named: "brand-logo-head")
        c.brandName = "Acme"
        c.brandImageBackgroundColor = UIColor(red: 0.88, green: 0.96, blue: 0.96, alpha: 0.9)
        c.appName = "Acme Setup"
        c.deviceImage = UIImage(named: "anvil")
        c.deviceName = "Connected Anvil"
        c.welcomeVideoFilename = "rr.mp4"

        c.normalTextFontName = "Skater Girls Rock"
        c.boldTextFontName = "CheriLiney"
        c.fontSizeOffset = 2;
    }
    
    @IBAction func startButtonTapped(sender: UIButton)
    {
//        self.customizeSetup()
        
        if let vc = SparkSetupMainController()
        {
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }

    
}

