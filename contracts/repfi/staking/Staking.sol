//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// imports
import { CustomOwnable } from "./imports/CustomOwnable.sol";
import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Address } from "./libs/Address.sol";
import { IVestingClaimingContract } from "./interfaces/IVestingClaimingContract.sol";

/**
 * @title Staking
 * @notice This contract manages staking, unstaking, and reward claiming functionalities.
 * @dev It uses Ownable, Pausable, and ReentrancyGuard modifiers and leverages SafeERC20 and Address libraries. 
 * The contract supports multiple staking schedules, each with its own parameters like duration, rate, penalty, 
 * and allocation. Users can stake tokens, earn rewards, and claim or unstake their tokens. 
 * The contract ensures secure token transfers and validates contract interactions. 
 * It also allows the owner to update configurations, manage schedules, and rescue tokens.
 */

contract Staking is CustomOwnable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;
    using Address for address;

    IERC20 private _baseAsset;
    IVestingClaimingContract private _vestingClaimImplementation;

    uint256 public constant ZERO = 0;
    uint256 public constant ONE = 1;
    uint256 public constant THREE = 3;
    uint256 public constant HUNDRED = 100;
    uint256 public constant THOUSAND = 1000;
    uint256 public maxThresholdRate = 400;
    uint256 public minThresholdDuration = 60 * 60;
    uint256 public minStakableAmount = 0;
    uint256 private _scheduleCounter;
    uint256 private _totalStakersCount;
    uint256 private _totalStakedToken;

    enum StakeStatus { PENDING, STARTED, COMPLETED }

    struct StakeDistribution {
        uint256 totalStaked;
        uint256 totalClaimed;
        uint256 totalPenalization;
        uint256 totalRewardsDistributed;
        uint256 totalStakers;
    }

    struct StakingSchedule {
        uint256 duration;
        uint256 rate;
        uint256 penalty;
        uint256 allocation;
        StakeDistribution balance;
        StakeStatus status;
    }

    struct Agreements {
        uint256 amount;
        uint256 stakingScheduleId;
        uint256 expectedReward;
        uint256 totalClaimed;
        uint256 lastClaim;
        uint256 penalization;
        uint256 refundAmount;
        bool unstaked;
        bool claimed;
    }

    mapping(uint256 => StakingSchedule) public stakingSchedules;
    mapping(address => mapping(uint256 => EnumerableSet.UintSet)) private _userScheduleAgreementIds;
    mapping(address => mapping(uint256 => mapping(uint256 => Agreements))) public userAgreements;

    // Events
    event VestingClaimContractUpdated(address indexed _oldVestingClaim, address indexed _newVestingClaim);
    event ThresholdForDurationUpdated(uint256 indexed _threshold);
    event ThresholdForRatesUpdated(uint256 indexed _threshold);
    event MinimumStakeAmountUpdated(uint256 indexed _minAmountOfTokens);
    event VestingTokensClaimed(uint256 indexed _oldAmount, uint256 indexed _newAmount);
    event StakingScheduleCreated(uint256 indexed _scheduleId);
    event StakingScheduleStarted(uint256 indexed _scheduleId);
    event Staked(
        address indexed _user, 
        uint256 indexed _amount, 
        uint256 indexed _expectedReward);
    event Unstaked(
        address indexed _user,
        uint256 indexed _refundAmount,
        uint256 indexed _penaltyAmount, 
        uint256 _agreementId);
    event ClaimRewards(
        address indexed _user,
        uint256 indexed _agreementId, 
        uint256 indexed reward,
        uint256 _stakeScheduleId
    );
    event Withdrawal(address indexed _owner, address indexed _destination, uint256 indexed _amount);

    // Errors
    error InvalidAddressInteraction();
    error InvalidContractInteraction();
    error InsufficientTokenBalance(uint256 requested, uint256 available);
    error StakeDurationNotExceeded();
    error InvalidScheduleID();
    error AgreementNotExist();
    error ScheduleDoesNotExist();
    error ScheduleNotStartable();
    error ScheduleNotStakable();
    error ScheduleAlreadyStarted();
    error ScheduleCanNotBeCompleted();
    error InvalidAgreement();
    error InvalidMinimumStakeAmount();
    error TokenAmountIsZero();
    error ExceedsAllocation();
    error AlreadyUnstaked();
    error AlreadyClaimed(uint256 _stakeScheduleId, uint256 _agreementId);
    error InvalidDurationSettings();
    error InvalidRateSettings();
    error InvalidPenaltySettings();
    error NoVestingTokensClaimed();
    error NotTheOwner();
    error DoesNotAcceptingEthers();
    error NotPermitted();

    modifier existingStakingSchedule(uint256 _stakeScheduleId) {
        if (_stakeScheduleId == ZERO || _stakeScheduleId > _scheduleCounter) revert InvalidScheduleID();
        _;
    }
    
    modifier validContract(address _address) {
        if(!_address.isContract()) {
            revert InvalidContractInteraction();
        }
        _;
    }

    modifier validAddress(address _address){
        if(_address == address(0)){
            revert InvalidAddressInteraction();
        }
        _;
    }

    /* setup------------------------------------------------------------------------------------------- */

    /**
     * @dev Initializes the contract with the given token address.
     * @param _token The address of the ERC20 token.
     */
    constructor(address _token, address initialOwner) CustomOwnable(initialOwner){
        if (!_token.isContract()) revert InvalidContractInteraction();
        _baseAsset = IERC20(_token);
    }

    receive() external payable {
        revert DoesNotAcceptingEthers();
    }

    fallback() external payable {
        revert NotPermitted();
    }

    /* mechanics---------------------------------------------------------------------------------------- */

    /**
     * @notice Allows a user to stake a specified amount in a given staking schedule.
     * @param _amount The amount to stake.
     * @param _stakeScheduleId The ID of the staking schedule.
     */
    function stake(uint256 _amount, uint256 _stakeScheduleId) 
    external 
    nonReentrant() 
    whenNotPaused()
    existingStakingSchedule(_stakeScheduleId) {
        StakingSchedule storage _schedule = stakingSchedules[_stakeScheduleId]; 
        if (_schedule.duration == ZERO) revert ScheduleDoesNotExist();
        if (_schedule.status != StakeStatus.STARTED) revert ScheduleNotStakable();
    
        if(_amount == ZERO) revert TokenAmountIsZero();
        if(_amount < minStakableAmount) revert InvalidMinimumStakeAmount();
        
        uint256 rewardEstimation = _amount * _schedule.rate / THOUSAND;
        if(_schedule.allocation < _schedule.balance.totalStaked + _amount + rewardEstimation) {
            revert ExceedsAllocation();
        }
    
        uint256 _agreementId = _userScheduleAgreementIds[_msgSender()][_stakeScheduleId].length() + ONE;
    
        Agreements memory newAgreement = Agreements({
            amount: _amount,
            stakingScheduleId: _stakeScheduleId,
            expectedReward:rewardEstimation + _amount,
            totalClaimed: ZERO,
            lastClaim: block.timestamp,
            penalization: ZERO,
            refundAmount:ZERO,
            unstaked: false,
            claimed:false
        });
    
        userAgreements[_msgSender()][_stakeScheduleId][_agreementId] = newAgreement;
        _userScheduleAgreementIds[_msgSender()][_stakeScheduleId].add(_agreementId);
    
        _baseAsset.safeTransferFrom(_msgSender(), address(this), _amount);
    
        _schedule.balance.totalStaked   += _amount;
        _schedule.balance.totalStakers  +=  ONE;
        
        _totalStakedToken   += _amount;
        _totalStakersCount  += ONE;

        emit Staked(_msgSender(), _amount, rewardEstimation);
    }

    /**
     * @notice Allows a user to unstake their tokens from a given staking schedule.
     * @param _stakeScheduleId The ID of the staking schedule.
     * @param _agreementId The ID of the staking agreement.
     */
     function unstake(uint256 _stakeScheduleId, uint256 _agreementId) 
     external 
     nonReentrant() 
     whenNotPaused()
     existingStakingSchedule(_stakeScheduleId) 
    {
        StakingSchedule storage _schedule = stakingSchedules[_stakeScheduleId];
        if (_schedule.duration == ZERO) revert ScheduleDoesNotExist();
    
        Agreements storage agreement = userAgreements[_msgSender()][_stakeScheduleId][_agreementId];
        
        _agreementClaimValidator(agreement, _stakeScheduleId, _agreementId);
    
        uint256 refundAmount = agreement.amount;
        bool isEarlyUnstake = block.timestamp < agreement.lastClaim + _schedule.duration;
        
        uint256 penaltyAmount = ZERO;
    
        if (isEarlyUnstake && _schedule.penalty > ZERO) {
            penaltyAmount = agreement.amount * _schedule.penalty / THOUSAND;
            refundAmount -= penaltyAmount;
        }
    
        agreement.unstaked = true;
        agreement.claimed = true;
        agreement.expectedReward = ZERO;
        agreement.refundAmount = refundAmount;
        agreement.penalization = penaltyAmount;
    
        _schedule.balance.totalStaked -= _schedule.balance.totalStaked == ZERO ? ZERO : agreement.amount;
        _schedule.balance.totalPenalization += penaltyAmount;
        _schedule.balance.totalStakers -= _schedule.balance.totalStakers == ZERO ? ZERO : ONE;
    
        _userScheduleAgreementIds[_msgSender()][_stakeScheduleId].remove(_agreementId);
        
        _totalStakedToken -= _totalStakedToken == ZERO ? ZERO : agreement.amount;
        _totalStakersCount -= _totalStakersCount == ZERO ? ZERO : ONE;
    
        emit Unstaked(_msgSender(), refundAmount, penaltyAmount, _agreementId);
    
        uint256 _balance = _baseAsset.balanceOf(address(this));
        if (_balance < refundAmount) revert InsufficientTokenBalance(refundAmount, _balance);
    
        _baseAsset.safeTransfer(_msgSender(), refundAmount);
    }
    
    /**
     * @notice Allows a user to claim their rewards from a given staking schedule.
     * @param _stakeScheduleId The ID of the staking schedule.
     * @param _agreementId The ID of the staking agreement.
     */
    function claim(uint256 _stakeScheduleId, uint256 _agreementId) 
    external nonReentrant()
    whenNotPaused()
    existingStakingSchedule(_stakeScheduleId) {
        StakingSchedule storage _schedule = stakingSchedules[_stakeScheduleId];
        if (_schedule.duration == ZERO) revert ScheduleDoesNotExist();
    
        Agreements storage agreement = userAgreements[_msgSender()][_stakeScheduleId][_agreementId];

        _agreementClaimValidator(agreement,_stakeScheduleId,_agreementId);

        bool claimable = block.timestamp >= agreement.lastClaim + _schedule.duration;

        if(!claimable) revert StakeDurationNotExceeded();

        if(agreement.expectedReward == agreement.totalClaimed || agreement.claimed) {
            revert AlreadyClaimed(_stakeScheduleId, _agreementId);
        }

        uint256 reward = agreement.expectedReward;

        agreement.claimed = true;
        agreement.totalClaimed = reward;
        agreement.lastClaim = block.timestamp;

        _schedule.balance.totalClaimed += reward;
        _schedule.balance.totalRewardsDistributed += reward;

        uint256 _balance = _baseAsset.balanceOf(address(this));
        if (_balance < reward) revert InsufficientTokenBalance(reward, _balance);
 
        emit ClaimRewards(_msgSender(), _agreementId, reward, _stakeScheduleId);
 
        _baseAsset.safeTransfer(_msgSender(), reward);
 
    }

    /* getters ----------------------------------------------------------------------------------------- */

    /**
     * @notice Returns the address of the base asset.
     * @return The base asset address.
     */
    function getBaseAsset() external view returns(address){
        return address(_baseAsset);
    }

    /**
     * @notice Returns the address of the vesting claim contract.
     * @return The vesting claim contract address.
     */
    function getVestingClaimContract() external view returns(address){
        return address(_vestingClaimImplementation);
    }

    /**
     * @notice Returns the details of a user's staking agreement.
     * @param _user The address of the user.
     * @param _stakeScheduleId The ID of the staking schedule.
     * @param _agreementId The ID of the staking agreement.
     * @return The details of the staking agreement.
     */
    function getAgreementDetails(address _user, uint256 _stakeScheduleId, uint256 _agreementId) 
    external 
    view 
    existingStakingSchedule(_stakeScheduleId)
    returns (Agreements memory) {
        Agreements memory _agreement = userAgreements[_user][_stakeScheduleId][_agreementId];
        if(_agreement.amount == ZERO) revert AgreementNotExist();
        return _agreement;
    }

    /**
     * @notice Returns the IDs of a user's agreements for a specific staking schedule.
     * @param _user The address of the user.
     * @param _stakeScheduleId The ID of the staking schedule.
     * @return The IDs of the user's agreements.
     */
    function getUserAgreementIdsForSchedule(address _user, uint256 _stakeScheduleId) 
    external
    view
    existingStakingSchedule(_stakeScheduleId)
    returns (uint256[] memory) {
        EnumerableSet.UintSet storage agreementIds = _userScheduleAgreementIds[_user][_stakeScheduleId];
        uint256[] memory ids = new uint256[](agreementIds.length());
    
        for (uint256 i = ZERO; i < agreementIds.length(); i++) {
            ids[i] = agreementIds.at(i);
        }
    
        return ids;
    }

    /**
     * @notice Returns the IDs of a user's active agreements for a specific staking schedule.
     * @param _user The address of the user.
     * @param _stakeScheduleId The ID of the staking schedule.
     * @return The IDs of the user's active agreements.
     */
    function getUserActiveAgreementIdsForSchedule(address _user, uint256 _stakeScheduleId) 
    external
    view
    existingStakingSchedule(_stakeScheduleId)
    returns (uint256[] memory) {
        EnumerableSet.UintSet storage agreementIds = _userScheduleAgreementIds[_user][_stakeScheduleId];
        uint256[] memory tempIds = new uint256[](agreementIds.length());
        uint256 activeCount = 0;

        for (uint256 i = 0; i < agreementIds.length(); i++) {
            uint256 agreementId = agreementIds.at(i);
            Agreements memory agreement = userAgreements[_user][_stakeScheduleId][agreementId];
            if (!agreement.unstaked && !agreement.claimed) {
                tempIds[activeCount] = agreementId;
                activeCount++;
            }
        }
        
        uint256[] memory activeIds = new uint256[](activeCount);
        for (uint256 i = 0; i < activeCount; i++) {
            activeIds[i] = tempIds[i];
        }
        
        return activeIds;
    }

    /**
     * @notice Returns the total amount staked by a user for a specific staking schedule.
     * @param _user The address of the user.
     * @param _stakeScheduleId The ID of the staking schedule.
     * @return The total amount staked by the user.
     */
    function getUserTotalStakedForSchedule(address _user, uint256 _stakeScheduleId) 
    external
    view
    existingStakingSchedule(_stakeScheduleId)
    returns (uint256) {
        uint256 totalStaked = ZERO;
        EnumerableSet.UintSet storage agreementIds = _userScheduleAgreementIds[_user][_stakeScheduleId];
    
        for (uint256 i = ZERO; i < agreementIds.length(); i++) {
            uint256 agreementId = agreementIds.at(i);
            Agreements memory agreement = userAgreements[_user][_stakeScheduleId][agreementId];
            totalStaked += agreement.amount;
        }
    
        return totalStaked;
    }
    
    /**
     * @notice Returns the total amount of tokens staked in the contract.
     * @return The total amount of tokens staked.
     */
    function getTotalStakedTokens() external view returns (uint256) {
        return _totalStakedToken;
    }

    /**
     * @notice Returns the total number of stakers.
     * @return The total number of stakers.
     */
    function getTotalStakersCount() external view returns (uint256) {
        return _totalStakersCount;
    }

    /**
     * @notice Returns the details of a specific staking schedule.
     * @param _stakeScheduleId The ID of the staking schedule.
     * @return The details of the staking schedule.
     */
    function getStakingScheduleDetails(uint256 _stakeScheduleId) 
    external 
    view 
    existingStakingSchedule(_stakeScheduleId)
    returns (StakingSchedule memory) {
        StakingSchedule memory _stakingScedule = stakingSchedules[_stakeScheduleId];
        return _stakingScedule;
    }

    /**
     * @notice Returns the IDs of all active staking schedules.
     * @return The IDs of all active staking schedules.
     */
    function getActiveScheduleIds() external view returns (uint256[] memory) {
        uint256 activeCount = ZERO;
        uint256 totalSchedules = _scheduleCounter;
        
        for (uint256 i = ONE; i <= totalSchedules; i++) {
            if (stakingSchedules[i].status == StakeStatus.STARTED) {
                activeCount++;
            }
        }
        
        uint256[] memory activeIds = new uint256[](activeCount);
        uint256 currentIndex = ZERO;
    
        for (uint256 i = ONE; i <= totalSchedules; i++) {
            if (stakingSchedules[i].status == StakeStatus.STARTED) {
                activeIds[currentIndex] = i;
                currentIndex++;
            }
        }
    
        return activeIds;
    }

    /* internals---- ----------------------------------------------------------------------------------- */

    /**
     * @dev Validates a staking agreement.
     * @param _agreement The staking agreement to validate.
     * @param _stakeScheduleId The ID of the staking schedule.
     * @param _agreementId The ID of the staking agreement.
     */
    function _agreementClaimValidator(
        Agreements memory _agreement, 
        uint256 _stakeScheduleId, 
        uint256 _agreementId
    ) internal pure {
        if (_agreement.amount == ZERO) revert InvalidAgreement();
        if (_agreement.unstaked) revert AlreadyUnstaked();
        if (_agreement.claimed) revert AlreadyClaimed(_stakeScheduleId, _agreementId);
    }

    /**
     * @dev Sanitizes the parameters for a staking schedule.
     * @param _duration The duration of the staking schedule.
     * @param _rate The rate of the staking schedule.
     * @param _penalty The penalty of the staking schedule.
     */
    function _sanitizeParameters(
        uint256 _duration,
        uint256 _rate,
        uint256 _penalty
    ) internal view{
        if(_duration == ZERO || _duration < minThresholdDuration) revert InvalidDurationSettings();
        if(_rate == ZERO || _rate > maxThresholdRate) revert InvalidRateSettings();
        if(_penalty > maxThresholdRate) revert InvalidPenaltySettings();
    }

    /* administrator ----------------------------------------------------------------------------------- */

    /**
     * @notice Creates a new staking schedule.
     * @param _duration The duration of the staking schedule.
     * @param _rate The rate of the staking schedule.
     * @param _penalty The penalty of the staking schedule.
     * @param _allocation The allocation of the staking schedule.
     */
    function createStakingSchedule(
        uint256 _duration,
        uint256 _rate,
        uint256 _penalty,
        uint256 _allocation
    ) external onlyOwner() whenNotPaused() {

        _sanitizeParameters(
            _duration,
            _rate,
            _penalty
        );

        StakeDistribution memory _distribution = StakeDistribution({
            totalStaked:ZERO,
            totalClaimed:ZERO,
            totalPenalization:ZERO,
            totalRewardsDistributed:ZERO,
            totalStakers:ZERO
        });

        StakingSchedule memory _schedule = StakingSchedule({
            duration: _duration,
            rate: _rate,
            penalty: _penalty,
            allocation: _allocation,
            balance: _distribution,
            status: StakeStatus.PENDING
        });

        _scheduleCounter += ONE;
        stakingSchedules[_scheduleCounter] = _schedule;

        emit StakingScheduleCreated(_scheduleCounter);
    }

    /**
     * @notice Starts a staking schedule.
     * @param _stakeScheduleId The ID of the staking schedule.
     */
    function startStakingSchedule(uint256 _stakeScheduleId) 
    external 
    onlyOwner() 
    whenNotPaused() {
        if (_stakeScheduleId == ZERO || _stakeScheduleId > _scheduleCounter) revert InvalidScheduleID();
        StakingSchedule storage _schedule = stakingSchedules[_stakeScheduleId];
        if (_schedule.duration == ZERO) revert ScheduleDoesNotExist();
        if (_schedule.status == StakeStatus.STARTED) revert ScheduleAlreadyStarted();
        if (_schedule.status != StakeStatus.PENDING) revert ScheduleNotStartable();

        _schedule.status = StakeStatus.STARTED;
        emit StakingScheduleStarted(_stakeScheduleId);
    }

    /**
     * @notice Completes a staking schedule.
     * @param _stakeScheduleId The ID of the staking schedule.
     */
    function completeStakingSchedule(uint256 _stakeScheduleId) 
    external 
    onlyOwner() 
    whenNotPaused() {
        if (_stakeScheduleId == ZERO || _stakeScheduleId > _scheduleCounter) revert InvalidScheduleID();
        StakingSchedule storage _schedule = stakingSchedules[_stakeScheduleId];
        if (_schedule.duration == ZERO) revert ScheduleDoesNotExist();
        if (_schedule.status != StakeStatus.STARTED) revert ScheduleCanNotBeCompleted();
    
        _schedule.status = StakeStatus.COMPLETED;
        emit StakingScheduleStarted(_stakeScheduleId);
    }

    /**
     * @notice Updates the minimum threshold for the duration of a staking schedule.
     * @param _threshold The new minimum threshold.
     */
    function updateMinimumThresholdForDuration(uint256 _threshold) 
    external 
    onlyOwner()
    whenNotPaused()
    {
        if(_threshold == ZERO) revert InvalidDurationSettings();
        minThresholdDuration = _threshold;
        emit ThresholdForDurationUpdated(_threshold);
    }
   
    /**
     * @notice Updates the maximum threshold for the rates of a staking schedule.
     * @param _threshold The new maximum threshold.
     */
    function updateMaximumThresholdForRates(uint256 _threshold) 
    external 
    onlyOwner()
    whenNotPaused()
    {
        if(_threshold == ZERO || _threshold > THOUSAND) revert InvalidRateSettings();
        maxThresholdRate = _threshold;
        emit ThresholdForRatesUpdated(_threshold);
    }
   
    /**
     * @notice Updates the minimum stake amount.
     * @param _minAmountOfTokens The new minimum stake amount.
     */
    function updateMinimumStakeAmount(uint256 _minAmountOfTokens) 
    external 
    onlyOwner()
    whenNotPaused()
    {
        minStakableAmount = _minAmountOfTokens;
        emit MinimumStakeAmountUpdated(_minAmountOfTokens);
    }

    /**
     * @notice Updates the vesting claim contract.
     * @param _newVestingClaimImplementation The address of the new vesting claim contract.
     */
    function updateVestingClaimContract(address _newVestingClaimImplementation) 
    external 
    validContract(_newVestingClaimImplementation)
    onlyOwner() 
    whenNotPaused()
    {
        address oldVestingClaimImplementation = address(_vestingClaimImplementation);
        _vestingClaimImplementation = IVestingClaimingContract(_newVestingClaimImplementation);
        emit VestingClaimContractUpdated(oldVestingClaimImplementation, _newVestingClaimImplementation);
    }

    /**
     * @notice Claims vested tokens.
     * @param templateName The name of the vesting template.
     */
    function claimVestedTokens(string calldata templateName) 
    external 
    nonReentrant() 
    onlyOwner() 
    whenNotPaused()
    {
        if(address(_vestingClaimImplementation)==address(0)) revert InvalidAddressInteraction();
        uint256 oldBalance = IERC20(_baseAsset).balanceOf(address(this));
        _vestingClaimImplementation.claimTokensForBeneficiary(templateName);
        uint256 currentBalance = IERC20(_baseAsset).balanceOf(address(this));

        if(oldBalance == currentBalance) revert NoVestingTokensClaimed();

        emit VestingTokensClaimed(oldBalance, currentBalance);
    }

    /**
     * @notice Rescues tokens from the contract.
     * @param _tokenAddress The address of the token to rescue.
     * @param _to The address to send the rescued tokens to.
     * @param _amount The amount of tokens to rescue.
     */
    function rescueTokens(address _tokenAddress, address _to, uint256 _amount) 
    external 
    validContract(_tokenAddress)
    validAddress(_to) 
    onlyOwner() 
    {
        if(_amount == 0) revert TokenAmountIsZero();
        SafeERC20.safeTransfer(IERC20(_tokenAddress), _to, _amount);
        emit Withdrawal(_tokenAddress, _to, _amount);
    }

    /**
     * @notice Pauses the contract.
     */
    function pause() external onlyOwner() {
        _pause();
    }

    /**
     * @notice Unpauses the contract.
     */
    function unpause() external onlyOwner(){
        _unpause();
    }

}