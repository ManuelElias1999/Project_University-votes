// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./CandidatosFactory.sol";

contract VotantesFactory {
    address[] public votantesContracts;
    mapping(address => bool) public isVotantesContract;

    event VotantesContractCreated(address indexed votantesContract, address indexed creator);

    function createVotantesContract() public {
        Votantes newVotantes = new Votantes();
        votantesContracts.push(address(newVotantes));
        isVotantesContract[address(newVotantes)] = true;
        emit VotantesContractCreated(address(newVotantes), msg.sender);
    }

    function getVotantesContracts() public view returns (address[] memory) {
        return votantesContracts;
    }
}

contract Votantes is ERC20, Candidatos {
    address public factory;
    address[] public tokenRecipients;
    mapping(address => bool) public hasVoted;

    constructor() ERC20("MyToken", "MTK") {
        factory = msg.sender;
        _mint(address(this), 1000);
    }

    function mint(uint256 _cantidad) public {
        require(msg.sender == factory, "Solo el Factory puede llamar a esta funcion");
        _mint(address(this), _cantidad);
    }

    function transferToken(address _to) public {
        require(msg.sender == factory, "Solo el Factory puede llamar a esta funcion");
        require(!hasVoted[_to], "Esta direccion ya recibio su token y no se puede dar mas");
        _transfer(address(this), _to, 1);
        tokenRecipients.push(_to);
        hasVoted[_to] = true;
    }

    function vote(uint256 _candidatoIndex) public {
        require(balanceOf(msg.sender) == 1, "No tienes suficientes tokens para votar");
        require(!hasVoted[msg.sender], "Ya has votado");
        require(_candidatoIndex < candidatos.length, "Candidato no encontrado");

        _burn(msg.sender, 1);
        candidatos[_candidatoIndex].votos++;
        hasVoted[msg.sender] = true;
    }

    function getTokenRecipients() public view returns (address[] memory) {
        return tokenRecipients;
    }

    // Función para añadir un nuevo candidato
    function agregarCandidato(string memory _nombre) public override {
        require(msg.sender == factory, "Solo el Factory puede llamar a esta funcion");
        candidatos.push(Candidato(_nombre, 0));
        emit CandidatoAgregado(_nombre);
    }

    // Función para obtener la información de todos los candidatos
    function getAllCandidatos() public view override returns (Candidato[] memory) {
        return candidatos;
    }
}
