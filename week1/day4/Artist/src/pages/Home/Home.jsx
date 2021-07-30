import React, { useReducer, useContext, useState } from 'react';
import classNames from 'classnames';
import { Link, useHistory } from 'react-router-dom';

import Pixel from '../../model/Pixel.js';

import FlowContext from '../../context/Flow.jsx';

import Collection from './Collection.jsx';
import Frame from '../Draw/Frame.jsx';

import './Home.css';

function reducer(state, action) {
	switch (action.type) {
		case 'setPicture': {
			return {
				...state,
				picture: action.payload,
			};
		}
		case 'startLoading': {
			return {
				...state,
				message: null,
				isLoading: true,
			};
		}
		case 'stopLoading': {
			return {
				...state,
				isLoading: false,
			};
		}
		case 'setMessage': {
			return {
				...state,
				message: action.payload,
				isLoading: false,
			};
		}
		default:
			return state;
	}
}

function Home(props) {
	const [focusedPicture, setFocusedPicture] = useState(null);
	const [state, dispatch] = useReducer(reducer, {
		message: null,
		isLoading: false,
	});
	const flow = useContext(FlowContext);
	const history = useHistory();

	const onFocus = (picture) => {
		if (focusedPicture === picture) {
			setFocusedPicture(null);
		} else {
			setFocusedPicture(picture);
		}
	};
	const onSell = () => {
		history.push('/trade');
	};

	//Quick copy pasta from Draw.jsx if statement has not been changed.
	const onDestroyCollection = async () => {
		if (!state.isLoading) {
			dispatch({ type: 'startLoading' });
			try {
				const response = await flow.destroyCollection();
				if (response.statusCode === 0) {
					await flow.fetchCollection();
					dispatch({ type: 'stopLoading' });
				}
			} catch (error) {
				dispatch({
					type: 'setMessage',
					payload: {
						type: 'warning',
						contents: error.toString().replace('Error: ', ''),
					},
				});
			}
		}
	};

	return (
		<div>
			<h5 className="title is-5">Account Information</h5>
			<table className="table is-bordered is-fullwidth">
				<tbody>
					<tr>
						<td>Address</td>
						<td>{flow.state.user.addr}</td>
					</tr>
					<tr>
						<td>FLOW balance</td>
						<td>{flow.state.balance}</td>
					</tr>
				</tbody>
			</table>

			<h5 className="title is-5">Collection</h5>
			<Collection
				collection={flow.state.collection}
				focusedPicture={focusedPicture}
				noCollectionNotification={
					<div className="notification">
						You don't have a collection, please create one in the{' '}
						<Link to="/draw">Draw</Link> tab.
					</div>
				}
				emptyCollectionNotification={
					<div className="notification">
						Your collection is empty.
					</div>
				}
				onFocus={onFocus}
			/>
			<button
				className={classNames({
					'button is-primary': true,
				})}
				onClick={onDestroyCollection}
			>
				Destroy Collection
			</button>

			{focusedPicture && (
				<React.Fragment>
					<h5 className="title is-5">Picture</h5>
					<div className="block">
						<Frame
							pixel={Pixel.full}
							grid={{
								rows: 5,
								columns: 5,
							}}
							picture={focusedPicture}
						/>
					</div>
					<div className="tags has-addons block">
						<span className="tag is-dark">Serialized</span>
						<span className="tag is-family-monospace">
							{focusedPicture.pixels}
						</span>
					</div>
					<div className="block">
						<div className="field is-grouped block">
							<div className="control">
								<button
									className="button is-primary"
									onClick={onSell}
								>
									Sell
								</button>
							</div>
						</div>
					</div>
				</React.Fragment>
			)}
		</div>
	);
}

export default Home;
