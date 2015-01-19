// Playground - noun: a place where people can play

import UIKit

class Queues {
  
  init() {
    
  }
  
  
  
  
  var arrayOfMetals = ["Silver", "Cobalt", "Iron"]
  
  func enQueue(itemToEnQueue: String){
    
    if !arrayOfMetals.isEmpty{
      arrayOfMetals.append(itemToEnQueue)
    }
    
    
  }
  
  
  func deQueue()->String?{
    
    if !arrayOfMetals.isEmpty{
      return arrayOfMetals.removeAtIndex(0)
    }else{
      return nil
    }
    
    
  }
  
  
  
}

let M = Queues()

M.enQueue("Gold")
M.deQueue()
M.arrayOfMetals
