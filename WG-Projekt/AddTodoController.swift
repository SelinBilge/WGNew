//
//  AddTodoController.swift
//  WG-Projekt
//
//  Created by Paul Pfisterer on 11.02.21.
//  Copyright © 2021 WG-Projekt. All rights reserved.
//

import UIKit

struct Person{
    var name : String
}

class AddTodoController: UIViewController{
    private var persons: [Person] = []
    private var activePerson = -1
    @IBOutlet weak var personCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        persons = [Person(name: "Paul"), Person(name: "Emil")]
        personCollection.delegate = self
        personCollection.dataSource = self
    }
}



extension AddTodoController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return persons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "personTag", for: indexPath) as! PersonTag
        cell.personName.text = persons[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell:PersonTag = collectionView.cellForItem(at: indexPath) as! PersonTag
        if(indexPath.row == activePerson) {
            cell.personImage.backgroundColor = UIColor(displayP3Red: 0.0/255.0, green: 144.0/255.0, blue: 163.0/255.0, alpha: 1.0)
            activePerson = -1
        } else {
            cell.personImage.backgroundColor = UIColor.gray
            if(activePerson != -1) {
                let activeIndexPath = NSIndexPath(row: activePerson, section: indexPath.section) as IndexPath
                let activeCell:PersonTag = collectionView.cellForItem(at: activeIndexPath) as! PersonTag
                activeCell.personImage.backgroundColor = UIColor(displayP3Red: 0.0/255.0, green: 144.0/255.0, blue: 163.0/255.0, alpha: 1.0)
            }
            activePerson = indexPath.row
        }
        
       
    }
    
    
}


extension AddTodoController : UICollectionViewDelegate {
    
}

