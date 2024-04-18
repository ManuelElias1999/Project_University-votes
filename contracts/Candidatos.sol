// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Candidatos is Ownable {
    // Struct para representar la información de un candidato
    struct Candidato {
        string name;
        uint256 votos;
    }
    
    // Array para almacenar la información de los candidatos
    Candidato[] public candidatos;

    // Evento emitido al agregar un nuevo candidato
    event CandidatoAgregado(string nombre);

    // Array para almacenar las direcciones que ya votaron
    mapping(address => bool) private hasVoted;

    constructor() Ownable(msg.sender) {}

    // Función para añadir un nuevo candidato
    function agregarCandidato(string memory _nombre) public onlyOwner {
        candidatos.push(Candidato(_nombre, 0));
        emit CandidatoAgregado(_nombre);
    }

    // Función para obtener la información de todos los candidatos
    function getAllCandidatos() public view returns (Candidato[] memory) {
        return candidatos;
    }
}