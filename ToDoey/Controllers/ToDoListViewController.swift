//
//  ViewController.swift
//  ToDoey
//
//  Created by David A Cantú Delgado on 11/22/18.
//  Copyright © 2018 Bugsracer. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableTableViewController {

    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory!.name
        guard let colorHex = selectedCategory?.color else {fatalError()}
        
        updateNavBar(withHexCode: colorHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "FFFFFF")
    }
    
    // MARK: - Navigation Bar Setup Methods
    func updateNavBar(withHexCode colorHex: String) {
        guard let navBar = navigationController?.navigationBar else {fatalError("NAvigatiion controller does not exist.")}
        navBar.barTintColor = UIColor(hexString: colorHex)
        navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: UIColor(hexString: colorHex), isFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: UIColor(hexString: colorHex), isFlat: true)]
        searchBar.barTintColor = UIColor(hexString: colorHex)
    }
        

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todoItems?.count ?? 1
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.item
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: color.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)), isFlat: true)
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
  
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.item = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                        //self.realm.add(newItem)
                    }
                } catch {
                    print("Error using context:  \(error)")
                }
            }
            
            self.tableView.reloadData()
            
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Delete Data from Swipe
    override func updateModel(at indexPath : IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting status \(error)")
            }
        }
        
        
    }
    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "item", ascending: true)
        self.tableView.reloadData()
    }
    
}
//MARK: - search Methods
extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("item CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }

}

