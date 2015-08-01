//
//  MasterViewController.swift
//  Weekly
//
//  Created by Wooseong Kim on 2015. 7. 31..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit
import CoreData
import SnapKit

class MasterViewController: UIViewController, NSFetchedResultsControllerDelegate, UIToolbarDelegate, SwipeViewDataSource,
    SwipeViewDelegate{
    
    @IBOutlet weak var toolbar: UIToolbar!
    var naviHairlineImageView: UIImageView?
    var swipeView: SwipeView!
    
    var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        initAddButton()
        
        self.toolbar.delegate = self;
//        self.toolbar.clipsToBounds = true
        
        initNavigationBar()
        initDayOfWeekLabels()
        initSwipeView()
    }

    func initAddButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    func initNavigationBar() {
        // 네비게이션 바 아래쪽 툴바를 붙이기에, 네비바 아래쪽 줄을 안보이게 해서 툴바와 같은 뷰처럼 보이게 처리
        let naviBarWidth = self.navigationController?.navigationBar.frame.size.width
        for naviSubView in self.navigationController!.navigationBar.subviews {
            for subView in naviSubView.subviews {
                let subViewWidth = subView.bounds.size.width
                let subViewHeight = subView.bounds.size.height
                if subView.isKindOfClass(UIImageView) && subViewWidth == naviBarWidth && subViewHeight < 2 {
                    self.naviHairlineImageView = subView as? UIImageView
                }
            }
        }
    }
    
    func initDayOfWeekLabels() {
        let screenWidth = UIScreen.mainScreen().applicationFrame.width
        let labelWidth = screenWidth / 7;
        
        // 디바이스 width를 7로 나누어서 일~토 까지 width를 설정해주고, horizontal로 붙인다.
        var dayOfWeekLabels = [UILabel]();
        
        for index in 0...6 {
            let dayOfWeekLabel = UILabel()
            dayOfWeekLabel.numberOfLines = 1
            dayOfWeekLabel.textAlignment = .Center;
            dayOfWeekLabel.text = getDayOfWeekString(index)
            dayOfWeekLabel.font = UIFont.systemFontOfSize(11)
            
            dayOfWeekLabel.backgroundColor = RandomColorUtil.get()
            
            self.view.addSubview(dayOfWeekLabel)
            dayOfWeekLabels.append(dayOfWeekLabel)
            
            dayOfWeekLabel.snp_makeConstraints { (make) -> Void in
                make.top.equalTo(toolbar)
                make.width.equalTo(labelWidth)
                make.height.equalTo(labelWidth / 3)
                
                if index == 0 {
                    make.left.equalTo(self.view)
                } else if index == 6 {
                    make.right.equalTo(self.view)
                } else {
                    make.left.equalTo(dayOfWeekLabels[index-1].snp_right)
                }
            }
        }
    }
    
    func getDayOfWeekString(index: Int) -> String {
        switch index {
        case 0:
            return "일"
        case 1:
            return "월"
        case 2:
            return "화"
        case 3:
            return "수"
        case 4:
            return "목"
        case 5:
            return "금"
        case 6:
            return "토"
        default:
            return ""
        }
    }
    
    func initSwipeView() {
        swipeView = SwipeView()
        swipeView.delegate = self
        swipeView.dataSource = self
        swipeView.pagingEnabled = true;
    }
    
    // MARK: - SwipeView delegate
    
    func swipeViewItemSize(swipeView: SwipeView!) -> CGSize {
        return CGSizeMake(UIScreen.mainScreen().applicationFrame.width, 50)
    }
    
    // MARK: - SwipeView data source
    
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return 1
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        return UIView()
    }
    
    // MARK: - ViewController Cycle
    
    override func viewWillAppear(animated: Bool) {
//        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        self.naviHairlineImageView?.hidden = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.naviHairlineImageView?.hidden = false
    }
    
    // MARK:

    func insertNewObject(sender: AnyObject) {
        /*
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
             
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(NSDate(), forKey: "timeStamp")
             
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        */
    }

    // MARK: - Segues

    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    */

    // MARK: - Toolbar
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .Top
    }
    
    // MARK: - Table View

    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    */
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        cell.textLabel!.text = object.valueForKey("timeStamp")!.description
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //print("Unresolved error \(error), \(error.userInfo)")
             abort()
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    /*
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    */

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

