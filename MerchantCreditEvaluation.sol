pragma solidity >=0.4.22 <0.6.0;
contract MerchantCreditEvaluation{
    
    struct commodity{
        string commodityname;
        string url;
        uint256 Evaluationcount;
        uint256 requestfound;
        mapping(address=>bytes32) evaluated;
    }
    struct player{
        address addr;
        uint256 socre;
        bool enoughfound;
        bool attitide;
        string sign;
        string  interval;
        
        
        
    }
    struct userPurchaseRecord{
        address submitter;
        string commodityname;
        string url;
        uint256 inputhash;
        uint256 outputhash;
       
    }
    
    commodity[] public commodities;
    player[] public user_purchases;
    player[] public user_unpurchases;
    player[] public TrustedThirdParty;
    userPurchaseRecord[] puRecords;
    mapping(address=>uint256) public users;
    uint256 public balance;
    
    
    
    event LogEvaluation(address evaluator,uint256 comno,string  url,uint256 socre,uint256 blocknum );
    
    modifier enough_found_balance(uint256 comno){
        require(balance>=commodities[comno].requestfound);
        _;
    }
    modifier signature_owner(uint256 user_puno){
        require (user_unpurchases[user_puno].addr!= msg.sender);
        _;
    }
    modifier user_purchased(address addr){
        require(users[addr]!=0);
        _;
    }
    modifier user_unpurchase(address addr){
        require(users[addr]==0);
        _;
    }
    modifier nozero_payment_made(){
        require(msg.value>0);
        _;
    }
    modifier user_purchases_Evaluate(uint256 comno){
        require(commodities[comno].Evaluationcount!=0);
        _;
    }
    modifier user_purchases_socre(uint256 user_puno){
        require(user_purchases[user_puno].socre>=4);
        _;
    }
    
    constructor (string memory name,string memory url,uint256 count,
        uint256 requestfound, address addr,uint256 socre,bool enoughfound,bool attitide,string memory sign,
        string memory interval) public{
        commodities.push(commodity(name,url,0,0));
        user_purchases.push(player(msg.sender,0,true,true,sign,interval));
        user_unpurchases.push(player(msg.sender,0,false,false,sign,interval));
        users[msg.sender] = user_purchases.length;
        balance = 0;
    }
    
    function() external payable{}
    
    function RequestSign(uint256 comno,uint256 user_puno,
    uint256 signno) public 
    enough_found_balance(comno) user_purchased(msg.sender) 
    user_purchases_socre(user_puno){
        
       TrustedThirdParty[signno].addr = msg.sender;
       //balance += msg.value;
    }
    
    function Evaluation(uint256 user_puno,uint256 comno,
   string memory url) public
    user_purchased(msg.sender) signature_owner(user_puno) {
        if(user_purchases[comno].attitide==true){
            commodities[comno].Evaluationcount=commodities[comno].Evaluationcount ++;
        }
        if(user_purchases[comno].attitide==false){
            commodities[comno].Evaluationcount=commodities[comno].Evaluationcount --;
        }else
        commodities[comno].Evaluationcount = commodities[comno].Evaluationcount;
       emit LogEvaluation(msg.sender,comno,url,user_purchases[user_puno].socre,block.number);
    }
    
    
    function Reward(uint256 comno,uint256 user_puno) public 
    user_purchases_Evaluate(comno){
        user_purchases[user_puno].socre ++;
    }
    
    
    function RequestPraiseRate(uint256 user_unpuno,uint256 comno,string memory url) public
    user_unpurchase(msg.sender){
        user_unpurchases[user_unpuno].addr = msg.sender;
    }
    
    function getUserPurchaseRecord(uint256 id) public
    view returns(address,string memory,string memory,uint256,uint256){
        return(puRecords[id].submitter,
               puRecords[id].commodityname,
               puRecords[id].url,
               puRecords[id].inputhash,
               puRecords[id].outputhash);
    }
    
    function getCommodityInfo(uint256 comno) public
    view returns(string memory,string memory,uint256,uint256){
        return(commodities[comno].commodityname,
               commodities[comno].url,
               commodities[comno].Evaluationcount,
               commodities[comno].requestfound);
    }
    
    function getUserPurchasedInfo(uint256 user_puno) public
    view returns(address,uint256){
        return(user_purchases[user_puno].addr,
               user_purchases[user_puno].socre);
    }
    
    
    function setInterval(uint256 user_puno,string memory time)  public{
        user_purchases[user_puno].interval = time;
    }
    
    function getInterval(uint256 addr) public returns(string memory){
        user_purchases[addr].addr = msg.sender;
        return user_purchases[addr].interval;
    }
}
