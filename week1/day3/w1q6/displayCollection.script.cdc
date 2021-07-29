import Artist from "./artist.contract.cdc"

// Return an array of formatted Pictures that exist in the account with the a specific address.
// Return nil if that account doesn't have a Picture Collection.
pub fun main(address: Address): [String]? {
    
    let acct = getAccount(address)

    let collectionRef = acct.getCapability<&{Artist.PictureReceiver}>(/public/PictureReceiver).borrow()
    
    if collectionRef == nil {
        return nil
    }

    return collectionRef!.getIDs()
}
