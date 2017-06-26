//
//  ViewController.swift
//  LootGen
//
//  Created by Harry Culpan on 6/23/17.
//  Copyright © 2017 Harry Culpan. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var count: Int32 = 1
    
    var modifier: Int32 = 0

    //var selectedItem: String = "Humanoid"
    
    var selectedIndex: Int = 0
    
    var topLevelLoot: [[String]] = [
        ["Trash", "[Coins]", "([Coins] + 1)", "([Coins]*2),(1d3 [Gems])", "([Coins]*2), (1d4 [Gems])", "([Coins]*3), (1d5 [Gems]), [Item]"],
        ["Junk", "[Coins]", "([Coins] + 1)", "([Coins]*2),(1d3 [Gems])", "([Coins]*2), (1d4 [Gems])", "([Coins]*3), (1d5 [Gems]), [Item]"]
    ]

    @IBOutlet weak var popupType: NSPopUpButtonCell!
    
    @IBOutlet weak var textLoot: NSTextField!
    
    @IBOutlet weak var textCount: NSTextField!
    
    @IBOutlet weak var stepperCount: NSStepper!
    
    @IBAction func generateLoot(_ sender: Any) {
        textLoot.stringValue = "Type: \(popupType.item(at: selectedIndex)!.title)\n"
            + "Count: \(self.count)\n"
            + "Modifier: \(self.modifier)\n\n"
        
        let treasure = topLevelLoot[selectedIndex][getTreasureLevel()]
        let treasureArr = treasure.components(separatedBy: ",")
        
        textLoot.stringValue += treasureArr.map( {
            (t: String) -> String in return "Treasure: \(generateTreasure(t))"
        }).joined(separator: "\n")
        
    }
    
    func getTreasureLevel() -> Int {
        let lootRoll: Int32 = Int32(arc4random_uniform(12))
            + self.modifier
        
        switch (lootRoll) {
        case -100...0: return 0
        case 1...2: return 1
        case 3...5: return 2
        case 6...9: return 3
        case 10...12: return 4
        default: return 5
        }
        
    }
    
    func generateTreasure(_ text: String) -> String {
        let tokenizer = Tokenizer(text)
        var loot = "\(text): "
        while true {
            let token = tokenizer.nextToken()
            if token.tokenType == TokenType.tokenEnd {
                break;
            }
            loot += "(" + String(describing: token.tokenType) + ",'" + token.token + "')"
        }
        return loot
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popupType.removeAllItems()
        popupType.addItem(withTitle: "Humanoid with Weapons")
        popupType.addItem(withTitle: "Dragon")
        popupType.addItem(withTitle: "Demons")
        popupType.addItem(withTitle: "Undead")
        popupType.addItem(withTitle: "Other Monsters")
        
        popupType.selectItem(at: 0)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

