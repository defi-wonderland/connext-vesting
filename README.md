# Connext Unlock Contract

The `Unlock` contract is meant to be used as a receiver of a LlamaPay stream. It allows the owner to unlock their vested tokens at a different rate than the vesting. The main goal of that would be to delay the unlocking of the tokens in case of an early cancellation of the vesting stream.

<img src="unlock.svg" alt="vesting and unlocking" align="center" />

## Setup

1. Copy the `.env.example` file to `.env` and fill in the variables.
1. Install the dependencies by running `yarn install`. In case there is an error with the commands, run `foundryup` and try them again.
1. Run `yarn test` to make sure everything is working.

## Deploy & verify

```bash
# Deploys to mainnet
yarn deploy

# Deploys to Sepolia
yarn deploy:sepolia
```

## Licensing

The primary license for Prophet contracts is MIT, see [`LICENSE`](./LICENSE).

## Contributors

Built with ❤️ by [Wonderland](https://defi.sucks), a team of top Web3 researchers, developers, and operators who believe that the future needs to be open-source, permissionless, and decentralized.

[DeFi sucks](https://defi.sucks), but Wonderland is here to make it better.
