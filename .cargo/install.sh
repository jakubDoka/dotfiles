rustup default nightly
rustup target add \
	wasm32-unknown-unknown \
	x86_64-unknown-linux-musl
cargo install \
	trunk \
	paru \
	cargo-udeps \
	cargo-tree
