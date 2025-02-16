  //SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract insuranceIssue{
    
    address public insurer;

    enum PolicyStatus { Active, Expired, Claimed }

    constructor() {
        insurer = msg.sender;
    }
    modifier onlyInsurer(){
        require(msg.sender == insurer);
        _;
    }

        struct Insurance{
        uint256 id;
        address user;
        uint256 premium;
        uint256 coverage;
        uint256 duration;  
        PolicyStatus status;      
    }
    mapping(uint256 => Insurance) public insurances;
    mapping(address => uint256[]) public userInsurances;
    uint256 public insuranceCounter;

    modifier onlyUser(uint256 id){
        require(insurances[id].user == msg.sender, "Only policyholder can perform this action");
        _;
    }

    event PolicyIssued(uint256 id, address user,uint256 premium, uint256 coverage,uint256 duration);
    event PremiumPaid(uint256 id,address user);
    event ClaimSubmitted(uint256 id,address user);
    event ClaimApproved(uint256 id,address user,uint256 coverage);

    function issuePolicy(address _user, uint256 _premium, uint256 _coverage, uint256 _duration) public onlyInsurer {
        insuranceCounter++;
        insurances[insuranceCounter] = Insurance(insuranceCounter, _user, _premium, _coverage, _duration, PolicyStatus.Active);
        userInsurances[_user].push(insuranceCounter);
        emit PolicyIssued(insuranceCounter, _user, _premium, _coverage, _duration);
    }

    function payPremium(uint256 id,uint256 _prein) public onlyUser(id) {
        require(_prein == insurances[id].premium, "Premium Amount not correct");
        emit PremiumPaid(id, msg.sender);
    }
       function submitClaim(uint256 id) public onlyUser(id) {
        require(insurances[id].status == PolicyStatus.Active, "Policy inactive");
        require(block.timestamp <= insurances[id].duration, "Policy expired");
        insurances[id].status = PolicyStatus.Claimed;
        emit ClaimSubmitted(id, msg.sender);
    }

    function approveClaim(uint256 id) public  payable onlyInsurer {
        require(insurances[id].status == PolicyStatus.Claimed, "Processing Done or Claim not Submitted");
        insurances[id].status = PolicyStatus.Expired;
        payable(insurances[id].user).transfer(insurances[id].coverage);
        emit ClaimApproved(id, insurances[id].user, insurances[id].coverage);
    }
}
