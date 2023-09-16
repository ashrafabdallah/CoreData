//
//  CategoryTableViewController.swift
//  CoreDataTest
//
//  Created by Ashraf Eltantawy on 16/09/2023.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    var categoryName:String?
    var arrayCategory = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
    }
    
    // MARK: - Table view data source
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayCategory.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.ToDoCategoryCell.rawValue, for: indexPath)
        cell.textLabel?.text = arrayCategory[indexPath.row].name
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoryName = arrayCategory[indexPath.row].name
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let itemViewController = segue.destination as? TodoListViewController , let indexPath = tableView.indexPathForSelectedRow {
                itemViewController.categoryName = arrayCategory[indexPath.row].name
                itemViewController.selectedCategory = arrayCategory[indexPath.row]
            
      
        }
    }

    
    @IBAction func buttonClick(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) {[weak self] action in
            guard let self = self else {return}
            if textField.text?.isEmpty == true{
                textField.placeholder = "please add item."
                self.present(alert, animated: true)
            }else{
                if let text = textField.text{
                    let newItem = Category(context: context)
                    newItem.name = text
                    self.arrayCategory.append(newItem)
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
            try context.save()
        }catch{
            print("error from save category \(error)")
        }
        tableView.reloadData()
    }
    func loadCategory(with request:NSFetchRequest<Category>=Category.fetchRequest()){
        do{
            arrayCategory = try context.fetch(request)
        }catch{
            print("error from get category \(error)")
        }
        tableView.reloadData()
    }
    
}
