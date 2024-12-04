# BOIIIIIIIIIII : An audio reactive boids-based VJing tool

##  [Dépôt du projet](https://github.com/NajibXY/gamagora_ia/tree/main/godot/projects/ia_jv_2)

## English Version [README-eng](https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_2/README-eng.md)

## Auteur : Najib EL KHADIR
https://github.com/NajibXY

## Gamagora 2024/2025 - IA pour le Jeu vidéo

### Contexte
Dans le cadre de cette UE, il fallait développer un prototype de jeu vidéo ou une application interactive utilisant le concept des Boids.

### Pré-requis et structure du dépôt
- Le code est ouvrable et réutilisable dans Godot, de préférence la version 4.3
- L'algorithme de mise à jour des boids en se basant sur les trois facteurs d'alignement, de séparation et de cohésion est implémenté ici [IA_JV1/scenes/scripts/utils](https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_2/compute_shaders/boid_simulation.glsl)
# TODO METTRE LIEN YOUTUBE ET DRIVE
- Une vidéo de démo est disponible [TODO : mettre lien youtube]()
- Ainsi qu'un exécutable pour tester directement le jeu : [BOIIIIIIIIIII.exe]()


### Concept de l'application
L'idée derrière BOIIIIIIIIIII est d'offrir dans sa version actuelle un outil interactif de visualisation des boids, de customization des paramètres de ceux-ci et surtout d'audio-réactivité. Permettant à l'utilisateur novice de l'utiliser comme un lecteur MP3 avec des visuels intéressants à observer : le champs de paramétrage des boids étant infini et la réactivité à l'audio rajoutant une dimension artistiquement intriguante. Mais pour l'utilisateur initié, une version plus avancé de ce projet pourra être utilisé, je l'espère, comme un outil à part entière de VJing (VJ = Visual Jockey, en analogie à DJ).

# TODO METTRE CAPTURE de base
</br>
  <img src="https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_1/readme_assets/capture1.png" width="800">
</br>

## Détails clés de l'application

### Fichiers de tests
# TODO
- Le Zip de l'application [BOIIIIIIIIIII.exe]() est founi avec plusieurs fichiers .ogg et palettes de couleur .png pour tester.

### Touches et interactivité
L'application permet un certain nombre d'actions sur le fil :
- La touche F permet de choisir un fichier audio .ogg à jouer.
- La touche G permet de choisir une palette de couleur .png à rajouter. Celles-ci sont importées dans le répertoire user:// de Godot, correspondant sur windows à "AppData\Roaming\Godot\app_userdata\BOIIIIIIIIIII".
- L'utilisateur peut interagir avec les différents paramètres du Canvas Layer pour expérimenter l'audio-réactivité ou le comportement des boids de base ou les deux en même temps.
- La touche J permet d'exporter une configuration actuelle sous le format .json. Celle-ci sera également stockée dans le répertoire user://
- La touche K permet d'importer une configuration précédemment sauvegardée.
- La touche R permet de réinitialiser les paramètres.
- Et enfin, la touche ESPACE, la touche magique, ou la touche du doom-scrolling (ça dépend comment on le voir) permet d'aléatoiriser les paramètres. L'utilisateur peut trouver beaucoup d'amusement à cette feature et essayer en boucle des configurations jusqu'à en trouver une qui le satisfait. (VIVE L'ALEATOIRE !)

### Paramètres des boids
- Les boids disposent de 8 paramètres toute somme classique pour ce cas d'école :
# TODO METTRE CAPTURE de paramètres
</br>
  <img src="https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_1/readme_assets/capture1.png" width="800">
</br>

### Paramètres d'audio-reactivité aux basses

#### Multiplicateurs et diviseurs
- A ces paramètres viennent se rajouter 8 autres, permettant d'agir comme multiplicateur ou diviseur au moment ou les boids réagissent aux basses de la musique jouée :
# TODO METTRE CAPTURE de paramètres
</br>
  <img src="https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_1/readme_assets/capture1.png" width="800">
</br>
- A noter que le paramètre stutter_on_kick fait tourner les boids sur eux-mêmes les faisant initialement prendre une direction aléatoire au moment où ils reprennent leur comportement normale. Au moment des basses cela peut créer des beaux effets visuels.

### Paramètres de coloration
- On peut également choisir un mode de coloration, ils sont pour l'instant au nombre de 3 : coloration monochromatique, coloration selon la direction des boids et coloration selon la température (influencée principalement sur le paramètres Friendly Radius).
# TODO METTRE CAPTURE des color modes et des palettes
</br>
  <img src="https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_1/readme_assets/capture1.png" width="800">
</br>

### Paramètres de scaling et de re-scaling du Material
- Le triangle des boids peut également être modifié en matières de taille, l'utilisateur peut s'amuser à créer des boids qui ressemblent à des cheveux d'anges, des particules fines, ou des gros triangles moches...
- Il y a également un paramètre de re-scaling permettant de changer le scale des boids au moment de l'audio-réactivité. Ce paramètre est l'un des plus critiques car il peut très bien donner des résultats magnifiques comme des résultats trop stroboscopique/épileptiques. Gare au mauvais usage !
- Ils peuvent être bloqués (non randomisables) ou pas grâce au paramètre "able scaling rand"
# TODO METTRE CAPTURE des scale
</br>
  <img src="https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_1/readme_assets/capture1.png" width="800">
</br>

### Paramètres de seuil de réactivité aux basses (encore en test)
- Les paramètres les plus récemment ajoutés sont ceux déterminant le seuil de magnitude et la plage de fréquence de l'audio-réactivité aux basses.
- Ces paramètres permettent notamment de ne pas avoir une bouilli due à une suréactivité aux basses lorsque le style de musique joué est un style riche en basses (typiquement de la Drum & Bass). Permettant de limiter l'audio-réactivité.
# TODO METTRE CAPTURE des basses
</br>
  <img src="https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_1/readme_assets/capture1.png" width="800">
</br>