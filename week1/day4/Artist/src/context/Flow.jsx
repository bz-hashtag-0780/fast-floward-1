import React, { useReducer, useEffect, useCallback } from 'react';
import * as fcl from '@onflow/fcl';
import * as FlowTypes from '@onflow/types';

import Picture from '../model/Picture.js';

const Context = React.createContext({});

function reducer(state, action) {
	switch (action.type) {
		case 'setUser': {
			return {
				...state,
				user: action.payload,
			};
		}
		case 'setBalance': {
			return {
				...state,
				balance: action.payload,
			};
		}
		case 'setCollection': {
			if (action.payload) {
				return {
					...state,
					collection: action.payload.map(
						(serialized) => new Picture(serialized.pixels)
					),
				};
			} else {
				return {
					...state,
					collection: action.payload,
				};
			}
		}
		default:
			return state;
	}
}

function Provider(props) {
	const [state, dispatch] = useReducer(reducer, {
		user: null,
		balance: null,
		collection: undefined,
	});

	const isReady = state.balance !== null && state.collection !== undefined;

	const fetchBalance = useCallback(async () => {
		if (state.user.addr && state.user.addr !== '0xLocalArtist') {
			// A sample script execution.
			// Query for the account's FLOW token balance.
			const balance = await fcl
				.send([
					fcl.script`
            import FungibleToken from 0x9a0766d93b6608b7
            import FlowToken from 0x7e60df042a9c0868
  
            pub fun main(address: Address): UFix64 {
              let vaultRef = getAccount(address)
                .getCapability(/public/flowTokenBalance)
                .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
                ?? panic("Could not borrow Balance reference to the Vault");
  
              return vaultRef.balance;
            }
          `,
					fcl.args([fcl.arg(state.user.addr, FlowTypes.Address)]),
				])
				.then(fcl.decode);

			dispatch({ type: 'setBalance', payload: balance });
		} else {
			return dispatch({ type: 'setBalance', payload: -42 });
		}
	}, [state.user]);
	const createCollection = useCallback(async () => {
		const transactionId = await fcl
			.send([
				fcl.transaction`
        import ${process.env.REACT_APP_ARTIST_CONTRACT_NAME} from ${process.env.REACT_APP_ARTIST_CONTRACT_HOST_ACCOUNT}

        // Create a Picture Collection for the transaction authorizer.
        transaction {
            prepare(account: AuthAccount) {
        
                // check if picture collection already exists
                if account.borrow<&LocalArtist.Collection>(from: /storage/LocalArtistPictureCollection) == nil {
        
                  account.save<@LocalArtist.Collection>(
                    <- LocalArtist.createCollection(),
                    to: /storage/LocalArtistPictureCollection
                  )
                  account.link<&{LocalArtist.PictureReceiver}>(
                    /public/LocalArtistPictureReceiver,
                    target: /storage/LocalArtistPictureCollection
                  )
                }
                
            }
        }
        `,
				fcl.payer(fcl.authz),
				fcl.proposer(fcl.authz),
				fcl.authorizations([fcl.authz]),
				fcl.limit(9999),
			])
			.then(fcl.decode);

		return fcl.tx(transactionId).onceSealed();
	}, []);
	const destroyCollection = useCallback(async () => {
		const transactionId = await fcl
			.send([
				fcl.transaction`
        import ${process.env.REACT_APP_ARTIST_CONTRACT_NAME} from ${process.env.REACT_APP_ARTIST_CONTRACT_HOST_ACCOUNT}
          transaction() {
            prepare(account: AuthAccount) {
              account.unlink(/public/LocalArtistPictureReceiver)
              let collection <- account.load<@LocalArtist.Collection>(
                from: /storage/LocalArtistPictureCollection
              )
              destroy collection
            }
          }
        `,
				fcl.payer(fcl.authz),
				fcl.proposer(fcl.authz),
				fcl.authorizations([fcl.authz]),
				fcl.limit(9999),
			])
			.then(fcl.decode);

		return fcl.tx(transactionId).onceSealed();
	}, []);
	const fetchCollection = useCallback(
		async (address) => {
			if (address || state.user.addr) {
				try {
					let args = null;
					if (address) {
						// eslint-disable-next-line
						args = fcl.args([fcl.arg(address, FlowTypes.Address)]);
					} else {
						// eslint-disable-next-line
						args = fcl.args([
							fcl.arg(state.user.addr, FlowTypes.Address),
						]);
					}

					const collection = await fcl
						.send([
							fcl.script`
      import ${process.env.REACT_APP_ARTIST_CONTRACT_NAME} from ${process.env.REACT_APP_ARTIST_CONTRACT_HOST_ACCOUNT}

      pub fun main(address: Address): [LocalArtist.Canvas] {
        let account = getAccount(address)
        let pictureReceiverRef = account
          .getCapability<&{LocalArtist.PictureReceiver}>(/public/LocalArtistPictureReceiver)
          .borrow()
          ?? panic("Couldn't borrow Picture Receiver reference.")
      
        return pictureReceiverRef.getCanvases()
      }
      `,
							fcl.args([
								fcl.arg(state.user.addr, FlowTypes.Address),
							]),
						])
						.then(fcl.decode);

					if (address) {
						return collection.map(
							(serialized) => new Picture(serialized.pixels)
						);
					} else {
						dispatch({
							type: 'setCollection',
							payload: collection,
						});
					}
				} catch (error) {
					if (address) {
						return null;
					} else {
						dispatch({ type: 'setCollection', payload: null });
					}
				}
			}
		},
		[state.user]
	);
	const printPicture = useCallback(async (picture) => {
		const transactionId = await fcl
			.send([
				fcl.transaction`
        import ${process.env.REACT_APP_ARTIST_CONTRACT_NAME} from ${process.env.REACT_APP_ARTIST_CONTRACT_HOST_ACCOUNT}

        transaction(width: Int, height: Int, pixels: String) {
          
          let picture: @LocalArtist.Picture?
          let collectionRef: &{LocalArtist.PictureReceiver}
        
          prepare(account: AuthAccount) {
            let printerRef = getAccount(0x54837d72c0a45f21)
              .getCapability<&LocalArtist.Printer>(/public/LocalArtistPicturePrinter)
              .borrow()
              ?? panic("Couldn't borrow printer reference.")
              
            self.picture <- printerRef.print(
              width: width,
              height: height,
              pixels: pixels
            )
            self.collectionRef = account
              .getCapability<&{LocalArtist.PictureReceiver}>(/public/LocalArtistPictureReceiver)
              .borrow()
              ?? panic("Couldn't borrow picture receiver reference.")
          }
          execute {
            if self.picture == nil {
              destroy self.picture
            } else {
              self.collectionRef.deposit(picture: <- self.picture!)
            }
          }
        }
        `,
				fcl.args([
					fcl.arg(5, FlowTypes.Int),
					fcl.arg(5, FlowTypes.Int),
					fcl.arg(picture.pixels, FlowTypes.String),
				]),
				fcl.payer(fcl.authz),
				fcl.proposer(fcl.authz),
				fcl.authorizations([fcl.authz]),
				fcl.limit(9999),
			])
			.then(fcl.decode);
		return fcl.tx(transactionId).onceSealed();
	}, []);

	const setUser = (user) => {
		dispatch({ type: 'setUser', payload: user });
	};

	const logIn = () => {
		fcl.logIn();
	};
	const logOut = () => {
		fcl.unauthenticate();
	};

	useEffect(() => {
		fcl.authenticate();
		fcl.currentUser().subscribe(setUser);
	}, []);

	useEffect(() => {
		if (state.user && state.user.addr) {
			fetchBalance();
			fetchCollection();
		}
	}, [state.user, fetchBalance, fetchCollection]);

	return (
		<Context.Provider
			value={{
				state,
				isReady,
				dispatch,
				logIn,
				logOut,
				fetchBalance,
				fetchCollection,
				createCollection,
				destroyCollection,
				printPicture,
			}}
		>
			{props.children}
		</Context.Provider>
	);
}

export { Context as default, Provider };
