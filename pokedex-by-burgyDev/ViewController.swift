//
//  ViewController.swift
//  pokedex-by-burgyDev
//
//  Created by Yong Jae Kim on 2015. 11. 21..
//  Copyright © 2015년 Yong Jae Kim. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet var collection: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!

    var pokemon = [Pokemon]()
    var musicPlayer: AVAudioPlayer!
    
    // store the filetered pokemon
    var filteredPokemon = [Pokemon]()
    var insearchMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.Done
        
        initAudio()
        parsePokemonCSV()

    }
    
    func initAudio(){
        
        let path = NSBundle.mainBundle().pathForResource("bgmusic", ofType: "mp3")!
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOfURL: NSURL(string: path)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    // parse CSV file
    func parsePokemonCSV() {
        let path = NSBundle.mainBundle().pathForResource("pokemon", ofType: "csv")!
        
        do {
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            
            for row in rows {
                let pokeId = Int(row["id"]!)!
                let name = row["identifier"]
                
                let poke = Pokemon(name: name!, pokedexId: pokeId)
                pokemon.append(poke)
            }
            
        } catch let err as NSError{
            print(err.debugDescription)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            insearchMode = false
            view.endEditing(true)
            collection.reloadData()
        } else {
            insearchMode = true
            let lower = searchBar.text!.lowercaseString

            filteredPokemon = pokemon.filter({$0.name.rangeOfString(lower) != nil})
            collection.reloadData()
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PokeCell", forIndexPath: indexPath) as? PokeCell {
            
            let poke: Pokemon!
            
            if insearchMode {
                poke = filteredPokemon[indexPath.row]
            } else {
                poke = pokemon[indexPath.row]
            }
            
            cell.configurCell(poke)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var poke: Pokemon!
        
        if insearchMode {
            poke = filteredPokemon[indexPath.row]
        } else {
            poke = pokemon[indexPath.row]
        }
        
        
        performSegueWithIdentifier("PokemonDetailVC", sender: poke)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if insearchMode {
            return filteredPokemon.count
        } else {
            return pokemon.count
        }
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(105, 105)
    }
    @IBAction func musicBtnPressed(sender: UIButton!) {
        
        if musicPlayer.playing {
            print("Playing now!")
            musicPlayer.pause()
            sender.alpha = 0.2
        } else {
            musicPlayer.play()
            print("I'm not playing!")
            sender.alpha = 1.0
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PokemonDetailVC" {
            if let detailVC = segue.destinationViewController as? PokemonDetailVC {
                if let poke = sender as? Pokemon {
                    detailVC.pokemon = poke
                }
            }
        } else {
            
        }
    }
}

