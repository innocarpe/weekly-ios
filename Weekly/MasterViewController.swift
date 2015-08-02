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
    SwipeViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let DAY_LABEL_INSET: CGFloat = 6
    
    var toolbar: UIToolbar!
    var naviHairlineImageView: UIImageView?
    var dayOfWeekLabels: [UILabel]!
    var swipeView: SwipeView!
    var tableView: UITableView!
    
    var selectedYear: Int = 0
    var selectedWeekOfYear: Int = 0
    var selectedWeekdayIndex: Int = 0 // 1 = Sunday, 7 = Saturday 에서 -1 처리함
    
    var visionTodoPoints = [TodoPoint]()
    var dailyTodoPoints = [TodoPoint]()
    var weeklyTodoPoints = [TodoPoint]()
    
    var managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        // Model
        initDate()
        
        // UI
        initAddButton()
        initToolbar()
        initNavigationBar()
        initDayOfWeekLabels()
        initSwipeView()
        
        // TODO: 나중에 지워야할 더미 데이터
        addDummys()
        initTableView()
    }
    
    func initDate() {
        // 오늘 날짜를 구해 요일 번호를 구한다
        let calendar = NSCalendar.autoupdatingCurrentCalendar()
        let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: NSDate())
        selectedYear = components.year
        selectedWeekOfYear = components.weekOfYear
        selectedWeekdayIndex = components.weekday - 1
    }

    func initAddButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewTodoPoint:")
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    func initToolbar() {
        toolbar = UIToolbar()
        self.view.addSubview(toolbar)
        toolbar.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo((self.topLayoutGuide as AnyObject as! UIView).snp_bottom)
        }
        toolbar.delegate = self;
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
        dayOfWeekLabels = [UILabel]();
        
        for index in 0...6 {
            let dayOfWeekLabel = UILabel()
            dayOfWeekLabel.numberOfLines = 1
            dayOfWeekLabel.textAlignment = .Center;
            dayOfWeekLabel.text = getDayOfWeekString(index)
            dayOfWeekLabel.font = UIFont.systemFontOfSize(11)

            self.view.addSubview(dayOfWeekLabel)
            dayOfWeekLabels.append(dayOfWeekLabel)
            
            dayOfWeekLabel.snp_makeConstraints { (make) -> Void in
                make.top.equalTo(toolbar)
                make.width.equalTo(labelWidth)
                make.height.equalTo(labelWidth / 3)
                
                if index == 0 {
                    make.leading.equalTo(self.view)
                    dayOfWeekLabel.textColor = UIColor.grayColor()
                } else if index == 6 {
                    make.trailing.equalTo(self.view)
                    dayOfWeekLabel.textColor = UIColor.grayColor()
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
        swipeView.pagingEnabled = true
        
        self.view.addSubview(swipeView)
        
        let screenWidth = UIScreen.mainScreen().applicationFrame.width
        let labelWidth = screenWidth / 7;
        
        swipeView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(dayOfWeekLabels[0].snp_bottom).offset(4)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(labelWidth)
        }

        // toolbar 아래쪽을 SwipeView 아래쪽과 맞춤(높이 조정)
        toolbar.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(swipeView.snp_bottom).offset(8)
        }
        
        // TODO: UI test
//        swipeView.backgroundColor = RandomColorUtil.get()
//        swipeView.backgroundColor = UIColor.clearColor()
    }
    
    func addDummys() {
        let items = [
            ("(Vision) Vision Point", "My vision is...", selectedYear, 0, 0, 0, 0),
            ("(Weekly) Weekly Point", "My weekly point 1 is", selectedYear, selectedWeekOfYear, 0, 0, 1),
            ("(Weekly) Weekly Point", "My weekly point 2 is", selectedYear, selectedWeekOfYear, 0, 0, 1),
            ("(Weekly) Weekly Point", "My weekly point 2 is", selectedYear, selectedWeekOfYear + 1, 0, 0, 1),
            ("(Daily) Daily Point", "My daily point 1 is", selectedYear, selectedWeekOfYear, selectedWeekdayIndex, 0, 2),
            ("(Daily) Daily Point", "My daily point 2 is", selectedYear, selectedWeekOfYear, selectedWeekdayIndex, 0, 2),
            ("(Daily) Daily Point", "My daily point 3 is", selectedYear, selectedWeekOfYear, selectedWeekdayIndex, 0, 2),
            ("(Daily) Daily Point", "My daily point 4 is", selectedYear, selectedWeekOfYear, selectedWeekdayIndex, 0, 2),
            ("(Daily) Daily Point", "My daily point 1 is", selectedYear, selectedWeekOfYear, selectedWeekdayIndex - 1, 0, 2),
            ("(Daily) Daily Point", "My daily point 2 is", selectedYear, selectedWeekOfYear, selectedWeekdayIndex - 1, 0, 2),
            ("(Daily) Daily Point", "My daily point 3 is", selectedYear, selectedWeekOfYear, selectedWeekdayIndex - 1, 0, 2),
            ("(Daily) Daily Point", "My daily point 4 is", selectedYear, selectedWeekOfYear, selectedWeekdayIndex - 1, 0, 2)
        ]
        
        for(itemTitle, itemNote, year, weekOfYear, weekDay, priority, type) in items {
            TodoPoint.createInManagedObjectContext(managedObjectContext, title: itemTitle, note: itemNote, year: year, weekOfYear: weekOfYear, weekDay: weekDay, priority: priority, type:type)
        }
    }
    
    func initTableView() {
        tableView = UITableView()
        self.view.addSubview(tableView)
        self.view.sendSubviewToBack(tableView)
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(toolbar.snp_bottom)
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo((self.bottomLayoutGuide as AnyObject as! UIView).snp_top)
        }
        
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "TodoPoint")
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchVisionTodoPoint()
        fetchWeeklyTodoPoint()
        fetchDailyTodoPoint()
    }
    
    func fetchVisionTodoPoint() {
        let fetchRequest = NSFetchRequest(entityName: "TodoPoint")
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "type == %i", 0)
        fetchRequest.predicate = predicate
        
        do {
            if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [TodoPoint] {
                visionTodoPoints = fetchResults
            }
        } catch {
            print(error)
        }
    }
    
    func fetchWeeklyTodoPoint() {
        let fetchRequest = NSFetchRequest(entityName: "TodoPoint")
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate1 = NSPredicate(format: "type == %i", 1)
        let predicate2 = NSPredicate(format: "year == %i", selectedYear)
        let predicate3 = NSPredicate(format: "weekOfYear == %i", selectedWeekOfYear)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicate1, predicate2, predicate3])
        
        fetchRequest.predicate = predicate
        
        do {
            if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [TodoPoint] {
                weeklyTodoPoints = fetchResults
            }
        } catch {
            print(error)
        }
    }
    
    func fetchDailyTodoPoint() {
        let fetchRequest = NSFetchRequest(entityName: "TodoPoint")
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate1 = NSPredicate(format: "type == %i", 2)
        let predicate2 = NSPredicate(format: "year == %i", selectedYear)
        let predicate3 = NSPredicate(format: "weekOfYear == %i", selectedWeekOfYear)
        let predicate4 = NSPredicate(format: "weekDay == %i", selectedWeekdayIndex)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicate1, predicate2, predicate3, predicate4])
        
        fetchRequest.predicate = predicate
        
        do {
            if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [TodoPoint] {
                dailyTodoPoints = fetchResults
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: - SwipeView delegate
    
    func swipeViewCurrentItemIndexDidChange(swipeView: SwipeView!) {
        NSLog("swipeViewCurrentItemIndexDidChange: %d", swipeView.currentItemIndex)
//        swipeView.currentItemIndex = 1
    }
    
    func swipeViewDidEndDragging(swipeView: SwipeView!, willDecelerate decelerate: Bool) {
        NSLog("swipeViewDidEndDragging: %d", swipeView.currentItemIndex)
//        swipeView.currentItemIndex = 1
    }
    
    func swipeViewDidEndScrollingAnimation(swipeView: SwipeView!) {
        NSLog("swipeViewDidEndScrollingAnimation: %d", swipeView.currentItemIndex)
    }
    
    /*
    func swipeViewItemSize(swipeView: SwipeView!) -> CGSize {
        return CGSizeMake(UIScreen.mainScreen().applicationFrame.width, 50)
    }
    */
    
    // MARK: - SwipeView data source
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return 3
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        // TODO: 원래는 뷰를 재사용해야 하기 때문에 nil이 아닐 경우에 대입만 따로 해 주는 로직을 구현할 필요가 있음
//        if view == nil {
            let dateComponents: (year: Int, weekOfYear: Int) = caculateDateComponents(index)
            
            let rootView = UIView(frame: swipeView.bounds)
            let screenWidth = UIScreen.mainScreen().applicationFrame.width
            let labelWidth = screenWidth / 7;
            
            // 디바이스 width를 7로 나누어서 일~토 까지 width를 설정해주고, horizontal로 붙인다.
            var dayViews = [UIView]();
            var dayLabels = [UILabel]();
            
            for weekDayIndex in 0...6 {
                let dayView = UIView()
                rootView.addSubview(dayView)
                dayViews.append(dayView)
                
                dayView.snp_makeConstraints { (make) -> Void in
                    make.top.bottom.equalTo(rootView)
                    make.width.equalTo(labelWidth)
                    
                    if weekDayIndex == 0 {
                        make.leading.equalTo(rootView)
                    } else if weekDayIndex == 6 {
                        make.trailing.equalTo(rootView)
                    } else {
                        make.left.equalTo(dayViews[weekDayIndex-1].snp_right)
                    }
                }
                
                let dayLabel = UILabel()
                dayLabel.numberOfLines = 1
                dayLabel.textAlignment = .Center;
                dayLabel.text = String(CalendarUtils.getDayFromComponents(dateComponents.year, weekOfYear:
                    dateComponents.weekOfYear, weekday: weekDayIndex + 1))
                dayLabel.font = UIFont.systemFontOfSize(18)
                dayLabel.tag = weekDayIndex
                
                dayView.addSubview(dayLabel)
                dayLabels.append(dayLabel)
                
                let isDayLabelToday = CalendarUtils.isDateComponentEqualToday(dateComponents.year, weekOfYear:
                    dateComponents.weekOfYear, weekday: weekDayIndex + 1)
                
                dayLabel.snp_makeConstraints { (make) -> Void in
                    make.edges.equalTo(dayView).inset(UIEdgeInsetsMake(DAY_LABEL_INSET, DAY_LABEL_INSET,
                        DAY_LABEL_INSET, DAY_LABEL_INSET))
                    
                    if weekDayIndex == 0 {
                        dayLabel.textColor = UIColor.grayColor()
                    } else if weekDayIndex == 6 {
                        dayLabel.textColor = UIColor.grayColor()
                    } else {
                        dayLabel.textColor = UIColor.blackColor()
                    }
                    
                    if isDayLabelToday == true {
                        dayLabel.textColor = UIColor.redColor()
                    }
                }
                
                // TODO: circle test
                if weekDayIndex == selectedWeekdayIndex {
                    dayLabel.layer.masksToBounds = true
                    dayLabel.layer.cornerRadius = (labelWidth - (DAY_LABEL_INSET * 2)) / 2
                    dayLabel.layer.borderWidth = 7.0;
                    dayLabel.layer.borderColor = UIColor.clearColor().CGColor
                    if isDayLabelToday == true {
                        dayLabel.backgroundColor = UIColor.redColor()
                    } else {
                        dayLabel.backgroundColor = UIColor.blackColor()
                    }
                    dayLabel.textColor = UIColor.whiteColor()
                }
                
                // recognizer는 한 뷰에만 적용 가능해서 동적으로 생성
                let tapRecognizer = UITapGestureRecognizer(target: self, action: "dayLabelTouchBegan:")
                dayLabel.userInteractionEnabled = true
                dayLabel.addGestureRecognizer(tapRecognizer)
                
                // TODO: UI test
//                dayView.backgroundColor = RandomColorUtil.get()
//                dayLabel.backgroundColor = RandomColorUtil.get()
            }
            return rootView
//        } else {
//            NSLog("index: %d", index)
//            return view
//        }
    }
    
    func caculateDateComponents(index: Int) -> (year: Int, weekOfYear: Int) {
        var year: Int = selectedYear
        var weekOfYear: Int
        
        if index == 1 {
            weekOfYear = selectedWeekOfYear
        } else if index == 0 {
            if selectedWeekOfYear == 1 {
                year = selectedYear - 1
                weekOfYear = CalendarUtils.getNumberOfWeeksOfYear(year)
            } else {
                year = selectedYear
                weekOfYear = selectedWeekOfYear - 1
            }
        } else {
            if selectedWeekOfYear == CalendarUtils.getNumberOfWeeksOfYear(selectedYear) {
                year = selectedYear + 1
                weekOfYear = 1
            } else {
                year = selectedYear
                weekOfYear = selectedWeekOfYear + 1
            }
        }
        return (year, weekOfYear)
    }
    
    func dayLabelTouchBegan(recognizer: UIGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            let dayLabel: UILabel = recognizer.view as! UILabel
            selectedWeekdayIndex = dayLabel.tag
            swipeView.reloadData()
        }
    }
    
    // MARK: - TableView delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Visioning Goals"
        } else if section == 1 {
            return "26 Jul 2015 ~ 1 Aug 2015"
        } else {
            return "21 Fri."
        }
    }
    
    // MARK: - TableView data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return visionTodoPoints.count
        } else if section == 1 {
            return weeklyTodoPoints.count
        } else {
            return dailyTodoPoints.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TodoPoint")
        
        
        // Get the LogItem for this index
        var todoPointItem : TodoPoint
        
        if indexPath.section == 0 {
            todoPointItem = visionTodoPoints[indexPath.row]
        } else if indexPath.section == 1 {
            todoPointItem = weeklyTodoPoints[indexPath.row]
        } else  {
            todoPointItem = dailyTodoPoints[indexPath.row]
        }
        
        // Set the title of the cell to be the title of the logItem
        cell!.textLabel?.text = todoPointItem.title
        return cell!
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete) {
            
            var itemToDelete : TodoPoint
            
            if indexPath.section == 0 {
                itemToDelete = visionTodoPoints[indexPath.row]
                managedObjectContext.deleteObject(itemToDelete)
                fetchVisionTodoPoint()
            } else if indexPath.section == 1 {
                itemToDelete = weeklyTodoPoints[indexPath.row]
                managedObjectContext.deleteObject(itemToDelete)
                fetchWeeklyTodoPoint()
            } else  {
                itemToDelete = dailyTodoPoints[indexPath.row]
                managedObjectContext.deleteObject(itemToDelete)
                fetchDailyTodoPoint()
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//            save()
        }
    }
    
    // MARK: - ViewController Cycle
    
    override func viewWillAppear(animated: Bool) {
//        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        naviHairlineImageView?.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // 여기서 처리를 안 해주면 깨짐. UI가 다 뜨고 나서 진행해야 하는 듯
        swipeView.currentItemIndex = 1
        swipeView.wrapEnabled = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        naviHairlineImageView?.hidden = false
    }
    
    // MARK:

    func insertNewTodoPoint(sender: AnyObject) {
        
        let viewControllerForPopover = UIStoryboard(name: "AddTodoPoint", bundle: nil).instantiateViewControllerWithIdentifier("addTodoPointViewController")
        self.navigationController?.pushViewController(viewControllerForPopover, animated: true)
        
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
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Master")
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

