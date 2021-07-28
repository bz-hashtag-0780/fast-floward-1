//Printing functions have been put into the script to avoid deploying too much logic in the Artist contract

import Artist from 0x05

pub fun main() {
  // add all accounts to a dictionary
  let accounts: {Int: PublicAccount} = {
    0: getAccount(0x01),
    1: getAccount(0x02),
    2: getAccount(0x03),
    3: getAccount(0x04),
    4: getAccount(0x05)
  }

  // borrow printer reference to get width and height
  let printerRef = getAccount(0x05).getCapability<&Artist.Printer>(/public/PicturePrinter).borrow()
    ?? panic("Couldn't borrow printer reference")

  // go through each accounts collection
  var count = 0
  while count < accounts.length {

    // find the public Receiver capability for their Collection
    let acctCapability = accounts[count]!.getCapability(/public/PictureReceiver)

    // borrow a reference from the capability
    let receiverRef = acctCapability.borrow<&{Artist.PictureReceiver}>()
    
    if receiverRef == nil {
      log("Account ".concat(accounts[count]!.address.toString()).concat(" has no collection"))
    } else if receiverRef!.getIDs().length == 0 {
      log("Account ".concat(accounts[count]!.address.toString()).concat(" has a collection with no pictures"))
    } else {
      log("Account ".concat(accounts[count]!.address.toString()).concat(" Pictures"))
      printAll(pictures: receiverRef!.getIDs(), width: Int(printerRef.width), height: Int(printerRef.height))
    }
    count = count + 1
  }

}

/** printing function start **/
pub fun printAll(pictures: [String], width: Int, height: Int) {
  var count = 0
  while count < pictures.length {
    var num = count + 1
    log("Picture #".concat(num.toString()))
    printPictures(picture: pictures[count], width: width, height: height)
    count = count + 1
  }

}

pub fun printPictures(picture: String, width: Int, height: Int) {
  displayTopAndBottomBorder(width: width)
  var count = 0
  var column = 0
  while count < height {
    var buffer = ""
    buffer = picture.slice(from: column, upTo: column + width)
    log("|".concat(buffer).concat("|"))
    count = count + 1
    column = column + width
  }
  displayTopAndBottomBorder(width: width)
}

pub fun displayTopAndBottomBorder(width: Int) {
  var buffer = "+"
    var i: Int = 0
    while i < width {
        buffer = buffer.concat("-")
        i = i + 1
    }
    buffer = buffer.concat("+")
    log(buffer)
}

/** printing function end **/
