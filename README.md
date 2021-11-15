# projet_vhdl

SME: BE VHDL

Le projet consiste à développer un pilote de barre franche sur FPGA
Binôme

- Prince Jacquet
- Mouloud Ziane



Structure du répertoire tirer de [Lien github vers le répertoire d'origin](https://github.com/Touftoufe/BE-VHDL)
realiser par le groupe de

- Sofiane AOUCI
- Kassandra BONHOURE



docs

On y trouve les documents liés au BE ainsi qu'un lien vers le rapport sur Notion.so

TP

On y trouve les premiers projets d'initiation au développement en VHDL

    Quartus 9
    Cyclone II carte DE2

BE

On y trouve le projet du BEs

    Quartus 18.1
    Cyclone IV carte DE0
    Modelsim
    Qsys

Celui-ci est structuré comme ci-dessous :

    testbenches : C'est les fonctions VHDL qui nous permettent de tester les blocs de base sur le FPGA
    functions : toutes les fonctions et blocs de base du projet
        FPGA : C'est les blocs VHDL principaux  (F1, F2, Anémomètre ... etc)
        SOPC : C'est les fonctions qui comprennent les blocs VHDL + les bus Avalon

    Functions_dev : Le répertoire contenant le projet Quartus 18.1 pour le développement des blocs de base
        components: contient les composants simple (Diviseur, compteur, Timer, Bascule, ..)
    SOPC_dev : Le répertoire contenant le projet Quartus et NIOS pour le développement du SoC
