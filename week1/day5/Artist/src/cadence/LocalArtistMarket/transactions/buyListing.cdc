//Untested improved buy transaction version

import LocalArtist from ${process.env.REACT_APP_ARTIST_CONTRACT_HOST_ACCOUNT}
          import LocalArtistMarket from ${process.env.REACT_APP_ARTIST_CONTRACT_HOST_ACCOUNT}
          import FungibleToken from 0x9a0766d93b6608b7
          import FlowToken from 0x7e60df042a9c0868

          transaction(listingIndex: Int) {
            let address: Address
            let marketRef: &{LocalArtistMarket.MarketInterface}
            let tokenVault: @FlowToken.Vault?
            let price: amount


            prepare(account: AuthAccount) {

              // get buyer address
              self.address = account.address

              // get reference to market capability
              self.marketRef = getAccount(${process.env.REACT_APP_ARTIST_CONTRACT_HOST_ACCOUNT})
                .getCapability(/public/LocalArtistMarket)
                .borrow<&{LocalArtistMarket.MarketInterface}>()
                ?? panic("Couldn't borrow market reference.")
        
              // get reference to buyer's vault
                self.tokenVault = account.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)!
              
              // get the listing
              let listing = self.marketRef.getListings()[listingIndex]!

              // get listing price
              self.price = listing.price

              
            }

            execute {
            // buy the listing
              self.marketRef.buy(
                listing: listingIndex, 
                with: <- self.tokenVault.withdraw(amount: self.price), 
                buyer: self.address
              )
            }
          }