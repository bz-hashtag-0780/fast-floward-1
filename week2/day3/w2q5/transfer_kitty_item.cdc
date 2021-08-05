// Add imports here, then do steps 1, 2, 3, and 4.
import NonFungibleToken from Flow.NonFungibleToken
import KittyItems from Project.KittyItems
// This transaction transfers a Kitty Item from one account to another.

transaction(recipient: Address, withdrawID: UInt64) {
    // local variable for a reference to the signer's Kitty Items Collection
    let signerCollectionRef: &KittyItems.Collection

    // local variable for a reference to the receiver's Kitty Items Collection
    let receiverCollectionRef: &{NonFungibleToken.CollectionPublic}

    prepare(signer: AuthAccount) {

        // 1) borrow a reference to the signer's Kitty Items Collection
        self.signerCollectionRef = signer.borrow<&KittyItems.Collection>(from: KittyItems.CollectionStoragePath)
            ?? panic("Couldn't borrow reference to signer's Kitty Items Collection")

        // 2) borrow a public reference to the recipient's Kitty Items Collection
        self.receiverCollectionRef = getAccount(recipient).getCapability(KittyItems.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Couldn't borrow public reference to recipient's Kitty Items Collection")
    }

    execute {

        // 3) withdraw the Kitty Item from the signer's Collection
        let token <- self.signerCollectionRef.withdraw(withdrawID: withdrawID)
        // 4) deposit the Kitty Item into the recipient's Collection
        self.receiverCollectionRef.deposit(token: <- token)
       
    }
}