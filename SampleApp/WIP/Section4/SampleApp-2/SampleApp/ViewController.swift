//
//  ViewController.swift
//  SampleApp
//
//  Created by Udemy on 2018/09/27.
//  Copyright © 2018 Hidehiko Kondo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("viewDidLoad")
        
        self.titleLabel.text = "AppTitle"
        self.titleLabel.textColor = UIColor.black
        self.titleLabel.font = UIFont.init(name: "Helvetica", size: 30)
    }
    
    // 画面表示する直前
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewWillAppear")
        
    }
    
    // 画面表示直後
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        
    }
    
    // 画面遷移などで画面が消える直前
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        
    }
    
    // 画面遷移などで画面が消えた直後
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
        
    }
    
    
    @IBAction func touchButton(_ sender: Any) {
        print("touch button")
    }
    

}

