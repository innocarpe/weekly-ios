//
//  RandomColorUtil.swift
//  Weekly
//
//  Created by Wooseong Kim on 2015. 8. 1..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit

class RandomColorUtil: NSObject {
    class func get() -> UIColor {
        let randomRed = CGFloat(drand48())
        let randomGreen = CGFloat(drand48())
        let randomBlue = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}
