// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract HotelManagement{

    address payable public owner ;
    address public receptionist;

    address[] public soloCustomers; //To keep the records for the solo customer
    address[] public duoCustomers; //To keep the records for the duo customer 
    address[] public familyCustomers; //To keep the records for the family customer

    mapping (address => uint ) public customerRoomType;
    mapping (uint =>mapping (address => uint )) public CustomerRecords; 
    mapping (uint => uint ) public roomRent;
    
    
    struct Rooms{
        string roomType;
        uint roomTypeCode;
        uint avaliableRoom;
        uint registrationFee;
        uint rentPerHours;
    }

    Rooms public soloRooms = Rooms("Solo", 1, 15, 500 wei, 100 wei);
    Rooms public duoRooms = Rooms("Duo", 2, 10, 500 wei, 200 wei);
    Rooms public familyRooms = Rooms("Family", 3, 5, 500 wei, 300 wei);

    constructor (address _setReceptionist) {
        owner = payable(msg.sender);
        receptionist = _setReceptionist;
        roomRent[1] = 100;
        roomRent[2] = 200;
        roomRent[3] = 300;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, " Only owner can have the acess to this function");
        _;
    }

    modifier onlyCustomer(){
        require(customerRoomType[msg.sender] == 1 || customerRoomType[msg.sender] == 2 || customerRoomType[msg.sender] == 3  , " Only a customer can access this function");
        _;
    }

    modifier onlyReceptionist(){
        require(msg.sender == receptionist); 
        _;
    }

    //Customer can see available rooms of every type
    function avaliableRooms() public view returns (uint SoloRooms, uint DuoRooms , uint FamilyRooms){
        return (soloRooms.avaliableRoom,duoRooms.avaliableRoom,  familyRooms.avaliableRoom);
    }

    //Total rent customer needs to pay according to their room type and time the stayed 
    function viewRent() public onlyCustomer view returns(uint _RENT){       
        uint totalHoursCheckedin = block.timestamp - CustomerRecords[customerRoomType[msg.sender]][msg.sender]; // block.timestamp - [typeOfRoom][address] => the time they checkedIn ;
        uint payableHours = (totalHoursCheckedin / 3600)+1;
        uint totalRent = roomRent[customerRoomType[msg.sender]] * payableHours;
        return totalRent;
    }

    //Enter 1 for Solo type room
    //Enter 2 for Duo type room
    //Enter 3 for Family type room
    function checkIn(uint _roomTypeCode) public payable {
        if(_roomTypeCode == 1){
            require (soloRooms.avaliableRoom > 0, "No Rooms avaliable for this Type, Please Check Other Type of rooms");
            require (msg.value == soloRooms.registrationFee, "Please Enter a Valid Amout, Solo Room const 1 Ether");
            customerRoomType[msg.sender] = _roomTypeCode;
            CustomerRecords[_roomTypeCode][msg.sender] = block.timestamp; 
            soloCustomers.push(msg.sender);
            soloRooms.avaliableRoom --;
        }else if(_roomTypeCode == 2){
            require (duoRooms.avaliableRoom > 0, "No Rooms avaliable for this Type, Please Check Other Type of rooms");
            require (msg.value == duoRooms.registrationFee, "Please Enter a Valid Amout, Duo Room const 2 Ether");
            customerRoomType[msg.sender] = _roomTypeCode;
            CustomerRecords[_roomTypeCode][msg.sender] = block.timestamp; 
            duoCustomers.push(msg.sender);
            duoRooms.avaliableRoom --;  
        }else if(_roomTypeCode == 3){
            require (familyRooms.avaliableRoom > 0, "No Rooms avaliable for this Type, Please Check Other Type of rooms");
            require (msg.value == familyRooms.registrationFee, "Please Enter a Valid Amout, Family Room const 3 Ether");
            customerRoomType[msg.sender] = _roomTypeCode;
            CustomerRecords[_roomTypeCode][msg.sender] = block.timestamp; 
            familyCustomers.push(msg.sender);
            familyRooms.avaliableRoom --;
        }
    }

    //Customers will pay the rent and checkout
    function checkOut() public payable onlyCustomer 
    {
        if (customerRoomType[msg.sender] == 1) 
        {
        uint rent = viewRent();
        require(msg.value == rent , "Please check your rent and then pay the amount eligible"); 
        soloRooms.avaliableRoom ++;
        }
        else if (customerRoomType[msg.sender] == 2)
        {
            uint rent = viewRent();
            require(msg.value == rent , "Please check your rent and then pay the amount eligible"); 
            duoRooms.avaliableRoom ++;
        }
        else if (customerRoomType[msg.sender] == 3)
        {
            uint rent = viewRent();
            require(msg.value == rent , "Please check your rent and then pay the amount eligible"); 
            familyRooms.avaliableRoom ++;
        }

    }
    
    //For  receptionist to check the rent of the customers
     function viewRent(address _adddressOfCustomer) public  view onlyReceptionist returns(uint _rentOfTheCustomer)
    {
        //                                          this will evaluate to            1/2/3       
        uint totalHoursCheckedin = block.timestamp - CustomerRecords[customerRoomType[_adddressOfCustomer]][_adddressOfCustomer]; // block.timestamp - [typeOfRoom][address] => the time they checkedIn ;
        uint payableHours = totalHoursCheckedin / 3600 ;
        uint totalRent = roomRent[customerRoomType[_adddressOfCustomer]] * payableHours;
        return totalRent;
    
    }

    //Owner can see the total generated amount
    function viewRevenue() public view onlyOwner returns(uint _revenue)
    {
        return address(this).balance;

    }

    //Owner can withdraw the total generated amount
    function withdrawRevenue() public payable onlyOwner
    {
        uint totalRevenue = address(this).balance;
        owner.transfer(totalRevenue);
    }

    //If owner wants to change the receptionist 
    function changeReceptionist(address _newReceptionist) public onlyOwner
    {
        receptionist = _newReceptionist;
    } 
}