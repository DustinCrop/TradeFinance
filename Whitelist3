pragma solidity ^0.5.11;

contract AddressList {

    mapping(address => bool) public list;
    address[] public addressList;

    constructor(address[] memory _assets) public {
        for (uint i = 0; i < _assets.length; i++) {
            if (isMember(_assets[i])) { // filter duplicates in _assets
                list[_assets[i]] = true;
                addressList.push(_assets[i]);
            }
    }

    /// @return whether an asset is in the list
    function isMember(address _asset) public view returns (bool) {
        return list[_asset];
    }

    /// @return number of assets specified in the list
    function getMemberCount() external view returns (uint) {
        return addressList.length;
    }

    /// @return array of all listed asset addresses
    function getMembers() external view returns (address[] memory) {
        return addressList;
    }
}
