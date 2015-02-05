//
//  main.swift
//  cui_shephy_new
//
//  Created by Ryo on 2015/01/26.
//  Copyright (c) 2015年 Ryo. All rights reserved.
//

import Foundation

//標準入力のための関数
func input(msg:String = "") -> Int {
    print(msg)
    var in_fh = NSFileHandle.fileHandleWithStandardInput()
    var data = in_fh.availableData
    var s = NSString(data: data, encoding: NSUTF8StringEncoding)
    var str:String = s!
    str = (str as NSString).substringToIndex(str.utf16Count - 1)
    //    s = s.substringToIndex(s.utf8count - 1)
    var num = str.toInt()!
    return num;
}

//羊全般に対するクラス。羊山と場
class Sheep{
    let mountnumber:[Int] = [1, 3, 10, 30, 100, 300, 1000]
    var mountrest:[Int] = [6, 7, 7, 7, 7, 7, 7]
    var field:[Int] = [0, -1, -1, -1, -1, -1, -1]
    var sheepnum:Int = 1
    
    func back(fieldnum:Int){
        var tmp:Int = field[fieldnum]
        field[fieldnum] = -1
        mountrest[tmp]++
        sheepnum--
    }
    
    func put(fieldnumrank:(Int, Int)){
        var (fieldnum, rank) = fieldnumrank
        var tmp:Int = field[fieldnum]
        field[fieldnum] = rank
        mountrest[rank]--
        sheepnum++
    }
    
    func rankup(fieldnum:Int){
        mountrest[field[fieldnum]]++
        field[fieldnum]++
        mountrest[field[fieldnum]]--
    }
    
    func rankdown(fieldnum:Int){
        mountrest[field[fieldnum]]++
        field[fieldnum]--
        if field[fieldnum]>0 {
            mountrest[field[fieldnum]]--
        }
        else {
            sheepnum--
        }
    }
    
    func showfield(){
        println("field")
        for i in 0...6 {
            println(String(i) + " : " + String(field[i]))
        }
    }
}

//アクションカードに関するクラス。山札と手札
class Actioncard{
    var deck:[Int] = [Int](count:22, repeatedValue:1)
    var hand:[Int] = [-1, -1, -1, -1, -1]
    var handnum:Int = 0
    var deckrest:Int = 22
    var deckmax:Int = 22
    
    func refresh(){
        for i in 0...21{
            if deck[i]==0 {
                deck[i] = 1
            }
        }
        deckrest = deckmax
    }
    
    func draw(){
        for i in 0...4{
            if deckrest == 0 {
                break
            }
            if hand[i] == -1{
                var drawcard = Int(arc4random()) % deckrest + 1
                var (idx,one) = (0,0)
                while one != drawcard {
                    if deck[idx] == 1 {
                        one++
                    }
                    idx++
                }
                
                hand[i] = idx - 1
                deck[idx - 1] = 0
                handnum++
                deckrest--
            }
        }
    }
    
    func trash(trashcard:Int){
        hand[trashcard] = -1
        handnum--
    }
    
    func expulsion(expcard:Int){
        deck[hand[expcard]] = -1
        hand[expcard] = -1
        handnum--
    }
    
    func choose(handcardchocard:(Int, Int)){
        var (handcard, chocard) = handcardchocard
        deck[chocard] = 0
        hand[handcard] = chocard
        deckrest--
    }
}

var sheep:Sheep = Sheep()
var actcard:Actioncard = Actioncard()
var deathflag:Bool = false
var enemysheep:Int = 1
var usehandcard:Int
var usecard:Int
var usecardmem:Int
var plaguenum:Int
var slumpnum:Int
var putnum:Int
var selnum:Int
var domsum:Int


actcard.draw()

