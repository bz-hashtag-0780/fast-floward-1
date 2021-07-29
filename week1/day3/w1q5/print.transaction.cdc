import Artist from "./artist.contract.cdc"

// Print a Picture and store it in the authorizing account's Picture Collection.
transaction(width: UInt8, height: UInt8, pixels: String) {

    let printerRef: &Artist.Printer
    let collectionRef: &AnyResource{Artist.PictureReceiver}
    
    prepare(acct: AuthAccount) {
        // get contract deployer that has the printer
        let emulatorAccount = getAccount(0xf8d6e0586b0a20c7)

        // borrow a reference to the printer 
        /*
        self.printerRef = emulatorAccount.getCapability<&Artist.Printer>(/public/PicturePrinter).borrow()
            ?? panic("Couldn't borrow printer reference")*/
        self.printerRef = emulatorAccount.getCapability<&Artist.Printer>(/public/PicturePrinter).borrow()
            ?? panic("Couldn't borrow printer reference")

        // borrow a reference to the account's collection
        self.collectionRef = acct.getCapability<&{Artist.PictureReceiver}>(/public/PictureReceiver).borrow()
            ?? panic("Couldn't borrow collection reference")

    }

    execute {

        let canvas = Artist.Canvas(
            width: width,
            height: height,
            pixels: pixels
        )

        let picture <- self.printerRef.print(canvas: canvas)

        if(picture == nil) {
            destroy picture
            //log("Picture already exists...")
        } else {
            self.collectionRef.deposit(picture: <-picture!)
            //log("Picture printed and saved!")
        }

    }

}