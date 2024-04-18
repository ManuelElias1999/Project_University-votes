// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Candidatos.sol";

contract Votantes is ERC20, Candidatos {

    // Array para almacenar los votantes que ya recibieron tokens
    address [] private tokenRecipients;

    // Array para almacenar las direcciones que ya votaron
    mapping(address => bool) private hasVoted;

    constructor() ERC20("MyToken", "MTK") {
        _mint(address(this), 1000);
    }

    // Generación de nuevos Tokens ERC-20
    function mint(uint256 _cantidad) public onlyOwner {
        _mint(address(this), _cantidad);
    }

    // Transferencia de tokens con verificación de duplicados
    function transferToken(address _to) public onlyOwner returns (bool) {
        // Verificar si el destinatario ya recibió tokens
        for (uint256 i = 0; i < tokenRecipients.length; i++) {
            require(tokenRecipients[i] != _to, "Esta direccion ya recibio su token y no se puede dar mas");
        }

        // Transferir el token
        _transfer(address(this), _to, 1);
        
        // Añadir el destinatario al array
        tokenRecipients.push( _to);

        return true;
    }

    // Función para votar por un candidato
    function vote(uint256 _candidatoIndex) public {
        require(balanceOf(msg.sender) == 1, "No tienes suficientes tokens para votar");
        require(!hasVoted[msg.sender], "Ya has votado");
        require(_candidatoIndex < candidatos.length, "Candidato no encontrado");

        // Quemar el token
        _burn(msg.sender, 1);

        // Incrementar el contador de votos del candidato correspondiente
        candidatos[_candidatoIndex].votos++;

        // Marcar al usuario como que ya votó
        hasVoted[msg.sender] = true;
    }

    // Función para obtener todas las direcciones que han recibido tokens
    function getTokenRecipients() public view returns (address[] memory) {
        address[] memory recipients = new address[](tokenRecipients.length);
        for (uint256 i = 0; i < tokenRecipients.length; i++) {
            recipients[i] = tokenRecipients[i];
        }
        return recipients;
    }

}