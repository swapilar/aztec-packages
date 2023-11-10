use dep::aztec::{
    note::{
        note_header::NoteHeader,
        note_interface::NoteInterface
}

struct Subscription {
    owner: Field,
    expiry: Field,
    randomness: Field,
    header: NoteHeader,
}


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
