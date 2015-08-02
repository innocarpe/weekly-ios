//
//  TodoPointCell.swift
//  Weekly
//
//  Created by YunSeungyong on 2015. 8. 2..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit
import Foundation

@objc protocol TodoPointCellDelegate {
    func doneStateChange(state: NSNumber, section:Int, row: Int)
}

class TodoPointCell: UITableViewCell {
    
    var delegate : TodoPointCellDelegate?
    
    var currentSection : Int?
    var currentRow : Int?
    var currentState : NSNumber?
    var state : NSNumber {
        get {
            return currentState!
        }
        set(newState) {
            if newState == 0 {
                currentState = 0
                let undoneIcon = UIImage(named: "TodoUndoneIcon")
                imageView?.image = undoneIcon
                textLabel?.textColor = UIColor.blackColor()
            } else {
                currentState = 1
                let doneIcon = UIImage(named: "TodoDoneIcon")
                imageView?.image = doneIcon
                textLabel?.textColor = UIColor.lightGrayColor()
            }
            
            currentState = newState
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = UITableViewCellSelectionStyle.None
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:"imageTapped:")
        tapGestureRecognizer.numberOfTapsRequired = 1;
        imageView?.userInteractionEnabled = true
        imageView!.addGestureRecognizer(tapGestureRecognizer)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageTapped(sender: AnyObject) {
        if currentState == 0 {
            changeToDone()
        } else {
            changeToUndone()
        }
    }
    
    func changeToDone() {
        currentState = 1
        let doneIcon = UIImage(named: "TodoDoneIcon")
        imageView?.image = doneIcon
        textLabel?.textColor = UIColor.lightGrayColor()
        
        delegate?.doneStateChange(state, section: currentSection!, row: currentRow!)
    }
    
    func changeToUndone() {
        currentState = 0
        let undoneIcon = UIImage(named: "TodoUndoneIcon")
        imageView?.image = undoneIcon
        textLabel?.textColor = UIColor.blackColor()
        
//        NSStrike
//        
//        var string = NSMutableAttributedString(string: (textLabel?.text)!)
//        string.addAttribute(NSStrikethroughStyleAttributeName, value: nil range: NSRange(0,(textLabel?.text)!.):@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)} range:[text rangeOfString:retailPrice]];
//        [self.label setAttributedText:string];
        
        delegate?.doneStateChange(state, section: currentSection!, row: currentRow!)
    }
    
}
