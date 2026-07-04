// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title ParallelGovCore
 * @dev Distributes structural voting targets across split slots to maximize OCC pipeline concurrency limits.
 */
contract ParallelGovCore {

    struct ProposalTally {
        uint256 forVotes;
        uint256 againstVotes;
        bool exists;
    }

    // Maps proposal IDs straight to isolated storage allocations to ensure non-blocking routes
    mapping(uint256 => ProposalTally) public proposalRegistry;
    mapping(uint256 => mapping(address => bool)) public voterReceipts;

    event VoteCast(address indexed voter, uint256 indexed proposalId, bool support, uint256 weight);

    /**
     * @notice Casts votes concurrently on structurally separated proposal slots.
     */
    function castBallotConcurrently(uint256 proposalId, bool support, uint256 weight) external {
        require(!voterReceipts[proposalId][msg.sender], "GovError: Ballot signature already registered");
        
        ProposalTally storage tally = proposalRegistry[proposalId];
        voterReceipts[proposalId][msg.sender] = true;

        if (support) {
            tally.forVotes += weight;
        } else {
            tally.againstVotes += weight;
        }

        emit VoteCast(msg.sender, proposalId, support, weight);
    }
}
