// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Trace {
    // The contract owner's address
    address public owner;
    mapping(address => bool) public rawMaterialProviders;
    mapping(address => bool) public drugManufacturers;
    mapping(address => bool) public wholesaleDistributors;
    
    // Struct to define the structure of a raw material batch
    struct RawMaterial {
        string materialName; // Name of the material
        address producer;    // Address of the producer
        string origin;       // Origin or source of the batch
        uint256 timestamp;   // Timestamp of when the batch was created
        string purity;
        string strength;
        string quality;      // e.g. physical characteristics and stability
    }

    // Struct to define the structure of a medication batch
    struct Medication {
        string medicationName;  // Name of the medication
        address producer;       // Address of the producer
        string origin;          // Origin or source of the batch
        uint256 timestamp;      // Timestamp of when the batch was created
        uint256[] rawBatchIDs;  // Raw material batch IDs
        string strength;
        string quality;         // e.g. physical characteristics
    }  

    // Struct to define the structure of medication distribution
    struct Distribution {
        address distributor;    // Who sent the medication
        uint256 medicationID;   // Which medication batch was sent
        uint256 timestamp;      // When it was sent
    }

    // Mappings to store raw material and medication info based on IDs
    mapping (uint256 => RawMaterial) public rawMaterialBatches;
    mapping (uint256 => Medication) public medicationBatches;

    // Mapping to track where each medication batch has been distributed
    mapping (uint256 => Distribution[]) public distributions;
    
    // Counters to keep track of the total number of raw material and medication batches
    uint256 public rawBatchCount;
    uint256 public medicationCount;

    // Event triggered when a new raw material batch is created
    event RawMaterialBatchCreated(uint256 rawBatchID, string materialName, address producer, string origin,
        uint256 timestamp, string purity, string strength, string quality);

    // Event triggered when a new raw material batch is created
    event MedicationCreated(uint256 medicationID, string medicationName, address producer, string origin,
        uint256 timestamp, uint256[] rawBatchIDs, string strength, string quality);

   // Event triggered emitted when a medication is distributed
    event MedicationDistributed(uint256 medicationID, address distributor, uint256 timestamp);

    // Contract constructor, executed once during deployment
    constructor() {
        // Set the contract owner to the address that deploys the contract
        owner = msg.sender;
    }

    // Modifiers to restrict access
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

    // Functions to add trusted user addresses
    function addRawMatProvider(address _address) public onlyOwner {
        rawMaterialProviders[_address] = true;
    }

    function addDrugManufacturer(address _address) public onlyOwner {
        drugManufacturers[_address] = true;
    }

    function addDistributor(address _address) public onlyOwner {
        wholesaleDistributors[_address] = true;
    }

    // Function to assign an ID to a new batch of raw materials
    function assignRawBatch(string memory _materialName, string memory _origin, string memory _purity, string memory _strength, string memory _quality) public onlyRawMaterials {
        // Increment rawBatchCount to generate a unique batch ID
        rawBatchCount++;
        
        // Create a new raw material batch and store it in the mapping
        rawMaterialBatches[rawBatchCount] = RawMaterial(
            _materialName,
            msg.sender,
            _origin,
            block.timestamp,
            _purity,
            _strength,
            _quality
        );
        
        // Emit an event to signify the creation of a new raw material batch
        emit RawMaterialBatchCreated(
            rawBatchCount,
            _materialName,
            msg.sender,
            _origin,
            block.timestamp,
            _purity,
            _strength,
            _quality
        );
    }

    // Function to assign an ID to a new medication batch
    function assignMed(string memory _medicationName, string memory _origin, uint256[] memory _rawBatchIDs, string memory _strength, string memory _quality) public onlyDrugManufacturers {
        // Increment medicationCount to generate a unique batch ID
        medicationCount++;
        
        // Create a new medication batch and store it in the mapping
        medicationBatches[medicationCount] = Medication(
            _medicationName,
            msg.sender,
            _origin,
            block.timestamp,
            _rawBatchIDs,
            _strength,
            _quality
        );
        
        // Emit an event to signify the creation of a new raw material batch
        emit MedicationCreated(
            rawBatchCount,
            _medicationName,
            msg.sender,
            _origin,
            block.timestamp,
            _rawBatchIDs,
            _strength,
            _quality
        );
    }

    // Distribution of the medication to pharmacies and hospitals
    function distribute(uint256 _medicationID) public onlyDistributors {
        // Make sure the medication batch exists
        require(medicationBatches[_medicationID].producer != address(0), "Invalid medication ID");

        // Save distribution info
        distributions[_medicationID].push(Distribution({
            distributor: msg.sender,
            medicationID: _medicationID,
            timestamp: block.timestamp
        }));

        // Emit event to log this action
        emit MedicationDistributed(_medicationID, msg.sender, block.timestamp);
    }

    // Function to get details of a specific medication's distributions based on its ID
    function getDistributions(uint256 _medicationID) public view returns (address[] memory, uint256[] memory) {
        // Check if the provided medication ID is valid
        require(_medicationID > 0 && _medicationID <= medicationCount, "Invalid medication ID");
        
        // Retrieve and return the details of the specified medication's distributions
        Distribution[] storage medDistributions = distributions[_medicationID];

        address[] memory distributorAddresses = new address[](medDistributions.length);
        uint256[] memory distributedTimestamps = new uint256[](medDistributions.length);

        for (uint i = 0; i < medDistributions.length; i++) {
            distributorAddresses[i] = medDistributions[i].distributor;
            distributedTimestamps[i] = medDistributions[i].timestamp;
        }

        return (distributorAddresses, distributedTimestamps);
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

        // Log the transfer event
        transferHistory[_medicationID].push(
            TransferRecord({
                sender: msg.sender,
                receiver: _to,
                medicationID: _medicationID,
                timestamp: block.timestamp
            })
        );

        emit MedicationTransferred(_medicationID, msg.sender, _to, block.timestamp);
    }
  // Function to retrieve a raw material batch by its ID
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

    // Function to retrieve a medication batch by its ID
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
