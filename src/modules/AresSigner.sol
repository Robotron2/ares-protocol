// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ECDSA} from"@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IAresRegistry}from"../interfaces/IAresRegistry.sol";

import {AresErrors} from "../libraries/utils/Errors.sol";
import {AresEvents} from "../libraries/utils/Events.sol";

contract AresSigner {

    using ECDSA for bytes32;

    IAresRegistry public registry;

    mapping(address => uint256) public nonces;

    bytes32 public DOMAIN_SEPARATOR;

    bytes32 public constant AUTH_TYPEHASH =
        keccak256("Authorize(address signer,bytes32 proposalHash,uint256 nonce)");

    constructor(address _registry) {
        registry = IAresRegistry(_registry);

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("ARES Protocol")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    function authorize(
        address signer,
        bytes32 proposalHash,
        bytes calldata signature
    ) external returns (bool) {

        if (!registry.isParticipant(signer)) revert AresErrors.InvalidSigner();

        uint256 nonce = nonces[signer];

        bytes32 structHash = keccak256(
            abi.encode(
                AUTH_TYPEHASH,
                signer,
                proposalHash,
                nonce
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );

        address recovered = ECDSA.recover(digest, signature);

        if (recovered != signer) revert AresErrors.InvalidSignature();

        nonces[signer]++;

        emit AresEvents.SignatureUsed(signer, proposalHash);

        return true;
    }
}