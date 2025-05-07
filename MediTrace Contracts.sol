// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Trace {
    // The contract owner's address
    address public owner;
    mapping(address => bool) public rawMaterialProviders;
    mapping(address => bool) public drugManufacturers;
    
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

    // Mappings to store raw material and medication info based on IDs
    mapping (uint256 => RawMaterial) public rawMaterialBatches;
    mapping (uint256 => Medication) public medicationBatches;
    
    // Counters to keep track of the total number of raw material and medication batches
    uint256 public rawBatchCount;
    uint256 public medicationCount;

    // Event triggered when a new raw material batch is created
    event RawMaterialBatchCreated(uint256 rawBatchID, string materialName, address producer, string origin,
        uint256 timestamp, string purity, string strength, string quality);

    // Event triggered when a new raw material batch is created
    event MedicationCreated(uint256 medicationID, string medicationName, address producer, string origin,
        uint256 timestamp, uint256[] rawBatchIDs, string strength, string quality);

    // Contract constructor, executed once during deployment
    constructor() {
        // Set the contract owner to the address that deploys the contract
        owner = msg.sender;
    }

    // Modifier to restrict access to only the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this");
        _;
    }

    // Modifier to restrict access to only raw material providers
    modifier onlyRawMaterials() {
        require(rawMaterialProviders[msg.sender], "Only raw material providers can execute this");
        _;
    }

    // Modifier to restrict access to only drug manufacturers
    modifier onlyDrugManufacturers() {
        require(drugManufacturers[msg.sender], "Only drug manufacturers can execute this");
        _;
    }

    // Functions to add trusted user addresses
    function addRawMatProvider(address _address) public onlyOwner {
        rawMaterialProviders[_address] = true;
    }

    function addDrugManufacturer(address _address) public onlyOwner {
        drugManufacturers[_address] = true;
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
    function distribute(uint256 _medicationID) public view {
        
    }
}

contract ProvideToConsumer {

}