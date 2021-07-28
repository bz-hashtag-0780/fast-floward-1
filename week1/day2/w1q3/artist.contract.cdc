// deploy to account 0x05
access(all) contract Artist {

  pub struct Canvas {
    pub let width: UInt8
    pub let height: UInt8
    pub let pixels: String

    init(width: UInt8, height: UInt8, pixels: String) {
      self.width = width
      self.height = height
      // The following pixels
      // 123
      // 456
      // 789
      // should be serialized as
      // 123456789
      self.pixels = pixels
    }
  }

  pub resource Picture {
    pub let canvas: Canvas
    pub let id: String

    init(canvas: Canvas) {
      self.canvas = canvas
      self.id = canvas.pixels
    }
  }
  
  pub resource Printer {
    pub let width: UInt8
    pub let height: UInt8
    pub var printedPictures: {String: Canvas}
    
    init(width: UInt8, height: UInt8) {
      self.width = width
      self.height = height
      self.printedPictures = {}
    }

    pub fun print(canvas: Canvas): @Picture? {
      // Canvas needs to fit Printer's dimensions.
      if canvas.pixels.length != Int(self.width * self.height) {
        return nil
      }

      // Canvas can only use visible ASCII characters.
      for symbol in canvas.pixels.utf8 {
        if symbol < 32 || symbol > 126 {
          return nil
        }
      }
      
      // Printer is only allowed to print unique canvases.
      if !self.printedPictures.containsKey(canvas.pixels) {
        self.printedPictures[canvas.pixels] = canvas
        return <- create Picture(canvas: canvas) 
      }
      return nil
    }

  }
  
  // Quest W1Q3
  pub resource Collection {
    pub var ownedPictures: @{String: Picture}

    init() {
      self.ownedPictures <- {}
    } 

    pub fun deposit(picture: @Picture) {
      // adds the picture to the dictionary, if there is already a value at that key, it will fail and revert.
      self.ownedPictures[picture.id] <-! picture
    }

    pub fun idExists(id: String): Bool {
    return self.ownedPictures[id] != nil
    }

    pub fun getIDs(): [String] {
      return self.ownedPictures.keys
    }

    destroy() {
      destroy self.ownedPictures
    }

  }

  pub fun createCollection(): @Collection {
    return <- create Collection()
  }

  init() {

    // store a Printer of 5x5 in account storage
    self.account.save(<-create Printer(width: 5, height: 5), to: /storage/PicturePrinter)

    // publish a reference to the Printer in storage - To allow any account print pictures.
    self.account.link<&Printer>(/public/PicturePrinter, target: /storage/PicturePrinter)

    // store an empty Collection in account storage
    self.account.save(<-self.createCollection(), to: /storage/PictureCollection)

    // publish a reference to the Collection in storage
    self.account.link<&Collection>(/public/PictureCollection, target: /storage/PictureCollection)

  }
}
