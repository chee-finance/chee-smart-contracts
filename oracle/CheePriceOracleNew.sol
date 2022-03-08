pragma solidity 0.5.16;

import "./PriceOracle.sol";
import "./CBep20.sol";
import "./BEP20Interface.sol";
import "./SafeMath.sol";
import "./ICheeOraclePrice.sol";

contract CheePriceOracleNew is PriceOracle {
    using SafeMath for uint;
    uint public constant CAI_VALUE = 1e18;
    address public admin;

    mapping(address => uint) internal prices;
    mapping(bytes32 => ICheeOraclePrice) internal feeds;
    event PricePosted(address asset, uint previousPriceMantissa, uint requestedPriceMantissa, uint newPriceMantissa);
    event NewAdmin(address oldAdmin, address newAdmin);
    event FeedSet(address feed, string symbol);

    constructor() public {
        admin = msg.sender;
    }

    function getUnderlyingPrice(CToken cToken) public view returns (uint) {
        string memory symbol = cToken.symbol();
        if (compareStrings(symbol, "cCELO")) {
            return getCheeOraclePrice(getFeed(symbol));
        } else if (compareStrings(symbol, "CAI")) {
            return CAI_VALUE;
        } else if (compareStrings(symbol, "CHEE")) {
            return prices[address(cToken)];
        } else {
            return getPrice(cToken);
        }
    }

    function getPrice(CToken cToken) internal view returns (uint price) {
        BEP20Interface token = BEP20Interface(CBep20(address(cToken)).underlying());

        if (prices[address(token)] != 0) {
            price = prices[address(token)];
        } else {
            price = getCheeOraclePrice(getFeed(token.symbol()));
        }

        return price;
    }

    function getCheeOraclePrice(ICheeOraclePrice feed) internal view returns (uint) {
        // USD-denominated feeds store answers at 18 decimals
        return uint(feed.get());
    }

    function setUnderlyingPrice(CToken cToken, uint underlyingPriceMantissa) external onlyAdmin() {
        address asset = address(CBep20(address(cToken)).underlying());
        emit PricePosted(asset, prices[asset], underlyingPriceMantissa, underlyingPriceMantissa);
        prices[asset] = underlyingPriceMantissa;
    }

    function setDirectPrice(address asset, uint price) external onlyAdmin() {
        emit PricePosted(asset, prices[asset], price, price);
        prices[asset] = price;
    }

    function setFeed(string calldata symbol, address feed) external onlyAdmin() {
        require(feed != address(0) && feed != address(this), "invalid feed address");
        emit FeedSet(feed, symbol);
        feeds[keccak256(abi.encodePacked(symbol))] = ICheeOraclePrice(feed);
    }

    function getFeed(string memory symbol) public view returns (ICheeOraclePrice) {
        return feeds[keccak256(abi.encodePacked(symbol))];
    }

    function assetPrices(address asset) external view returns (uint) {
        return prices[asset];
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function setAdmin(address newAdmin) external onlyAdmin() {
        address oldAdmin = admin;
        admin = newAdmin;

        emit NewAdmin(oldAdmin, newAdmin);
    }

    modifier onlyAdmin() {
      require(msg.sender == admin, "only admin may call");
      _;
    }
}
