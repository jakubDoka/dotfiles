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
	subxt-cli
	# contracts-node \

install_repo() {
	local dir="temp-install"
	local repo="$1"

	git clone "$repo" "$dir"
	cargo update --manifest-path "$dir/Cargo.toml"
	cargo install --path "$dir"
	rm -rf "$dir"
}

install_repo https://github.com/paritytech/smart-bench.git
