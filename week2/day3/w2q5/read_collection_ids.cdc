// Add imports here, then do steps 1 and 2.
import NonFungibleToken from Flow.NonFungibleToken
import KittyItems from Project.KittyItems

// This script returns an array of all the NFT IDs in an account's Kitty Items Collection.

pub fun main(address: Address): [UInt64] {

    // 1) Get a public reference to the address' public Kitty Items Collection
    let collectionRef = getAccount(address).getCapability(KittyItems.CollectionPublicPath)
                        .borrow<&{NonFungibleToken.CollectionPublic}>()
                        ?? panic("Could not borrow capability from public collection")
    // 2) Return the Collection's IDs 
    return collectionRef.getIDs()

}