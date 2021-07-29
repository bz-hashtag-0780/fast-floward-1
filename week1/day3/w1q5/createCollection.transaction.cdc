import Artist from "./artist.contract.cdc"

// Create a Picture Collection for the transaction authorizer.
transaction {
    prepare(acct: AuthAccount) {

        // check if picture collection already exists
        if acct.borrow<&Artist.Collection>(from: /storage/PictureCollection) == nil {

            // create and store an empty collection in account storage
            acct.save<@Artist.Collection>(<-Artist.createCollection(), to: /storage/PictureCollection)

            // create a public capability for the collection
            acct.link<&{Artist.PictureReceiver}>(/public/PictureReceiver, target: /storage/PictureCollection)
        }
        
    }
}
