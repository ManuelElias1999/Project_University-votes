// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Candidatos.sol";

contract Mesa_Votantes is ERC20, Candidatos {
    // Struct para representar la información de una mesa
    struct Mesa {
        address owner; // Propietario de la mesa
        mapping(address => bool) hasVoted; // Mapa de votantes
        uint256[] votosCandidatos; // Contador de votos por candidato
        bool isOpen; // Estado de apertura de la mesa
    }

    mapping(uint256 => Mesa) public mesas; // Mapa de mesas

    // Array para almacenar los votantes que ya recibieron tokens
    address[] private tokenRecipients;

    uint256 public numMesas; // Contador de mesas creadas

    event NuevaMesaAbierta(uint256 indexed mesaIndex, string nombreMesa);

    constructor() ERC20("MyToken", "MTK") {
        _mint(address(this), 1000);

        // Inicializar todas las mesas como cerradas
        for (uint256 i = 0; i < numMesas; i++) {
            mesas[i].isOpen = false;
        }
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
        tokenRecipients.push(_to);

        return true;
    }

    function vote(uint256 _candidatoIndex, uint256 _mesaIndex) public payable {
        require(balanceOf(msg.sender) >= 1, "No tienes suficientes tokens para votar");
        require(!mesas[_mesaIndex].hasVoted[msg.sender], "Ya has votado en esta mesa");
        require(_candidatoIndex < candidatos.length, "Candidato no encontrado");
        require(mesas[_mesaIndex].isOpen, "Esta mesa no esta abierta para votacion");

        // Quemar el token
        _burn(msg.sender, 1);

        // Incrementar el contador de votos del candidato correspondiente en la mesa
        mesas[_mesaIndex].votosCandidatos[_candidatoIndex]++;

        // Marcar al usuario como que ya votó en esta mesa
        mesas[_mesaIndex].hasVoted[msg.sender] = true;
    }


    // Función para abrir una nueva mesa con un nombre específico
    function agregarMesa(string memory _nombre, address _owner) public onlyOwner {
        numMesas++;
        Mesa storage nuevaMesa = mesas[numMesas-1];
        nuevaMesa.owner = _owner;
        nuevaMesa.isOpen = true;
        nuevaMesa.votosCandidatos = new uint256[](candidatos.length);
        emit NuevaMesaAbierta(numMesas, _nombre);
    }


    // Función para cerrar una mesa
    function cerrarMesa(uint256 _mesaIndex) public {
        require(msg.sender == mesas[_mesaIndex].owner, "No eres el propietario de esta mesa");
        require(mesas[_mesaIndex].isOpen, "Esta mesa ya esta cerrada");

        mesas[_mesaIndex].isOpen = false;
    }

    // Función para abrir una mesa
    function abrirMesa(uint256 _mesaIndex) public {
        require(msg.sender == mesas[_mesaIndex].owner, "No eres el propietario de esta mesa");
        require(!mesas[_mesaIndex].isOpen, "Esta mesa ya esta abierta");

        mesas[_mesaIndex].isOpen = true;
    }

    // Función para cerrar todas las mesas por el owner
    function cerrarTodasLasMesas() public onlyOwner {
        for (uint256 i = 0; i < numMesas; i++) {
            if (mesas[i].isOpen) {
                mesas[i].isOpen = false;
            }
        }
    }

    // Función para abrir todas las mesas por el owner
    function abrirTodasLasMesas() public onlyOwner {
        for (uint256 i = 0; i < numMesas; i++) {
            if (!mesas[i].isOpen) {
                mesas[i].isOpen = true;
            }
        }
    }

    // Función para obtener el recuento de votos de una mesa
    function obtenerRecuentoVotos(uint256 _mesaIndex) public view returns (uint256[] memory) {
        return mesas[_mesaIndex].votosCandidatos;
    }

    // Función para obtener todas las direcciones que han recibido tokens
    function getTokenRecipients() public view returns (address[] memory) {
        return tokenRecipients;
    }

    // Función para contar todos los recuentos de votos de cada candidato de todas las mesas
    function contarRecuentoTotal() public view returns (string[] memory nombres, uint256[] memory votos) {
        nombres = new string[](candidatos.length);
        votos = new uint256[](candidatos.length);
        for (uint256 i = 0; i < candidatos.length; i++) {
            nombres[i] = candidatos[i].name;
        }
        for (uint256 i = 0; i <= numMesas; i++) {
            uint256[] memory recuentoMesa = obtenerRecuentoVotos(i);
            for (uint256 j = 0; j < recuentoMesa.length; j++) {
                votos[j] += recuentoMesa[j];
            }
        }
    }
}
