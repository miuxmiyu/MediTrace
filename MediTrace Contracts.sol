// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Trace {
    address public owner;
    mapping(address => bool) public rawMaterialProviders;
    mapping(address => bool) public drugManufacturers;
    mapping(address => bool) public wholesaleDistributors;

    struct RawMaterial {
        string materialName;
        address producer;
        string origin;
        uint256 timestamp;
        string purity;
        string strength;
        string quality;
    }

    struct Medication {
        string medicationName;
        address producer;
        string origin;
        uint256 timestamp;
        uint256[] rawBatchIDs;
        string strength;
        string quality;
    }  

    struct Distribution {
        address distributor;
        uint256 medicationID;
        uint256 timestamp;
    }

    mapping (uint256 => RawMaterial) public rawMaterialBatches;
    mapping (uint256 => Medication) public medicationBatches;
    mapping (uint256 => Distribution[]) public distributions;

    uint256 public rawBatchCount;
    uint256 public medicationCount;

    event RawMaterialBatchCreated(uint256 rawBatchID, string materialName, address producer, string origin,
        uint256 timestamp, string purity, string strength, string quality);

    event MedicationCreated(uint256 medicationID, string medicationName, address producer, string origin,
        uint256 timestamp, uint256[] rawBatchIDs, string strength, string quality);

    event MedicationDistributed(uint256 medicationID, address distributor, uint256 timestamp);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this");
        _;
    }

    modifier onlyRawMaterials() {
        require(rawMaterialProviders[msg.sender], "Only raw material providers can execute this");
        _;
    }

    modifier onlyDrugManufacturers() {
        require(drugManufacturers[msg.sender], "Only drug manufacturers can execute this");
        _;
    }

    modifier onlyDistributors() {
        require(wholesaleDistributors[msg.sender], "Only wholesale distributors can execute this");
        _;
    }

    function addRawMatProvider(address _address) public onlyOwner {
        rawMaterialProviders[_address] = true;
    }

    function addDrugManufacturer(address _address) public onlyOwner {
        drugManufacturers[_address] = true;
    }

    function addDistributor(address _address) public onlyOwner {
        wholesaleDistributors[_address] = true;
    }

    function assignRawBatch(string memory _materialName, string memory _origin, string memory _purity, string memory _strength, string memory _quality) public onlyRawMaterials {
        rawBatchCount++;
        rawMaterialBatches[rawBatchCount] = RawMaterial(_materialName, msg.sender, _origin, block.timestamp, _purity, _strength, _quality);
        emit RawMaterialBatchCreated(rawBatchCount, _materialName, msg.sender, _origin, block.timestamp, _purity, _strength, _quality);
    }

    function assignMed(string memory _medicationName, string memory _origin, uint256[] memory _rawBatchIDs, string memory _strength, string memory _quality) public onlyDrugManufacturers {
        medicationCount++;
        medicationBatches[medicationCount] = Medication(_medicationName, msg.sender, _origin, block.timestamp, _rawBatchIDs, _strength, _quality);
        emit MedicationCreated(rawBatchCount, _medicationName, msg.sender, _origin, block.timestamp, _rawBatchIDs, _strength, _quality);
    }

    function distribute(uint256 _medicationID) public onlyDistributors {
        require(medicationBatches[_medicationID].producer != address(0), "Invalid medication ID");
        distributions[_medicationID].push(Distribution({distributor: msg.sender, medicationID: _medicationID, timestamp: block.timestamp}));
        emit MedicationDistributed(_medicationID, msg.sender, block.timestamp);
    }

    function getDistributions(uint256 _medicationID) public view returns (address[] memory, uint256[] memory) {
        require(_medicationID > 0 && _medicationID <= medicationCount, "Invalid medication ID");
        Distribution[] storage medDistributions = distributions[_medicationID];
        address[] memory distributorAddresses = new address[](medDistributions.length);
        uint256[] memory distributedTimestamps = new uint256[](medDistributions.length);
        for (uint i = 0; i < medDistributions.length; i++) {
            distributorAddresses[i] = medDistributions[i].distributor;
            distributedTimestamps[i] = medDistributions[i].timestamp;
        }
        return (distributorAddresses, distributedTimestamps);
    }

    function getRawBatch(uint256 _rawBatchID) public view returns (
        string memory,
        address,
        string memory,
        uint256,
        string memory,
        string memory,
        string memory
    ) {
        require(_rawBatchID > 0 && _rawBatchID <= rawBatchCount, "Invalid raw batch ID");
        RawMaterial storage batch = rawMaterialBatches[_rawBatchID];
        return (
            batch.materialName,
            batch.producer,
            batch.origin,
            batch.timestamp,
            batch.purity,
            batch.strength,
            batch.quality
        );
    }

    function getMed(uint256 _medicationID) public view returns (
        string memory,
        address,
        string memory,
        uint256,
        string memory,
        string memory
    ) {
        require(_medicationID > 0 && _medicationID <= medicationCount, "Invalid medication ID");
        Medication storage med = medicationBatches[_medicationID];
        return (
            med.medicationName,
            med.producer,
            med.origin,
            med.timestamp,
            med.strength,
            med.quality
        );
    }
}

contract ProvideToConsumer {
    address public owner;

    struct TransferRecord {
        address sender;
        address receiver;
        uint256 medicationID;
        uint256 timestamp;
    }

    mapping(uint256 => TransferRecord[]) public transferHistory;

    event MedicationTransferred(uint256 medicationID, address from, address to, uint256 timestamp);

    constructor() {
        owner = msg.sender;
    }

    function transfer(uint256 _medicationID, address _to) public {
        require(_to != address(0), "Invalid receiver address");
        transferHistory[_medicationID].push(TransferRecord({
            sender: msg.sender,
            receiver: _to,
            medicationID: _medicationID,
            timestamp: block.timestamp
        }));
        emit MedicationTransferred(_medicationID, msg.sender, _to, block.timestamp);
    }
}
