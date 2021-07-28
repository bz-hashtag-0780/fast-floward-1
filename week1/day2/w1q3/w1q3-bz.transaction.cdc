import Artist from 0x05

transaction {

  let pixels: String
  let picture: @Artist.Picture? 

  prepare(acct: AuthAccount) {
    
    let printerRef = getAccount(0x05).getCapability<&Artist.Printer>(/public/PicturePrinter).borrow()
    ?? panic("Couldn't borrow printer reference")

    self.pixels = "*   * * *   *   * * *   *"
    let canvas = Artist.Canvas(
      width: printerRef.width,
      height: printerRef.height,
      pixels: self.pixels
    )

    self.picture <- printerRef.print(canvas: canvas)

  }

  execute {
    let collectionRef = getAccount(0x05).getCapability<&Artist.Collection>(/public/PictureCollection).borrow()
    ?? panic("Couldn't borrow collection reference")

    if(self.picture == nil) {
      destroy self.picture
      log("Picture already exists...")
    } else {
      collectionRef.deposit(picture: <-self.picture!)
      log("Picture printed and saved!")
    }
    
  }
}
