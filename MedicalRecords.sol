// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HealthRecord {

    struct Record {
        uint256 id;
        string patientName;
        string medicalCondition;
        string doctorName;
        string date;
        string dataHash;
        address owner;
        bool isShared;
    }

    Record[] public records;

    mapping (uint256 => address) public recordToApprover;
    mapping (address => mapping (uint256 => bool)) public approvedRecords;

    event RecordCreated(uint256 id, string patientName, string medicalCondition, string doctorName, string date, string dataHash, address owner);
    event RecordShared(uint256 id, address sharee);
    event RecordOwnershipTransferred(uint256 id, address oldOwner, address newOwner);

    function createRecord(string memory _patientName, string memory _medicalCondition, string memory _doctorName, string memory _date, string memory _dataHash) public {
        uint256 id = records.length + 1;
        records.push(Record(id, _patientName, _medicalCondition, _doctorName, _date, _dataHash, msg.sender, false));
        emit RecordCreated(id, _patientName, _medicalCondition, _doctorName, _date, _dataHash, msg.sender);
    }

    function shareRecord(uint256 _id, address _sharee) public {
        require(msg.sender == records[_id - 1].owner, "Only the owner of the record can share it.");
        require(_sharee != address(0), "Invalid sharee address.");
        require(!approvedRecords[_sharee][_id], "Record already shared with this sharee.");
        recordToApprover[_id] = msg.sender;
        approvedRecords[_sharee][_id] = true;
        records[_id - 1].isShared = true;
        emit RecordShared(_id, _sharee);
    }

    function transferRecordOwnership(uint256 _id, address _newOwner) public {
        require(msg.sender == records[_id - 1].owner, "Only the owner of the record can transfer ownership.");
        require(_newOwner != address(0), "Invalid new owner address.");
        records[_id - 1].owner = _newOwner;
        emit RecordOwnershipTransferred(_id, msg.sender, _newOwner);
    }

    function getRecordsCount() public view returns (uint256) {
        return records.length;
    }

    function getRecord(uint256 _id) public view returns (string memory, string memory, string memory, string memory, string memory, address, bool) {
        require(_id <= records.length && _id > 0, "Invalid record ID.");
        Record memory record = records[_id - 1];
        return (record.patientName, record.medicalCondition, record.doctorName, record.date, record.dataHash, record.owner, record.isShared);
    }
}
