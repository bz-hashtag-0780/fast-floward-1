import Artist from 0x05

// This transaction configures a user's account
// to use the Artist contract by creating a new empty collection,
// storing it in their account storage, and publishing a capability
transaction {
    prepare(acct: AuthAccount) {

        // create and store an empty Collection in account storage
        acct.save<@Artist.Collection>(<-Artist.createCollection(), to: /storage/PictureCollection)
        
        log("Collection created for account ".concat(acct.address.toString()))

        // create a public capability for the Collection
        acct.link<&{Artist.PictureReceiver}>(/public/PictureReceiver, target: /storage/PictureCollection)
        
        log("Capability created")
    }
}
 