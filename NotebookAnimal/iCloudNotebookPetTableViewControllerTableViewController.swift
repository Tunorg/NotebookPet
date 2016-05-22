//
//  iCloudNotebookPetTablewViewControllerTableViewController.swift
//  NotebookAnimal
//
//  Created by Nikolay on 21.05.16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit
import CloudKit

class iCloudNotebookPetTablewViewControllerTableViewController: UITableViewController {
    //*** Этот класс выводит информацию из iCloud в которй содержит базу животных, которые добавляли

    @IBOutlet var spinner: UIActivityIndicatorView!
    var notebookAnimals:[CKRecord] = []
    
    let tableIdentifier = "iCloudCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRecordsFromCloud()
        
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        
        //pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.whiteColor()
        refreshControl?.tintColor = UIColor.grayColor()
        refreshControl?.addTarget(self, action: #selector(iCloudNotebookPetTablewViewControllerTableViewController.getRecordsFromCloud), forControlEvents: UIControlEvents.ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notebookAnimals.count
    }

    func getRecordsFromCloud() {
        var newRestaurantsFromCloud:[CKRecord] = []
        let cloudContainer = CKContainer.defaultContainer()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "NotebookAnimal", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let queryOperation = CKQueryOperation(query: query)
        //Делаем запрос по ключам       
        queryOperation.desiredKeys = ["namePet"]
        queryOperation.desiredKeys = ["kindOfPet"]
        queryOperation.queuePriority = .VeryHigh
        queryOperation.resultsLimit = 50
    
        queryOperation.recordFetchedBlock = { (record: CKRecord!) -> Void in
            if let restaurantRecord = record {
                newRestaurantsFromCloud.append(restaurantRecord)             }
        }
        
        queryOperation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: NSError?) -> Void in
            if error != nil {
                let alertController = UIAlertController(title: "Ошибка", message: "Не удалось получить данные из ICloud.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            print("Success")
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.notebookAnimals = newRestaurantsFromCloud
                self.tableView.reloadData()
                self.spinner.stopAnimating()
                self.refreshControl?.endRefreshing()
            }
        }
        
        publicDatabase.addOperation(queryOperation)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableIdentifier, forIndexPath: indexPath) as! iCloudCustomTableViewCell

        // Configure the cell...
        let notebookAnimal = notebookAnimals[indexPath.row]
        
        cell.namePetLabel.text = notebookAnimal.objectForKey("namePet") as? String
        cell.kindOfAnimalLabel.text = notebookAnimal.objectForKey("namePet") as? String

        return cell
    }

}
