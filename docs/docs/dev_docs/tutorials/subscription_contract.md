# Subscription Contract

In this example we're gonna build a subscription contract

## User flow

- User calls a function on the contract
  - Generates authwit
  - Calls the "subscribe" private function (runs client-side) with the authwit
  - "Subscribe" calls the token contract
  - Token contract verifies authwit
- Contract adds subscription to a note map set
- [On a noir project OR private function] prove that you own a valid subscription

## Building blocks

What do we need for this tutorial:
  
1. Run the sandbox
2. Deploy a [token contract](./writing_token_contract.md)
3. Create a `main.nr` file to hold our contract.
4. Download and import the token contract interface (currently, generate it from the previous step) at the top of `main.nr`

```rust
mod token_interface;
```

## Our imports

In order to build our project, we need to set up some boilerplate. Namely, we need private state, which means we need to import `Context`:

```rust
contract SubscriptionManager {
    use dep::aztec::{
        context::{Context}
    }
}
```

<!--  TODO hyperlinks to MAP -->
We also need state variables, namely Map (so we can map addresses to Notes), and Set (where notes are stored), and PublicState because we need public state as well:

```rust
contract SubscriptionManager {
    use dep::aztec::{
        // other imports
        state_vars::{map::Map, set::Set, public_state::PublicState},
    }
}
```

## Defining our Note type

Our subscription contract holds private Notes, representing individual subscriptions to our system. This means we have to define its structure.

Let's create another file `subscription_note.nr` and start adding stuff there.

### Note structure

For our note type, we need some information about the subscription (Note Contents). We will be adding methods using an `impl` declaration:

```rust
struct Subscription {
    owner: Field,
    expiry: Field,
}

impl Subscription {
    // our methods go here
}
```

NoteHeader is a mandatory field in every note, so we will be adding it. Since our note is meant to be private, we should also add a `randomness` Field.

```rust
use dep::aztec::{
    // ...your other dependencies...
    note::{
        note_header::NoteHeader,
    }
}


struct SubscriptionNote {
    // ...your other fields... 
    randomness: Field,
    header: NoteHeader,
}
```

### Note methods

We should now have a clear view on what's going to be stored. However, we still need to declare how to access them, and what do they do exactly.

### Serialization and deserialization

Aztec contracts are expected to store data as an array of fields. As you can imagine, the order of these fields matter a lot! For that reason, we need to define some methods to correctly serialize and deserialize this private state.

```rust

global SUBSCRIPTION_NOTE_LENGTH: Field = 3;

impl Subscription {
    pub fn serialize(self) -> [Field; SUBSCRIPTION_NOTE_LENGTH]{
        [self.owner, self.expiry, self.randomness]
    }

    pub fn deserialize(serialized: [Field; SUBSCRIPTION_NOTE_LENGTH]) -> Self {
        Subscription {
            owner: serialized[0],
            expiry: serialized[1],
            randomness: serialized[2],
            header: NoteHeader::empty(),
        }
    }
}
```

### Interface

So far, so good. We told the compiler how is our Note defined, and what methods can be used to access them.

However, since Noir doesn't support Traits yet, we need to define these methods outside of our `impl`, and export them as an interface:

```rust
use dep::aztec::{
    note::{ note_interface::NoteInterface },
}

fn serialize(note: Subscription) -> [Field; SUBSCRIPTION_NOTE_LENGTH]{
    note.serialize()
}

fn deserialize(serialized_note : [Field; SUBSCRIPTION_NOTE_LENGTH]) -> Subscription {
    note.deserialize(serialized_note)
}


global SubscriptionInterface = NoteInterface {
    serialize,
    deserialize
};
```

:::note
You need to remember to correctly export your methods in the interface, by defining them outside of the `impl` declaration, and passing them to the NoteInterface constructor.
:::

## Our contract

Back to our contract `main.nr`, we're ready to start writing our methods. Let's start with the big stuff: how to subscribe to our service!

The whole point is that the user doesn't reveal to the world the purchase of the subscription. So, this function executes client-side, and only the proof of the execution is sent.

So, the `token_contract` address needs to be passed in, together with the required amount

```rust
#[aztec(private)]
fn subscribe( 
    token_contract: AztecAddress,
    amount: Field,
    nonce: Field,
) {
    // body goes here
}
```