while !deathflag {
    while !deathflag && actcard.handnum>0 {
        actcard.draw()
        sheep.showfield()
        //usecard_start
        println("hand")
        for i in 0...4 {
            print(String(i) + " : ")
            println(actcard.hand[i])
        }
        println("usecard")
        usehandcard = input()
        usecard = actcard.hand[usehandcard]
        usecardmem = usecard
        actcard.hand[usehandcard] = -1
        actcard.handnum--
        
        
        //All-purpose Sheep
        if usecard == 0 {
            for i in 0...4 {
                if actcard.hand[i] != -1 {
                    print(String(i) + " : ")
                    println(actcard.hand[i])
                }
            }
            usecard = actcard.hand[input()]
        }
        
        switch usecard {
            //Be Fruitful
        case 1...3:
            if sheep.sheepnum < 7 {
                println("①どこに②どこの羊をコピーしますか？")
                println([0, 1, 2, 3, 4, 5, 6])
                println(sheep.field)
                sheep.put((input(), sheep.field[input()]))
            }
            
            //Crowding
        case 4:
            if sheep.sheepnum > 2{
                while sheep.sheepnum <= 2 {
                    println("どの羊を手放しますか？")
                    sheep.back(input())
                }
            }
            //Dominion
        case 5, 6:
            domsum = 0
            println("手放す羊カードを選んでください　-1で終了")
            while true {
                selnum = input()
                if selnum == -1 {
                    break
                }
                domsum += sheep.mountnumber[sheep.field[selnum]]
                sheep.back(selnum)
            }
            println("どの種類のカードを配置しますか？")
            for i in 0...6 {
                if sheep.mountnumber[i] > domsum {
                    break
                }
                print(String(i) + " : ")
                println(sheep.mountnumber[i])
            }
            selnum = input()
            println("どこに配置しますか？")
            sheep.put((input(), selnum))
            
            
            //Falling Rock
        case 7:
            println("どの羊を手放しますか？")
            sheep.back(input())
            
            //Fill the Earth
        case 8:
            println("どこに1羊を置きますか？ -1で終了")
            while true {
                putnum = input()
                if putnum == -1 {
                    break
                }
                sheep.put((putnum,0))
            }
            
            //Flourish
        case 9:
            println("①どの羊を選びますか？　②どこに置きますか？")
            selnum = input()
            if sheep.field[selnum] > 0 {
                for _ in 0...2 {
                    sheep.put((sheep.field[selnum] - 1, input()))
                    if sheep.sheepnum == 7{
                        break
                    }
                }
            }
            
            //Golden Hooves
        case 10:
            println("最大でない羊カードを選んでください　-1で終了")
            while true {
                putnum = input()
                if putnum == -1 {
                    break
                }
                sheep.rankup(putnum)
            }
            
            //Inspiration
        case 11:
            println("手札に加えたいカードを選んでください")
            actcard.choose((usehandcard,input()))
            
            //Lightning
        case 12:
            println("手放す、最大の羊カードを選んでください")
            sheep.back(input())
            
            //Meteor
        case 13:
            println("手放す羊カードを3枚選んでください")
            for _ in 0...2 {
                if sheep.sheepnum > 0 {
                    sheep.back(input())
                }
            }
            actcard.deck[usecardmem] = -1
            
            //Multiply
        case 14:
            println("どこに3羊を置きますか？")
            if sheep.sheepnum < 7 {
                sheep.put((input(), 1))
            }
            
            //Plague
        case 15:
            println("手放す種類の羊カードを選んでください")
            plaguenum = sheep.field[input()]
            for i in 0...6 {
                if sheep.field[i] == plaguenum {
                    sheep.back(i)
                }
            }
            
            //Planning Sheep
        case 16:
            println("追放するカードを選んでください")
            actcard.expulsion(input())
            
            //Sheep Dog
        case 17:
            println("捨てるカードを選んでください")
            actcard.trash(input())
            
            //Shephion
        case 18:
            for i in 0...6 {
                if sheep.field[i] != -1 {
                    sheep.back(i)
                }
            }
            
            //Slump
        case 19:
            slumpnum = sheep.sheepnum / 2
            if slumpnum > 0 {
                for _ in 0...slumpnum {
                    println("どの羊を手放しますか？")
                    sheep.back(input())
                }
            }
            
            //Storm
        case 20:
            println("手放す羊カードを2枚選んでください")
            for _ in 0...1 {
                if sheep.sheepnum > 0 {
                    sheep.back(input())
                }
            }
            
            //Wolves
        case 21:
            println("ランクダウンする最大の羊カードを選んでください")
            sheep.rankdown(input())
            
        default:
            println("Error")
        }
        //usecard_end
        if sheep.sheepnum == 0 {
            deathflag = true
        }
    }
    enemysheep *= 10
    if enemysheep == 1000 {
        deathflag = true
    }
    actcard.refresh()
}
var sheepsum:Int = 0
for i in 0...4 {
    if sheep.field[i] != -1{
        sheepsum += sheep.mountnumber[sheep.field[i]]
    }
}
println(sheepsum)


