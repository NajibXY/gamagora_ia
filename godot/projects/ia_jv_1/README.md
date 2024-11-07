# MAKE THEM FEAR

## English Version [README-eng](https://github.com/NajibXY/gamagora_ia/blob/93992c574a0228af7837e398cb8148ba4e16693f/godot/projects/ia_jv_1/README-eng.md)

## Auteur : Najib EL KHADIR
https://github.com/NajibXY

## Gamagora 2024/2025 - IA pour le Jeu vidéo

### Contexte
Dans le cadre de cet UE, il fallait développer un prototype de jeu vidéo en codant des algorithmes de recherche de chemins, notamment Djikstra et A*.

### Pré-requis et structure du dépôt
- Le code est ouvrable et réutilisable dans Godot, de préférence la version 4.3
- Les algorithmes de recherche de chemin sont disponibles dans le dossier [IA_JV1/scenes/scripts/utils](https://github.com/NajibXY/gamagora_ia/tree/b9b40df2f3f82b49f14e7ee8e62809284ee98d51/godot/projects/ia_jv_1/scenes/scripts/utils)
- Une vidéo de démo est disponible [ici](https://github.com/NajibXY/gamagora_ia/blob/b9b40df2f3f82b49f14e7ee8e62809284ee98d51/godot/projects/ia_jv_1/MAKE_THEM_FEAR_demo.mp4)
- Ainsi qu'un exécutable pour tester directement le jeu : [MAKE_THEM_FEAR.exe](https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_1/MAKE_THEM_FEAR.exe)


### Concept du jeu
L'idée derrière MAKE THEM FEAR est simple, vous êtes un tank qui fait face à une armée de véhicules qu'il doit rediriger. Ces véhicules apparaissent à deux points différents de la carte et cherchent le plus court chemin vers l'un des objectifs. Or, il y a des véhicules VERTS qui doivent être orientés vers des objectifs VERTS, et respectivement des véhicules JAUNES qui doivent être orientés vers des objectifs JAUNES.</br></br>
Vous n'avez pas de munitions, ni de moyen de communication verbale. Votre seul moyen de rediriger les véhicules et de les menacer en ciblant un point de leur chemin actuel pour les forcer à recalculer un nouveau chemin, de préférence vers l'objectif qui correpond à leur couleur.
</br>
  <img src="https://github.com/NajibXY/gamagora_ia/blob/f38e7725803899a804433d780e81a0b88f352142/godot/projects/ia_jv_1/readme_assets/capture1.png" width="800">
</br>

## Détails clés du jeu

### Utilisation des algorithmes de recherche de chemin
- Les véhicules vertes utilisent Djikstra
- Les véhicules jaunes utilisent A*
- L'heuristique utilisé pour A* est la distance de Manhattan avec un poids de 0.5 (modifiable dans le code)

### Rejouabilité
- Il y a 3 modes de difficultés, permettant de changer : la vitesse de déplacement des véhicules / leur temps d'attente à leur case de départ / leur interval d'apparition / la vitesse du joueur et des véhicules sur les cases pénalisantes (couleur herbe)
- Le but est de scorer un maximum de points positifs (véhicule arrivant à l'objectif de sa couleur) et d'exploser les recors dans les trois modes de jeu

### Carte et noeuds
- Je suis parti sur une TileMap en vue 2D isométrique
- Il y a deux points d'apparition, deux objectifs verts et deux objectifs jaunes.
- Des blocs noirs obstruent la ligne de mire du joueur
- Des flaques d'eau rendent des parties du terrain non navigables par le joueur et les véhicules
- Des cases d'herbe rendent les déplacement plus lents pour le joueur et les véhicules
- Les transisitons entre vers les cases normales valent 1, vers les cases ralentissantes valent 3 ; et celles vers les murs, les flaques d'eau ou les cases ciblés par le joueur valent +INF

### Calcul des chemins, threading et influence du joueur 
- Les chemins de tous les véhicules instanciés sont montrés sur la carte (cela peut être parfois un peu fouillis, mais on s'y habitue en jouant) 
- Les véhicules se déplacent case par case, alors que le joueur peut se déplacer sur le terrain en continu
- Un véhicule recalcule son plus court chemin s'il est ciblé par la nouvelle ligne de mire que le joueur a défini sur la carte en cliquant
- Les transitions vers les cases nouvellement ciblés passent à +INF, celles vers les cases anciennement ciblés sont remises à leur valeur de base
- Du multi-threading a été implémenté pour fluidifier le tout, cela peut être amélioré en sémaphores

## Musiques par Scott Buckley
- Licence Creative Commons
- Scott Buckley "Freedom"
- Scottt Buckley "Legionnaire"
https://www.youtube.com/@ScottBuckley
