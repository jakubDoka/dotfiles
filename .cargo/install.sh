pacman -S mold rustup

rustup default nightly
rustup target add \
	wasm32-unknown-unknown \
	x86_64-unknown-linux-musl
rustup component add \
	rustc-codegen-cranelift-preview \
	--toolchain nightly

cargo install \
	cargo-expand \
	trunk \
	paru \
	cargo-udeps \
	cargo-tree \
	bat \
	ripgrep \
	live-server \
	cargo-contract \
	subxt-cli \
	mdbook \
	mdbook-mermaid \
	wasm-bindgen-cli \
	wasm-opt \
	cargo-sweep
	# contracts-node \

