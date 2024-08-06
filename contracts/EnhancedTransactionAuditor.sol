// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract EnhancedTransactionAuditor is AccessControl, ReentrancyGuard {
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    struct Transaction {
        address from;
        address to;
        uint256 amount;
        string description;
        uint256 timestamp;
        bool isAudited;
        bool isFlagged;
        string category;
        uint256 usdValue;
    }

    struct UserReputation {
        uint256 totalTransactions;
        uint256 flaggedTransactions;
        uint256 reputationScore;
    }

    struct AuditorReputation {
        uint256 totalAudits;
        uint256 accurateAudits;
        uint256 reputationScore;
    }

    Transaction[] public transactions;
    mapping(address => UserReputation) public userReputations;
    mapping(address => AuditorReputation) public auditorReputations;

    AggregatorV3Interface internal priceFeed;

    event TransactionRegistered(
        uint256 indexed id,
        address from,
        address to,
        uint256 amount,
        string category
    );
    event TransactionAudited(
        uint256 indexed id,
        bool isFlagged,
        address auditor
    );
    event ReputationUpdated(address indexed user, uint256 newScore);

    constructor(address _priceFeedAddress) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(AUDITOR_ROLE, msg.sender);

        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    function addAuditor(address _auditor) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(AUDITOR_ROLE, _auditor);
    }

    function removeAuditor(
        address _auditor
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(AUDITOR_ROLE, _auditor);
    }

    function registerTransaction(
        address _to,
        uint256 _amount,
        string memory _description,
        string memory _category
    ) public nonReentrant {
        uint256 usdValue = getUsdValue(_amount);
        transactions.push(
            Transaction({
                from: msg.sender,
                to: _to,
                amount: _amount,
                description: _description,
                timestamp: block.timestamp,
                isAudited: false,
                isFlagged: false,
                category: _category,
                usdValue: usdValue
            })
        );

        userReputations[msg.sender].totalTransactions++;
        updateUserReputation(msg.sender);

        emit TransactionRegistered(
            transactions.length - 1,
            msg.sender,
            _to,
            _amount,
            _category
        );
    }

    function auditTransaction(
        uint256 _id,
        bool _flag
    ) public onlyRole(AUDITOR_ROLE) nonReentrant {
        require(_id < transactions.length, "Transaction does not exist");
        Transaction storage transaction = transactions[_id];
        require(!transaction.isAudited, "Transaction already audited");

        transaction.isAudited = true;
        transaction.isFlagged = _flag;

        if (_flag) {
            userReputations[transaction.from].flaggedTransactions++;
            updateUserReputation(transaction.from);
        }

        auditorReputations[msg.sender].totalAudits++;
        updateAuditorReputation(msg.sender);

        emit TransactionAudited(_id, _flag, msg.sender);
    }

    function getTransaction(
        uint256 _id
    )
        public
        view
        returns (
            address from,
            address to,
            uint256 amount,
            string memory description,
            uint256 timestamp,
            bool isAudited,
            bool isFlagged,
            string memory category,
            uint256 usdValue
        )
    {
        require(_id < transactions.length, "Transaction does not exist");
        Transaction storage transaction = transactions[_id];
        return (
            transaction.from,
            transaction.to,
            transaction.amount,
            transaction.description,
            transaction.timestamp,
            transaction.isAudited,
            transaction.isFlagged,
            transaction.category,
            transaction.usdValue
        );
    }

    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    function getUserReputation(address _user) public view returns (uint256) {
        return userReputations[_user].reputationScore;
    }

    function getAuditorReputation(
        address _auditor
    ) public view returns (uint256) {
        return auditorReputations[_auditor].reputationScore;
    }

    function updateUserReputation(address _user) internal {
        UserReputation storage rep = userReputations[_user];
        if (rep.totalTransactions > 0) {
            rep.reputationScore =
                ((rep.totalTransactions - rep.flaggedTransactions) * 100) /
                rep.totalTransactions;
        } else {
            rep.reputationScore = 0;
        }
        emit ReputationUpdated(_user, rep.reputationScore);
    }

    function updateAuditorReputation(address _auditor) internal {
        AuditorReputation storage rep = auditorReputations[_auditor];
        if (rep.totalAudits > 0) {
            rep.reputationScore = (rep.accurateAudits * 100) / rep.totalAudits;
        } else {
            rep.reputationScore = 0;
        }
        emit ReputationUpdated(_auditor, rep.reputationScore);
    }

    function getUsdValue(uint256 _amount) internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return (_amount * uint256(price)) / 1e8; // Assuming 8 decimal places for price feed
    }

    function getFilteredTransactions(
        string memory _category,
        uint256 _fromTimestamp,
        uint256 _toTimestamp
    ) public view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < transactions.length; i++) {
            if (
                keccak256(bytes(transactions[i].category)) ==
                keccak256(bytes(_category)) &&
                transactions[i].timestamp >= _fromTimestamp &&
                transactions[i].timestamp <= _toTimestamp
            ) {
                count++;
            }
        }

        uint256[] memory filteredIds = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < transactions.length; i++) {
            if (
                keccak256(bytes(transactions[i].category)) ==
                keccak256(bytes(_category)) &&
                transactions[i].timestamp >= _fromTimestamp &&
                transactions[i].timestamp <= _toTimestamp
            ) {
                filteredIds[index] = i;
                index++;
            }
        }

        return filteredIds;
    }
}
