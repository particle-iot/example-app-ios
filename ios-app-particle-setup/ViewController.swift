//
//  ViewController.swift
//  ios-app-particle-setup
//
//  Created by Ido Kleinman on 3/9/18.
//  Copyright © 2018 Particle. All rights reserved.
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
    
    
    func particleSetupViewController(_ controller: ParticleSetupMainController!, didNotSucceeedWithDeviceID deviceID: String!) {
        print("Oh no setup failed")
        
    }
    

    @IBAction func startParticleSetup(_ sender: Any) {
        if let setupController = ParticleSetupMainController()
        {
            setupController.delegate = self //as! UIViewController & ParticleSetupMainControllerDelegate
            self.present(setupController, animated: true, completion: nil)
        }
    }
    
}

