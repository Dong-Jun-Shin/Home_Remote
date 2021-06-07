//
//  LaunchScreenController.swift
//  Home_Remote
//
//  Created by 임시 사용자 (DJ) on 2021/06/06.
//


import UIKit

class LaunchScreeenController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let seconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: {print("delay")})
    }
}
