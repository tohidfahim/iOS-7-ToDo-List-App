//
//  ViewController.swift
//  ToDoList
//
//  Created by Tohid Fahim on 10/6/20.
//  Copyright © 2020 Tohid Fahim. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var myTableView: UITableView!
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    // - ARRAY OF MODEL CLASS
    var itemArray = [Item]()
    
    // - CONTEXT FOR CORE DATA
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       
    // - CREATE USER DEFAULTS DB OBJECT
       ///var defaults = UserDefaults.standard
    
    // - CREATING NSCODER FILE PATH
    ///let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    // - VIEW DID LOAD (APP OPENS) FUNCTION
       override func viewDidLoad() {
           super.viewDidLoad()
        
        ///if let items = defaults.array(forKey: "TodoListArray") as? [Item]
        ///{
           /// itemArray = items     //Database Items Load Into The Array For Appearing The First View
        ///}
           searchBar.placeholder = "Search From TodoList Items"
           
           ///loadItems()     //NSCoder Database     //Core Data Database
       }

       
    
    // - CREATE NUMBER OF ROWS
       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return itemArray.count
       }
       
       
    
    // - CELL FOR ROWS, HERE CHECKS FOR EVERY CELL ON TABLE (ONE BY ONE)
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
           
           let item = itemArray[indexPath.row]     //New Name For itemArray[indexPath.row]
           cell.textLabel?.text = item.title
        
       /// - CHECKMARK DATA CHECK ON CLASS BEFORE SHOWING ON TABLE
           cell.accessoryType = item.done ? .checkmark : .none     //Ternary Operator
        
           return cell
       }
       
       
    
    // - SELECT SPECIFIC ROW
       override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /// - SELECT ONE ROW AND ITS CHECKMARK WILL BE OPPOSITE
            itemArray[indexPath.row].done = !itemArray[indexPath.row].done
            saveItems()     //NSCoder Database     //Core Data Database
        
        /// - TO TRIGGER THE "CELL FOR ROWS AT" METHOD FOR UPDATIONG THE VIEW
            tableView.reloadData()
           
        /// - DESELECT ROW BY FADDING AWAY SELECT
            tableView.deselectRow(at: indexPath, animated: true)
       }
       
       
    
    // - BAR BUTTON (ACTION) FOR ADDING TODO LIST ITEMS
       @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
           var textField = UITextField()
           
        /// - POP UP ALERT TO ADD ITEMS
           let alert = UIAlertController(title: "Add New Item to List", message: "", preferredStyle: .alert)
           let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
               
        /// - USER CLICKS THE ADD ITEM, AND THIS WILL HAPPEN
               if textField.text != "" {
                   ///let newItem = Item()
                   let newItem = Item(context: self.context)
                   newItem.title = textField.text!
                   newItem.done = false     /// For Core Data Default False Value
                   newItem.parentCategory = self.selectedCategory   //BECAUSE OF RELATIONSHIP
                
                   self.itemArray.append(newItem)
                   ///self.defaults.set(self.itemArray, forKey: "TodoListArray")     //For Append In Database
                   self.saveItems()     //NSCoder Database    //Core Data Database
                   self.tableView.reloadData()
               }
           }
           
            /// - ADD TEXT FIELD FOR INPUT DATA
           alert.addTextField { (alertTextField) in
            /// - PLACE HOLDER TO GET INPUT IN TEXT FIELD
               alertTextField.placeholder = "Create New Item"
            /// - FOR STORING THE INPUT TEXT TO DATABASE AND ARRAY, SAVE IT TO OUTSIDE
               textField = alertTextField
           }
           
           /// - PERFORMS THE ALERT ACTIONS
           alert.addAction(action)
           present(alert, animated: true, completion: nil)
           
       }
       
       
    // - DELETE ITEMS FROM ARRAY
       override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == UITableViewCell.EditingStyle.delete {
               ///itemArray.remove(at: indexPath.row)
               ///defaults.set(itemArray, forKey: "TodoListArray")     //Save Updated Array
               ///saveItems()     //NSCoder Database
               removeItems(place : indexPath)     //Core Data Database
               tableView.reloadData()
           }
       }

    
    /*// - NSCoder Encoder Function
    func saveItems(){
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        }
        catch{
            print("Error Encoding")
        }
    }
    
    // - NSCoder Decoder Function
    func loadItems(){
        let decoder = PropertyListDecoder()
        if let data = try? Data(contentsOf: dataFilePath!){
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            }
            catch{
                print("Decoder Error")
            }
        }
    }*/
    
    
    // - CORE DATA (SAVE)
    func saveItems(){
        do{
            try context.save()
        }catch{
            print("Saving Error")
        }
    }
    
    // - CORE DATA (LOAD)
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil){
        ///let request : NSFetchRequest<Item> = Item.fetchRequest()     /// For Fetching Data From Database
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        ///let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categorypredicate, predicate])
        ///request.predicate = compoundPredicate
        
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Fetch Error")
        }
        
        tableView.reloadData()
    }
    
    // - CORE DATA (UPDATE)
    func updateItems(){
        
    }
    
    // - CORE DATA (REMOVE)
    func removeItems(place : IndexPath){
        context.delete(itemArray[place.row])     /// Firstly Remove From Database, Then From Array
        itemArray.remove(at: place.row)
        
        saveItems()
    }
    
    
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = itemArray[sourceIndexPath.row]
        itemArray.remove(at: sourceIndexPath.row)
        itemArray.insert(item, at: destinationIndexPath.row)
        saveItems()
        tableView.reloadData()
    }
    
    @IBAction func organizeView(_ sender: UIBarButtonItem) {
        myTableView.isEditing = !myTableView.isEditing
    }
}



// - SEARCH BAR METHODS BY ENTENSION OF CLASS
extension TodoListViewController : UISearchBarDelegate{
    
    
    // - DYNAMIC CHANGE IN SEARCHING
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count != 0 {
        /// - MODIFIED REQUEST !  PREVIOUS IT WAS IN CORE DATA (LOAD)
        let request : NSFetchRequest<Item> = Item.fetchRequest()     /// Request To Fetch Data From Item Entity Core Data Database
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)     /// For Quering (NSPredicate) Names in SearchBar    /// CASE DIACRITIC
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]           ///  NSSortDescriptor Is An Array Of DATA  and It Is Sorted
            
            loadItems(with : request, predicate: predicate)
            
           /// do{
               ///  itemArray = try context.fetch(request)     /// For Fectching The Data From Context and Saving The Search Data To The Main Code Array Named ITEMARRAY
       /// } catch{
           /// print("Fetch Error")
        ///}
        ///tableView.reloadData()
       /// }
        }
        
       else {
           loadItems()
           tableView.reloadData()
            
            // - MUTITHREADING
            DispatchQueue.main.async {
               searchBar.resignFirstResponder()
            }
    }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadItems()
        tableView.reloadData()
        
        searchBar.resignFirstResponder()
    }
}


