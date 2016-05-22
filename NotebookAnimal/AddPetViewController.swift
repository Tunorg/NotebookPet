//
//  ViewController.swift
//  NotebookAnimal
//
//  Created by Nikolay on 20.05.16.
//  Copyright © 2016 Nikolay. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class AddPetViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate  {
//*** Этот класс мы полностью настроили на запись/ввод введенной информации. *** Первым делом добавим аутлеты для всех объектов взаимодействия
    
    @IBOutlet weak var labelKindOfAnimal: UILabel!
    @IBOutlet weak var namePetTextField: UITextField!
    
    var notebookAnimal: NotebookAnimal!
    
    let tableIdentifier = "CellKind"
    
    var tableData = [String]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("SourceTable", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        
        tableData = dict!.objectForKey("Kind") as! [String]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    required init (coder aDecoder:(NSCoder!)){
        super.init(coder:aDecoder)!
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView!,
                   cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!{
        
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Default, reuseIdentifier:tableIdentifier)
        
        cell.textLabel?.text = tableData[indexPath.row]
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let path = tableView.indexPathForSelectedRow
        let cell = tableView.cellForRowAtIndexPath(path!)
        
        labelKindOfAnimal.text = cell!.textLabel?.text
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        let namePet = namePetTextField.text
        let kindOfAnimal = labelKindOfAnimal.text
        
        // Проверка на введенных строк
        if namePet == "" {
            let alertController = UIAlertController(title: "Ошибка", message: "Убедитесь что все поля заполнены.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            notebookAnimal = NSEntityDescription.insertNewObjectForEntityForName("NotebookAnimal", inManagedObjectContext: managedObjectContext) as! NotebookAnimal
            
            notebookAnimal.namePet = namePet!
            notebookAnimal.kindOfPet = kindOfAnimal!
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
                return
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
        
        saveRecordToCloud(notebookAnimal)
    }
    
    func saveRecordToCloud(notebookAnimal: NotebookAnimal!) -> Void {
        //prepare
        let record = CKRecord(recordType: "NotebookAnimal")
        record.setValue(notebookAnimal.namePet, forKey: "namePat")
        record.setValue(notebookAnimal.kindOfPet, forKey: "kindOfAnimal")
        
        //tmp use
        let namePetFilePath = NSTemporaryDirectory() + notebookAnimal.namePet!
        
        let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        
        publicDatabase.saveRecord(record, completionHandler: { (record: CKRecord?, error: NSError?) -> Void in
            //remove tmp
            do {
                try NSFileManager.defaultManager().removeItemAtPath(namePetFilePath)
            } catch {
                print("saving error")
            }
        })
        
    }

}

