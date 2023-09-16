//
//  ViewController.swift
//  Todoey
//
//  Created by Ashraf Eltantawy on 11/09/2023.
//

import UIKit
import CoreData
class TodoListViewController: UITableViewController {
    var categoryName:String?
    var selectedCategory:Category? {
        didSet{
            loadItems()
        }
    }
    var array = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func loadItemsFromCategory(){
        let request :NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", categoryName!)
        request.predicate = predicate
        let sortDscriptors = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDscriptors]
      loadItems(with: request)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.ToDoItemCell.rawValue, for: indexPath)
        
        let item = array[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done  ? .checkmark : .none
     
       // cell.accessoryType  = (indexPath.row  == selectedRow) ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
      //  array[indexPath.row].done = !array[indexPath.row].done
        let item = array.remove(at: indexPath.row)
        context.delete(item)
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) {[weak self] action in
            guard let self = self else {return}
            if textField.text?.isEmpty == true{
                textField.placeholder = "please add item."
                self.present(alert, animated: true)
            }else{
                if let text = textField.text{
                    let newItem = Item(context: context)
                    newItem.title = text
                    newItem.done = false
                    newItem.parentCategory=self.selectedCategory
                    self.array.append(newItem)
                }
                saveItems()
                self.dismiss(animated: true)
            }
        }
        
        alert.addTextField{
            $0.placeholder = "Create New Item"
            textField = $0
            
        }
        
        
        alert.addAction(action)
        present(alert, animated: true)
        
    }
    func saveItems(){
   
        do{
            print("Success")
            try context.save()
            
           
        }catch{
            print("Error is \(error)")
        }
        tableView.reloadData()
    }
    func loadItems(with request :NSFetchRequest<Item> = Item.fetchRequest(),predicate:NSPredicate?=nil){
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let addiationalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,addiationalPredicate])
        }else{
            request.predicate=categoryPredicate
        }
       
        do{
            array = try context.fetch(request)
        }catch{
            print("error from get data from core data \(error)")
        }
        tableView.reloadData()
    }
    
}
// MARK: - search
extension TodoListViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request :NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate
        let sortDscriptors = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDscriptors]
        loadItems(with: request,predicate:predicate)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
