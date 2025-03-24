pragma solidity >=0.8.0;

// Royalty models: PublicGood, IntegrationFee, UsageTier.
enum RoyaltiesModel {
    PublicGood,
    IntegrationFee,
    UsageTier
}

// Same as InteractionTemplate minus "author" and uniqueHash
struct InteractionTemplateParams {
    string name;
    string description;
    string logo;
    string actionUrl;
    address targetContract;
    string contractURI;
    uint256 networkId;
    uint256 price;
    RoyaltiesModel royaltiesModel;
}

struct InteractionTemplate {
    string name;
    string description;
    string logo;
    string actionUrl;
    address targetContract;
    string contractURI;
    uint256 networkId;
    uint256 price;
    RoyaltiesModel royaltiesModel;
    address author;
    bytes32 uniqueHash; // Unique hash for deduplication.
}
