//
//  RecipeDetailVC.swift
//  cookingCompanion
//
//  Created by Raymond Kim on 5/23/17.
//  Copyright © 2017 Raymond Kim. All rights reserved.
//

import UIKit

class RecipeDetailVC: UIViewController {

    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var recipeNameLabel: UILabel!
    @IBOutlet var durationlabel: UILabel!
    @IBOutlet var ingredientsTitleLabel: UILabel!
    
    @IBAction func startPressed(_ sender: UIButton) {
        
    }
    
    var recipeName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeNameLabel.text = recipeName
    }

}

extension RecipeDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ingredientCell", for: indexPath) as! IngredientCell
        
        cell.ingredientLabel.text = "1. 1 large steak"
        
        return cell
    }
}
