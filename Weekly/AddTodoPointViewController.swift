//
//  AddTodoPointViewController.swift
//  Weekly
//
//  Created by YunSeungyong on 2015. 8. 2..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import Foundation

class AddTodoPointViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var todoTitleTextField: UITextField!
    @IBOutlet weak var todoTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var todoDatePicker: UIDatePicker!
    @IBOutlet weak var todoNoteTextView: UITextView!
    
    var managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        initSaveButton()
        
        todoTitleTextField.delegate = self
    }
    
    func initSaveButton() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "insertNewTodoPoint:")
        self.navigationItem.rightBarButtonItem = saveButton
    }

    func insertNewTodoPoint(sender: AnyObject) {
        
        if todoTitleTextField.text!.isEmpty {
            return
        }
        
        let selectedDate = todoDatePicker.date
        let selectedCalendar = todoDatePicker.calendar
        
        let components = selectedCalendar.components([.Year, .WeekOfYear, .Weekday], fromDate: selectedDate)
        
        let titleToAdd = todoTitleTextField.text!
        let noteToAdd = todoNoteTextView.text!
        let selectedYear = components.year
        let selectedWeekOfYear = components.weekOfYear
        let selectedWeekdayIndex = components.weekday - 1
        let priority = 0
        let type = todoTypeSegmentedControl.selectedSegmentIndex
        
        print("\(titleToAdd) : \(noteToAdd) [\(selectedYear).\(selectedWeekdayIndex).\(selectedWeekOfYear)] \(priority) , (\(type))")
        
        
        TodoPoint.createInManagedObjectContext(managedObjectContext, title: titleToAdd, note: noteToAdd, year: selectedYear, weekOfYear: selectedWeekOfYear, weekDay: selectedWeekdayIndex, priority: priority, type:type)
        
        save()
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func save() {
        do {
            try managedObjectContext.save()
        } catch{
            print(error)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        todoTitleTextField.resignFirstResponder()
        
        return true
    }
    
}
