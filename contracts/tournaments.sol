// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Tournament is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tournamentIds;

    // enum TournamentsStatus {
    //     ACTIVE,
    //     ENDED
    // }
    
    struct Tournament {
        string metadata;
        uint256 endTimestamp;
        uint256 score;
        uint256 thresholdUsers;
        uint256 totalJoinedUsers;
    }

    mapping(uint256 => Tournament) private _tournaments;
    mapping(unit256 => mapping(address => bool)) private _interestedParticipants;
    mapping(unit256 => mapping(address => uint256)) private _tournamentsScores;

    //events

    event TournamentCreated(uint256,string,uint256,uint256,uint256);
    event TournamentJoined(uint256,address,uint256,uint256);
    event TournamentScores(uint256,address,uint256);

    // modifier 

    modifier isTournamentIdValid(uint256 tournamentId){
        require(tournamentId < _tournamentIds.current(),"Invalid TournamentId");
        _;
    }

    modifier isTournamentActive(uint256 tournamentId){
        require(_tournaments[tournamentId].endTimestamp >= block.timestamp,"Tournament Ended");
        require(_tournaments[tournamentId].thresholdUsers < _tournaments[tournamentId].totalJoinedUsers,"Tournament Ended");
        _;
    }

    modifier isTournamentEnded(uint256 tournamentId){
        require(_tournaments[tournamentId].endTimestamp < block.timestamp,"Tournament Active");
        _;
    }

    modifier doesUserJoinedTournament(uint256 tournamentId,address user){
        require(_interestedParticipants[tournamentId][user],"User has not joine the tournament");
    }

    //logic 

    function createTournament(string calldata metadata,uint256 endTimestamp,uint256 score,uint256 thresholdUsers) public onlyOwner {
        Tournament tournament = Tournament(metadata,endTimestamp,score,thresholdUsers,0);
        uint256 _tournamentId = _tournamentIds.current();
        
        _tournamentIds.increment();
        _tournaments[_tournamentId] = tournament;
        emit TournamentCreated(tournamentId,metadata,endTimestamp,score,thresholdUsers);
    }

    function joinTournament(address calldata interestedUser,uint256 tournamentId) public onlyOwner {
        
        _interestedParticipants[tournamentId].push(interestedUser);
        _tournaments[tournamentId].totalJoinedUsers += 1;

        emit TournamentJoined(tournamentId,interestedUser,block.timestamp,_tournaments[tournamentId].totalJoinedUsers);
    }

    function increaseScore(address calldata interestedUser,uint256 tournamentId) public onlyOwner isTournamentIdValid(tournamentId) isTournamentActive(tournamentId) doesUserJoinedTournament(tournamentId,interestedUser) {
        _tournamentsScores[tournamentId][interestedUser] += _tournaments[tournamentId].score;

        emit TournamentScores(tournamentId,interestedUser,block.timestamp);
    }

    function TournamentLeaderboard(uint256 tournamentId) public isTournamentEnded(tournamentId)  returns(mapping(address => uint256) memory) {
        return _tournamentsScores[tournamentId];
    }   

    function fetchActiveTournament() public returns(Tournament[] memory) {
        Tournament[] memory tournament;

        for(uint256 i = 0;i < _tournamentIds.current();i++){
            if(tournament[i].endTimestamp >= block.timestamp){
                tournament.push(tournament);
            }
        }
        return tournament;
    }   

}
