pragma solidity ^0.5.16;

contract ICheeOraclePrice {
    function post() external;
    function get() external view returns (uint256);
    function getWithError() external view returns (uint256, bool, bool);
    function void() external;
    function activate() external;
}
