Chee Protocol
=================

The Chee Protocol is an Binance Smart Chain smart contract for supplying or borrowing assets. Through the cToken contracts, accounts on the blockchain *supply* capital (CELO or BEP-20 tokens) to receive cTokens or *borrow* assets from the protocol (holding other assets as collateral). The protocol will also enable the minting of CAI, which is the first synthetic stablecoin on Chee that aims to be pegged to 1 USD. CAI is minted by the same collateral that is supplied to the protocol. The Chee cToken contracts track these balances and algorithmically set interest rates for borrowers.

Contracts
=========

We detail the core contracts in the Chee protocol.

<dl>
  <dt>CToken, CBep20 and CCELO</dt>
  <dd>The Chee cTokens, which are self-contained borrowing and lending contracts. CToken contains the core logic and CBep20, VBUSD, VSXP and CCELO add public interfaces for Bep20 tokens and celo, respectively. Each CToken is assigned an interest rate and risk model (see InterestRateModel and Comptroller sections), and allows accounts to *mint* (supply capital), *redeem* (withdraw capital), *borrow* and *repay a borrow*. Each CToken is an BEP-20 compliant token where balances represent ownership of the market.</dd>
</dl>

<dl>
  <dt>Comptroller</dt>
  <dd>The risk model contract, which validates permissible user actions and disallows actions if they do not fit certain risk parameters. For instance, the Comptroller enforces that each borrowing user must maintain a sufficient collateral balance across all cTokens.</dd>
</dl>

<dl>
  <dt>InterestRateModel</dt>
  <dd>Contracts which define interest rate models. These models algorithmically determine interest rates based on the current utilization of a given market (that is, how much of the supplied assets are liquid versus borrowed).</dd>
</dl>

<dl>
  <dt>Careful Math</dt>
  <dd>Library for safe math operations.</dd>
</dl>

<dl>
  <dt>ErrorReporter</dt>
  <dd>Library for tracking error codes and failure conditions.</dd>
</dl>

<dl>
  <dt>Exponential</dt>
  <dd>Library for handling fixed-point decimal numbers.</dd>
</dl>

<dl>
  <dt>WhitePaperInterestRateModel</dt>
  <dd>Initial interest rate model, as defined in the Whitepaper. This contract accepts a base rate and slope parameter in its constructor.</dd>
</dl>

<dl>
  <dt>JumpRateModel</dt>
  <dd>Advanced interest rate model, as defined in the Whitepaper.</dd>
</dl>
