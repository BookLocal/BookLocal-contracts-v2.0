# BookLocal-contracts-v2.0
This repo contains the core smart contracts for BookLocal v2.0.

## Quick Test
In a terminal, change into your favorite working directory, and type:
``` bash
git clone https://github.com/BookLocal/BookLocal-contracts-v2.0
cd BookLocal-contracts-v2.0
truffle dev
```
This will log 10 test addresses.
Then, in a new terminal (2), change back into this folder and type:
`
truffle test
`
It should pass all tests without compiler warning. If warnings appear or a test fails, please raise an issue on this repo!

## Usage

In terminal 2: `truffle compile` then `truffle migrate` to deploy the 'BookLocal' contract.

In terminal 1 (at the `truffle(develop)>` prompt):
```
BookLocal.deployed().then(function(res){BL = BookLocal.at(res.address)});
```
This will access the contract. Create a multiSigWallet by:
```

```
Then deploy a new hotel:
```
BL.newHotel([test address from truffle dev (, or two)], multiSigWallet address);
```
This will return the hotel's address. 


## Contents
For a method overview, see "Interfaces" folder. A general overview of the file structure is as follows:

### BookLocal.sol
Constructs with a list of owners and an address that points to the owners current multisig wallet. BookLocal primary role is to act as a 'hotel factory' and records the deployed address for each new hotel.

### Hotel.sol
Constructs with a list of owners and an address that points to the owners current multisig wallet. Additionally, the hotel can include a list of administrator accounts that can perform daily hotel functions (i.e. checkout a guest). The Hotel acts as a RoomType and Reservation factory and records the deployed addresses.

### RoomType.sol
Simple storage contract that can group similar rooms into a single unit. The exact information that it includes can change. The RoomType keeps track of it's own availability and daily status. For example, each day you can easily see:
- arrivals by roomType
- checkOuts by roomType
- occupied by roomType

### Reservation.sol
Simple escrow account between BookLocal, the hotel, and the guest. Commission details subjects to change. Only the hotel can change the final price. Any party in the contract can cancel or checkout of the room. For now, disputes should be settled in person between the hotel and guest with a price adjustement before checkout.
