//
//  DetailsVC.swift
//  BookCaseProject
//
//  Created by Mahir Kaan Küçükgençay on 27.11.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var authorText: UITextField!
    @IBOutlet weak var genreText: UITextField!
    @IBOutlet weak var pageText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    var chosenBook = ""
    var chosenBookId : UUID?
 
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
       if chosenBook != "" {
            saveButton.isEnabled = false
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Books")
            let idString = chosenBookId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0{
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let author = result.value(forKey: "author") as? String {
                            authorText.text = author
                        }
                        if let genre = result.value(forKey: "genre") as? String {
                            genreText.text = genre
                        }
                        if let pageCount = result.value(forKey: "pageCount") as? Int {
                            pageText.text = String(pageCount)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                        
                    }
                }

            } catch{
                print("error")
            }
            
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            
        }
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    

    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newBooks = NSEntityDescription.insertNewObject(forEntityName: "Books", into: context)
        
        newBooks.setValue(nameText.text!, forKey: "name")
        newBooks.setValue(authorText.text!, forKey: "author")
        newBooks.setValue(genreText.text!, forKey:"genre")
        
        if let pageCount = Int(pageText.text!) {
            newBooks.setValue(pageCount, forKey: "pageCount")
        }
        newBooks.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newBooks.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("succes")
        }catch{
            print("error")
        }
        
        NotificationCenter.default.post(name:NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
}
