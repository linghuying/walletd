CREATE TABLE sia_addresses (
	id INTEGER PRIMARY KEY,
	sia_address BLOB UNIQUE NOT NULL,
	siacoin_balance BLOB NOT NULL,
	immature_siacoin_balance BLOB NOT NULL,
	siafund_balance INTEGER NOT NULL
);

CREATE TABLE siacoin_elements (
	id BLOB PRIMARY KEY,
	siacoin_value BLOB NOT NULL,
	merkle_proof BLOB NOT NULL,
	leaf_index INTEGER NOT NULL,
	maturity_height INTEGER NOT NULL, /* stored as int64 for easier querying */
	address_id INTEGER NOT NULL REFERENCES sia_addresses (id),
	matured BOOLEAN NOT NULL, /* tracks whether the value has been added to the address balance */
	block_id BLOB NOT NULL,
	height INTEGER NOT NULL
);
CREATE INDEX siacoin_elements_address_id ON siacoin_elements (address_id);
CREATE INDEX siacoin_elements_maturity_height_matured ON siacoin_elements (maturity_height, matured);
CREATE INDEX siacoin_elements_block_id_height ON siacoin_elements (block_id, height);

CREATE TABLE siafund_elements (
	id BLOB PRIMARY KEY,
	claim_start BLOB NOT NULL,
	merkle_proof BLOB NOT NULL,
	leaf_index INTEGER NOT NULL,
	siafund_value INTEGER NOT NULL,
	address_id INTEGER NOT NULL REFERENCES sia_addresses (id),
	block_id BLOB NOT NULL,
	height INTEGER NOT NULL
);
CREATE INDEX siafund_elements_address_id ON siafund_elements (address_id);
CREATE INDEX siafund_elements_block_id_height ON siafund_elements (block_id, height);

CREATE TABLE events (
	id INTEGER PRIMARY KEY,
	event_id BLOB UNIQUE NOT NULL,
	maturity_height INTEGER NOT NULL,
	date_created INTEGER NOT NULL,
	event_type TEXT NOT NULL,
	event_data BLOB NOT NULL,
	block_id BLOB NOT NULL,
	height INTEGER NOT NULL
);
CREATE INDEX events_block_id_height ON events (block_id, height);

CREATE TABLE event_addresses (
	event_id INTEGER NOT NULL REFERENCES events (id) ON DELETE CASCADE,
	address_id INTEGER NOT NULL REFERENCES sia_addresses (id),
	PRIMARY KEY (event_id, address_id)
);
CREATE INDEX event_addresses_event_id_idx ON event_addresses (event_id);
CREATE INDEX event_addresses_address_id_idx ON event_addresses (address_id);

CREATE TABLE wallets (
	id INTEGER PRIMARY KEY,
	friendly_name TEXT NOT NULL,
	description TEXT NOT NULL,
	date_created INTEGER NOT NULL,
	last_updated INTEGER NOT NULL,
	extra_data BLOB
);

CREATE TABLE wallet_addresses (
	wallet_id INTEGER NOT NULL REFERENCES wallets (id),
	address_id INTEGER NOT NULL REFERENCES sia_addresses (id),
	description TEXT NOT NULL,
	spend_policy BLOB,
	extra_data BLOB,
	UNIQUE (wallet_id, address_id)
);
CREATE INDEX wallet_addresses_wallet_id ON wallet_addresses (wallet_id);
CREATE INDEX wallet_addresses_address_id ON wallet_addresses (address_id);

CREATE TABLE syncer_peers (
	peer_address TEXT PRIMARY KEY NOT NULL,
	first_seen INTEGER NOT NULL
);

CREATE TABLE syncer_bans (
	net_cidr TEXT PRIMARY KEY NOT NULL,
	expiration INTEGER NOT NULL,
	reason TEXT NOT NULL
);
CREATE INDEX syncer_bans_expiration_index ON syncer_bans (expiration);

CREATE TABLE global_settings (
	id INTEGER PRIMARY KEY NOT NULL DEFAULT 0 CHECK (id = 0), -- enforce a single row
	db_version INTEGER NOT NULL, -- used for migrations
	last_indexed_tip BLOB NOT NULL -- the last chain index that was processed
);
