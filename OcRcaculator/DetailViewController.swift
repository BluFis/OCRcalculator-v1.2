//
//  DetailViewController.swift
//  OcRcaculator
//
//  Created by Apple on 2017/8/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var chiView: UIView!

    @IBOutlet weak var engView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        chiView.alpha = 1
        engView.alpha = 0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backBtn(_ sender: Button) {
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func choice(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0{
            chiView.alpha = 1
            engView.alpha = 0
        }else{
            chiView.alpha = 0
            engView.alpha = 1
        }
        
        
    }

}
