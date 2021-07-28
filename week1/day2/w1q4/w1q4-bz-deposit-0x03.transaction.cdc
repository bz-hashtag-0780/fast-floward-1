import Artist from 0x05

// This transaction creates a picture and deposits it to a user's collection
transaction {

    let pixels3: String
    let picture: @Artist.Picture?
	
    prepare(acct: AuthAccount) {

        let printerRef = getAccount(0x05).getCapability<&Artist.Printer>(/public/PicturePrinter).borrow()
            ?? panic("Couldn't borrow printer reference")

        self.pixels3 = "*****    * ****    ******"
        let canvas = Artist.Canvas(
            width: printerRef.width,
            height: printerRef.height,
            pixels: self.pixels3
        )

    self.picture <- printerRef.print(canvas: canvas)
    }

    execute {
        // get the recipient's public account object
        let recipient = getAccount(0x03)

        // get the collection reference for the receiver
        let receiverRef = recipient.getCapability<&{Artist.PictureReceiver}>(/public/PictureReceiver)
            .borrow()
            ?? panic("Could not borrow receiver reference")

        // deposit the picture in the recipient's collection
        if(self.picture == nil) {
            destroy self.picture
            log("Picture already exists...")
        } else {
            receiverRef.deposit(picture: <-self.picture!)
            log("Picture printed and saved!")
        }
    }

}
 