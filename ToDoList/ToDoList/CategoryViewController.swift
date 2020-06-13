//
//  CategoryViewController.swift
//  ToDoList
//
//  Created by Tohid Fahim on 12/6/20.
//  Copyright © 2020 Tohid Fahim. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        
        return cell 
        
    }
    
    
    
    // - MAIN CODE
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        ///tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    //..............................
    
    
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "ADD", style: .default) { (act) in
            
            if textField.text != "" {
                let newCategory = Category(context: self.context)
                newCategory.name = textField.text
                
                self.categoryArray.append(newCategory)
                self.saveCategories()
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { (newCategoryInput) in
            newCategoryInput.placeholder = "Add a New Category"
            textField = newCategoryInput
        }
        
        alert.addAction(action)
        present(alert, animated: true , completion: nil)
        
    }
    
    
    // - DATBASE FUNCTIONS
    
    func saveCategories(){
        do {
            try context.save()
        }catch{
            print("Save Error")
        }
    }
    
    func loadCategories(){
        let request : NSFetchRequest <Category> = Category.fetchRequest()
        do{
            categoryArray = try context.fetch(request)
        }catch{
            print("Read Error")
        }
    }
    
    
    
    
    
    
    
    
    // - DELETE FUNCTIONALITY
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            removeItems(place : indexPath)     //Core Data Database
            tableView.reloadData()
        }
    }
    
    // - CORE DATA (REMOVE)
    func removeItems(place : IndexPath){
        context.delete(categoryArray[place.row])     /// Firstly Remove From Database, Then From Array
        categoryArray.remove(at: place.row)
        
        saveCategories()
    }

}
