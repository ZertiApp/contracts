# Zerti

---

## Smart contracts for the Zerti app.

__How it works:__

* VoteFactory & EIP1167 Contracts - Use of the EIP-1167 "Minimal Proxy" standard for cheap cloning and usage of vote contract.
* Vote Contract - Ballot and pool reward system for entity validation.

![ProxyPattern](docs\ProxyPattern.png)

We will be calling acaemic institutes and/or enterprises wishing to emit certificates entities. When one of such postulates as one, it interacts with the VoteFactory contract, which uses an upgradeable EIP1167 implementation, creating a clone of the Vote contract. 

![VotePattern](docs\VotingPoolPattern.png)

For each Vote contract, users are able to create a "Voting Pool" and to determine if the entity in question should be considered as such. Each vote has its time limit,  minimum votes and voting cost required. It is important to consider that results are given by majority and that each clone of the Vote contract acts independentely.

Voting Pool: Stake-ish MATIC pool formed by the tokens sent by Users. It is distributed based on majoritarian vote, generating a reward system for people in order to incentivate entity verification.

![DistributePoolPattern](docs\DistributePoolPattern.png)

When a vote finishes, as mentioned before, the pool is distributed based on majoritarian vote. The system's sole objective is to incentivate entity verification for the community.


---
# The Zerti team:

### Blockchain Developers:
* Matias Arazi
* Lucas Grasso
### Web developers
* Ilan Tobal
* Naomi Couriel
* Nicolas Halperin
### Design and UX:
* Victoria Salgado
* Matilde Azubel


