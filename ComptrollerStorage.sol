pragma solidity ^0.5.16;

import "./CToken.sol";
import "./PriceOracle.sol";
import "./CAIControllerInterface.sol";

contract UnitrollerAdminStorage {
    /**
    * @notice Administrator for this contract
    */
    address public admin;

    /**
    * @notice Pending administrator for this contract
    */
    address public pendingAdmin;

    /**
    * @notice Active brains of Unitroller
    */
    address public comptrollerImplementation;

    /**
    * @notice Pending brains of Unitroller
    */
    address public pendingComptrollerImplementation;
}

contract ComptrollerV1Storage is UnitrollerAdminStorage {

    /**
     * @notice Oracle which gives the price of any given asset
     */
    PriceOracle public oracle;

    /**
     * @notice Multiplier used to calculate the maximum repayAmount when liquidating a borrow
     */
    uint public closeFactorMantissa;

    /**
     * @notice Multiplier representing the discount on collateral that a liquidator receives
     */
    uint public liquidationIncentiveMantissa;

    /**
     * @notice Max number of assets a single account can participate in (borrow or use as collateral)
     */
    uint public maxAssets;

    /**
     * @notice Per-account mapping of "assets you are in", capped by maxAssets
     */
    mapping(address => CToken[]) public accountAssets;

    struct Market {
        /// @notice Whether or not this market is listed
        bool isListed;

        /**
         * @notice Multiplier representing the most one can borrow against their collateral in this market.
         *  For instance, 0.9 to allow borrowing 90% of collateral value.
         *  Must be between 0 and 1, and stored as a mantissa.
         */
        uint collateralFactorMantissa;

        /// @notice Per-market mapping of "accounts in this asset"
        mapping(address => bool) accountMembership;

        /// @notice Whether or not this market receives CHEE
        bool isChee;
    }

    /**
     * @notice Official mapping of cTokens -> Market metadata
     * @dev Used e.g. to determine if a market is supported
     */
    mapping(address => Market) public markets;

    /**
     * @notice The Pause Guardian can pause certain actions as a safety mechanism.
     *  Actions which allow users to remove their own assets cannot be paused.
     *  Liquidation / seizing / transfer can only be paused globally, not by market.
     */
    address public pauseGuardian;
    bool public _mintGuardianPaused;
    bool public _borrowGuardianPaused;
    bool public transferGuardianPaused;
    bool public seizeGuardianPaused;
    mapping(address => bool) public mintGuardianPaused;
    mapping(address => bool) public borrowGuardianPaused;

    struct CheeMarketState {
        /// @notice The market's last updated cheeBorrowIndex or cheeSupplyIndex
        uint224 index;

        /// @notice The block number the index was last updated at
        uint32 block;
    }

    /// @notice A list of all markets
    CToken[] public allMarkets;

    /// @notice The rate at which the flywheel distributes CHEE, per block
    uint public cheeRate;

    /// @notice The portion of cheeRate that each market currently receives
    mapping(address => uint) public cheeSpeeds;

    /// @notice The Chee market supply state for each market
    mapping(address => CheeMarketState) public cheeSupplyState;

    /// @notice The Chee market borrow state for each market
    mapping(address => CheeMarketState) public cheeBorrowState;

    /// @notice The Chee supply index for each market for each supplier as of the last time they accrued CHEE
    mapping(address => mapping(address => uint)) public cheeSupplierIndex;

    /// @notice The Chee borrow index for each market for each borrower as of the last time they accrued CHEE
    mapping(address => mapping(address => uint)) public cheeBorrowerIndex;

    /// @notice The CHEE accrued but not yet transferred to each user
    mapping(address => uint) public cheeAccrued;

    /// @notice The Address of CAIController
    CAIControllerInterface public caiController;

    /// @notice The minted CAI amount to each user
    mapping(address => uint) public mintedCAIs;

    /// @notice CAI Mint Rate as a percentage
    uint public caiMintRate;

    /**
     * @notice The Pause Guardian can pause certain actions as a safety mechanism.
     */
    bool public mintCAIGuardianPaused;
    bool public repayCAIGuardianPaused;

    /**
     * @notice Pause/Unpause whole protocol actions
     */
    bool public protocolPaused;

    /// @notice The rate at which the flywheel distributes CHEE to CAI Minters, per block
    uint public cheeCAIRate;
}

contract ComptrollerV2Storage is ComptrollerV1Storage {
    /// @notice The rate at which the flywheel distributes CHEE to CAI Vault, per block
    uint public cheeCAIVaultRate;

    // address of CAI Vault
    address public caiVaultAddress;

    // start block of release to CAI Vault
    uint256 public releaseStartBlock;

    // minimum release amount to CAI Vault
    uint256 public minReleaseAmount;
}

contract ComptrollerV3Storage is ComptrollerV2Storage {
    /// @notice The borrowCapGuardian can set borrowCaps to any number for any market. Lowering the borrow cap could disable borrowing on the given market.
    address public borrowCapGuardian;

    /// @notice Borrow caps enforced by borrowAllowed for each cToken address. Defaults to zero which corresponds to unlimited borrowing.
    mapping(address => uint) public borrowCaps;
}

contract ComptrollerV4Storage is ComptrollerV3Storage {
    /// @notice Treasury Guardian address
    address public treasuryGuardian;

    /// @notice Treasury address
    address public treasuryAddress;

    /// @notice Fee percent of accrued interest with decimal 18
    uint256 public treasuryPercent;
}
contract ComptrollerV5Storage is ComptrollerV4Storage {
    /// @notice The portion of CHEE that each contributor receives per block
    mapping(address => uint) public cheeContributorSpeeds;

    /// @notice Last block at which a contributor's CHEE rewards have been allocated
    mapping(address => uint) public lastContributorBlock;
}
