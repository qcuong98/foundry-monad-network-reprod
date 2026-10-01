# Repro: `--network monad` breaks multichain `forge script` / `forge test`

Since forge 1.8.0, forking Monad requires `--network monad`. This flag is set once for the whole
invocation, so a single `forge script` or `forge test` that touches Monad **and** a non-Monad
chain can no longer run correctly. It has to be split into two separate invocations.

Tested with:

```
forge Version: 1.8.3
Commit SHA: cae51ad458f6abb64852b7709eb784352429825d
```

## Setup

```shell
git clone <this repo> && cd foundry-monad-network-reprod
forge install
```

The repo has two RPC endpoints in `foundry.toml`, and no private key or funds are needed:

| alias           | chain                 | network family |
| --------------- | --------------------- | -------------- |
| `sepolia`       | Ethereum Sepolia      | `ethereum`     |
| `monad_testnet` | Monad Testnet (10143) | `monad`        |

## Script: one invocation across chains fails

[`script/DeployMultichain.s.sol`](script/DeployMultichain.s.sol). `run()` deploys `Counter` to
every chain using `vm.createSelectFork`.

```shell
forge script script/DeployMultichain.s.sol
```

```
  sepolia 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
Error: script failed: vm.createSelectFork: cannot create a `monad` fork with an EVM instantiated for `ethereum`
```

Current workaround: run once per network family.

```shell
forge script script/DeployMultichain.s.sol --sig "deploy(string)" sepolia
forge script script/DeployMultichain.s.sol --sig "deploy(string)" monad_testnet --network monad
```

## Test: one invocation across chains fails

[`test/MultichainFork.t.sol`](test/MultichainFork.t.sol)

```shell
forge test
```

```
[FAIL: vm.createSelectFork: cannot create a `monad` fork with an EVM instantiated for `ethereum`] test_monadTestnet() (gas: 3160)
[PASS] test_sepolia() (gas: 51078)
Suite result: FAILED. 1 passed; 1 failed; 0 skipped
```

Current workaround: run once per network family.

```shell
forge test --no-match-test monad
forge test --match-test monad --network monad
```

## Why not pass `--network monad` to everything?

`forge script ... --network monad` and `forge test --network monad` do pass. But then the
Sepolia fork also runs under Monad's EVM rules, not Ethereum's. That is wrong for any
non-Monad chain in the same run, so the only correct option today is to split the run.

## Expected

A single `forge script` or `forge test` should be able to fork Monad and non-Monad chains
together, as it could before 1.8.0. Two possible approaches:

- **Auto-detect the network family per fork** from the fork's chain id (`143` / `10143` → `monad`),
  so `vm.createSelectFork` switches EVM family when it switches forks.
- **Per-endpoint config**, for example:

  ```toml
  [rpc_endpoints]
  monad_testnet = { endpoint = "https://testnet-rpc.monad.xyz", network = "monad" }
  ```
